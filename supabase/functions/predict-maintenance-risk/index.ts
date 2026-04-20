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

const clamp = (value: number, min: number, max: number) => Math.max(min, Math.min(value, max));

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
    const machineId = body.machineId as string | undefined;
    const companyId = body.companyId as string | undefined;
    const temperature = Number(body.temperature ?? 70);
    const vibration = Number(body.vibration ?? 2.1);
    const pressure = Number(body.pressure ?? 90);

    if (!machineId || !companyId) {
      return json({ error: 'machineId and companyId are required' }, 400);
    }

    // Placeholder AI scoring logic (OpenAI-style output contract for future extension).
    const tempFactor = clamp((temperature - 60) / 45, 0, 1);
    const vibrationFactor = clamp((vibration - 1.2) / 4.6, 0, 1);
    const pressureFactor = clamp((pressure - 80) / 45, 0, 1);
    const risk = clamp(tempFactor * 0.35 + vibrationFactor * 0.45 + pressureFactor * 0.2, 0.05, 0.99);

    const status = risk >= 0.85 ? 'stopped' : risk >= 0.65 ? 'warning' : 'running';
    const critical = risk >= 0.85;

    await supabase
      .from('machines')
      .update({ failure_risk: risk, status, updated_at: new Date().toISOString() })
      .eq('id', machineId)
      .eq('company_id', companyId);

    if (risk >= 0.7) {
      await supabase.from('alerts').insert({
        company_id: companyId,
        machine_id: machineId,
        type: 'predictive_maintenance',
        severity: critical ? 'critical' : 'warning',
        title: 'Failure risk detected',
        message: `Machine telemetry indicates elevated risk (${(risk * 100).toFixed(1)}%).`,
        ai_generated: true,
      });
    }

    if (critical) {
      try {
        await sendCriticalAlertEmail({
          supabase,
          companyId,
          subject: 'Allarme critico macchina FabricOS',
          bodyTitle: 'Rischio macchina critico rilevato',
          bodyText:
            'La telemetria della macchina ha superato la soglia critica e richiede intervento immediato.',
          details: [
            `Machine ID: ${machineId}`,
            `Risk score: ${(risk * 100).toFixed(1)}%`,
          ],
          linkLabel: 'Apri le macchine',
          linkPath: '/app/machines',
        });
      } catch (emailError) {
        console.error('Critical maintenance email failed', emailError);
      }
    }

    return json({
      machineId,
      companyId,
      risk,
      status,
      model: 'mock-ai-v1',
      explanation: {
        temperature,
        vibration,
        pressure,
        tempFactor,
        vibrationFactor,
        pressureFactor,
      },
    });
  } catch (error) {
    return json({ error: String(error) }, 500);
  }
});
