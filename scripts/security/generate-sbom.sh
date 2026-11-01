#!/usr/bin/env bash
# =============================================================================
#  generate-sbom.sh — Genera un SBOM (Software Bill of Materials) con Syft
#  Uso: ./generate-sbom.sh [formato] [destino]
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

FORMAT="${1:-spdx-json}"
OUTPUT="${2:-sbom.${FORMAT#*-}.json}"
OUTPUT_DIR="${PROJECT_ROOT}/artifacts/sbom"

echo "==> Generando SBOM (formato: $FORMAT)..."
echo ""

mkdir -p "$OUTPUT_DIR"
OUTPUT_PATH="${OUTPUT_DIR}/${OUTPUT}"

# ---- Opción A: Syft (recomendado si está instalado) ----
if command -v syft >/dev/null 2>&1; then
  echo "==> Usando Syft..."
  syft dir:. -o "$FORMAT" > "$OUTPUT_PATH"
  echo "[OK] SBOM generado: $OUTPUT_PATH"
  echo ""
  echo "    Tamaño: $(du -h "$OUTPUT_PATH" | cut -f1)"
  echo "    Paquetes: $(jq '.packages | length' "$OUTPUT_PATH" 2>/dev/null || echo 'N/A')"
  exit 0
fi

# ---- Opción B: Docker BuildKit (si hay Dockerfile) ----
if command -v docker >/dev/null 2>&1 && [[ -f "Dockerfile" ]]; then
  echo "==> Syft no disponible. Usando Docker BuildKit (--sbom=true)..."
  docker buildx build \
    --sbom=true \
    --output type=local,dest="$OUTPUT_DIR" \
    . 2>/dev/null || {
    echo "ERROR: Docker BuildKit SBOM falló." >&2
    exit 1
  }
  echo "[OK] SBOM generado en: $OUTPUT_DIR"
  ls -la "$OUTPUT_DIR"/sbom*.json 2>/dev/null || true
  exit 0
fi

# ---- Opción C: Fallback con npm ----
echo "==> Syft y Docker BuildKit no disponibles. Generando SBOM básico con npm..."
if command -v npx >/dev/null 2>&1; then
  npx --yes @cyclonedx/cyclonedx-npm --output-file "$OUTPUT_PATH" 2>/dev/null || {
    echo "ADVERTENCIA: cyclonedx-npm falló. Generando lista simple..."
    npm ls --all --json > "$OUTPUT_PATH" 2>/dev/null || true
  }
  echo "[OK] SBOM (básico) generado: $OUTPUT_PATH"
  exit 0
fi

echo "ERROR: No hay herramienta disponible para generar SBOM." >&2
echo "  Instala Syft: https://github.com/anchore/syft#installation" >&2
exit 1