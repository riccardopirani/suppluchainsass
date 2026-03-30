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

    const { data: suppliers } = await supabase
      .from('suppliers')
      .select('id,reliability_score,compliance_status,avg_delay_days')
      .eq('company_id', companyId);

    const updates = [];
    for (const s of suppliers ?? []) {
      const reliability = Number(s.reliability_score ?? 75);
      const delay = Number(s.avg_delay_days ?? 0);
      const compliance = String(s.compliance_status ?? 'under_review');
      const financialRisk = Math.max(10, Math.min(95, 100 - reliability + delay * 3));
      const deliveryRisk = Math.max(8, Math.min(99, delay * 11 + (100 - reliability) * 0.35));
      const complianceRisk =
        compliance === 'non_compliant' ? 90 : compliance === 'under_review' ? 65 : 25;
      const score = Math.max(0, Math.min(100, financialRisk * 0.3 + deliveryRisk * 0.45 + complianceRisk * 0.25));

      await supabase
        .from('suppliers')
        .update({
          risk_score: Number(score.toFixed(2)),
          financial_risk: Number(financialRisk.toFixed(2)),
          delivery_risk: Number(deliveryRisk.toFixed(2)),
          compliance_risk: Number(complianceRisk.toFixed(2)),
          last_evaluation: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        })
        .eq('id', s.id)
        .eq('company_id', companyId);
      updates.push({ supplierId: s.id, riskScore: Number(score.toFixed(2)) });
    }

    return json({ companyId, updated: updates.length, suppliers: updates });
  } catch (error) {
    return json({ error: String(error) }, 500);
  }
});
