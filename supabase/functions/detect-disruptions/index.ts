import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { sendCriticalAlertEmail } from '../_shared/email.ts';
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

    const [ordersRes, suppliersRes, shipmentsRes] = await Promise.all([
      supabase.from('orders').select('order_number,delay_days,status').eq('company_id', companyId).neq('status', 'completed'),
      supabase.from('suppliers').select('name,reliability_score,risk_score').eq('company_id', companyId),
      supabase.from('shipments').select('order_id,status').eq('company_id', companyId),
    ]);

    const disruptions: Array<{ type: string; severity: string; message: string }> = [];
    const criticalMessages: string[] = [];
    for (const order of ordersRes.data ?? []) {
      const delay = Number(order.delay_days ?? 0);
      if (delay > 0) disruptions.push({
        type: 'supplier_delay',
        severity: delay >= 7 ? 'critical' : 'warning',
        message: `Order ${order.order_number} delayed by ${delay} day(s).`,
      });
      if (delay >= 7) {
        criticalMessages.push(`Ordine ${order.order_number} in ritardo di ${delay} giorno/i.`);
      }
    }
    for (const supplier of suppliersRes.data ?? []) {
      const score = Number(supplier.risk_score ?? 50);
      const reliability = Number(supplier.reliability_score ?? 75);
      if (score > 75 || reliability < 60) disruptions.push({
        type: 'anomaly',
        severity: score > 85 ? 'critical' : 'warning',
        message: `Supplier ${supplier.name} performance anomaly detected.`,
      });
      if (score > 85) {
        criticalMessages.push(`Fornitore ${supplier.name} con anomalia critica (score ${score.toFixed(1)}).`);
      }
    }
    for (const shipment of shipmentsRes.data ?? []) {
      if (shipment.status === 'delayed') disruptions.push({
        type: 'shipment_delay',
        severity: 'warning',
        message: `Shipment for order ${shipment.order_id} is delayed.`,
      });
    }

    if (disruptions.length) {
      await supabase.from('supply_disruptions').insert(disruptions.map((d) => ({ ...d, company_id: companyId })));
    }

    if (criticalMessages.length > 0) {
      try {
        await sendCriticalAlertEmail({
          supabase,
          companyId,
          subject: 'Allarme critico supply chain FabricOS',
          bodyTitle: 'Sono state rilevate interruzioni critiche',
          bodyText: 'Alcuni segnali della supply chain richiedono attenzione immediata.',
          details: criticalMessages,
          linkLabel: 'Apri la supply chain',
          linkPath: '/app/supply',
        });
      } catch (emailError) {
        console.error('Critical disruption email failed', emailError);
      }
    }

    return json({ companyId, created: disruptions.length });
  } catch (error) {
    return json({ error: String(error) }, 500);
  }
});
