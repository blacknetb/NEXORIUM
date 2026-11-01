#!/usr/bin/env bash
# =============================================================================
#  secret-scan.sh — Escanea secretos en el repositorio con Gitleaks
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

echo "==> Escaneando secretos en el repositorio..."
echo ""

# ---- Verificar que Gitleaks está instalado ----
if ! command -v gitleaks >/dev/null 2>&1; then
  echo "ADVERTENCIA: Gitleaks no está instalado. Intentando vía Docker..."

  if command -v docker >/dev/null 2>&1; then
    echo "==> Usando Gitleaks vía Docker..."
    docker run --rm -v "$PROJECT_ROOT:/repo" \
      zricethezav/gitleaks:latest detect \
      --source=/repo \
      --verbose \
      --report-format=json \
      --report-path=/repo/gitleaks-report.json

    EXIT_CODE=$?
  else
    echo "ERROR: Ni Gitleaks ni Docker están disponibles." >&2
    echo "  Instala Gitleaks: https://github.com/gitleaks/gitleaks#installing" >&2
    exit 1
  fi
else
  echo "==> Usando Gitleaks local..."
  gitleaks detect \
    --source=. \
    --verbose \
    --report-format=json \
    --report-path=gitleaks-report.json

  EXIT_CODE=$?
fi

echo ""
if [[ $EXIT_CODE -eq 0 ]]; then
  echo "==> No se encontraron secretos."
  rm -f gitleaks-report.json
else
  echo "==> ERROR: Se encontraron posibles secretos en el código." >&2
  echo "    Revisa el reporte: gitleaks-report.json" >&2
  echo "    Para ignorar un falso positivo, añade el fingerprint a .gitleaksignore" >&2
fi

exit $EXIT_CODE