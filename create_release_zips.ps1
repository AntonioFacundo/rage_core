# Script para crear ZIPs de release
# Ejecutar desde la raiz del proyecto

param(
    [string]$Version = ""
)

$projectRoot = $PSScriptRoot

# Si no se proporciona versión, intentar leerla del CHANGELOG
if ([string]::IsNullOrEmpty($Version)) {
    $changelogPath = Join-Path $projectRoot "CHANGELOG.md"
    if (Test-Path $changelogPath) {
        $changelogContent = Get-Content $changelogPath -Raw
        if ($changelogContent -match '## \[(\d+\.\d+\.\d+)\]') {
            $Version = $matches[1]
            Write-Host "Versión detectada del CHANGELOG: v$Version"
        }
    }
    
    if ([string]::IsNullOrEmpty($Version)) {
        Write-Host "Error: No se pudo detectar la versión. Especifica con -Version X.Y.Z" -ForegroundColor Red
        exit 1
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Creando ZIPs para release v$Version" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Validar que los directorios existen
$coreSource = Join-Path $projectRoot "addons\rage_core"
$toolkitSource = Join-Path $projectRoot "addons\rage_toolkit"

if (-not (Test-Path $coreSource)) {
    Write-Host "Error: No se encuentra addons\rage_core" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $toolkitSource)) {
    Write-Host "Error: No se encuentra addons\rage_toolkit" -ForegroundColor Red
    exit 1
}

# Crear ZIP de Rage Core
$coreZip = Join-Path $projectRoot "rage_core_v$Version.zip"

if (Test-Path $coreZip) {
    Write-Host "Eliminando ZIP anterior de Rage Core..." -ForegroundColor Yellow
    Remove-Item $coreZip -Force
}

Write-Host "Comprimiendo Rage Core..." -ForegroundColor Green
try {
    Compress-Archive -Path $coreSource -DestinationPath $coreZip -Force
    $coreSize = (Get-Item $coreZip).Length / 1MB
    Write-Host "  ✓ Rage Core comprimido: $([math]::Round($coreSize, 2)) MB" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Error al comprimir Rage Core: $_" -ForegroundColor Red
    exit 1
}

# Crear ZIP de Rage Toolkit
$toolkitZip = Join-Path $projectRoot "rage_toolkit_v$Version.zip"

if (Test-Path $toolkitZip) {
    Write-Host "Eliminando ZIP anterior de Rage Toolkit..." -ForegroundColor Yellow
    Remove-Item $toolkitZip -Force
}

Write-Host "Comprimiendo Rage Toolkit..." -ForegroundColor Green
try {
    Compress-Archive -Path $toolkitSource -DestinationPath $toolkitZip -Force
    $toolkitSize = (Get-Item $toolkitZip).Length / 1MB
    Write-Host "  ✓ Rage Toolkit comprimido: $([math]::Round($toolkitSize, 2)) MB" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Error al comprimir Rage Toolkit: $_" -ForegroundColor Red
    exit 1
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "ZIPs creados exitosamente:" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  - $coreZip" -ForegroundColor White
Write-Host "  - $toolkitZip" -ForegroundColor White
Write-Host "`nListo para subir a GitHub Release o Asset Library!`n" -ForegroundColor Green
