#!/usr/bin/env bash
# =============================================================================
#  prepare-release.sh — Prepara un release (versión, changelog, commit, tag)
#  Uso: ./prepare-release.sh <version> [--dry-run]
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

VERSION="${1:-}"
DRY_RUN="${2:-}"

if [[ -z "$VERSION" ]]; then
  echo "Uso: $0 <version> [--dry-run]"
  echo "Ejemplo: $0 0.2.0"
  exit 1
fi

# Validar formato semántico (ej. 1.2.3, 1.2.3-beta.1)
if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?$ ]]; then
  echo "ERROR: Versión '$VERSION' no es semántica válida (ej. 0.2.0, 1.0.0-beta.1)." >&2
  exit 1
fi

echo "==> Preparando release v$VERSION..."
echo ""

# ---- 1. Verificar estado limpio de git ----
if [[ -n "$(git status --porcelain)" ]]; then
  echo "ERROR: Hay cambios sin commitear. Haz commit o stash antes de continuar." >&2
  git status --short
  exit 1
fi
echo "[OK] Working tree limpio."

# ---- 2. Verificar rama actual ----
CURRENT_BRANCH=$(git branch --show-current)
if [[ "$CURRENT_BRANCH" != "main" && "$CURRENT_BRANCH" != "develop" ]]; then
  echo "ADVERTENCIA: Estás en la rama '$CURRENT_BRANCH' (recomendado: main o develop)."
  read -r -p "¿Continuar? [y/N] " confirm
  [[ "$confirm" =~ ^[yY]$ ]] || { echo "Cancelado."; exit 1; }
fi
echo "[OK] Rama: $CURRENT_BRANCH"

# ---- 3. Verificar que los tests pasan ----
echo ""
echo "==> Ejecutando verificación previa (lint + typecheck + test)..."
if [[ "$DRY_RUN" != "--dry-run" ]]; then
  npm run lint
  npm run typecheck
  npm run test
else
  echo "    (Modo dry-run: omitiendo verificación)"
fi

# ---- 4. Actualizar versión en package.json raíz ----
echo ""
echo "==> Actualizando versión en package.json..."
if [[ "$DRY_RUN" != "--dry-run" ]]; then
  npm version "$VERSION" --no-git-tag-version
fi
echo "[OK] Versión actualizada a $VERSION"

# ---- 5. Generar entrada de CHANGELOG ----
echo ""
echo "==> Generando CHANGELOG..."
CHANGELOG="CHANGELOG.md"
DATE=$(date +%Y-%m-%d)

if [[ ! -f "$CHANGELOG" ]]; then
  echo "# Changelog" > "$CHANGELOG"
  echo "" >> "$CHANGELOG"
fi

# Insertar nueva entrada después de la línea "# Changelog"
TEMP_FILE=$(mktemp)
awk -v version="$VERSION" -v date="$DATE" '
  /^# Changelog$/ {
    print
    print ""
    print "## [" version "] - " date
    print ""
    print "### Added"
    print "- (ver commits)"
    print ""
    print "### Changed"
    print "- (ver commits)"
    print ""
    print "### Fixed"
    print "- (ver commits)"
    print ""
    next
  }
  { print }
' "$CHANGELOG" > "$TEMP_FILE"
mv "$TEMP_FILE" "$CHANGELOG"

echo "[OK] CHANGELOG actualizado."

# ---- 6. Commit y tag ----
if [[ "$DRY_RUN" == "--dry-run" ]]; then
  echo ""
  echo "==> DRY-RUN: no se crean commit ni tag."
  echo "    Commit sería: chore(release): v$VERSION"
  echo "    Tag sería:    v$VERSION"
else
  echo ""
  echo "==> Creando commit y tag..."
  git add package.json "$CHANGELOG"
  git commit -m "chore(release): v$VERSION"
  git tag -a "v$VERSION" -m "Release v$VERSION"
  echo "[OK] Commit y tag creados."
  echo ""
  echo "==> Siguiente paso:"
  echo "    git push origin $CURRENT_BRANCH --follow-tags"
fi

echo ""
echo "==> Preparación de release v$VERSION completada."