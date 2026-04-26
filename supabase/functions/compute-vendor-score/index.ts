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

  const admin = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    { global: { headers: { Authorization: authHeader } }, auth: { persistSession: false } },
  );

  const {
    data: { user },
  } = await admin.auth.getUser(authHeader.replace('Bearer ', ''));
  if (!user) return json({ error: 'Unauthorized' }, 401);

  try {
    const body = await req.json().catch(() => ({}));
    const companyId = String(body.companyId ?? '').trim();
    if (!companyId) return json({ error: 'companyId is required' }, 400);

    const denied = await enforceCompanyFeature(
      admin,
      user.id,
      companyId,
      'predictive_ai',
      json,
    );
    if (denied) return denied;

    const { data: suppliers } = await admin
      .from('suppliers')
      .select('id, reliability_score')
      .eq('company_id', companyId);

    const updated: Array<{ supplierId: string; score: number }> = [];

    for (const supplier of suppliers ?? []) {
      const supplierId = String(supplier.id);
      const baseReliability = Number(supplier.reliability_score ?? 70);
      const { data: confirmations } = await admin
        .from('vendor_order_confirmations')
        .select('status')
        .eq('company_id', companyId)
        .eq('supplier_id', supplierId);

      const total = confirmations?.length ?? 0;
      const onTime = (confirmations ?? []).filter((c) => c.status === 'confirmed').length;
      const late = (confirmations ?? []).filter((c) => c.status === 'delayed').length;
      const risk = total == 0
        ? Math.max(5, 100 - baseReliability)
        : Math.min(99, Math.max(5, (late / total) * 80 + (1 - onTime / total) * 20));

      await admin
        .from('suppliers')
        .update({
          risk_score: Number(risk.toFixed(2)),
          last_evaluation: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        })
        .eq('company_id', companyId)
        .eq('id', supplierId);

      updated.push({ supplierId, score: Number(risk.toFixed(2)) });
    }

    return json({ companyId, updated: updated.length, suppliers: updated });
  } catch (error) {
    return json({ error: String(error) }, 500);
  }
});
