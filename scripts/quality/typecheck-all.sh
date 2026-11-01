#!/usr/bin/env bash
# =============================================================================
#  typecheck-all.sh — Ejecuta verificación de tipos en todos los workspaces
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

echo "==> Ejecutando typecheck en todos los workspaces..."
echo ""

if ! command -v npx >/dev/null 2>&1; then
  echo "ERROR: npx no disponible." >&2
  exit 1
fi

# Ejecutar typecheck vía Turbo
npx turbo run typecheck

EXIT_CODE=$?

if [[ $EXIT_CODE -eq 0 ]]; then
  echo ""
  echo "==> Typecheck completado sin errores."
else
  echo ""
  echo "==> ERROR: Typecheck falló en uno o más workspaces." >&2
fi

exit $EXIT_CODE