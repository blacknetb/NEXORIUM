#!/usr/bin/env bash
# =============================================================================
#  seed-development.sh — Carga datos de desarrollo en la BD de ESM
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
API_DIR="$PROJECT_ROOT/apps/api"

# ---- Cargar .env raíz -------------------------------------------------------
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

# ---- Seguridad: no ejecutar en producción ----------------------------------
if [[ "${NODE_ENV:-development}" == "production" ]]; then
  echo "ERROR: seed-development.sh no debe ejecutarse en producción."
  exit 1
fi

echo "==> Verificando prerequisitos..."
[[ -d "$API_DIR" ]] || { echo "ERROR: no existe $API_DIR"; exit 1; }
command -v npx >/dev/null 2>&1 || { echo "ERROR: npx no disponible"; exit 1; }

# ---- Ejecutar seeder --------------------------------------------------------
echo "==> Cargando datos de desarrollo en '$DB_NAME' ($DB_HOST:$DB_PORT)..."
export NODE_ENV=development
export DATABASE_URL="mysql://${DB_USER}:${DB_PASS}@${DB_HOST}:${DB_PORT}/${DB_NAME}"

cd "$API_DIR"
npx tsx src/db/seed.ts

echo "==> Datos de desarrollo cargados correctamente."