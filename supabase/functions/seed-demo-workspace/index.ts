import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });

  const authHeader = req.headers.get('Authorization');
  if (!authHeader) {
    return new Response(JSON.stringify({ error: 'Unauthorized' }), {
      status: 401,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    { global: { headers: { Authorization: authHeader } } }
  );

  const { data: { user } } = await supabase.auth.getUser(authHeader.replace('Bearer ', ''));
  if (!user) {
    return new Response(JSON.stringify({ error: 'Unauthorized' }), {
      status: 401,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }

  try {
    const body = await req.json().catch(() => ({}));
    const workspaceName = (body as { name?: string }).name ?? 'Demo Workspace';

    const { data: workspace, error: wsErr } = await supabase
      .from('workspaces')
      .insert({ name: workspaceName, slug: `demo-${user.id.slice(0, 8)}` })
      .select('id')
      .single();

    if (wsErr || !workspace) {
      return new Response(JSON.stringify({ error: wsErr?.message ?? 'Failed to create workspace' }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    await supabase.from('workspace_members').insert({
      workspace_id: workspace.id,
      user_id: user.id,
      role: 'owner',
    });

    const { data: supplier } = await supabase
      .from('suppliers')
      .insert({
        workspace_id: workspace.id,
        name: 'Demo Supplier',
        lead_time_days: 14,
      })
      .select('id')
      .single();

    const productRows = [
      { sku: 'SKU-001', name: 'Product Alpha', current_stock: 45, reorder_point: 30, lead_time_days: 14, unit_cost: 12.5, selling_price: 24 },
      { sku: 'SKU-002', name: 'Product Beta', current_stock: 12, reorder_point: 25, lead_time_days: 7, unit_cost: 8, selling_price: 18 },
      { sku: 'SKU-003', name: 'Product Gamma', current_stock: 120, reorder_point: 40, lead_time_days: 10, unit_cost: 5, selling_price: 12 },
    ];

    for (const row of productRows) {
      await supabase.from('products').insert({
        workspace_id: workspace.id,
        supplier_id: supplier?.id ?? null,
        ...row,
      });
    }

    return new Response(
      JSON.stringify({ workspaceId: workspace.id, message: 'Demo workspace created' }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
