import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { enforceWorkspaceFeature } from '../_shared/plan_entitlements.ts';

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
    const workspaceId = (body as { workspaceId?: string }).workspaceId;
    if (!workspaceId) return json({ error: 'workspaceId required' }, 400);

    const denied = await enforceWorkspaceFeature(
      supabase,
      user.id,
      workspaceId,
      'predictive_ai',
      json,
    );
    if (denied) return denied;

    const { data: products } = await supabase
      .from('products')
      .select('id')
      .eq('workspace_id', workspaceId)
      .eq('active', true);

    const { data: sales } = await supabase
      .from('sales_history')
      .select('product_id, quantity')
      .eq('workspace_id', workspaceId)
      .gte('sale_date', new Date(Date.now() - 90 * 24 * 60 * 60 * 1000).toISOString().slice(0, 10));

    const totalByProduct: Record<string, number> = {};
    for (const s of sales ?? []) {
      const id = s.product_id as string;
      totalByProduct[id] = (totalByProduct[id] ?? 0) + Number(s.quantity);
    }
    const days = 90;
    const avgDailyByProduct: Record<string, number> = {};
    for (const id of Object.keys(totalByProduct)) {
      avgDailyByProduct[id] = totalByProduct[id] / days;
    }

    let inserted = 0;
    for (const p of products ?? []) {
      const avgDaily = avgDailyByProduct[p.id] ?? 0;
      const forecast30 = Math.round(avgDaily * 30 * 100) / 100;
      const periodStart = new Date();
      const periodEnd = new Date();
      periodEnd.setDate(periodEnd.getDate() + 30);
      await supabase.from('forecasts').insert({
        workspace_id: workspaceId,
        product_id: p.id,
        period_start: periodStart.toISOString().slice(0, 10),
        period_end: periodEnd.toISOString().slice(0, 10),
        forecast_quantity: forecast30,
        confidence: avgDaily > 0 ? 0.8 : 0.3,
        algorithm: 'moving_average_90d',
      });
      inserted++;
    }

    return json({ count: inserted });
  } catch (e) {
    return json({ error: String(e) }, 500);
  }
});
