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
    const eventType = String(body.eventType ?? 'production');
    const quantity = Number(body.quantity ?? 0);
    const machineId = body.machineId ? String(body.machineId) : null;
    const notes = body.notes ? String(body.notes) : null;
    const qrCode = body.qrCode ? String(body.qrCode) : null;
    const plantId = body.plantId ? String(body.plantId) : null;

    if (!companyId) return json({ error: 'companyId is required' }, 400);

    const { data: inserted, error } = await admin
      .from('production_quick_logs')
      .insert({
        company_id: companyId,
        plant_id: plantId,
        machine_id: machineId,
        operator_id: user.id,
        event_type: eventType,
        quantity,
        notes,
        qr_code: qrCode,
        happened_at: new Date().toISOString(),
      })
      .select('id,event_type,quantity,happened_at')
      .single();

    if (error) return json({ error: error.message }, 400);

    if (eventType === 'downtime' && machineId) {
      await admin.from('alerts').insert({
        company_id: companyId,
        machine_id: machineId,
        type: 'plant_floor_downtime',
        severity: 'warning',
        title: 'Downtime logged from plant floor',
        message: notes ?? 'An operator flagged downtime from Plant Floor Mode.',
        ai_generated: false,
      });
    }

    return json({ ok: true, quickLog: inserted });
  } catch (error) {
    return json({ error: String(error) }, 500);
  }
});
