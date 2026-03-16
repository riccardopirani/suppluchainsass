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
    const workspaceId = (body as { workspaceId?: string }).workspaceId;
    if (!workspaceId) {
      return new Response(JSON.stringify({ error: 'workspaceId required' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // Placeholder: evaluate conditions and create alerts (e.g. low stock, overstock)
    // Email integration can be added here
    const { data: products } = await supabase
      .from('products')
      .select('id, sku, name, current_stock, reorder_point')
      .eq('workspace_id', workspaceId)
      .eq('active', true);

    let created = 0;
    for (const p of products ?? []) {
      if (p.current_stock <= (p.reorder_point ?? 0)) {
        await supabase.from('alerts').insert({
          workspace_id: workspaceId,
          product_id: p.id,
          alert_type: 'stockout_risk',
          severity: 'critical',
          title: 'Low stock',
          message: `${p.sku} (${p.name}) is at or below reorder point`,
        });
        created++;
      }
    }

    return new Response(JSON.stringify({ created }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
