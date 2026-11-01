#!/usr/bin/env bash
# =============================================================================
#  verify-restore.sh — Restaura un backup SQL y verifica integridad
#  Uso: ./verify-restore.sh <archivo_backup.sql> [base_de_datos_destino]
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# ---- Argumentos -------------------------------------------------------------
BACKUP_FILE="${1:-}"
TARGET_DB="${2:-}"

if [[ -z "$BACKUP_FILE" ]]; then
  echo "Uso: $0 <archivo_backup.sql> [base_de_datos_destino]"
  exit 1
fi

if [[ ! -f "$BACKUP_FILE" ]]; then
  echo "ERROR: no existe el archivo '$BACKUP_FILE'"
  exit 1
fi

# ---- Cargar .env ------------------------------------------------------------
if [[ -f "$PROJECT_ROOT/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "$PROJECT_ROOT/.env"
  set +a
fi

DB_HOST="${MYSQL_HOST:-localhost}"
DB_PORT="${MYSQL_PORT:-3306}"
DB_USER="${MYSQL_USER:-ADMIN}"
DB_PASS="${MYSQL_PASSWORD:-J-admin-crfenix55}"
DB_NAME="${TARGET_DB:-${MYSQL_DATABASE:-esm_db}}"

# ---- Advertir si se restaura sobre la BD de desarrollo ---------------------
if [[ "$DB_NAME" == "${MYSQL_DATABASE:-esm_db}" ]]; then
  echo "ADVERTENCIA: vas a restaurar sobre la base de datos '$DB_NAME'."
  read -r -p "¿Continuar? [y/N] " confirm
  [[ "$confirm" =~ ^[yY]$ ]] || { echo "Cancelado."; exit 1; }
fi

# ---- Ejecutar restauración --------------------------------------------------
echo "==> Restaurando '$BACKUP_FILE' en '$DB_NAME'..."
mysql \
  --host="$DB_HOST" \
  --port="$DB_PORT" \
  --user="$DB_USER" \
  --password="$DB_PASS" \
  "$DB_NAME" < "$BACKUP_FILE"

if [[ $? -ne 0 ]]; then
  echo "ERROR: falló la restauración."
  exit 1
fi

# ---- Verificación post-restauración -----------------------------------------
echo "==> Verificando restauración..."

TABLE_COUNT=$(mysql \
  --host="$DB_HOST" \
  --port="$DB_PORT" \
  --user="$DB_USER" \
  --password="$DB_PASS" \
  --batch --skip-column-names \
  -e "SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = '$DB_NAME';")

echo "    Tablas encontradas: $TABLE_COUNT"

if [[ "$TABLE_COUNT" -eq 0 ]]; then
  echo "ERROR: la base de datos '$DB_NAME' no contiene tablas tras la restauración."
  exit 1
fi

# Verificar tabla de migraciones Drizzle
DRIZZLE_LOG=$(mysql \
  --host="$DB_HOST" \
  --port="$DB_PORT" \
  --user="$DB_USER" \
  --password="$DB_PASS" \
  --batch --skip-column-names \
  -e "SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = '$DB_NAME' AND TABLE_NAME = '__drizzle_migrations';")

if [[ "$DRIZZLE_LOG" -gt 0 ]]; then
  MIGRATION_COUNT=$(mysql \
    --host="$DB_HOST" \
    --port="$DB_PORT" \
    --user="$DB_USER" \
    --password="$DB_PASS" \
    --batch --skip-column-names \
    -e "SELECT COUNT(*) FROM \`$DB_NAME\`.\`__drizzle_migrations\`;")
  echo "    Migraciones registradas: $MIGRATION_COUNT"
else
  echo "    ADVERTENCIA: tabla __drizzle_migrations no encontrada."
fi

echo "==> Restauración y verificación completadas correctamente."