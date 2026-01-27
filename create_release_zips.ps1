# Script para crear ZIPs de release
# Ejecutar desde la raiz del proyecto

$version = "1.0.1"
$projectRoot = $PSScriptRoot

Write-Host "Creando ZIPs para release v$version..."

# Crear ZIP de Rage Core
$coreSource = Join-Path $projectRoot "addons\rage_core"
$coreZip = Join-Path $projectRoot "rage_core_v$version.zip"

if (Test-Path $coreZip) {
    Remove-Item $coreZip -Force
}

Write-Host "Comprimiendo Rage Core..."
Compress-Archive -Path $coreSource -DestinationPath $coreZip -Force

# Crear ZIP de Rage Toolkit
$toolkitSource = Join-Path $projectRoot "addons\rage_toolkit"
$toolkitZip = Join-Path $projectRoot "rage_toolkit_v$version.zip"

if (Test-Path $toolkitZip) {
    Remove-Item $toolkitZip -Force
}

Write-Host "Comprimiendo Rage Toolkit..."
Compress-Archive -Path $toolkitSource -DestinationPath $toolkitZip -Force

Write-Host "`nZIPs creados:"
Write-Host "  - $coreZip"
Write-Host "  - $toolkitZip"
Write-Host "`nListo para subir a GitHub Release o Asset Library!"
