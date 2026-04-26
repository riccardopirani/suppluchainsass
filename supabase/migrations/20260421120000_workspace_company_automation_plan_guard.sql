-- Planning workspaces → company (billing gates on generate-forecast / generate-reorder-recommendations).
-- automation_settings: block enabling full auto-replenishment unless Industriale-tier rules match.

DO $$
BEGIN
  IF to_regclass('public.workspaces') IS NOT NULL THEN
    ALTER TABLE public.workspaces
      ADD COLUMN IF NOT EXISTS company_id UUID REFERENCES public.companies(id) ON DELETE SET NULL;

    IF to_regclass('public.workspace_members') IS NOT NULL
      AND to_regclass('public.users') IS NOT NULL THEN
      UPDATE public.workspaces w
      SET company_id = u.company_id
      FROM public.workspace_members m
      JOIN public.users u ON u.id = m.user_id
      WHERE m.workspace_id = w.id
        AND w.company_id IS NULL
        AND u.company_id IS NOT NULL;
    END IF;

    CREATE INDEX IF NOT EXISTS idx_workspaces_company_id ON public.workspaces(company_id);
  END IF;
END $$;

-- Effective commercial plan key (companies.selected_plan + subscriptions.metadata.plan).
CREATE OR REPLACE FUNCTION public.company_effective_plan_key(p_company_id UUID)
RETURNS TEXT
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  pk TEXT;
  meta JSONB;
BEGIN
  SELECT COALESCE(c.selected_plan, 'essenziale')
  INTO pk
  FROM public.companies c
  WHERE c.id = p_company_id;

  IF NOT FOUND OR pk IS NULL THEN
    pk := 'essenziale';
  END IF;

  SELECT s.metadata
  INTO meta
  FROM public.subscriptions s
  WHERE s.company_id = p_company_id
  ORDER BY s.updated_at DESC
  LIMIT 1;

  IF meta IS NOT NULL AND meta ? 'plan' THEN
    pk := meta->>'plan';
  END IF;

  RETURN pk;
END;
$$;

CREATE OR REPLACE FUNCTION public.company_can_access_app(p_company_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  te TIMESTAMPTZ;
  st TEXT;
BEGIN
  SELECT c.trial_ends_at INTO te FROM public.companies c WHERE c.id = p_company_id;

  IF te IS NOT NULL AND te > now() THEN
    RETURN TRUE;
  END IF;

  SELECT s.status INTO st
  FROM public.subscriptions s
  WHERE s.company_id = p_company_id
  ORDER BY s.updated_at DESC
  LIMIT 1;

  RETURN st IN ('active', 'trialing', 'past_due');
END;
$$;

-- Industriale-style tier only (full auto replenishment).
CREATE OR REPLACE FUNCTION public.plan_key_allows_full_auto_replenishment(pk TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
  s TEXT;
BEGIN
  s := lower(trim(coalesce(pk, '')));
  IF s = '' THEN
    RETURN FALSE;
  END IF;
  IF s = 'industriale' THEN
    RETURN TRUE;
  END IF;
  IF s LIKE '%industrial%' OR s LIKE '%full%' OR s LIKE '%fascia c%' THEN
    RETURN TRUE;
  END IF;
  IF s LIKE '%enterprise%' THEN
    RETURN TRUE;
  END IF;
  RETURN FALSE;
END;
$$;

CREATE OR REPLACE FUNCTION public.trg_automation_settings_plan_guard()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  IF NOT public.company_can_access_app(NEW.company_id) THEN
    RAISE EXCEPTION 'billing_blocked: subscription or active trial required'
      USING ERRCODE = 'check_violation';
  END IF;

  IF NEW.auto_replenishment_enabled = TRUE THEN
    IF TG_OP = 'INSERT' OR (
      TG_OP = 'UPDATE' AND COALESCE(OLD.auto_replenishment_enabled, FALSE) IS DISTINCT FROM TRUE
    ) THEN
      IF NOT public.plan_key_allows_full_auto_replenishment(
        public.company_effective_plan_key(NEW.company_id)
      ) THEN
        RAISE EXCEPTION 'plan_feature:auto_replenish_full not allowed for current plan'
          USING ERRCODE = 'check_violation';
      END IF;
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_automation_settings_plan_guard ON public.automation_settings;
CREATE TRIGGER trg_automation_settings_plan_guard
BEFORE INSERT OR UPDATE ON public.automation_settings
FOR EACH ROW
EXECUTE FUNCTION public.trg_automation_settings_plan_guard();
