#!/usr/bin/env bash

set -euo pipefail

if [[ ! -f ".env" ]]; then
  echo "Missing .env file. Create it from .env.example first." >&2
  exit 1
fi

set -a
# shellcheck disable=SC1091
source .env
set +a

SUPABASE_URL_VALUE="${SUPABASE_URL:-${NEXT_PUBLIC_SUPABASE_URL:-}}"
SUPABASE_PUBLISHABLE_VALUE="${SUPABASE_ANON_KEY:-${SUPABASE_PUBLISHABLE_DEFAULT_KEY:-${NEXT_PUBLIC_SUPABASE_PUBLISHABLE_DEFAULT_KEY:-}}}"

if [[ -z "$SUPABASE_URL_VALUE" || -z "$SUPABASE_PUBLISHABLE_VALUE" ]]; then
  echo "Missing Supabase URL or publishable key in .env." >&2
  exit 1
fi

flutter "$@" \
  --dart-define=SUPABASE_URL="$SUPABASE_URL_VALUE" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_PUBLISHABLE_VALUE"
