-- FabricOS Enterprise Foundations
-- Multi-tenant foundations for planning, quality, traceability, multi-plant,
-- public integrations, and immutable audit/event trail.

-- =========================
-- Multi-plant architecture
-- =========================
CREATE TABLE IF NOT EXISTS public.plants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  code TEXT NOT NULL,
  name TEXT NOT NULL,
  country_code TEXT,
  timezone TEXT NOT NULL DEFAULT 'UTC',
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (company_id, code)
);

CREATE TABLE IF NOT EXISTS public.user_plant_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  plant_id UUID NOT NULL REFERENCES public.plants(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('operator', 'supervisor', 'planner', 'qa', 'manager', 'admin')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (plant_id, user_id, role)
);

-- =========================
-- Production planning schema
-- =========================
CREATE TABLE IF NOT EXISTS public.resources (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  plant_id UUID NOT NULL REFERENCES public.plants(id) ON DELETE CASCADE,
  resource_type TEXT NOT NULL CHECK (resource_type IN ('machine', 'line', 'workcenter', 'labor_group')),
  code TEXT NOT NULL,
  name TEXT NOT NULL,
  capacity_per_hour NUMERIC(12,2),
  efficiency_target NUMERIC(5,2),
  status TEXT NOT NULL DEFAULT 'available' CHECK (status IN ('available', 'down', 'maintenance', 'planned_stop')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (company_id, plant_id, code)
);

CREATE TABLE IF NOT EXISTS public.bom_headers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  plant_id UUID REFERENCES public.plants(id) ON DELETE SET NULL,
  item_sku TEXT NOT NULL,
  version TEXT NOT NULL DEFAULT 'v1',
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  effective_from DATE,
  effective_to DATE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (company_id, item_sku, version)
);

CREATE TABLE IF NOT EXISTS public.bom_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  bom_id UUID NOT NULL REFERENCES public.bom_headers(id) ON DELETE CASCADE,
  component_sku TEXT NOT NULL,
  quantity_per NUMERIC(12,4) NOT NULL,
  scrap_factor NUMERIC(6,4) NOT NULL DEFAULT 0,
  uom TEXT NOT NULL DEFAULT 'pcs',
  position_no INTEGER,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.routing_steps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  bom_id UUID NOT NULL REFERENCES public.bom_headers(id) ON DELETE CASCADE,
  step_no INTEGER NOT NULL,
  name TEXT NOT NULL,
  resource_id UUID REFERENCES public.resources(id) ON DELETE SET NULL,
  setup_minutes INTEGER NOT NULL DEFAULT 0,
  run_minutes INTEGER NOT NULL DEFAULT 0,
  queue_minutes INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (bom_id, step_no)
);

CREATE TABLE IF NOT EXISTS public.work_orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  plant_id UUID NOT NULL REFERENCES public.plants(id) ON DELETE CASCADE,
  order_number TEXT NOT NULL,
  item_sku TEXT NOT NULL,
  bom_id UUID REFERENCES public.bom_headers(id) ON DELETE SET NULL,
  planned_qty NUMERIC(12,2) NOT NULL,
  produced_qty NUMERIC(12,2) NOT NULL DEFAULT 0,
  scrapped_qty NUMERIC(12,2) NOT NULL DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'planned' CHECK (status IN ('planned', 'released', 'in_progress', 'blocked', 'done', 'cancelled')),
  priority SMALLINT NOT NULL DEFAULT 3 CHECK (priority BETWEEN 1 AND 5),
  scheduled_start TIMESTAMPTZ,
  scheduled_end TIMESTAMPTZ,
  actual_start TIMESTAMPTZ,
  actual_end TIMESTAMPTZ,
  oee_availability NUMERIC(6,2),
  oee_performance NUMERIC(6,2),
  oee_quality NUMERIC(6,2),
  oee_total NUMERIC(6,2),
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (company_id, plant_id, order_number)
);

CREATE TABLE IF NOT EXISTS public.work_order_operations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  work_order_id UUID NOT NULL REFERENCES public.work_orders(id) ON DELETE CASCADE,
  routing_step_id UUID REFERENCES public.routing_steps(id) ON DELETE SET NULL,
  resource_id UUID REFERENCES public.resources(id) ON DELETE SET NULL,
  status TEXT NOT NULL DEFAULT 'planned' CHECK (status IN ('planned', 'ready', 'running', 'paused', 'done', 'blocked')),
  planned_start TIMESTAMPTZ,
  planned_end TIMESTAMPTZ,
  actual_start TIMESTAMPTZ,
  actual_end TIMESTAMPTZ,
  wip_in_qty NUMERIC(12,2) NOT NULL DEFAULT 0,
  wip_out_qty NUMERIC(12,2) NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ==========
-- QMS schema
-- ==========
CREATE TABLE IF NOT EXISTS public.nonconformities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  plant_id UUID REFERENCES public.plants(id) ON DELETE SET NULL,
  source_type TEXT NOT NULL CHECK (source_type IN ('incoming', 'in_process', 'final', 'customer')),
  severity TEXT NOT NULL CHECK (severity IN ('minor', 'major', 'critical')),
  status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'in_progress', 'closed', 'accepted_risk')),
  reference_type TEXT CHECK (reference_type IN ('work_order', 'shipment', 'lot', 'order', 'supplier')),
  reference_id UUID,
  title TEXT NOT NULL,
  description TEXT,
  reported_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  assigned_to UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  due_date DATE,
  closed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.inspection_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  plant_id UUID REFERENCES public.plants(id) ON DELETE SET NULL,
  name TEXT NOT NULL,
  version TEXT NOT NULL DEFAULT 'v1',
  schema_json JSONB NOT NULL DEFAULT '{"fields":[]}'::jsonb,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (company_id, name, version)
);

CREATE TABLE IF NOT EXISTS public.inspections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  plant_id UUID REFERENCES public.plants(id) ON DELETE SET NULL,
  template_id UUID REFERENCES public.inspection_templates(id) ON DELETE SET NULL,
  reference_type TEXT CHECK (reference_type IN ('work_order', 'lot', 'shipment', 'supplier')),
  reference_id UUID,
  result TEXT NOT NULL CHECK (result IN ('pass', 'fail', 'conditional_pass')),
  score NUMERIC(6,2),
  payload_json JSONB NOT NULL DEFAULT '{}'::jsonb,
  inspected_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  inspected_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.corrective_actions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  nonconformity_id UUID NOT NULL REFERENCES public.nonconformities(id) ON DELETE CASCADE,
  action_type TEXT NOT NULL CHECK (action_type IN ('containment', 'correction', 'root_cause', 'preventive')),
  description TEXT NOT NULL,
  owner_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'in_progress', 'done', 'overdue')),
  due_date DATE,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ==========================
-- Compliance & traceability
-- ==========================
CREATE TABLE IF NOT EXISTS public.lot_tracking (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  plant_id UUID REFERENCES public.plants(id) ON DELETE SET NULL,
  lot_code TEXT NOT NULL,
  item_sku TEXT NOT NULL,
  origin_type TEXT NOT NULL CHECK (origin_type IN ('supplier', 'production', 'transfer')),
  origin_ref UUID,
  production_date DATE,
  expiry_date DATE,
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'quarantined', 'blocked', 'consumed', 'shipped', 'recalled')),
  quantity NUMERIC(12,2),
  uom TEXT NOT NULL DEFAULT 'pcs',
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (company_id, lot_code)
);

CREATE TABLE IF NOT EXISTS public.supply_chain_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  plant_id UUID REFERENCES public.plants(id) ON DELETE SET NULL,
  lot_id UUID REFERENCES public.lot_tracking(id) ON DELETE SET NULL,
  event_type TEXT NOT NULL CHECK (event_type IN ('received', 'inspected', 'produced', 'split', 'merged', 'transferred', 'picked', 'shipped', 'returned', 'quarantined', 'released')),
  source_type TEXT,
  source_id UUID,
  target_type TEXT,
  target_id UUID,
  quantity NUMERIC(12,2),
  payload_json JSONB NOT NULL DEFAULT '{}'::jsonb,
  occurred_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.recall_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  recall_code TEXT NOT NULL,
  reason TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'simulated', 'active', 'closed')),
  initiated_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  initiated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  closed_at TIMESTAMPTZ,
  impact_json JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (company_id, recall_code)
);

CREATE TABLE IF NOT EXISTS public.recall_lots (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  recall_id UUID NOT NULL REFERENCES public.recall_events(id) ON DELETE CASCADE,
  lot_id UUID NOT NULL REFERENCES public.lot_tracking(id) ON DELETE CASCADE,
  action TEXT NOT NULL CHECK (action IN ('inspect', 'hold', 'destroy', 'return_supplier', 'notify_customer')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (recall_id, lot_id)
);

-- ====================================
-- Public API + immutable event sourcing
-- ====================================
CREATE TABLE IF NOT EXISTS public.integration_apps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('erp', 'mes', 'wms', 'iot', 'ecommerce', 'accounting', 'custom')),
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'paused', 'disabled')),
  client_id TEXT NOT NULL,
  client_secret_hash TEXT NOT NULL,
  scopes TEXT[] NOT NULL DEFAULT '{}'::text[],
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (company_id, client_id)
);

CREATE TABLE IF NOT EXISTS public.api_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  integration_app_id UUID REFERENCES public.integration_apps(id) ON DELETE CASCADE,
  token_hash TEXT NOT NULL,
  expires_at TIMESTAMPTZ,
  revoked_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.webhook_endpoints (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  integration_app_id UUID REFERENCES public.integration_apps(id) ON DELETE CASCADE,
  url TEXT NOT NULL,
  secret_hash TEXT NOT NULL,
  events TEXT[] NOT NULL DEFAULT '{}'::text[],
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'paused', 'disabled')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.webhook_deliveries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  endpoint_id UUID NOT NULL REFERENCES public.webhook_endpoints(id) ON DELETE CASCADE,
  event_name TEXT NOT NULL,
  payload JSONB NOT NULL DEFAULT '{}'::jsonb,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'delivered', 'failed', 'abandoned')),
  attempts INTEGER NOT NULL DEFAULT 0,
  last_attempt_at TIMESTAMPTZ,
  response_code INTEGER,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.event_store (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  aggregate_type TEXT NOT NULL,
  aggregate_id UUID NOT NULL,
  event_type TEXT NOT NULL,
  event_version INTEGER NOT NULL DEFAULT 1,
  event_data JSONB NOT NULL DEFAULT '{}'::jsonb,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  causation_id UUID,
  correlation_id UUID,
  occurred_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  recorded_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.audit_log_immutable (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  actor_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  action TEXT NOT NULL,
  entity_type TEXT NOT NULL,
  entity_id UUID,
  previous_hash TEXT,
  current_hash TEXT NOT NULL,
  payload JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============
-- Touch update
-- ============
DROP TRIGGER IF EXISTS trg_plants_updated_at ON public.plants;
CREATE TRIGGER trg_plants_updated_at BEFORE UPDATE ON public.plants
FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

DROP TRIGGER IF EXISTS trg_resources_updated_at ON public.resources;
CREATE TRIGGER trg_resources_updated_at BEFORE UPDATE ON public.resources
FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

DROP TRIGGER IF EXISTS trg_bom_headers_updated_at ON public.bom_headers;
CREATE TRIGGER trg_bom_headers_updated_at BEFORE UPDATE ON public.bom_headers
FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

DROP TRIGGER IF EXISTS trg_work_orders_updated_at ON public.work_orders;
CREATE TRIGGER trg_work_orders_updated_at BEFORE UPDATE ON public.work_orders
FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

DROP TRIGGER IF EXISTS trg_work_order_operations_updated_at ON public.work_order_operations;
CREATE TRIGGER trg_work_order_operations_updated_at BEFORE UPDATE ON public.work_order_operations
FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

DROP TRIGGER IF EXISTS trg_nonconformities_updated_at ON public.nonconformities;
CREATE TRIGGER trg_nonconformities_updated_at BEFORE UPDATE ON public.nonconformities
FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

DROP TRIGGER IF EXISTS trg_inspection_templates_updated_at ON public.inspection_templates;
CREATE TRIGGER trg_inspection_templates_updated_at BEFORE UPDATE ON public.inspection_templates
FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

DROP TRIGGER IF EXISTS trg_corrective_actions_updated_at ON public.corrective_actions;
CREATE TRIGGER trg_corrective_actions_updated_at BEFORE UPDATE ON public.corrective_actions
FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

DROP TRIGGER IF EXISTS trg_lot_tracking_updated_at ON public.lot_tracking;
CREATE TRIGGER trg_lot_tracking_updated_at BEFORE UPDATE ON public.lot_tracking
FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

DROP TRIGGER IF EXISTS trg_recall_events_updated_at ON public.recall_events;
CREATE TRIGGER trg_recall_events_updated_at BEFORE UPDATE ON public.recall_events
FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

DROP TRIGGER IF EXISTS trg_integration_apps_updated_at ON public.integration_apps;
CREATE TRIGGER trg_integration_apps_updated_at BEFORE UPDATE ON public.integration_apps
FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

DROP TRIGGER IF EXISTS trg_webhook_endpoints_updated_at ON public.webhook_endpoints;
CREATE TRIGGER trg_webhook_endpoints_updated_at BEFORE UPDATE ON public.webhook_endpoints
FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

-- =======
-- Indexes
-- =======
CREATE INDEX IF NOT EXISTS idx_plants_company ON public.plants(company_id);
CREATE INDEX IF NOT EXISTS idx_user_plant_roles_company_user ON public.user_plant_roles(company_id, user_id);
CREATE INDEX IF NOT EXISTS idx_resources_company_plant_type ON public.resources(company_id, plant_id, resource_type);
CREATE INDEX IF NOT EXISTS idx_work_orders_company_plant_status ON public.work_orders(company_id, plant_id, status, scheduled_start);
CREATE INDEX IF NOT EXISTS idx_work_order_ops_order_status ON public.work_order_operations(work_order_id, status);
CREATE INDEX IF NOT EXISTS idx_nonconformities_company_status ON public.nonconformities(company_id, status, severity, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_inspections_company_date ON public.inspections(company_id, inspected_at DESC);
CREATE INDEX IF NOT EXISTS idx_corrective_actions_company_status ON public.corrective_actions(company_id, status, due_date);
CREATE INDEX IF NOT EXISTS idx_lot_tracking_company_status ON public.lot_tracking(company_id, status, expiry_date);
CREATE INDEX IF NOT EXISTS idx_supply_chain_events_company_lot_time ON public.supply_chain_events(company_id, lot_id, occurred_at DESC);
CREATE INDEX IF NOT EXISTS idx_recall_events_company_status ON public.recall_events(company_id, status, initiated_at DESC);
CREATE INDEX IF NOT EXISTS idx_integration_apps_company_type ON public.integration_apps(company_id, type, status);
CREATE INDEX IF NOT EXISTS idx_webhook_deliveries_endpoint_status ON public.webhook_deliveries(endpoint_id, status, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_event_store_company_aggregate ON public.event_store(company_id, aggregate_type, aggregate_id, id DESC);
CREATE INDEX IF NOT EXISTS idx_audit_immutable_company_created ON public.audit_log_immutable(company_id, created_at DESC);

-- ============
-- RLS policies
-- ============
ALTER TABLE public.plants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_plant_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.resources ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bom_headers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bom_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.routing_steps ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.work_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.work_order_operations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.nonconformities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inspection_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inspections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.corrective_actions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lot_tracking ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.supply_chain_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recall_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recall_lots ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.integration_apps ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.api_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.webhook_endpoints ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.webhook_deliveries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.event_store ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_log_immutable ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS plants_all ON public.plants;
CREATE POLICY plants_all ON public.plants FOR ALL
USING (company_id = public.current_company_id())
WITH CHECK (company_id = public.current_company_id());

DROP POLICY IF EXISTS user_plant_roles_all ON public.user_plant_roles;
CREATE POLICY user_plant_roles_all ON public.user_plant_roles FOR ALL
USING (company_id = public.current_company_id())
WITH CHECK (company_id = public.current_company_id());

DROP POLICY IF EXISTS resources_all ON public.resources;
CREATE POLICY resources_all ON public.resources FOR ALL
USING (company_id = public.current_company_id())
WITH CHECK (company_id = public.current_company_id());

DROP POLICY IF EXISTS bom_headers_all ON public.bom_headers;
CREATE POLICY bom_headers_all ON public.bom_headers FOR ALL
USING (company_id = public.current_company_id())
WITH CHECK (company_id = public.current_company_id());

DROP POLICY IF EXISTS bom_items_all ON public.bom_items;
CREATE POLICY bom_items_all ON public.bom_items FOR ALL
USING (company_id = public.current_company_id())
WITH CHECK (company_id = public.current_company_id());

DROP POLICY IF EXISTS routing_steps_all ON public.routing_steps;
CREATE POLICY routing_steps_all ON public.routing_steps FOR ALL
USING (company_id = public.current_company_id())
WITH CHECK (company_id = public.current_company_id());

DROP POLICY IF EXISTS work_orders_all ON public.work_orders;
CREATE POLICY work_orders_all ON public.work_orders FOR ALL
USING (company_id = public.current_company_id())
WITH CHECK (company_id = public.current_company_id());

DROP POLICY IF EXISTS work_order_operations_all ON public.work_order_operations;
CREATE POLICY work_order_operations_all ON public.work_order_operations FOR ALL
USING (company_id = public.current_company_id())
WITH CHECK (company_id = public.current_company_id());

DROP POLICY IF EXISTS nonconformities_all ON public.nonconformities;
CREATE POLICY nonconformities_all ON public.nonconformities FOR ALL
USING (company_id = public.current_company_id())
WITH CHECK (company_id = public.current_company_id());

DROP POLICY IF EXISTS inspection_templates_all ON public.inspection_templates;
CREATE POLICY inspection_templates_all ON public.inspection_templates FOR ALL
USING (company_id = public.current_company_id())
WITH CHECK (company_id = public.current_company_id());

DROP POLICY IF EXISTS inspections_all ON public.inspections;
CREATE POLICY inspections_all ON public.inspections FOR ALL
USING (company_id = public.current_company_id())
WITH CHECK (company_id = public.current_company_id());

DROP POLICY IF EXISTS corrective_actions_all ON public.corrective_actions;
CREATE POLICY corrective_actions_all ON public.corrective_actions FOR ALL
USING (company_id = public.current_company_id())
WITH CHECK (company_id = public.current_company_id());

DROP POLICY IF EXISTS lot_tracking_all ON public.lot_tracking;
CREATE POLICY lot_tracking_all ON public.lot_tracking FOR ALL
USING (company_id = public.current_company_id())
WITH CHECK (company_id = public.current_company_id());

DROP POLICY IF EXISTS supply_chain_events_all ON public.supply_chain_events;
CREATE POLICY supply_chain_events_all ON public.supply_chain_events FOR ALL
USING (company_id = public.current_company_id())
WITH CHECK (company_id = public.current_company_id());

DROP POLICY IF EXISTS recall_events_all ON public.recall_events;
CREATE POLICY recall_events_all ON public.recall_events FOR ALL
USING (company_id = public.current_company_id())
WITH CHECK (company_id = public.current_company_id());

DROP POLICY IF EXISTS recall_lots_all ON public.recall_lots;
CREATE POLICY recall_lots_all ON public.recall_lots FOR ALL
USING (company_id = public.current_company_id())
WITH CHECK (company_id = public.current_company_id());

DROP POLICY IF EXISTS integration_apps_all ON public.integration_apps;
CREATE POLICY integration_apps_all ON public.integration_apps FOR ALL
USING (company_id = public.current_company_id())
WITH CHECK (company_id = public.current_company_id());

DROP POLICY IF EXISTS api_tokens_all ON public.api_tokens;
CREATE POLICY api_tokens_all ON public.api_tokens FOR ALL
USING (company_id = public.current_company_id())
WITH CHECK (company_id = public.current_company_id());

DROP POLICY IF EXISTS webhook_endpoints_all ON public.webhook_endpoints;
CREATE POLICY webhook_endpoints_all ON public.webhook_endpoints FOR ALL
USING (company_id = public.current_company_id())
WITH CHECK (company_id = public.current_company_id());

DROP POLICY IF EXISTS webhook_deliveries_all ON public.webhook_deliveries;
CREATE POLICY webhook_deliveries_all ON public.webhook_deliveries FOR ALL
USING (company_id = public.current_company_id())
WITH CHECK (company_id = public.current_company_id());

DROP POLICY IF EXISTS event_store_all ON public.event_store;
CREATE POLICY event_store_all ON public.event_store FOR ALL
USING (company_id = public.current_company_id())
WITH CHECK (company_id = public.current_company_id());

DROP POLICY IF EXISTS audit_log_immutable_all ON public.audit_log_immutable;
CREATE POLICY audit_log_immutable_all ON public.audit_log_immutable FOR ALL
USING (company_id = public.current_company_id())
WITH CHECK (company_id = public.current_company_id());
