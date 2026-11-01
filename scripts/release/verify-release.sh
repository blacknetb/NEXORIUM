#!/usr/bin/env bash
# =============================================================================
#  verify-release.sh — Verifica la integridad de un release
#  Uso: ./verify-release.sh <version>
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

VERSION="${1:-}"

if [[ -z "$VERSION" ]]; then
  echo "Uso: $0 <version>"
  echo "Ejemplo: $0 0.2.0"
  exit 1
fi

TAG="v$VERSION"
ERRORS=0

echo "==> Verificando release $TAG..."
echo ""

# ---- 1. Tag existe localmente ----
if git rev-parse "$TAG" >/dev/null 2>&1; then
  echo "[OK] Tag '$TAG' existe localmente."
else
  echo "[FAIL] Tag '$TAG' NO existe localmente." >&2
  ERRORS=$((ERRORS + 1))
fi

# ---- 2. Tag existe en remoto ----
if git ls-remote --tags origin "refs/tags/$TAG" 2>/dev/null | grep -q "$TAG"; then
  echo "[OK] Tag '$TAG' existe en remoto."
else
  echo "[WARN] Tag '$TAG' NO existe en remoto (¿hiciste push?)."
fi

# ---- 3. Versión en package.json coincide ----
PKG_VERSION=$(node -p "require('./package.json').version" 2>/dev/null || echo "unknown")
if [[ "$PKG_VERSION" == "$VERSION" ]]; then
  echo "[OK] Versión en package.json coincide ($PKG_VERSION)."
else
  echo "[FAIL] Versión en package.json es '$PKG_VERSION', esperada '$VERSION'." >&2
  ERRORS=$((ERRORS + 1))
fi

# ---- 4. Entrada en CHANGELOG ----
if grep -q "\[$VERSION\]" CHANGELOG.md 2>/dev/null; then
  echo "[OK] Entrada de versión encontrada en CHANGELOG.md."
else
  echo "[WARN] No se encontró entrada para '$VERSION' en CHANGELOG.md."
fi

# ---- 5. Commit del tag es alcanzable ----
if git merge-base --is-ancestor "$TAG" HEAD 2>/dev/null; then
  echo "[OK] El tag es alcanzable desde HEAD."
else
  echo "[FAIL] El tag NO es alcanzable desde HEAD." >&2
  ERRORS=$((ERRORS + 1))
fi

echo ""
if [[ $ERRORS -eq 0 ]]; then
  echo "==> Verificación de release $TAG completada sin errores."
  exit 0
else
  echo "==> ERROR: $ERRORS problema(s) encontrado(s)." >&2
  exit 1
fi