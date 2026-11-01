#!/usr/bin/env bash
# =============================================================================
#  format-check.sh — Verifica el formato de código con Prettier
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

echo "==> Verificando formato con Prettier..."
echo ""

if ! command -v npx >/dev/null 2>&1; then
  echo "ERROR: npx no disponible." >&2
  exit 1
fi

# Verificar que existe la configuración de Prettier
if [[ ! -f ".prettierrc.json" ]]; then
  echo "ADVERTENCIA: .prettierrc.json no encontrado en la raíz."
fi

# Ejecutar Prettier en modo check (no modifica archivos)
npx prettier --check "**/*.{ts,tsx,js,jsx,json,md,yml,yaml}"

EXIT_CODE=$?

if [[ $EXIT_CODE -eq 0 ]]; then
  echo ""
  echo "==> Formato correcto."
else
  echo ""
  echo "==> ERROR: Hay archivos con formato incorrecto." >&2
  echo "    Ejecuta 'npm run format' para corregirlos automáticamente." >&2
fi

exit $EXIT_CODE