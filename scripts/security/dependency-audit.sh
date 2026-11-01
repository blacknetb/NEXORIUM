#!/usr/bin/env bash
# =============================================================================
#  dependency-audit.sh — Audita dependencias con npm audit
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

echo "==> Auditando dependencias (npm audit)..."
echo ""

# ---- 1. npm audit (todas las severidades) ----
echo "--- npm audit ---"
npm audit --audit-level=moderate

NPM_AUDIT_EXIT=$?

# ---- 2. Verificar licencias (opcional con license-checker) ----
if command -v npx >/dev/null 2>&1 && npx --yes license-checker --version >/dev/null 2>&1; then
  echo ""
  echo "--- Verificación de licencias ---"
  npx --yes license-checker --summary --failOn "GPL-3.0;AGPL-3.0" 2>/dev/null || {
    echo "ADVERTENCIA: Se encontraron dependencias con licencias restrictivas."
  }
else
  echo ""
  echo "    (license-checker no disponible, omitiendo)"
fi

echo ""
if [[ $NPM_AUDIT_EXIT -eq 0 ]]; then
  echo "==> Auditoría de dependencias completada sin vulnerabilidades moderadas o superiores."
  exit 0
else
  echo "==> ERROR: Se encontraron vulnerabilidades en dependencias." >&2
  exit 1
fi