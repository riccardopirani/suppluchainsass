-- FabricOS core schema (multi-tenant manufacturing operations MVP)

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE OR REPLACE FUNCTION public.touch_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

CREATE TABLE IF NOT EXISTS public.companies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  size_band TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  company_id UUID REFERENCES public.companies(id) ON DELETE SET NULL,
  email TEXT,
  full_name TEXT,
  role TEXT NOT NULL DEFAULT 'operator' CHECK (role IN ('admin', 'manager', 'operator')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.suppliers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  contact_email TEXT,
  reliability_score NUMERIC(5,2) NOT NULL DEFAULT 75,
  compliance_status TEXT NOT NULL DEFAULT 'under_review',
  avg_delay_days NUMERIC(6,2) NOT NULL DEFAULT 0,
  risk_level TEXT NOT NULL DEFAULT 'medium',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.machines (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  supplier_id UUID REFERENCES public.suppliers(id) ON DELETE SET NULL,
  name TEXT NOT NULL,
  type TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'running' CHECK (status IN ('running', 'warning', 'stopped')),
  last_maintenance_at TIMESTAMPTZ,
  next_maintenance_at TIMESTAMPTZ,
  failure_risk NUMERIC(5,4) NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.machine_telemetry (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  machine_id UUID NOT NULL REFERENCES public.machines(id) ON DELETE CASCADE,
  temperature NUMERIC(8,3),
  vibration NUMERIC(8,3),
  pressure NUMERIC(8,3),
  recorded_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.maintenance_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  machine_id UUID NOT NULL REFERENCES public.machines(id) ON DELETE CASCADE,
  technician TEXT,
  notes TEXT,
  cost NUMERIC(12,2) NOT NULL DEFAULT 0,
  performed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  supplier_id UUID REFERENCES public.suppliers(id) ON DELETE SET NULL,
  order_number TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed')),
  expected_delivery_date TIMESTAMPTZ,
  delivered_at TIMESTAMPTZ,
  delay_days INTEGER NOT NULL DEFAULT 0,
  amount NUMERIC(12,2) NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (company_id, order_number)
);

CREATE TABLE IF NOT EXISTS public.alerts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  machine_id UUID REFERENCES public.machines(id) ON DELETE CASCADE,
  order_id UUID REFERENCES public.orders(id) ON DELETE CASCADE,
  supplier_id UUID REFERENCES public.suppliers(id) ON DELETE CASCADE,
  type TEXT NOT NULL,
  severity TEXT NOT NULL DEFAULT 'info' CHECK (severity IN ('info', 'warning', 'critical')),
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  ai_generated BOOLEAN NOT NULL DEFAULT TRUE,
  resolved BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.esg_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  report_month DATE NOT NULL,
  emissions_tco2 NUMERIC(12,3) NOT NULL DEFAULT 0,
  supplier_compliance_score NUMERIC(6,2) NOT NULL DEFAULT 0,
  summary TEXT,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_by UUID REFERENCES public.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (company_id, report_month)
);

CREATE INDEX IF NOT EXISTS idx_users_company ON public.users(company_id);
CREATE INDEX IF NOT EXISTS idx_suppliers_company ON public.suppliers(company_id);
CREATE INDEX IF NOT EXISTS idx_machines_company ON public.machines(company_id);
CREATE INDEX IF NOT EXISTS idx_telemetry_company_machine ON public.machine_telemetry(company_id, machine_id, recorded_at DESC);
CREATE INDEX IF NOT EXISTS idx_maintenance_company_machine ON public.maintenance_logs(company_id, machine_id, performed_at DESC);
CREATE INDEX IF NOT EXISTS idx_orders_company_status ON public.orders(company_id, status);
CREATE INDEX IF NOT EXISTS idx_orders_expected_delivery ON public.orders(company_id, expected_delivery_date);
CREATE INDEX IF NOT EXISTS idx_alerts_company_created ON public.alerts(company_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_esg_company_month ON public.esg_reports(company_id, report_month DESC);

DROP TRIGGER IF EXISTS trg_companies_updated_at ON public.companies;
CREATE TRIGGER trg_companies_updated_at
BEFORE UPDATE ON public.companies
FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

DROP TRIGGER IF EXISTS trg_users_updated_at ON public.users;
CREATE TRIGGER trg_users_updated_at
BEFORE UPDATE ON public.users
FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

DROP TRIGGER IF EXISTS trg_suppliers_updated_at ON public.suppliers;
CREATE TRIGGER trg_suppliers_updated_at
BEFORE UPDATE ON public.suppliers
FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

DROP TRIGGER IF EXISTS trg_machines_updated_at ON public.machines;
CREATE TRIGGER trg_machines_updated_at
BEFORE UPDATE ON public.machines
FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

DROP TRIGGER IF EXISTS trg_orders_updated_at ON public.orders;
CREATE TRIGGER trg_orders_updated_at
BEFORE UPDATE ON public.orders
FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

DROP TRIGGER IF EXISTS trg_alerts_updated_at ON public.alerts;
CREATE TRIGGER trg_alerts_updated_at
BEFORE UPDATE ON public.alerts
FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

DROP TRIGGER IF EXISTS trg_esg_reports_updated_at ON public.esg_reports;
CREATE TRIGGER trg_esg_reports_updated_at
BEFORE UPDATE ON public.esg_reports
FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

CREATE OR REPLACE FUNCTION public.current_company_id()
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT company_id FROM public.users WHERE id = auth.uid() LIMIT 1;
$$;

CREATE OR REPLACE FUNCTION public.current_user_role()
RETURNS TEXT
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT role FROM public.users WHERE id = auth.uid() LIMIT 1;
$$;

GRANT EXECUTE ON FUNCTION public.current_company_id() TO authenticated, anon;
GRANT EXECUTE ON FUNCTION public.current_user_role() TO authenticated, anon;

CREATE OR REPLACE FUNCTION public.handle_new_auth_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.users (id, email, full_name, role)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data ->> 'full_name', ''),
    'admin'
  )
  ON CONFLICT (id) DO NOTHING;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE FUNCTION public.handle_new_auth_user();

ALTER TABLE public.companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.suppliers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.machines ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.machine_telemetry ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.maintenance_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.esg_reports ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS companies_select ON public.companies;
CREATE POLICY companies_select ON public.companies
FOR SELECT USING (id = public.current_company_id());

DROP POLICY IF EXISTS companies_insert ON public.companies;
CREATE POLICY companies_insert ON public.companies
FOR INSERT TO authenticated
WITH CHECK (true);

DROP POLICY IF EXISTS companies_update ON public.companies;
CREATE POLICY companies_update ON public.companies
FOR UPDATE USING (id = public.current_company_id())
WITH CHECK (id = public.current_company_id());

DROP POLICY IF EXISTS users_select ON public.users;
CREATE POLICY users_select ON public.users
FOR SELECT USING (
  id = auth.uid() OR company_id = public.current_company_id()
);

DROP POLICY IF EXISTS users_insert ON public.users;
CREATE POLICY users_insert ON public.users
FOR INSERT TO authenticated
WITH CHECK (id = auth.uid());

DROP POLICY IF EXISTS users_update ON public.users;
CREATE POLICY users_update ON public.users
FOR UPDATE USING (
  id = auth.uid() OR (public.current_user_role() = 'admin' AND company_id = public.current_company_id())
)
WITH CHECK (
  id = auth.uid() OR (public.current_user_role() = 'admin' AND company_id = public.current_company_id())
);

DROP POLICY IF EXISTS users_delete ON public.users;
CREATE POLICY users_delete ON public.users
FOR DELETE USING (public.current_user_role() = 'admin' AND company_id = public.current_company_id());

DROP POLICY IF EXISTS suppliers_all ON public.suppliers;
CREATE POLICY suppliers_all ON public.suppliers
FOR ALL USING (company_id = public.current_company_id())
WITH CHECK (company_id = public.current_company_id());

DROP POLICY IF EXISTS machines_all ON public.machines;
CREATE POLICY machines_all ON public.machines
FOR ALL USING (company_id = public.current_company_id())
WITH CHECK (company_id = public.current_company_id());

DROP POLICY IF EXISTS telemetry_all ON public.machine_telemetry;
CREATE POLICY telemetry_all ON public.machine_telemetry
FOR ALL USING (company_id = public.current_company_id())
WITH CHECK (company_id = public.current_company_id());

DROP POLICY IF EXISTS maintenance_all ON public.maintenance_logs;
CREATE POLICY maintenance_all ON public.maintenance_logs
FOR ALL USING (company_id = public.current_company_id())
WITH CHECK (company_id = public.current_company_id());

DROP POLICY IF EXISTS orders_all ON public.orders;
CREATE POLICY orders_all ON public.orders
FOR ALL USING (company_id = public.current_company_id())
WITH CHECK (company_id = public.current_company_id());

DROP POLICY IF EXISTS alerts_all ON public.alerts;
CREATE POLICY alerts_all ON public.alerts
FOR ALL USING (company_id = public.current_company_id())
WITH CHECK (company_id = public.current_company_id());

DROP POLICY IF EXISTS esg_reports_all ON public.esg_reports;
CREATE POLICY esg_reports_all ON public.esg_reports
FOR ALL USING (company_id = public.current_company_id())
WITH CHECK (company_id = public.current_company_id());

DO $$
BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE public.alerts;
EXCEPTION
  WHEN duplicate_object THEN NULL;
END;
$$;

DO $$
BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE public.machines;
EXCEPTION
  WHEN duplicate_object THEN NULL;
END;
$$;
