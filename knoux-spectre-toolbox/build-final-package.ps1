<#
.SYNOPSIS
    Build Script for Knoux Spectre Toolbox Distribution Package
#>

$ProjectName = "Knoux-Spectre-Toolbox"
$Version = "2.0.0"
$OutputDir = "dist"
$BuildDate = Get-Date -Format "yyyy-MM-dd"

if (Test-Path $OutputDir) { Remove-Item -Path $OutputDir -Recurse -Force }
New-Item -ItemType Directory -Path $OutputDir | Out-Null

Copy-Item -Path "config","core","lib","modules","outputs","logs" -Destination $OutputDir -Recurse -ErrorAction SilentlyContinue
@("knoux.ps1","README.md","LICENSE") | ForEach-Object { if (Test-Path $_) { Copy-Item -Path $_ -Destination $OutputDir } }

$metadata = @{ projectName=$ProjectName; version=$Version; buildDate=$BuildDate }
$metadata | ConvertTo-Json | Out-File -FilePath "$OutputDir/build-info.json" -Encoding UTF8

$zipPath = "${ProjectName}-v${Version}.zip"
Compress-Archive -Path "$OutputDir\*" -DestinationPath $zipPath -Force
Remove-Item -Path $OutputDir -Recurse -Force
Write-Host "Build completed: $zipPath" -ForegroundColor Green
