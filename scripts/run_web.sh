#!/usr/bin/env bash
# Run Flutter web with Supabase compile-time env from .env (see .env.example).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [[ -f .env ]]; then
  set -a
  # shellcheck source=/dev/null
  source .env
  set +a
fi

SUPABASE_URL_EFFECTIVE="${SUPABASE_URL:-${NEXT_PUBLIC_SUPABASE_URL:-}}"
SUPABASE_KEY_EFFECTIVE="${SUPABASE_ANON_KEY:-${SUPABASE_PUBLISHABLE_DEFAULT_KEY:-${NEXT_PUBLIC_SUPABASE_PUBLISHABLE_DEFAULT_KEY:-${NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY:-}}}}"

if [[ -z "$SUPABASE_URL_EFFECTIVE" || -z "$SUPABASE_KEY_EFFECTIVE" ]]; then
  echo "Supabase non configurato per Flutter: mancano URL o chiave anonima." >&2
  echo "Copia .env.example in .env e imposta almeno SUPABASE_URL e SUPABASE_ANON_KEY" >&2
  echo "(oppure NEXT_PUBLIC_SUPABASE_URL e NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY)." >&2
  exit 1
fi

DEVICE="${FLUTTER_DEVICE:-chrome}"
exec flutter run -d "$DEVICE" \
  --dart-define=SUPABASE_URL="$SUPABASE_URL_EFFECTIVE" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_KEY_EFFECTIVE" \
  "$@"
