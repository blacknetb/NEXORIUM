<#
.SYNOPSIS
    Verifica los prerrequisitos del entorno de desarrollo para ESM.
.DESCRIPTION
    Comprueba versiones de Node.js, npm, Docker, Docker Compose y Git.
    Sale con código 0 si todo está OK, 1 si falta algo.
#>

$ErrorActionPreference = "Stop"

function Test-Command($cmd, $minVersion, $versionArg = "--version") {
    try {
        $output = & $cmd $versionArg 2>&1 | Out-String
        if ($LASTEXITCODE -ne 0) { return $null }
        return $output.Trim()
    } catch {
        return $null
    }
}

Write-Host "==> Verificando prerrequisitos de ESM..." -ForegroundColor Cyan
Write-Host ""

$missing = @()

# ---- Node.js ----
$nodeVer = Test-Command "node"
if ($nodeVer) {
    $ver = ($nodeVer -replace '^v', '') -split '\.' | Select-Object -First 1
    if ([int]$ver -ge 20) {
        Write-Host "  [OK]   Node.js $nodeVer (>= 20)" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] Node.js $nodeVer (se requiere >= 20)" -ForegroundColor Red
        $missing += "Node.js >= 20"
    }
} else {
    Write-Host "  [FAIL] Node.js no encontrado" -ForegroundColor Red
    $missing += "Node.js >= 20"
}

# ---- npm ----
$npmVer = Test-Command "npm"
if ($npmVer) {
    $ver = ($npmVer -replace '^v', '') -split '\.' | Select-Object -First 1
    if ([int]$ver -ge 10) {
        Write-Host "  [OK]   npm $npmVer (>= 10)" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] npm $npmVer (se requiere >= 10)" -ForegroundColor Red
        $missing += "npm >= 10"
    }
} else {
    Write-Host "  [FAIL] npm no encontrado" -ForegroundColor Red
    $missing += "npm >= 10"
}

# ---- Docker ----
$dockerVer = Test-Command "docker"
if ($dockerVer) {
    Write-Host "  [OK]   Docker $dockerVer" -ForegroundColor Green
} else {
    Write-Host "  [FAIL] Docker no encontrado" -ForegroundColor Red
    $missing += "Docker"
}

# ---- Docker Compose ----
$composeVer = Test-Command "docker" "compose" "version"
if ($composeVer -and $composeVer -match "v\d+\.\d+") {
    Write-Host "  [OK]   Docker Compose $composeVer" -ForegroundColor Green
} else {
    Write-Host "  [FAIL] Docker Compose no encontrado" -ForegroundColor Red
    $missing += "Docker Compose"
}

# ---- Git ----
$gitVer = Test-Command "git"
if ($gitVer) {
    Write-Host "  [OK]   Git $gitVer" -ForegroundColor Green
} else {
    Write-Host "  [FAIL] Git no encontrado" -ForegroundColor Red
    $missing += "Git"
}

Write-Host ""
if ($missing.Count -gt 0) {
    Write-Host "==> Faltan los siguientes prerrequisitos:" -ForegroundColor Red
    $missing | ForEach-Object { Write-Host "    - $_" -ForegroundColor Yellow }
    exit 1
} else {
    Write-Host "==> Todos los prerrequisitos están OK." -ForegroundColor Green
    exit 0
}