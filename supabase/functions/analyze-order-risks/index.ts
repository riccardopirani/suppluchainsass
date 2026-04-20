import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { sendCriticalAlertEmail } from '../_shared/email.ts';

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

  const {
    data: { user },
  } = await supabase.auth.getUser(authHeader.replace('Bearer ', ''));
  if (!user) return json({ error: 'Unauthorized' }, 401);

  try {
    const body = await req.json().catch(() => ({}));
    let companyId = body.companyId as string | undefined;

    if (!companyId) {
      const { data: profile } = await supabase
        .from('users')
        .select('company_id')
        .eq('id', user.id)
        .maybeSingle();
      companyId = profile?.company_id;
    }

    if (!companyId) {
      return json({ error: 'companyId is required' }, 400);
    }

    const now = new Date();
    const criticalAlerts: string[] = [];

    const { data: orders } = await supabase
      .from('orders')
      .select('id, supplier_id, order_number, expected_delivery_date, status, delay_days')
      .eq('company_id', companyId)
      .neq('status', 'completed');

    let created = 0;
    const delaysBySupplier = new Map<string, number[]>();

    for (const order of orders ?? []) {
      const expected = order.expected_delivery_date
        ? new Date(order.expected_delivery_date as string)
        : null;
      if (!expected || Number.isNaN(expected.valueOf())) continue;

      const delay = Math.floor((now.getTime() - expected.getTime()) / (1000 * 60 * 60 * 24));
      const normalizedDelay = delay > 0 ? delay : 0;

      if (normalizedDelay > 0) {
        const severity = normalizedDelay >= 7 ? 'critical' : 'warning';
        await supabase
          .from('orders')
          .update({ delay_days: normalizedDelay, updated_at: new Date().toISOString() })
          .eq('id', order.id);

        await supabase.from('alerts').insert({
          company_id: companyId,
          order_id: order.id,
          supplier_id: order.supplier_id,
          type: 'order_delay_risk',
          severity,
          title: 'Order risk delay',
          message: `Order ${order.order_number} is delayed by ${normalizedDelay} day(s).`,
          ai_generated: true,
        });

        if (severity === 'critical') {
          criticalAlerts.push(
            `Ordine ${order.order_number} in ritardo di ${normalizedDelay} giorno/i.`,
          );
        }

        created += 1;
      }

      if (order.supplier_id) {
        const list = delaysBySupplier.get(order.supplier_id as string) ?? [];
        list.push(normalizedDelay);
        delaysBySupplier.set(order.supplier_id as string, list);
      }
    }

    for (const [supplierId, delays] of delaysBySupplier.entries()) {
      if (delays.length === 0) continue;
      const avgDelay = delays.reduce((sum, value) => sum + value, 0) / delays.length;

      await supabase
        .from('suppliers')
        .update({
          avg_delay_days: Number(avgDelay.toFixed(2)),
          risk_level: avgDelay >= 6 ? 'high' : avgDelay >= 2 ? 'medium' : 'low',
          updated_at: new Date().toISOString(),
        })
        .eq('id', supplierId)
        .eq('company_id', companyId);
    }

    if (criticalAlerts.length > 0) {
      try {
        await sendCriticalAlertEmail({
          supabase,
          companyId,
          subject: 'Allarme critico ordini FabricOS',
          bodyTitle: 'Ci sono ritardi critici negli ordini',
          bodyText:
            'Alcuni ordini hanno superato la soglia critica e richiedono attenzione immediata.',
          details: criticalAlerts,
          linkLabel: 'Apri gli ordini',
          linkPath: '/app/orders',
        });
      } catch (emailError) {
        console.error('Critical order email failed', emailError);
      }
    }

    return json({ companyId, created, analyzedOrders: orders?.length ?? 0 });
  } catch (error) {
    return json({ error: String(error) }, 500);
  }
});
