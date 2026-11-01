#!/usr/bin/env bash
# =============================================================================
#  migrate.sh — Aplica migraciones Drizzle Kit para ESM (MySQL)
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
API_DIR="$PROJECT_ROOT/apps/api"

# ---- Cargar .env raíz si existe --------------------------------------------
if [[ -f "$PROJECT_ROOT/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "$PROJECT_ROOT/.env"
  set +a
fi

DB_HOST="${MYSQL_HOST:-localhost}"
DB_PORT="${MYSQL_PORT:-3306}"
DB_NAME="${MYSQL_DATABASE:-esm_db}"
DB_USER="${MYSQL_USER:-ADMIN}"
DB_PASS="${MYSQL_PASSWORD:-J-admin-crfenix55}"

# ---- Validaciones -----------------------------------------------------------
echo "==> Verificando prerequisitos..."
[[ -d "$API_DIR" ]] || { echo "ERROR: no existe $API_DIR"; exit 1; }
command -v npx >/dev/null 2>&1 || { echo "ERROR: npx no disponible"; exit 1; }

# ---- Ejecutar migraciones ---------------------------------------------------
echo "==> Aplicando migraciones Drizzle en '$DB_NAME' ($DB_HOST:$DB_PORT)..."
export DATABASE_URL="mysql://${DB_USER}:${DB_PASS}@${DB_HOST}:${DB_PORT}/${DB_NAME}"

cd "$API_DIR"
npx drizzle-kit migrate

echo "==> Migraciones aplicadas correctamente."