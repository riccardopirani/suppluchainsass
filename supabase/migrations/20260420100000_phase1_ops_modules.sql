-- Phase 1 operational modules: Plant Floor, Vendor Portal, Offline Sync.

CREATE TABLE IF NOT EXISTS public.production_quick_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  plant_id UUID REFERENCES public.plants(id) ON DELETE SET NULL,
  machine_id UUID REFERENCES public.machines(id) ON DELETE SET NULL,
  operator_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  event_type TEXT NOT NULL CHECK (event_type IN ('production', 'scrap', 'downtime', 'quality_check')),
  quantity NUMERIC(12,2) NOT NULL DEFAULT 0,
  notes TEXT,
  qr_code TEXT,
  happened_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.shift_signatures (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  plant_id UUID REFERENCES public.plants(id) ON DELETE SET NULL,
  shift_code TEXT NOT NULL,
  signed_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  signer_name TEXT,
  signature_payload JSONB NOT NULL DEFAULT '{}'::jsonb,
  signed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.vendor_order_confirmations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  supplier_id UUID REFERENCES public.suppliers(id) ON DELETE SET NULL,
  order_id UUID REFERENCES public.orders(id) ON DELETE SET NULL,
  promised_delivery_date DATE,
  confirmed_quantity NUMERIC(12,2),
  status TEXT NOT NULL DEFAULT 'confirmed' CHECK (status IN ('confirmed', 'at_risk', 'delayed', 'cancelled')),
  notes TEXT,
  confirmed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.offline_sync_queue (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  entity_type TEXT NOT NULL,
  entity_id UUID,
  operation_type TEXT NOT NULL CHECK (operation_type IN ('insert', 'update', 'delete')),
  payload JSONB NOT NULL DEFAULT '{}'::jsonb,
  client_operation_id TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'applied', 'failed', 'conflict')),
  conflict_reason TEXT,
  queued_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  applied_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (company_id, client_operation_id)
);

DROP TRIGGER IF EXISTS trg_offline_sync_queue_updated_at ON public.offline_sync_queue;
CREATE TRIGGER trg_offline_sync_queue_updated_at
BEFORE UPDATE ON public.offline_sync_queue
FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

CREATE INDEX IF NOT EXISTS idx_quick_logs_company_happened ON public.production_quick_logs(company_id, happened_at DESC);
CREATE INDEX IF NOT EXISTS idx_shift_signatures_company_signed ON public.shift_signatures(company_id, signed_at DESC);
CREATE INDEX IF NOT EXISTS idx_vendor_conf_company_created ON public.vendor_order_confirmations(company_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_offline_queue_company_status ON public.offline_sync_queue(company_id, status, queued_at);

ALTER TABLE public.production_quick_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shift_signatures ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vendor_order_confirmations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.offline_sync_queue ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS production_quick_logs_all ON public.production_quick_logs;
CREATE POLICY production_quick_logs_all ON public.production_quick_logs
FOR ALL USING (company_id = public.current_company_id())
WITH CHECK (company_id = public.current_company_id());

DROP POLICY IF EXISTS shift_signatures_all ON public.shift_signatures;
CREATE POLICY shift_signatures_all ON public.shift_signatures
FOR ALL USING (company_id = public.current_company_id())
WITH CHECK (company_id = public.current_company_id());

DROP POLICY IF EXISTS vendor_order_confirmations_all ON public.vendor_order_confirmations;
CREATE POLICY vendor_order_confirmations_all ON public.vendor_order_confirmations
FOR ALL USING (company_id = public.current_company_id())
WITH CHECK (company_id = public.current_company_id());

DROP POLICY IF EXISTS offline_sync_queue_all ON public.offline_sync_queue;
CREATE POLICY offline_sync_queue_all ON public.offline_sync_queue
FOR ALL USING (company_id = public.current_company_id())
WITH CHECK (company_id = public.current_company_id());
