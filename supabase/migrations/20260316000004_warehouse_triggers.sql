-- Trigger to sync inventory when warehouse is created
CREATE OR REPLACE FUNCTION public.handle_warehouse_insert()
RETURNS TRIGGER AS $$
BEGIN
  -- Call edge function via http
  PERFORM
    net.http_post(
      url:='https://ouieulumtrnnjsjtlyxe.supabase.co/functions/v1/sync-warehouse-inventory',
      headers:='{"Content-Type": "application/json", "Authorization": "Bearer ' || current_setting('app.jwt_secret', true) || '"}'::jsonb,
      body:=jsonb_build_object(
        'type', 'INSERT',
        'schema', TG_TABLE_SCHEMA,
        'table', TG_TABLE_NAME,
        'record', row_to_json(NEW)
      )
    );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS on_warehouse_created ON warehouses;

-- Create trigger
CREATE TRIGGER on_warehouse_created
  AFTER INSERT ON warehouses
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_warehouse_insert();
