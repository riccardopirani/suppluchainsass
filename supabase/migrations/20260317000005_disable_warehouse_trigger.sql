-- Disable the problematic warehouse trigger
-- The trigger was causing JSON parsing errors due to invalid JWT handling
DROP TRIGGER IF EXISTS on_warehouse_created ON warehouses;
DROP FUNCTION IF EXISTS public.handle_warehouse_insert();
