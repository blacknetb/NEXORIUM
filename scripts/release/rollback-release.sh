#!/usr/bin/env bash
# =============================================================================
#  rollback-release.sh — Revierte un release (tag + commit de versión)
#  Uso: ./rollback-release.sh <version> [--force]
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

VERSION="${1:-}"
FORCE="${2:-}"

if [[ -z "$VERSION" ]]; then
  echo "Uso: $0 <version> [--force]"
  echo "Ejemplo: $0 0.2.0"
  exit 1
fi

TAG="v$VERSION"

echo "==> Preparando rollback de $TAG..."
echo ""

# ---- 1. Verificar que el tag existe ----
if ! git rev-parse "$TAG" >/dev/null 2>&1; then
  echo "ERROR: El tag '$TAG' no existe." >&2
  exit 1
fi
echo "[OK] Tag '$TAG' encontrado."

# ---- 2. Confirmar rollback ----
if [[ "$FORCE" != "--force" ]]; then
  echo ""
  echo "ADVERTENCIA: Esta acción eliminará el tag local y remoto '$TAG'."
  echo "             NO elimina commits ni revierte código automáticamente."
  read -r -p "¿Continuar? [y/N] " confirm
  [[ "$confirm" =~ ^[yY]$ ]] || { echo "Cancelado."; exit 1; }
fi

# ---- 3. Verificar si el tag está pusheado ----
REMOTE_EXISTS=$(git ls-remote --tags origin "refs/tags/$TAG" 2>/dev/null | wc -l | tr -d ' ')
if [[ "$REMOTE_EXISTS" -gt 0 ]]; then
  echo "==> El tag '$TAG' existe en remoto. Eliminando..."
  git push origin ":refs/tags/$TAG" || echo "ADVERTENCIA: no se pudo eliminar tag remoto."
fi

# ---- 4. Eliminar tag local ----
echo "==> Eliminando tag local '$TAG'..."
git tag -d "$TAG"

# ---- 5. Revertir commit de release (opcional) ----
if git log -1 --format='%s' | grep -q "chore(release): $TAG"; then
  echo ""
  echo "==> El último commit es el release. Revirtiendo..."
  if [[ "$FORCE" == "--force" ]]; then
    git reset --hard HEAD~1
    echo "[OK] Commit revertido (hard reset)."
  else
    read -r -p "¿Revertir también el commit de release? [y/N] " confirm
    if [[ "$confirm" =~ ^[yY]$ ]]; then
      git reset --hard HEAD~1
      echo "[OK] Commit revertido."
    else
      echo "[SKIP] Commit conservado."
    fi
  fi
fi

echo ""
echo "==> Rollback de $TAG completado."