#!/usr/bin/env bash
# =============================================================================
#  test-all.sh — Ejecuta todos los tests del monorepo
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

echo "==> Ejecutando tests en todos los workspaces..."
echo ""

if ! command -v npx >/dev/null 2>&1; then
  echo "ERROR: npx no disponible." >&2
  exit 1
fi

# Tests unitarios
echo "--- Tests unitarios ---"
npx turbo run test
UNIT_EXIT=$?

# Tests de integración (si existen)
echo ""
echo "--- Tests de integración ---"
if npx turbo run test:integration --dry-run 2>/dev/null | grep -q "test:integration"; then
  npx turbo run test:integration
  INTEGRATION_EXIT=$?
else
  echo "    (No hay tarea test:integration configurada, omitiendo)"
  INTEGRATION_EXIT=0
fi

echo ""
if [[ $UNIT_EXIT -eq 0 && $INTEGRATION_EXIT -eq 0 ]]; then
  echo "==> Todos los tests pasaron."
  exit 0
else
  echo "==> ERROR: Algunos tests fallaron." >&2
  exit 1
fi