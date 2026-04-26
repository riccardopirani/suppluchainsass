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

    const [inventoryRes, forecastRes] = await Promise.all([
      supabase.from('inventory').select('*').eq('company_id', companyId),
      supabase.from('demand_forecasts').select('item_id,predicted_quantity,confidence_score').eq('company_id', companyId),
    ]);

    const demandByItem = new Map<string, { demand: number; confidence: number }>();
    for (const row of forecastRes.data ?? []) {
      const key = String(row.item_id);
      const current = demandByItem.get(key) ?? { demand: 0, confidence: 0.65 };
      current.demand += Number(row.predicted_quantity ?? 0);
      current.confidence = Math.max(current.confidence, Number(row.confidence_score ?? 0.65));
      demandByItem.set(key, current);
    }

    const recommendations = [];
    for (const item of inventoryRes.data ?? []) {
      const key = String(item.item_name).toLowerCase().replaceAll(' ', '_');
      const demand = demandByItem.get(key)?.demand ?? 0;
      const confidence = demandByItem.get(key)?.confidence ?? 0.65;
      const optimalStock = Math.max(Number(item.safety_stock ?? 0), demand * (0.35 + confidence * 0.2));
      const reorderQty = Math.max(0, optimalStock - Number(item.stock_quantity ?? 0));
      const reorderPoint = Math.max(Number(item.safety_stock ?? 0), optimalStock * 0.6);

      await supabase
        .from('inventory')
        .update({ reorder_point: Number(reorderPoint.toFixed(2)), updated_at: new Date().toISOString() })
        .eq('id', item.id)
        .eq('company_id', companyId);

      recommendations.push({
        item_id: item.id,
        item_name: item.item_name,
        optimal_stock: Number(optimalStock.toFixed(2)),
        reorder_quantity: Number(reorderQty.toFixed(2)),
      });
    }

    return json({ companyId, recommendations });
  } catch (error) {
    return json({ error: String(error) }, 500);
  }
});
