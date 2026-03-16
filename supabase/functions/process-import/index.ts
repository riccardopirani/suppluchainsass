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
    const body = await req.json();
    const { workspaceId, type, rows } = body as {
      workspaceId: string;
      type: 'products' | 'sales' | 'suppliers';
      rows: Record<string, unknown>[];
    };

    if (!workspaceId || !type || !Array.isArray(rows)) {
      return new Response(JSON.stringify({ error: 'workspaceId, type, rows required' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const { data: importRow, error: insertErr } = await supabase
      .from('imports')
      .insert({
        workspace_id: workspaceId,
        type,
        status: 'processing',
        total_rows: rows.length,
        created_by: user.id,
      })
      .select('id')
      .single();

    if (insertErr || !importRow) {
      return new Response(JSON.stringify({ error: insertErr?.message ?? 'Failed to create import' }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    let successCount = 0;
    const errors: { row: number; message: string }[] = [];

    if (type === 'products') {
      for (let i = 0; i < rows.length; i++) {
        const r = rows[i] as Record<string, unknown>;
        const { error } = await supabase.from('products').insert({
          workspace_id: workspaceId,
          sku: String(r.sku ?? r.SKU ?? ''),
          name: String(r.name ?? r.product ?? ''),
          current_stock: Number(r.current_stock ?? r.stock ?? 0),
          reorder_point: Number(r.reorder_point ?? 0),
          unit_cost: Number(r.unit_cost ?? r.cost ?? 0),
          selling_price: Number(r.selling_price ?? r.price ?? 0),
          lead_time_days: Number(r.lead_time_days ?? 7),
        });
        if (error) {
          errors.push({ row: i + 1, message: error.message });
        } else {
          successCount++;
        }
      }
    }

    await supabase
      .from('imports')
      .update({
        status: 'completed',
        success_rows: successCount,
        error_rows: errors.length,
      })
      .eq('id', importRow.id);

    return new Response(
      JSON.stringify({
        importId: importRow.id,
        success: successCount,
        errors: errors.length,
        details: errors.slice(0, 10),
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
