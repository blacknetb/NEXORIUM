#!/usr/bin/env bash
# =============================================================================
#  verify-schema.sh — Verifica el esquema de la BD de ESM contra el esperado
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# ---- Cargar .env ------------------------------------------------------------
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

MYSQL_CMD=(mysql --host="$DB_HOST" --port="$DB_PORT" --user="$DB_USER" --password="$DB_PASS" --batch --skip-column-names)

echo "==> Verificando esquema de '$DB_NAME' ($DB_HOST:$DB_PORT)..."
echo ""

# ---- 1. Existencia de la base de datos --------------------------------------
DB_EXISTS=$("${MYSQL_CMD[@]}" -e "SELECT COUNT(*) FROM information_schema.SCHEMATA WHERE SCHEMA_NAME = '$DB_NAME';")
if [[ "$DB_EXISTS" -eq 0 ]]; then
  echo "✗ La base de datos '$DB_NAME' NO existe."
  exit 1
fi
echo "✓ Base de datos '$DB_NAME' existe."

# ---- 2. Conteo de tablas ----------------------------------------------------
TABLE_COUNT=$("${MYSQL_CMD[@]}" -e "SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = '$DB_NAME';")
echo "✓ Tablas encontradas: $TABLE_COUNT"

if [[ "$TABLE_COUNT" -eq 0 ]]; then
  echo "✗ No hay tablas en el esquema."
  exit 1
fi

# ---- 3. Tabla de migraciones Drizzle ----------------------------------------
MIGRATIONS_TABLE=$("${MYSQL_CMD[@]}" -e "SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = '$DB_NAME' AND TABLE_NAME = '__drizzle_migrations';")
if [[ "$MIGRATIONS_TABLE" -eq 0 ]]; then
  echo "✗ Tabla '__drizzle_migrations' NO encontrada. ¿Ejecutaste las migraciones?"
  exit 1
fi

MIGRATION_COUNT=$("${MYSQL_CMD[@]}" -e "SELECT COUNT(*) FROM \`$DB_NAME\`.\`__drizzle_migrations\`;")
echo "✓ Tabla '__drizzle_migrations' existe ($MIGRATION_COUNT migraciones registradas)."

# ---- 4. Verificar motor InnoDB (necesario para FKs) -------------------------
echo ""
echo "==> Verificando motores de almacenamiento..."
NON_INNODB=$("${MYSQL_CMD[@]}" -e "SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = '$DB_NAME' AND ENGINE != 'InnoDB' AND TABLE_TYPE = 'BASE TABLE';")
if [[ "$NON_INNODB" -gt 0 ]]; then
  echo "⚠ ADVERTENCIA: $NON_INNODB tabla(s) no usan InnoDB. Las FKs podrían no funcionar."
  "${MYSQL_CMD[@]}" -e "SELECT TABLE_NAME, ENGINE FROM information_schema.TABLES WHERE TABLE_SCHEMA = '$DB_NAME' AND ENGINE != 'InnoDB' AND TABLE_TYPE = 'BASE TABLE';"
else
  echo "✓ Todas las tablas usan InnoDB."
fi

# ---- 5. Verificar charset utf8mb4 -------------------------------------------
echo ""
echo "==> Verificando charset..."
NON_UTF8=$("${MYSQL_CMD[@]}" -e "SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = '$DB_NAME' AND TABLE_COLLATION NOT LIKE 'utf8mb4%' AND TABLE_TYPE = 'BASE TABLE';")
if [[ "$NON_UTF8" -gt 0 ]]; then
  echo "⚠ ADVERTENCIA: $NON_UTF8 tabla(s) no usan utf8mb4."
else
  echo "✓ Todas las tablas usan utf8mb4."
fi

# ---- 6. Listado resumido de tablas ------------------------------------------
echo ""
echo "==> Tablas en el esquema:"
"${MYSQL_CMD[@]}" -e "SELECT TABLE_NAME, ENGINE, TABLE_COLLATION FROM information_schema.TABLES WHERE TABLE_SCHEMA = '$DB_NAME' AND TABLE_TYPE = 'BASE BASE TABLE' ORDER BY TABLE_NAME;" 2>/dev/null || \
"${MYSQL_CMD[@]}" -e "SELECT TABLE_NAME, ENGINE, TABLE_COLLATION FROM information_schema.TABLES WHERE TABLE_SCHEMA = '$DB_NAME' AND TABLE_TYPE = 'BASE TABLE' ORDER BY TABLE_NAME;"

echo ""
echo "==> Verificación de esquema completada."