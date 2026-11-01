#!/usr/bin/env bash
# =============================================================================
#  waf-regression.sh — Pruebas de regresión del WAF con OWASP ZAP
#  Uso: ./waf-regression.sh [target_url]
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

TARGET="${1:-http://localhost:3000}"
REPORT_DIR="${PROJECT_ROOT}/artifacts/waf-regression"
ZAP_RULES="${PROJECT_ROOT}/.zap/rules.tsv"

echo "==> Ejecutando pruebas de regresión WAF contra '$TARGET'..."
echo ""

# ---- 1. Verificar prerequisitos ----
if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: Docker es necesario para ejecutar ZAP." >&2
  exit 1
fi

if [[ ! -f "$ZAP_RULES" ]]; then
  echo "ADVERTENCIA: '$ZAP_RULES' no encontrado. Se usarán reglas por defecto."
  ZAP_RULES=""
fi

# ---- 2. Verificar conectividad al target ----
echo "==> Verificando conectividad a '$TARGET'..."
if ! curl -sSf --max-time 10 "$TARGET" >/dev/null 2>&1; then
  echo "ERROR: No se puede alcanzar '$TARGET'." >&2
  echo "  Asegúrate de que la aplicación esté corriendo (docker compose up)." >&2
  exit 1
fi
echo "[OK] Target alcanzable."

# ---- 3. Preparar directorio de reportes ----
mkdir -p "$REPORT_DIR"

# ---- 4. Ejecutar ZAP Baseline Scan ----
echo ""
echo "==> Ejecutando ZAP Baseline Scan..."
echo ""

DOCKER_ARGS=(
  --rm
  -v "$REPORT_DIR:/zap/wrk:rw"
  -t ghcr.io/zaproxy/zaproxy:stable
  zap-baseline.py
  -t "$TARGET"
  -r waf-regression-report.html
  -J waf-regression-report.json
  -I
)

if [[ -n "$ZAP_RULES" && -f "$ZAP_RULES" ]]; then
  DOCKER_ARGS+=(-c /zap/wrk/rules.tsv)
  cp "$ZAP_RULES" "$REPORT_DIR/rules.tsv"
fi

docker run "${DOCKER_ARGS[@]}"

EXIT_CODE=$?

echo ""
if [[ $EXIT_CODE -eq 0 ]]; then
  echo "==> Pruebas WAF completadas: no se encontraron fallos críticos."
elif [[ $EXIT_CODE -eq 1 ]]; then
  echo "==> ADVERTENCIA: Se encontraron advertencias de seguridad."
elif [[ $EXIT_CODE -eq 2 ]]; then
  echo "==> ERROR: Se encontraron fallos de seguridad críticos." >&2
else
  echo "==> ERROR: ZAP terminó con código inesperado ($EXIT_CODE)." >&2
fi

echo ""
echo "==> Reportes generados en: $REPORT_DIR"
ls -la "$REPORT_DIR"/*.html "$REPORT_DIR"/*.json 2>/dev/null || true

exit $EXIT_CODE