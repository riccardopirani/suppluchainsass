import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

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

    const [suppliersRes, ordersRes] = await Promise.all([
      supabase.from('suppliers').select('id,name,reliability_score,avg_delay_days').eq('company_id', companyId),
      supabase.from('orders').select('supplier_id,amount').eq('company_id', companyId),
    ]);

    const spendBySupplier = new Map<string, number>();
    for (const o of ordersRes.data ?? []) {
      const key = String(o.supplier_id ?? '');
      if (!key) continue;
      spendBySupplier.set(key, (spendBySupplier.get(key) ?? 0) + Number(o.amount ?? 0));
    }

    const suggestions = [];
    const sorted = [...(suppliersRes.data ?? [])].sort((a, b) => Number(b.reliability_score ?? 0) - Number(a.reliability_score ?? 0));
    const best = sorted[0];
    for (const supplier of sorted.slice(1, 4)) {
      const spend = spendBySupplier.get(String(supplier.id)) ?? 0;
      const saveRate = Math.max(0.03, Math.min(0.18, (Number(best?.reliability_score ?? 80) - Number(supplier.reliability_score ?? 70)) * 0.002 + Number(supplier.avg_delay_days ?? 0) * 0.01));
      suggestions.push({
        message: `Switch part of volume from ${supplier.name} to ${best?.name ?? 'top supplier'} to save about €${(spend * saveRate).toFixed(0)}.`,
        supplier_id: supplier.id,
        estimated_saving: Number((spend * saveRate).toFixed(2)),
      });
    }

    return json({ companyId, suggestions });
  } catch (error) {
    return json({ error: String(error) }, 500);
  }
});
