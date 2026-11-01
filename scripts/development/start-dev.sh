#!/usr/bin/env bash
# =============================================================================
#  start-dev.sh — Levanta servicios de infraestructura para desarrollo
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

echo "==> Iniciando servicios de desarrollo de ESM..."
echo ""

# ---- 1. Verificar Docker ----
if ! docker info >/dev/null 2>&1; then
  echo "ERROR: Docker no está en ejecución. Inicia Docker Desktop o el daemon." >&2
  exit 1
fi

# ---- 2. Levantar contenedores ----
echo "==> Levantando contenedores (MySQL, Redis, Adminer)..."
docker compose -f compose.yaml -f compose.dev.yaml up -d

if [[ $? -ne 0 ]]; then
  echo "ERROR: docker compose up falló." >&2
  exit 1
fi

# ---- 3. Esperar a que MySQL esté healthy ----
echo "==> Esperando a que MySQL esté healthy..."
MAX_WAIT=60
WAITED=0
HEALTHY=false

while [[ $WAITED -lt $MAX_WAIT ]]; do
  STATUS=$(docker inspect --format='{{.State.Health.Status}}' esm-mysql-dev 2>/dev/null || echo "unknown")
  if [[ "$STATUS" == "healthy" ]]; then
    HEALTHY=true
    break
  fi
  sleep 2
  WAITED=$((WAITED + 2))
done

if [[ "$HEALTHY" == "true" ]]; then
  echo "    MySQL está healthy."
else
  echo "    ADVERTENCIA: MySQL no reportó healthy en ${MAX_WAIT}s. Revisa: docker logs esm-mysql-dev"
fi

# ---- 4. Mostrar información ----
echo ""
echo "==> Servicios disponibles:"
echo "    MySQL:     localhost:3306  (usuario: ADMIN, DB: esm_db)"
echo "    Redis:     localhost:6379"
echo "    Adminer:   http://localhost:8080"
echo ""
echo "    Adminer -> Sistema: MySQL, Servidor: mysql, Usuario: ADMIN, DB: esm_db"
echo ""
echo "==> Siguiente paso: aplicar migraciones con ./scripts/database/migrate.sh"