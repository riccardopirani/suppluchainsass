-- AI Supply Chain upgrade: forecasting, inventory, disruptions, shipments, simulations.

ALTER TABLE public.suppliers
  ADD COLUMN IF NOT EXISTS risk_score NUMERIC(5,2) NOT NULL DEFAULT 50,
  ADD COLUMN IF NOT EXISTS financial_risk NUMERIC(5,2) NOT NULL DEFAULT 50,
  ADD COLUMN IF NOT EXISTS delivery_risk NUMERIC(5,2) NOT NULL DEFAULT 50,
  ADD COLUMN IF NOT EXISTS compliance_risk NUMERIC(5,2) NOT NULL DEFAULT 50,
  ADD COLUMN IF NOT EXISTS last_evaluation TIMESTAMPTZ;

CREATE TABLE IF NOT EXISTS public.demand_forecasts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  item_id TEXT NOT NULL,
  predicted_quantity NUMERIC(12,2) NOT NULL,
  confidence_score NUMERIC(5,4) NOT NULL DEFAULT 0.7,
  forecast_date DATE NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.inventory (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  item_name TEXT NOT NULL,
  stock_quantity NUMERIC(12,2) NOT NULL DEFAULT 0,
  safety_stock NUMERIC(12,2) NOT NULL DEFAULT 0,
  reorder_point NUMERIC(12,2) NOT NULL DEFAULT 0,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.supply_disruptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('supplier_delay', 'shipment_delay', 'anomaly')),
  severity TEXT NOT NULL DEFAULT 'warning' CHECK (severity IN ('info', 'warning', 'critical')),
  message TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.auto_orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  item_id TEXT NOT NULL,
  quantity NUMERIC(12,2) NOT NULL,
  supplier_id UUID REFERENCES public.suppliers(id) ON DELETE SET NULL,
  status TEXT NOT NULL DEFAULT 'created' CHECK (status IN ('created', 'submitted', 'cancelled')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.shipments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'in_transit' CHECK (status IN ('in_transit', 'delayed', 'delivered')),
  eta TIMESTAMPTZ,
  location TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.warehouses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  location TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.inventory_locations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  warehouse_id UUID NOT NULL REFERENCES public.warehouses(id) ON DELETE CASCADE,
  item_id TEXT NOT NULL,
  quantity NUMERIC(12,2) NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (warehouse_id, item_id)
);

CREATE TABLE IF NOT EXISTS public.simulations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  scenario_type TEXT NOT NULL,
  input_data JSONB NOT NULL DEFAULT '{}'::jsonb,
  result JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.automation_settings (
  company_id UUID PRIMARY KEY REFERENCES public.companies(id) ON DELETE CASCADE,
  auto_replenishment_enabled BOOLEAN NOT NULL DEFAULT FALSE,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_forecasts_company_date ON public.demand_forecasts(company_id, forecast_date DESC);
CREATE INDEX IF NOT EXISTS idx_inventory_company ON public.inventory(company_id);
CREATE INDEX IF NOT EXISTS idx_disruptions_company_created ON public.supply_disruptions(company_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_auto_orders_company_created ON public.auto_orders(company_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_shipments_company_status ON public.shipments(company_id, status, eta);
CREATE INDEX IF NOT EXISTS idx_warehouses_company ON public.warehouses(company_id);
CREATE INDEX IF NOT EXISTS idx_simulations_company_created ON public.simulations(company_id, created_at DESC);

DROP TRIGGER IF EXISTS trg_inventory_updated_at ON public.inventory;
CREATE TRIGGER trg_inventory_updated_at
BEFORE UPDATE ON public.inventory
FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

DROP TRIGGER IF EXISTS trg_shipments_updated_at ON public.shipments;
CREATE TRIGGER trg_shipments_updated_at
BEFORE UPDATE ON public.shipments
FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

DROP TRIGGER IF EXISTS trg_warehouses_updated_at ON public.warehouses;
CREATE TRIGGER trg_warehouses_updated_at
BEFORE UPDATE ON public.warehouses
FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

DROP TRIGGER IF EXISTS trg_inventory_locations_updated_at ON public.inventory_locations;
CREATE TRIGGER trg_inventory_locations_updated_at
BEFORE UPDATE ON public.inventory_locations
FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

DROP TRIGGER IF EXISTS trg_automation_settings_updated_at ON public.automation_settings;
CREATE TRIGGER trg_automation_settings_updated_at
BEFORE UPDATE ON public.automation_settings
FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

ALTER TABLE public.demand_forecasts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.supply_disruptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.auto_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shipments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.warehouses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory_locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.simulations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.automation_settings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS demand_forecasts_all ON public.demand_forecasts;
CREATE POLICY demand_forecasts_all ON public.demand_forecasts
FOR ALL USING (company_id = public.current_company_id())
WITH CHECK (company_id = public.current_company_id());

DROP POLICY IF EXISTS inventory_all ON public.inventory;
CREATE POLICY inventory_all ON public.inventory
FOR ALL USING (company_id = public.current_company_id())
WITH CHECK (company_id = public.current_company_id());

DROP POLICY IF EXISTS disruptions_all ON public.supply_disruptions;
CREATE POLICY disruptions_all ON public.supply_disruptions
FOR ALL USING (company_id = public.current_company_id())
WITH CHECK (company_id = public.current_company_id());

DROP POLICY IF EXISTS auto_orders_all ON public.auto_orders;
CREATE POLICY auto_orders_all ON public.auto_orders
FOR ALL USING (company_id = public.current_company_id())
WITH CHECK (company_id = public.current_company_id());

DROP POLICY IF EXISTS shipments_all ON public.shipments;
CREATE POLICY shipments_all ON public.shipments
FOR ALL USING (company_id = public.current_company_id())
WITH CHECK (company_id = public.current_company_id());

DROP POLICY IF EXISTS warehouses_all ON public.warehouses;
CREATE POLICY warehouses_all ON public.warehouses
FOR ALL USING (company_id = public.current_company_id())
WITH CHECK (company_id = public.current_company_id());

DROP POLICY IF EXISTS inventory_locations_all ON public.inventory_locations;
CREATE POLICY inventory_locations_all ON public.inventory_locations
FOR ALL USING (
  EXISTS (
    SELECT 1 FROM public.warehouses w
    WHERE w.id = inventory_locations.warehouse_id
      AND w.company_id = public.current_company_id()
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.warehouses w
    WHERE w.id = inventory_locations.warehouse_id
      AND w.company_id = public.current_company_id()
  )
);

DROP POLICY IF EXISTS simulations_all ON public.simulations;
CREATE POLICY simulations_all ON public.simulations
FOR ALL USING (company_id = public.current_company_id())
WITH CHECK (company_id = public.current_company_id());

DROP POLICY IF EXISTS automation_settings_all ON public.automation_settings;
CREATE POLICY automation_settings_all ON public.automation_settings
FOR ALL USING (company_id = public.current_company_id())
WITH CHECK (company_id = public.current_company_id());
