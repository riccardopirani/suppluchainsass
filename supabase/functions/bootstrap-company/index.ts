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

  const {
    data: { user },
  } = await supabase.auth.getUser(authHeader.replace('Bearer ', ''));
  if (!user) return json({ error: 'Unauthorized' }, 401);

  try {
    const payload = await req.json().catch(() => ({}));
    const companyName = (payload.name as string | undefined)?.trim() || 'New Manufacturing Company';
    const sizeBand = (payload.sizeBand as string | undefined)?.trim() || '10-50';

    const { data: profile } = await supabase
      .from('users')
      .select('company_id')
      .eq('id', user.id)
      .maybeSingle();

    if (profile?.company_id) {
      return json({ companyId: profile.company_id, alreadyConfigured: true });
    }

    const { data: company, error: companyError } = await supabase
      .from('companies')
      .insert({ name: companyName, size_band: sizeBand })
      .select('id')
      .single();

    if (companyError || !company) {
      return json({ error: companyError?.message ?? 'Failed to create company' }, 500);
    }

    await supabase
      .from('users')
      .update({ company_id: company.id, role: 'admin' })
      .eq('id', user.id);

    const suppliers = [
      { name: 'Delta Components', reliability_score: 89, compliance_status: 'compliant', risk_level: 'low' },
      { name: 'North Forge Metals', reliability_score: 81, compliance_status: 'under_review', risk_level: 'medium' },
    ];

    const { data: insertedSuppliers } = await supabase
      .from('suppliers')
      .insert(
        suppliers.map((s) => ({
          company_id: company.id,
          ...s,
          avg_delay_days: 0,
        }))
      )
      .select('id');

    const primarySupplierId = insertedSuppliers?.[0]?.id ?? null;

    await supabase.from('machines').insert([
      {
        company_id: company.id,
        supplier_id: primarySupplierId,
        name: 'CNC Mill A1',
        type: 'CNC',
        status: 'running',
        last_maintenance_at: new Date(Date.now() - 1000 * 60 * 60 * 24 * 20).toISOString(),
        failure_risk: 0.22,
      },
      {
        company_id: company.id,
        supplier_id: primarySupplierId,
        name: 'Packaging Line B2',
        type: 'Packaging',
        status: 'warning',
        last_maintenance_at: new Date(Date.now() - 1000 * 60 * 60 * 24 * 35).toISOString(),
        failure_risk: 0.65,
      },
    ]);

    await supabase.from('orders').insert([
      {
        company_id: company.id,
        supplier_id: insertedSuppliers?.[0]?.id,
        order_number: `ORD-${Date.now().toString().slice(-5)}-A`,
        status: 'pending',
        expected_delivery_date: new Date(Date.now() + 1000 * 60 * 60 * 24 * 9).toISOString(),
        amount: 8500,
      },
      {
        company_id: company.id,
        supplier_id: insertedSuppliers?.[1]?.id,
        order_number: `ORD-${Date.now().toString().slice(-5)}-B`,
        status: 'in_progress',
        expected_delivery_date: new Date(Date.now() + 1000 * 60 * 60 * 24 * 14).toISOString(),
        amount: 13400,
      },
    ]);

    await supabase.from('alerts').insert({
      company_id: company.id,
      type: 'onboarding',
      severity: 'info',
      title: 'Workspace ready',
      message: 'FabricOS workspace initialized with starter operational data.',
      ai_generated: false,
    });

    return json({ companyId: company.id, seeded: true });
  } catch (error) {
    return json({ error: String(error) }, 500);
  }
});
