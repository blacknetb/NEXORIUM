<#
.SYNOPSIS
    Configura el entorno de desarrollo de ESM (PowerShell).
.DESCRIPTION
    - Verifica prerrequisitos.
    - Copia .env si no existe.
    - Instala dependencias npm si node_modules no existe.
    - Avisa si faltan scripts de esbuild por aprobar.
#>

$ErrorActionPreference = "Stop"
$ProjectRoot = Resolve-Path "$PSScriptRoot\..\.."
Set-Location $ProjectRoot

Write-Host "==> Configurando entorno de desarrollo de ESM..." -ForegroundColor Cyan
Write-Host ""

# ---- 1. Verificar prerrequisitos ----
$checkScript = Join-Path $PSScriptRoot "check-prerequisites.ps1"
if (Test-Path $checkScript) {
    & powershell -NoProfile -ExecutionPolicy Bypass -File $checkScript
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: prerrequisitos no cumplidos." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "ADVERTENCIA: check-prerequisites.ps1 no encontrado, omitiendo." -ForegroundColor Yellow
}

# ---- 2. Copiar .env si no existe ----
$envFile = Join-Path $ProjectRoot ".env"
if (-not (Test-Path $envFile)) {
    Write-Host "==> .env no encontrado. Copiando .env.example (si existe)..." -ForegroundColor Yellow
    $example = Join-Path $ProjectRoot ".env.example"
    if (Test-Path $example) {
        Copy-Item $example $envFile
        Write-Host "    .env creado a partir de .env.example. Revisa las credenciales." -ForegroundColor Green
    } else {
        Write-Host "    ADVERTENCIA: .env.example no existe. Crea .env manualmente." -ForegroundColor Yellow
    }
} else {
    Write-Host "==> .env ya existe." -ForegroundColor Green
}

# ---- 3. Instalar dependencias ----
$nodeModules = Join-Path $ProjectRoot "node_modules"
if (-not (Test-Path $nodeModules)) {
    Write-Host "==> Instalando dependencias npm..." -ForegroundColor Yellow
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: npm install falló." -ForegroundColor Red
        exit 1
    }
    Write-Host "    Aprobando scripts de esbuild/msgpackr-extract..." -ForegroundColor Yellow
    npm install-scripts approve --all
    npm rebuild esbuild
} else {
    Write-Host "==> node_modules ya existe, omitiendo npm install." -ForegroundColor Green
}

# ---- 4. Aviso final ----
Write-Host ""
Write-Host "==> Configuración completada." -ForegroundColor Green
Write-Host ""
Write-Host "Siguientes pasos:" -ForegroundColor Cyan
Write-Host "  1. Levantar infraestructura:  .\scripts\development\start-dev.ps1"
Write-Host "  2. Aplicar migraciones:       .\scripts\database\migrate.ps1"
Write-Host "  3. Cargar datos de prueba:    bash scripts/database/seed-development.sh"
Write-Host "  4. Ejecutar en modo dev:      npm run dev"