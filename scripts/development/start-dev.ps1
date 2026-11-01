<#
.SYNOPSIS
    Levanta los servicios de infraestructura para desarrollo (MySQL + Redis + Adminer).
.DESCRIPTION
    - Verifica que Docker esté en ejecución.
    - Levanta los contenedores con compose.dev.yaml.
    - Espera a que MySQL esté healthy.
    - Muestra las URLs y credenciales.
#>

$ErrorActionPreference = "Stop"
$ProjectRoot = Resolve-Path "$PSScriptRoot\..\.."
Set-Location $ProjectRoot

Write-Host "==> Iniciando servicios de desarrollo de ESM..." -ForegroundColor Cyan
Write-Host ""

# ---- 1. Verificar Docker en ejecución ----
try {
    docker info 2>&1 | Out-Null
} catch {
    Write-Host "ERROR: Docker no está en ejecución. Inicia Docker Desktop." -ForegroundColor Red
    exit 1
}

# ---- 2. Levantar contenedores ----
Write-Host "==> Levantando contenedores (MySQL, Redis, Adminer)..." -ForegroundColor Yellow
docker compose -f compose.yaml -f compose.dev.yaml up -d

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: docker compose up falló." -ForegroundColor Red
    exit 1
}

# ---- 3. Esperar a que MySQL esté healthy ----
Write-Host "==> Esperando a que MySQL esté healthy..." -ForegroundColor Yellow
$maxWait = 60
$waited = 0
$healthy = $false

while ($waited -lt $maxWait) {
    $status = docker inspect --format='{{.State.Health.Status}}' esm-mysql-dev 2>$null
    if ($status -eq "healthy") {
        $healthy = $true
        break
    }
    Start-Sleep -Seconds 2
    $waited += 2
}

if ($healthy) {
    Write-Host "    MySQL está healthy." -ForegroundColor Green
} else {
    Write-Host "    ADVERTENCIA: MySQL no reportó healthy en $maxWait s. Revisa: docker logs esm-mysql-dev" -ForegroundColor Yellow
}

# ---- 4. Mostrar información ----
Write-Host ""
Write-Host "==> Servicios disponibles:" -ForegroundColor Cyan
Write-Host "    MySQL:     localhost:3306  (usuario: ADMIN, DB: esm_db)" -ForegroundColor White
Write-Host "    Redis:     localhost:6379" -ForegroundColor White
Write-Host "    Adminer:   http://localhost:8080" -ForegroundColor White
Write-Host ""
Write-Host "    Adminer -> Sistema: MySQL, Servidor: mysql, Usuario: ADMIN, DB: esm_db" -ForegroundColor Gray
Write-Host ""
Write-Host "==> Siguiente paso: aplicar migraciones con .\scripts\database\migrate.ps1" -ForegroundColor Cyan