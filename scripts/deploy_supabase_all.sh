#!/usr/bin/env bash

set -euo pipefail

require_var() {
  local name="$1"
  if [[ -z "${!name:-}" ]]; then
    echo "Missing required env var: $name" >&2
    exit 1
  fi
}

if ! command -v supabase >/dev/null 2>&1; then
  echo "Supabase CLI is not installed." >&2
  exit 1
fi

SUPABASE_URL_VALUE="${SUPABASE_URL:-${NEXT_PUBLIC_SUPABASE_URL:-}}"
SUPABASE_PUBLISHABLE_VALUE="${SUPABASE_ANON_KEY:-${SUPABASE_PUBLISHABLE_DEFAULT_KEY:-${NEXT_PUBLIC_SUPABASE_PUBLISHABLE_DEFAULT_KEY:-}}}"
SUPABASE_SERVICE_ROLE_VALUE="${SUPABASE_SERVICE_ROLE_KEY:-${SUPABASE_SECRET_KEY:-}}"
SUPABASE_PROJECT_REF_VALUE="${SUPABASE_PROJECT_REF:-}"

if [[ -z "$SUPABASE_PROJECT_REF_VALUE" && -n "$SUPABASE_URL_VALUE" ]]; then
  SUPABASE_PROJECT_REF_VALUE="$(echo "$SUPABASE_URL_VALUE" | sed -E 's#https?://([^.]+)\.supabase\.co/?#\1#')"
fi

if [[ "$SUPABASE_PROJECT_REF_VALUE" == "$SUPABASE_URL_VALUE" ]]; then
  echo "Could not derive SUPABASE_PROJECT_REF from SUPABASE_URL." >&2
  exit 1
fi

require_var SUPABASE_ACCESS_TOKEN
require_var SUPABASE_DB_PASSWORD

if [[ -z "$SUPABASE_URL_VALUE" ]]; then
  echo "Missing SUPABASE_URL (or NEXT_PUBLIC_SUPABASE_URL)." >&2
  exit 1
fi

if [[ -z "$SUPABASE_PUBLISHABLE_VALUE" ]]; then
  echo "Missing SUPABASE_ANON_KEY/SUPABASE_PUBLISHABLE_DEFAULT_KEY." >&2
  exit 1
fi

if [[ -z "$SUPABASE_SERVICE_ROLE_VALUE" ]]; then
  echo "Missing SUPABASE_SERVICE_ROLE_KEY (or SUPABASE_SECRET_KEY)." >&2
  exit 1
fi

if [[ -z "$SUPABASE_PROJECT_REF_VALUE" ]]; then
  echo "Missing SUPABASE_PROJECT_REF and unable to infer from SUPABASE_URL." >&2
  exit 1
fi

echo "Linking project: $SUPABASE_PROJECT_REF_VALUE"
supabase link --project-ref "$SUPABASE_PROJECT_REF_VALUE" --password "$SUPABASE_DB_PASSWORD"

echo "Pushing migrations..."
supabase db push --password "$SUPABASE_DB_PASSWORD"

echo "Setting edge function secrets..."
supabase secrets set --project-ref "$SUPABASE_PROJECT_REF_VALUE" \
  SUPABASE_URL="$SUPABASE_URL_VALUE" \
  SUPABASE_SERVICE_ROLE_KEY="$SUPABASE_SERVICE_ROLE_VALUE" \
  SUPABASE_ANON_KEY="$SUPABASE_PUBLISHABLE_VALUE"

if [[ -n "${APP_BASE_URL:-}" ]]; then
  supabase secrets set --project-ref "$SUPABASE_PROJECT_REF_VALUE" APP_BASE_URL="$APP_BASE_URL"
fi

deploy_fn() {
  local fn_name="$1"
  shift
  echo "Deploying function: $fn_name"
  supabase functions deploy "$fn_name" --project-ref "$SUPABASE_PROJECT_REF_VALUE" --use-api "$@"
}

deploy_fn bootstrap-company
deploy_fn predict-maintenance-risk
deploy_fn analyze-order-risks
deploy_fn generate-esg-report
deploy_fn submit-contact-form --no-verify-jwt

echo "Supabase deploy completed for project $SUPABASE_PROJECT_REF_VALUE."
