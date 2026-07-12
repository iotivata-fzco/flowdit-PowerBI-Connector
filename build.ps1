# Build script for Flowdit Power BI Custom Connector
# Produces a .mez file that can be installed in Power BI Desktop
# Usage: powershell -ExecutionPolicy Bypass -File build.ps1

$ErrorActionPreference = "Stop"

$rootFolder = Split-Path -Parent $MyInvocation.MyCommand.Path
$buildFolder = Join-Path $rootFolder "build"

# Clean previous build
if (Test-Path $buildFolder) {
    Remove-Item $buildFolder -Recurse -Force
}

New-Item -Path $buildFolder -ItemType "directory" | Out-Null

# Copy required assets into the build folder
Copy-Item "$rootFolder\*.png" -Destination $buildFolder
Copy-Item "$rootFolder\*.pqm" -Destination $buildFolder

# Copy the connector .pq file as .m (Power Query module format)
Copy-Item "$rootFolder\flowditConnector.pq" "$buildFolder\flowditConnector.m"

# Compress all files into a .mez archive
$compress = @{
    Path             = "$buildFolder\*"
    CompressionLevel = "Fastest"
    DestinationPath  = "$buildFolder\flowditConnector.zip"
}
Compress-Archive @compress

# Rename .zip to .mez (Power BI custom connector format)
Rename-Item -Path "$buildFolder\flowditConnector.zip" -NewName "flowditConnector.mez"

Write-Host ""
Write-Host "Build complete: $buildFolder\flowditConnector.mez" -ForegroundColor Green
Write-Host ""
Write-Host "To install:" -ForegroundColor Cyan
Write-Host "  1. Copy flowditConnector.mez to: [Documents]\Power BI Desktop\Custom Connectors\"
Write-Host "  2. In Power BI Desktop: Options > Security > Data Extensions > enable custom connectors"
Write-Host "  3. Restart Power BI Desktop"
Write-Host "  4. Get Data > flowditConnector"
