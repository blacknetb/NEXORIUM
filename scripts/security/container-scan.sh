#!/usr/bin/env bash
# =============================================================================
#  container-scan.sh — Escanea imágenes Docker con Trivy
#  Uso: ./container-scan.sh [imagen:tag] [severidad]
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

IMAGE="${1:-esm-api:latest}"
SEVERITY="${2:-CRITICAL,HIGH}"

echo "==> Escaneando imagen '$IMAGE' (severidad: $SEVERITY)..."
echo ""

# Verificar que Trivy está instalado
if ! command -v trivy >/dev/null 2>&1; then
  echo "ERROR: Trivy no está instalado." >&2
  echo "  Instalación: https://aquasecurity.github.io/trivy/latest/getting-started/installation/" >&2
  exit 1
fi

# Verificar que la imagen existe localmente
if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
  echo "ADVERTENCIA: La imagen '$IMAGE' no existe localmente. Intentando pull..."
  docker pull "$IMAGE" || {
    echo "ERROR: No se pudo obtener la imagen '$IMAGE'." >&2
    exit 1
  }
fi

# Ejecutar escaneo
echo "==> Ejecutando Trivy..."
trivy image \
  --severity "$SEVERITY" \
  --exit-code 1 \
  --ignore-unfixed \
  --format table \
  "$IMAGE"

EXIT_CODE=$?

echo ""
if [[ $EXIT_CODE -eq 0 ]]; then
  echo "==> Escaneo completado: no se encontraron vulnerabilidades de severidad $SEVERITY."
else
  echo "==> ERROR: Se encontraron vulnerabilidades de severidad $SEVERITY en '$IMAGE'." >&2
fi

exit $EXIT_CODE