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
      .select('id, current_stock, reorder_point, safety_stock, lead_time_days')
      .eq('workspace_id', workspaceId)
      .eq('active', true);

    if (!products?.length) {
      return json({ count: 0, message: 'No products' });
    }

    const { data: sales } = await supabase
      .from('sales_history')
      .select('product_id, quantity')
      .eq('workspace_id', workspaceId)
      .gte('sale_date', new Date(Date.now() - 90 * 24 * 60 * 60 * 1000).toISOString().slice(0, 10));

    const dailyByProduct: Record<string, number> = {};
    for (const s of sales ?? []) {
      const id = s.product_id as string;
      dailyByProduct[id] = (dailyByProduct[id] ?? 0) + Number(s.quantity);
    }
    const days = 90;
    for (const id of Object.keys(dailyByProduct)) {
      dailyByProduct[id] = dailyByProduct[id] / days;
    }

    let inserted = 0;
    for (const p of products) {
      const avgDaily = dailyByProduct[p.id] ?? 0;
      const leadTime = p.lead_time_days ?? 7;
      const safety = p.safety_stock ?? 0;
      const reorderPoint = p.reorder_point ?? 0;
      const current = p.current_stock ?? 0;
      const demandDuringLead = avgDaily * leadTime;
      const target = Math.ceil(demandDuringLead + safety);
      const recommendedQty = Math.max(0, target - current);

      if (current <= reorderPoint || recommendedQty > 0) {
        const projectedStockout = avgDaily > 0 ? new Date(Date.now() + (current / avgDaily) * 24 * 60 * 60 * 1000) : null;
        await supabase.from('reorder_recommendations').insert({
          workspace_id: workspaceId,
          product_id: p.id,
          recommended_quantity: recommendedQty || target,
          recommended_order_date: new Date().toISOString().slice(0, 10),
          projected_stockout_date: projectedStockout?.toISOString().slice(0, 10) ?? null,
          reason: current <= reorderPoint ? 'Below reorder point' : 'Forecast demand',
          confidence: avgDaily > 0 ? 0.85 : 0.5,
          status: 'pending',
        });
        inserted++;
      }
    }

    return json({ count: inserted });
  } catch (e) {
    return json({ error: String(e) }, 500);
  }
});
