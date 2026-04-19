#!/usr/bin/env bash
# Deploy all Edge Functions with JWT verification disabled at the gateway.
# Each function must enforce auth/signature in its own code where needed.
set -euo pipefail

: "${SUPABASE_PROJECT_REF:?Set SUPABASE_PROJECT_REF}"

DEPLOY=(supabase functions deploy --project-ref "$SUPABASE_PROJECT_REF" --use-api --no-verify-jwt)

"${DEPLOY[@]}" accept-invitation
"${DEPLOY[@]}" analyze-order-risks
"${DEPLOY[@]}" analyze-supplier-risk
"${DEPLOY[@]}" auto-replenishment
"${DEPLOY[@]}" bootstrap-company
"${DEPLOY[@]}" create-stripe-checkout-session
"${DEPLOY[@]}" create-stripe-portal-session
"${DEPLOY[@]}" detect-disruptions
"${DEPLOY[@]}" generate-esg-report
"${DEPLOY[@]}" generate-forecast
"${DEPLOY[@]}" generate-reorder-recommendations
"${DEPLOY[@]}" invite-user
"${DEPLOY[@]}" optimize-costs
"${DEPLOY[@]}" optimize-inventory
"${DEPLOY[@]}" predict-demand
"${DEPLOY[@]}" predict-maintenance-risk
"${DEPLOY[@]}" process-import
"${DEPLOY[@]}" register-mobile-purchase
"${DEPLOY[@]}" run-simulation
"${DEPLOY[@]}" seed-demo-workspace
"${DEPLOY[@]}" send-alerts
"${DEPLOY[@]}" stripe-webhook
"${DEPLOY[@]}" submit-contact-form
"${DEPLOY[@]}" sync-warehouse-inventory

echo "All edge functions deployed (--no-verify-jwt)."
