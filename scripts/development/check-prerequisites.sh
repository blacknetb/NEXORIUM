#!/usr/bin/env bash
# =============================================================================
#  check-prerequisites.sh — Verifica prerrequisitos para ESM
# =============================================================================
set -euo pipefail

echo "==> Verificando prerrequisitos de ESM..."
echo ""

MISSING=()

# ---- Node.js ----
if command -v node >/dev/null 2>&1; then
  NODE_VER=$(node -v | sed 's/^v//')
  NODE_MAJOR=$(echo "$NODE_VER" | cut -d. -f1)
  if [[ "$NODE_MAJOR" -ge 20 ]]; then
    echo "  [OK]   Node.js v$NODE_VER (>= 20)"
  else
    echo "  [FAIL] Node.js v$NODE_VER (se requiere >= 20)"
    MISSING+=("Node.js >= 20")
  fi
else
  echo "  [FAIL] Node.js no encontrado"
  MISSING+=("Node.js >= 20")
fi

# ---- npm ----
if command -v npm >/dev/null 2>&1; then
  NPM_VER=$(npm -v)
  NPM_MAJOR=$(echo "$NPM_VER" | cut -d. -f1)
  if [[ "$NPM_MAJOR" -ge 10 ]]; then
    echo "  [OK]   npm v$NPM_VER (>= 10)"
  else
    echo "  [FAIL] npm v$NPM_VER (se requiere >= 10)"
    MISSING+=("npm >= 10")
  fi
else
  echo "  [FAIL] npm no encontrado"
  MISSING+=("npm >= 10")
fi

# ---- Docker ----
if command -v docker >/dev/null 2>&1; then
  DOCKER_VER=$(docker --version 2>/dev/null | head -1)
  echo "  [OK]   $DOCKER_VER"
else
  echo "  [FAIL] Docker no encontrado"
  MISSING+=("Docker")
fi

# ---- Docker Compose ----
if docker compose version >/dev/null 2>&1; then
  COMPOSE_VER=$(docker compose version --short 2>/dev/null || docker compose version 2>/dev/null | head -1)
  echo "  [OK]   Docker Compose $COMPOSE_VER"
else
  echo "  [FAIL] Docker Compose no encontrado"
  MISSING+=("Docker Compose")
fi

# ---- Git ----
if command -v git >/dev/null 2>&1; then
  GIT_VER=$(git --version)
  echo "  [OK]   $GIT_VER"
else
  echo "  [FAIL] Git no encontrado"
  MISSING+=("Git")
fi

echo ""
if [[ ${#MISSING[@]} -gt 0 ]]; then
  echo "==> Faltan los siguientes prerrequisitos:" >&2
  printf '    - %s\n' "${MISSING[@]}" >&2
  exit 1
else
  echo "==> Todos los prerrequisitos están OK."
  exit 0
fi