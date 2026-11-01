#!/usr/bin/env bash
# =============================================================================
#  setup.sh — Configura el entorno de desarrollo de ESM
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

echo "==> Configurando entorno de desarrollo de ESM..."
echo ""

# ---- 1. Verificar prerrequisitos ----
CHECK_SCRIPT="$SCRIPT_DIR/check-prerequisites.sh"
if [[ -f "$CHECK_SCRIPT" ]]; then
  bash "$CHECK_SCRIPT"
else
  echo "ADVERTENCIA: check-prerequisites.sh no encontrado, omitiendo."
fi

# ---- 2. Copiar .env si no existe ----
if [[ ! -f "$PROJECT_ROOT/.env" ]]; then
  echo "==> .env no encontrado. Copiando .env.example..."
  if [[ -f "$PROJECT_ROOT/.env.example" ]]; then
    cp "$PROJECT_ROOT/.env.example" "$PROJECT_ROOT/.env"
    echo "    .env creado a partir de .env.example. Revisa las credenciales."
  else
    echo "    ADVERTENCIA: .env.example no existe. Crea .env manualmente."
  fi
else
  echo "==> .env ya existe."
fi

# ---- 3. Instalar dependencias ----
if [[ ! -d "$PROJECT_ROOT/node_modules" ]]; then
  echo "==> Instalando dependencias npm..."
  npm install
  echo "    Aprobando scripts de esbuild/msgpackr-extract..."
  npm install-scripts approve --all
  npm rebuild esbuild
else
  echo "==> node_modules ya existe, omitiendo npm install."
fi

# ---- 4. Aviso final ----
echo ""
echo "==> Configuración completada."
echo ""
echo "Siguientes pasos:"
echo "  1. Levantar infraestructura:  ./scripts/development/start-dev.sh"
echo "  2. Aplicar migraciones:       ./scripts/database/migrate.sh"
echo "  3. Cargar datos de prueba:    ./scripts/database/seed-development.sh"
echo "  4. Ejecutar en modo dev:      npm run dev"