#!/usr/bin/env bash
# Sblocca "Waiting for another flutter command to release the startup lock..."
# (es. dopo Ctrl+Z su flutter run). Esegui dalla root del progetto: ./scripts/flutter_unlock.sh
set -euo pipefail

echo "Termino processi Flutter/Dart (se presenti)…"
pkill -9 -f "flutter_tools.snapshot" 2>/dev/null || true
killall -9 dart 2>/dev/null || true

FLUTTER_BIN="$(command -v flutter 2>/dev/null || true)"
if [[ -n "$FLUTTER_BIN" ]]; then
  FLUTTER_ROOT="$(cd "$(dirname "$FLUTTER_BIN")/.." && pwd)"
  LOCK="$FLUTTER_ROOT/bin/cache/lockfile"
  if [[ -e "$LOCK" ]]; then
    rm -f "$LOCK"
    echo "Rimosso lock SDK: $LOCK"
  else
    echo "Nessun file lock SDK (ok): $LOCK"
  fi
else
  echo "Comando 'flutter' non in PATH: salto rimozione lock SDK."
fi

echo "Fatto. Rilancia: ./scripts/run_web.sh  oppure  flutter run -d chrome …"
