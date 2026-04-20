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
    const operations = Array.isArray(body.operations) ? body.operations : [];
    if (!companyId) return json({ error: 'companyId is required' }, 400);

    const applied: string[] = [];
    const conflicts: Array<{ operationId: string; reason: string }> = [];

    for (const op of operations) {
      const operationId = String(op.clientOperationId ?? '').trim();
      const entityType = String(op.entityType ?? '').trim();
      const operationType = String(op.operationType ?? '').trim();
      const payload = op.payload && typeof op.payload === 'object' ? op.payload : {};

      if (!operationId || !entityType || !operationType) {
        conflicts.push({ operationId, reason: 'invalid_operation_payload' });
        continue;
      }

      const { data: existing } = await admin
        .from('offline_sync_queue')
        .select('id,status')
        .eq('company_id', companyId)
        .eq('client_operation_id', operationId)
        .maybeSingle();
      if (existing) {
        conflicts.push({ operationId, reason: 'duplicate_client_operation_id' });
        continue;
      }

      const { error: queueError } = await admin.from('offline_sync_queue').insert({
        company_id: companyId,
        user_id: user.id,
        entity_type: entityType,
        operation_type: operationType,
        payload,
        client_operation_id: operationId,
        status: 'pending',
      });
      if (queueError) {
        conflicts.push({ operationId, reason: queueError.message });
        continue;
      }

      let applyError: string | null = null;
      if (entityType === 'production_quick_logs' && operationType === 'insert') {
        const { error } = await admin.from('production_quick_logs').insert({
          company_id: companyId,
          machine_id: payload.machineId ?? null,
          operator_id: user.id,
          event_type: payload.eventType ?? 'production',
          quantity: Number(payload.quantity ?? 0),
          notes: payload.notes ?? null,
          qr_code: payload.qrCode ?? null,
          happened_at: payload.happenedAt ?? new Date().toISOString(),
        });
        if (error) applyError = error.message;
      } else {
        applyError = 'unsupported_operation';
      }

      if (applyError) {
        await admin
          .from('offline_sync_queue')
          .update({
            status: 'conflict',
            conflict_reason: applyError,
            updated_at: new Date().toISOString(),
          })
          .eq('company_id', companyId)
          .eq('client_operation_id', operationId);
        conflicts.push({ operationId, reason: applyError });
      } else {
        await admin
          .from('offline_sync_queue')
          .update({
            status: 'applied',
            applied_at: new Date().toISOString(),
            updated_at: new Date().toISOString(),
          })
          .eq('company_id', companyId)
          .eq('client_operation_id', operationId);
        applied.push(operationId);
      }
    }

    return json({ companyId, applied, conflicts, total: operations.length });
  } catch (error) {
    return json({ error: String(error) }, 500);
  }
});
