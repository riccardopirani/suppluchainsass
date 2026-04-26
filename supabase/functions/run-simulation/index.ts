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
    const scenarioType = String(body.scenarioType ?? 'supplier_delay');
    const inputData = (body.inputData ?? {}) as Record<string, unknown>;
    if (!companyId) return json({ error: 'companyId is required' }, 400);

    const denied = await enforceCompanyFeature(
      supabase,
      user.id,
      companyId,
      'what_if',
      json,
    );
    if (denied) return denied;

    let result: Record<string, unknown> = {};
    if (scenarioType === 'supplier_delay') {
      const days = Number(inputData.days ?? 5);
      result = {
        estimated_otif_drop: Math.min(35, days * 2.4),
        extra_cost_eur: Math.round(days * 820),
        recommendation: 'Activate backup supplier and expedite critical SKUs.',
      };
    } else if (scenarioType === 'demand_spike') {
      const spike = Number(inputData.spikePercent ?? 30);
      result = {
        stockout_risk: Math.min(95, spike * 1.4),
        extra_reorder_units: Math.round(spike * 12),
        recommendation: 'Raise safety stock and trigger auto-replenishment.',
      };
    } else {
      const disruption = Number(inputData.disruptionHours ?? 24);
      result = {
        delayed_shipments: Math.max(1, Math.round(disruption / 6)),
        potential_penalty_eur: Math.round(disruption * 120),
        recommendation: 'Reroute shipments and increase buffer inventory.',
      };
    }

    const { data, error } = await supabase
      .from('simulations')
      .insert({
        company_id: companyId,
        scenario_type: scenarioType,
        input_data: inputData,
        result,
      })
      .select()
      .single();

    if (error) return json({ error: error.message }, 500);
    return json(data);
  } catch (error) {
    return json({ error: String(error) }, 500);
  }
});
