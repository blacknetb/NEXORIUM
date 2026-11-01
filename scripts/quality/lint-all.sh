#!/usr/bin/env bash
# =============================================================================
#  lint-all.sh — Ejecuta ESLint en todos los workspaces del monorepo
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

echo "==> Ejecutando lint en todos los workspaces..."
echo ""

if ! command -v npx >/dev/null 2>&1; then
  echo "ERROR: npx no disponible." >&2
  exit 1
fi

# Ejecutar lint vía Turbo (todos los workspaces)
npx turbo run lint

EXIT_CODE=$?

if [[ $EXIT_CODE -eq 0 ]]; then
  echo ""
  echo "==> Lint completado sin errores."
else
  echo ""
  echo "==> ERROR: Lint falló en uno o más workspaces." >&2
fi

exit $EXIT_CODE