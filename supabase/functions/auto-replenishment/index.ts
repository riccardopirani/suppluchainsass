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
      'auto_replenish_full',
      json,
    );
    if (denied) return denied;

    const settings = await supabase
      .from('automation_settings')
      .select('auto_replenishment_enabled')
      .eq('company_id', companyId)
      .maybeSingle();

    if (!settings.data?.auto_replenishment_enabled) {
      return json({ companyId, created: 0, message: 'Auto-replenishment disabled' });
    }

    const inventoryRes = await supabase.from('inventory').select('*').eq('company_id', companyId);
    const suppliersRes = await supabase.from('suppliers').select('id').eq('company_id', companyId).limit(1);
    const defaultSupplierId = suppliersRes.data?.[0]?.id ?? null;
    let created = 0;

    for (const item of inventoryRes.data ?? []) {
      const stock = Number(item.stock_quantity ?? 0);
      const reorderPoint = Number(item.reorder_point ?? 0);
      if (stock >= reorderPoint) continue;
      const quantity = Math.max(1, reorderPoint - stock + Number(item.safety_stock ?? 0));

      await supabase.from('auto_orders').insert({
        company_id: companyId,
        item_id: String(item.item_name).toLowerCase().replaceAll(' ', '_'),
        quantity: Number(quantity.toFixed(2)),
        supplier_id: defaultSupplierId,
        status: 'created',
      });
      created += 1;
    }

    return json({ companyId, created });
  } catch (error) {
    return json({ error: String(error) }, 500);
  }
});
