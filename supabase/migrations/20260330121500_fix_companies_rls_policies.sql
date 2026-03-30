-- Normalize companies RLS policies in case legacy/restrictive policies exist remotely.
DO $$
DECLARE
  pol RECORD;
BEGIN
  FOR pol IN
    SELECT policyname
    FROM pg_policies
    WHERE schemaname = 'public' AND tablename = 'companies'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.companies', pol.policyname);
  END LOOP;
END;
$$;

ALTER TABLE public.companies ENABLE ROW LEVEL SECURITY;

CREATE POLICY companies_select ON public.companies
FOR SELECT
USING (id = public.current_company_id());

CREATE POLICY companies_insert ON public.companies
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY companies_update ON public.companies
FOR UPDATE
USING (id = public.current_company_id())
WITH CHECK (id = public.current_company_id());
