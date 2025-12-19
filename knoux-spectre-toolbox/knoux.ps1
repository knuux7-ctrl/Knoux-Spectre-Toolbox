<#
.SYNOPSIS
    Knoux Spectre Toolbox - Main Application Entry Point
#>
param(
    [switch]$Silent = $false,
    [string]$Profile = "default"
)

try {
    Write-Host "[LOADING] Knoux Spectre Toolbox..." -ForegroundColor Gray
    $configPath = Join-Path $PSScriptRoot "config/theme.json"
    if (Test-Path $configPath) { $script:ThemeConfig = Get-Content -Path $configPath | ConvertFrom-Json }

    $coreFiles = @("core/loader.ps1","lib/helper.functions.ps1","core/menuengine.ps1")
    foreach ($file in $coreFiles) {
        $fullPath = Join-Path $PSScriptRoot $file
        if (Test-Path $fullPath) { . $fullPath }
    }

    Write-Host "[READY] Knoux Spectre Toolbox Loaded Successfully" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Failed to initialize: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

do {
    Clear-Host
    Write-Host "Welcome to Knoux Spectre Toolbox" -ForegroundColor Cyan

    $mainMenuItems = @(
        @{ Label = "🧠 AI & Coding Tools"; Action = "Invoke-PromptEngine" },
        @{ Label = "🛠 Dev Tools"; Action = "Install-VSCodeExtensions" },
        @{ Label = "ℹ About & Diagnostics"; Action = "Show-AboutDiagnostics" }
    )

    Show-KnouxSubMenu -Title "MAIN DASHBOARD" -MenuItems $mainMenuItems -BackLabel "Exit Application"

    $exitChoice = Read-ValidatedSubInput -Max 3
    if ($exitChoice -eq 0) { break }
} while ($true)

Write-Host "Goodbye!" -ForegroundColor Green
