import type { SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2';

/** Mirrors `lib/config/plan_catalog.dart` (SubscriptionPlanTier + PlanDefinition). */
export type PlanTier = 'essenziale' | 'professionale' | 'industriale';

export type PlanFeature =
  | 'predictive_ai'
  | 'what_if'
  | 'esg'
  | 'cost_inventory_ai'
  | 'auto_replenish_full';

export interface PlanEntitlements {
  tier: PlanTier;
  includesPredictiveAi: boolean;
  includesWhatIf: boolean;
  includesEsgCompliance: boolean;
  includesCopilot: boolean;
  includesApiErp: boolean;
  includesAutoReplenishmentFull: boolean;
}

export function parsePlanTier(raw: string | null | undefined): PlanTier {
  if (raw == null || String(raw).trim() === '') return 'essenziale';
  const s = String(raw).toLowerCase().trim();
  if (
    s === 'industriale' ||
    s.includes('industrial') ||
    s.includes('full') ||
    s.includes('fascia c')
  ) {
    return 'industriale';
  }
  if (
    s === 'professionale' ||
    s.includes('professional') ||
    s.includes('core') ||
    s === 'pro' ||
    s.includes('growth') ||
    s.includes('fascia b')
  ) {
    return 'professionale';
  }
  if (
    s === 'essenziale' ||
    s.includes('essential') ||
    s.includes('ingresso') ||
    s.includes('starter') ||
    s.includes('basic') ||
    s.includes('fascia a')
  ) {
    return 'essenziale';
  }
  if (s.includes('enterprise')) return 'industriale';
  return 'essenziale';
}

export function entitlementsForTier(tier: PlanTier): PlanEntitlements {
  switch (tier) {
    case 'industriale':
      return {
        tier,
        includesPredictiveAi: true,
        includesWhatIf: true,
        includesEsgCompliance: true,
        includesCopilot: true,
        includesApiErp: true,
        includesAutoReplenishmentFull: true,
      };
    case 'professionale':
      return {
        tier,
        includesPredictiveAi: true,
        includesWhatIf: true,
        includesEsgCompliance: true,
        includesCopilot: true,
        includesApiErp: false,
        includesAutoReplenishmentFull: false,
      };
    default:
      return {
        tier: 'essenziale',
        includesPredictiveAi: false,
        includesWhatIf: false,
        includesEsgCompliance: false,
        includesCopilot: false,
        includesApiErp: false,
        includesAutoReplenishmentFull: false,
      };
  }
}

export interface BillingContext {
  canAccessApp: boolean;
  planKey: string;
  entitlements: PlanEntitlements;
}

export async function fetchBillingContext(
  supabase: SupabaseClient,
  companyId: string,
): Promise<BillingContext> {
  const { data: company } = await supabase
    .from('companies')
    .select('trial_ends_at, selected_plan')
    .eq('id', companyId)
    .maybeSingle();

  const { data: sub } = await supabase
    .from('subscriptions')
    .select('status, metadata')
    .eq('company_id', companyId)
    .order('updated_at', { ascending: false })
    .limit(1)
    .maybeSingle();

  const trialEndsRaw = company?.trial_ends_at as string | undefined;
  const trialEndsAt = trialEndsRaw ? new Date(trialEndsRaw) : null;
  const inTrial = trialEndsAt !== null && !Number.isNaN(trialEndsAt.valueOf()) &&
    trialEndsAt.getTime() > Date.now();

  const status = String(sub?.status ?? '');
  const hasActiveSubscription =
    status === 'active' || status === 'trialing' || status === 'past_due';
  const canAccessApp = hasActiveSubscription || inTrial;

  let planKey = String(company?.selected_plan ?? 'essenziale');
  if (sub?.metadata && typeof sub.metadata === 'object') {
    const meta = sub.metadata as Record<string, unknown>;
    if (meta.plan != null) planKey = String(meta.plan);
  }

  const tier = parsePlanTier(planKey);
  return {
    canAccessApp,
    planKey,
    entitlements: entitlementsForTier(tier),
  };
}

function featureAllowed(ent: PlanEntitlements, feature: PlanFeature): boolean {
  switch (feature) {
    case 'predictive_ai':
      return ent.includesPredictiveAi;
    case 'what_if':
      return ent.includesWhatIf;
    case 'esg':
      return ent.includesEsgCompliance;
    case 'cost_inventory_ai':
      return ent.includesAutoReplenishmentFull && ent.includesApiErp;
    case 'auto_replenish_full':
      return ent.includesAutoReplenishmentFull;
  }
}

type JsonFn = (body: unknown, status?: number) => Response;

/** Caller must belong to `company_id` on `public.users` (FabricOS tenant). */
export async function assertUserInCompany(
  supabase: SupabaseClient,
  userId: string,
  companyId: string,
  json: JsonFn,
): Promise<Response | null> {
  const { data: member } = await supabase
    .from('users')
    .select('id')
    .eq('id', userId)
    .eq('company_id', companyId)
    .maybeSingle();
  if (!member) {
    return json({ error: 'Forbidden', code: 'COMPANY_MISMATCH' }, 403);
  }
  return null;
}

export async function fetchBillingAndCheckFeature(
  supabase: SupabaseClient,
  companyId: string,
  feature: PlanFeature,
  json: JsonFn,
): Promise<Response | null> {
  const billing = await fetchBillingContext(supabase, companyId);
  if (!billing.canAccessApp) {
    return json({
      error: 'Subscription or active trial required',
      code: 'BILLING_BLOCKED',
    }, 402);
  }
  if (!featureAllowed(billing.entitlements, feature)) {
    return json({
      error: 'Current plan does not include this feature',
      code: 'PLAN_FEATURE',
      feature,
      tier: billing.entitlements.tier,
    }, 403);
  }
  return null;
}

/** Active trial/subscription for company (no tier feature). */
export async function fetchBillingAccessOnly(
  supabase: SupabaseClient,
  companyId: string,
  json: JsonFn,
): Promise<Response | null> {
  const billing = await fetchBillingContext(supabase, companyId);
  if (!billing.canAccessApp) {
    return json({
      error: 'Subscription or active trial required',
      code: 'BILLING_BLOCKED',
    }, 402);
  }
  return null;
}

/** Membership + active trial/subscription (no tier feature). */
export async function enforceCompanyBilling(
  supabase: SupabaseClient,
  userId: string,
  companyId: string,
  json: JsonFn,
): Promise<Response | null> {
  const denied = await assertUserInCompany(supabase, userId, companyId, json);
  if (denied) return denied;
  return fetchBillingAccessOnly(supabase, companyId, json);
}

/** Membership + billing + plan feature (matches Flutter `SubscriptionEntitlements`). */
export async function enforceCompanyFeature(
  supabase: SupabaseClient,
  userId: string,
  companyId: string,
  feature: PlanFeature,
  json: JsonFn,
): Promise<Response | null> {
  const denied = await assertUserInCompany(supabase, userId, companyId, json);
  if (denied) return denied;
  return fetchBillingAndCheckFeature(supabase, companyId, feature, json);
}

/**
 * Planning workspaces (`workspaceId`): member check via `workspace_members`, then same billing/feature as company.
 * Requires `workspaces.company_id` set (backfilled in migration / seed-demo-workspace).
 */
export async function enforceWorkspaceFeature(
  supabase: SupabaseClient,
  userId: string,
  workspaceId: string,
  feature: PlanFeature,
  json: JsonFn,
): Promise<Response | null> {
  const { data: membership } = await supabase
    .from('workspace_members')
    .select('workspace_id')
    .eq('workspace_id', workspaceId)
    .eq('user_id', userId)
    .maybeSingle();

  if (!membership) {
    return json({ error: 'Forbidden', code: 'WORKSPACE_MISMATCH' }, 403);
  }

  const { data: workspace } = await supabase
    .from('workspaces')
    .select('id, company_id')
    .eq('id', workspaceId)
    .maybeSingle();

  if (!workspace?.id) {
    return json({ error: 'Workspace not found', code: 'WORKSPACE_NOT_FOUND' }, 404);
  }

  const companyId = workspace.company_id as string | null;
  if (!companyId) {
    return json({
      error:
        'Workspace is not linked to a company. Set workspaces.company_id (e.g. deploy migration / re-seed).',
      code: 'WORKSPACE_COMPANY_UNSET',
    }, 428);
  }

  return fetchBillingAndCheckFeature(supabase, companyId, feature, json);
}
