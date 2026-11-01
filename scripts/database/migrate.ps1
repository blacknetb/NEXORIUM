<#
.SYNOPSIS
    Ejecuta las migraciones de base de datos para ESM usando Drizzle Kit.
.DESCRIPTION
    Aplica las migraciones generadas por Drizzle Kit al esquema de MySQL.
    Requiere que el contenedor MySQL (esm-mysql-dev) esté healthy y que
    las migraciones hayan sido generadas previamente con `db:generate`.
.EXAMPLE
    .\scripts\database\migrate.ps1
#>

$ErrorActionPreference = "Stop"

# ====== CONFIGURACIÓN ======
$ProjectRoot = Resolve-Path "$PSScriptRoot\..\.."
$ApiDir      = Join-Path $ProjectRoot "apps\api"

# Cargar credenciales desde .env raíz si existe
$EnvFile = Join-Path $ProjectRoot ".env"
if (Test-Path $EnvFile) {
    Get-Content $EnvFile | ForEach-Object {
        if ($_ -match '^\s*([^#][^=]+)=(.*)$') {
            $key = $matches[1].Trim()
            $val = $matches[2].Trim()
            [System.Environment]::SetEnvironmentVariable($key, $val, "Process")
        }
    }
}

$DbHost = if ($env:MYSQL_HOST) { $env:MYSQL_HOST } else { "localhost" }
$DbPort = if ($env:MYSQL_PORT) { $env:MYSQL_PORT } else { "3306" }
$DbName = if ($env:MYSQL_DATABASE) { $env:MYSQL_DATABASE } else { "esm_db" }
$DbUser = if ($env:MYSQL_USER) { $env:MYSQL_USER } else { "ADMIN" }
$DbPass = if ($env:MYSQL_PASSWORD) { $env:MYSQL_PASSWORD } else { "J-admin-crfenix55" }

# ====== VALIDACIONES ======
Write-Host "==> Verificando prerequisitos..." -ForegroundColor Cyan

if (-not (Test-Path $ApiDir)) {
    Write-Error "No se encontró apps/api en $ApiDir"
    exit 1
}

if (-not (Get-Command npx -ErrorAction SilentlyContinue)) {
    Write-Error "npx no está disponible. Instala Node.js >= 20.11.1"
    exit 1
}

# ====== EJECUCIÓN ======
Write-Host "==> Aplicando migraciones Drizzle en '$DbName' ($DbHost`:$DbPort)..." -ForegroundColor Yellow

Push-Location $ApiDir
try {
    $env:DATABASE_URL = "mysql://${DbUser}:${DbPass}@${DbHost}:${DbPort}/${DbName}"

    npx drizzle-kit migrate
    if ($LASTEXITCODE -ne 0) {
        throw "drizzle-kit migrate falló con código $LASTEXITCODE"
    }

    Write-Host "==> Migraciones aplicadas correctamente." -ForegroundColor Green
}
catch {
    Write-Host "ERROR: $_" -ForegroundColor Red
    exit 1
}
finally {
    Pop-Location
}