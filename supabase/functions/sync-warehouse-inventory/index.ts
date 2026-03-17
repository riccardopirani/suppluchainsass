import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.38.4";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface WarehouseEvent {
  type: "INSERT" | "UPDATE" | "DELETE";
  schema: string;
  table: string;
  record: {
    id: string;
    workspace_id: string;
    name: string;
  };
}

serve(async (req) => {
  // Handle CORS
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const event: WarehouseEvent = await req.json();

    // Only process warehouse inserts
    if (event.table !== "warehouses" || event.type !== "INSERT") {
      return new Response(
        JSON.stringify({ success: true, message: "Not a warehouse insert" }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL") || "";
    const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") || "";

    const supabase = createClient(supabaseUrl, supabaseKey);

    // Get all products in the workspace
    const { data: products, error: productsError } = await supabase
      .from("products")
      .select("id")
      .eq("workspace_id", event.record.workspace_id);

    if (productsError) throw productsError;

    // Create product_inventory records for the new warehouse
    const inventoryRecords = (products || []).map((product) => ({
      product_id: product.id,
      warehouse_id: event.record.id,
      quantity: 0,
      reorder_point: null,
      safety_stock: null,
    }));

    if (inventoryRecords.length > 0) {
      const { error: insertError } = await supabase
        .from("product_inventory")
        .insert(inventoryRecords);

      if (insertError) throw insertError;
    }

    return new Response(
      JSON.stringify({
        success: true,
        message: `Created ${inventoryRecords.length} inventory records for warehouse ${event.record.name}`,
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.error("Error:", error);
    return new Response(
      JSON.stringify({
        error: error instanceof Error ? error.message : String(error),
      }),
      {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
