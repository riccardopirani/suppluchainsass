-- Team members, seat limits, and per-role menu permissions

-- Seat limit on companies (set during checkout)
ALTER TABLE public.companies
ADD COLUMN IF NOT EXISTS seat_limit INTEGER NOT NULL DEFAULT 10;

-- Team members (invites + active users per company)
CREATE TABLE IF NOT EXISTS public.team_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
  email TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'operator' CHECK (role IN ('admin', 'manager', 'operator', 'viewer')),
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'active', 'disabled')),
  invited_by UUID REFERENCES public.users(id) ON DELETE SET NULL,
  invited_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  joined_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (company_id, email)
);

CREATE INDEX IF NOT EXISTS idx_team_members_company ON public.team_members(company_id);
CREATE INDEX IF NOT EXISTS idx_team_members_user ON public.team_members(user_id);
CREATE INDEX IF NOT EXISTS idx_team_members_email ON public.team_members(email);

DROP TRIGGER IF EXISTS trg_team_members_updated_at ON public.team_members;
CREATE TRIGGER trg_team_members_updated_at
BEFORE UPDATE ON public.team_members
FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

ALTER TABLE public.team_members ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS team_members_select ON public.team_members;
CREATE POLICY team_members_select ON public.team_members
FOR SELECT USING (company_id = public.current_company_id());

DROP POLICY IF EXISTS team_members_insert ON public.team_members;
CREATE POLICY team_members_insert ON public.team_members
FOR INSERT TO authenticated
WITH CHECK (
  company_id = public.current_company_id()
  AND public.current_user_role() IN ('admin', 'manager')
);

DROP POLICY IF EXISTS team_members_update ON public.team_members;
CREATE POLICY team_members_update ON public.team_members
FOR UPDATE USING (
  company_id = public.current_company_id()
  AND public.current_user_role() IN ('admin', 'manager')
);

DROP POLICY IF EXISTS team_members_delete ON public.team_members;
CREATE POLICY team_members_delete ON public.team_members
FOR DELETE USING (
  company_id = public.current_company_id()
  AND public.current_user_role() = 'admin'
);

-- Menu permissions per role per company (JSON array of route keys)
-- Default: null = all access for admin, specific routes for others
CREATE TABLE IF NOT EXISTS public.menu_permissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('admin', 'manager', 'operator', 'viewer')),
  allowed_routes JSONB NOT NULL DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (company_id, role)
);

ALTER TABLE public.menu_permissions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS menu_permissions_select ON public.menu_permissions;
CREATE POLICY menu_permissions_select ON public.menu_permissions
FOR SELECT USING (company_id = public.current_company_id());

DROP POLICY IF EXISTS menu_permissions_manage ON public.menu_permissions;
CREATE POLICY menu_permissions_manage ON public.menu_permissions
FOR ALL USING (
  company_id = public.current_company_id()
  AND public.current_user_role() = 'admin'
)
WITH CHECK (
  company_id = public.current_company_id()
  AND public.current_user_role() = 'admin'
);

DROP TRIGGER IF EXISTS trg_menu_permissions_updated_at ON public.menu_permissions;
CREATE TRIGGER trg_menu_permissions_updated_at
BEFORE UPDATE ON public.menu_permissions
FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

-- Allow a user to belong to multiple companies: update current_company_id() to
-- accept a preference header, but default to first company. For multi-company
-- support, the user picks company at login and we store it in user metadata.
-- The existing current_company_id() already reads from users.company_id which
-- is their "active" company. When switching companies, we update users.company_id.

-- Update users role CHECK to include 'viewer'
ALTER TABLE public.users DROP CONSTRAINT IF EXISTS users_role_check;
ALTER TABLE public.users ADD CONSTRAINT users_role_check
  CHECK (role IN ('admin', 'manager', 'operator', 'viewer'));
