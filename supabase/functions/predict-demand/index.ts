import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { enforceCompanyFeature } from '../_shared/plan_entitlements.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  const authHeader = req.headers.get('Authorization');
  if (!authHeader) return json({ error: 'Unauthorized' }, 401);

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    { global: { headers: { Authorization: authHeader } } }
  );

  const { data: { user } } = await supabase.auth.getUser(authHeader.replace('Bearer ', ''));
  if (!user) return json({ error: 'Unauthorized' }, 401);

  try {
    const body = await req.json().catch(() => ({}));
    const companyId = body.companyId as string | undefined;
    if (!companyId) return json({ error: 'companyId is required' }, 400);

    const denied = await enforceCompanyFeature(
      supabase,
      user.id,
      companyId,
      'predictive_ai',
      json,
    );
    if (denied) return denied;

    const [ordersRes, machinesRes] = await Promise.all([
      supabase.from('orders').select('amount').eq('company_id', companyId).limit(300),
      supabase.from('machines').select('failure_risk').eq('company_id', companyId),
    ]);

    const baseline = (ordersRes.data ?? []).reduce((s, r) => s + Math.max(1, Number(r.amount ?? 0) / 2000), 0) / 10;
    const riskPenalty = (machinesRes.data ?? []).reduce((s, r) => s + Number(r.failure_risk ?? 0), 0) * 0.7;
    const items = ['raw_materials', 'components', 'packaging'];
    const rows: Array<Record<string, unknown>> = [];

    for (let day = 1; day <= 30; day++) {
      const date = new Date();
      date.setDate(date.getDate() + day);
      for (const [idx, itemId] of items.entries()) {
        const seasonality = 1 + Math.sin((day / 30) * Math.PI * 2 + idx) * 0.08;
        const predicted = Math.max(8, baseline * seasonality - riskPenalty + idx * 5);
        rows.push({
          company_id: companyId,
          item_id: itemId,
          predicted_quantity: Number(predicted.toFixed(2)),
          confidence_score: Number(Math.max(0.55, 0.86 - day * 0.005).toFixed(4)),
          forecast_date: date.toISOString().slice(0, 10),
        });
      }
    }

    await supabase.from('demand_forecasts').delete().eq('company_id', companyId);
    const { error } = await supabase.from('demand_forecasts').insert(rows);
    if (error) return json({ error: error.message }, 500);
    return json({ companyId, generated: rows.length, days: 30 });
  } catch (error) {
    return json({ error: String(error) }, 500);
  }
});
