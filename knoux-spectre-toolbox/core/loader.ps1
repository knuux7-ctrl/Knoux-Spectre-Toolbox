<#
.SYNOPSIS
    Knoux Spectre Toolbox Module Loader
.DESCRIPTION
    Dynamically loads all core libraries and modules
.AUTHOR
    Knoux Systems
.VERSION
    1.0.0
#>

Write-Log "[LOADER] Starting core module initialization" "DEBUG"

# Load theme configuration (safe-read)
try {
    $themePath = Join-Path $PSScriptRoot "..\config\theme.json"
    if (Test-Path $themePath) { $script:ThemeConfig = Get-Content -Path $themePath -Raw | ConvertFrom-Json }
}
catch { Write-Log "[LOADER] Failed reading theme config: $($_.Exception.Message)" "WARN" }

# Recreate ANSI hashtable from theme config with safe defaults
$script:ANSI = @{}
try {
    if ($null -ne $script:ThemeConfig -and $script:ThemeConfig.ansi) {
        $script:ANSI = @{
            RESET          = $script:ThemeConfig.ansi.reset
            BOLD           = $script:ThemeConfig.ansi.bold
            DIM            = $script:ThemeConfig.ansi.dim
            BG_DARK        = $script:ThemeConfig.ansi.bg_dark
            TEXT_PRIMARY   = $script:ThemeConfig.ansi.text_primary
            TEXT_SECONDARY = $script:ThemeConfig.ansi.text_secondary
            TEXT_FADED     = $script:ThemeConfig.ansi.text_faded
            PURPLE         = $script:ThemeConfig.ansi.purple
            PURPLE_HOVER   = $script:ThemeConfig.ansi.purple_hover
            GREEN          = $script:ThemeConfig.ansi.green
            ORANGE         = $script:ThemeConfig.ansi.orange
            RED            = $script:ThemeConfig.ansi.red
            BORDER         = $script:ThemeConfig.ansi.border
        }
    }
}
catch { Write-Log "[LOADER] Failed building ANSI table: $($_.Exception.Message)" "DEBUG" }

Write-Log "[LOADER] Theme engine loaded (if present)" "DEBUG"

# Load shared helper functions
$helperPath = Join-Path $PSScriptRoot "..\lib\helper.functions.ps1"
if (Test-Path $helperPath) { . $helperPath; Write-Log "[LOADER] Shared helpers loaded" "DEBUG" }

# Load menu engine
$menuPath = Join-Path $PSScriptRoot "..\core\menuengine.ps1"
if (Test-Path $menuPath) { . $menuPath; Write-Log "[LOADER] Menu engine loaded" "DEBUG" }

# Ensure security/access control is available before loading modules that depend on it
$accessControlPath = Join-Path $PSScriptRoot "..\security\access.control.ps1"
if (Test-Path $accessControlPath) {
    try { . $accessControlPath; Write-Log "[LOADER] AccessControl loaded" "DEBUG" } catch { Write-Log "[LOADER] Failed loading AccessControl: $($_.Exception.Message)" "WARN" }
}

# Register core integrations (registration only; no eager initialization)
$script:RegisteredModules = @{}

$emotionalModule = Join-Path $PSScriptRoot "..\modules\emotional_ai\controller.emotional_bridge.ps1"
if (Test-Path $emotionalModule) {
    $script:RegisteredModules['emotional_ai'] = @{ path = $emotionalModule; registered = (Get-Date) }
    Write-Log "[LOADER] Emotional AI module registered (no init)" "DEBUG"
}

$historyModule = Join-Path $PSScriptRoot "..\modules\history\history.timeline.recording.ps1"
if (Test-Path $historyModule) {
    $script:RegisteredModules['history'] = @{ path = $historyModule; registered = (Get-Date) }
    Write-Log "[LOADER] History timeline recorder registered (no init)" "DEBUG"
}

# Load runner wrappers (safe, non-interactive functions exposed to API)
$wrapperPath = Join-Path $PSScriptRoot "..\modules\wrappers\runner.wrappers.ps1"
if (Test-Path $wrapperPath) { try { . $wrapperPath; Write-Log "[LOADER] Runner wrappers loaded" "DEBUG" } catch { Write-Log "[LOADER] Failed loading runner wrappers: $($_.Exception.Message)" "WARN" } }

# Wire optional systems: Updater and AISystem (dot-source but do not auto-start services)
try {
    $updateScript = Join-Path $PSScriptRoot "..\update\updater.system.ps1"
    if (Test-Path $updateScript) {
        try { . $updateScript; Write-Log "[LOADER] Updater script sourced" "DEBUG" } catch { Write-Log "[LOADER] Failed sourcing Updater: $($_.Exception.Message)" "WARN" }
        if (-not $global:Updater) {
            if (Get-Command -Name 'Initialize-Updater' -ErrorAction SilentlyContinue) {
                try { $global:Updater = Initialize-Updater -NoAutoStart; Write-Log "[LOADER] Updater initialized (no auto-start)" "DEBUG" } catch { Write-Log "[LOADER] Updater initialization failed: $($_.Exception.Message)" "WARN" }
            }
            elseif (Get-Variable -Name 'UpdaterInstance' -Scope Script -ErrorAction SilentlyContinue) {
                $global:Updater = $script:UpdaterInstance; Write-Log "[LOADER] Updater instance wired from script variable" "DEBUG"
            }
            else { Write-Log "[LOADER] Updater script loaded but no initializer found" "DEBUG" }
        }
    }
}
catch { Write-Log "[LOADER] Updater wiring error: $($_.Exception.Message)" "WARN" }

try {
    $aiScript = Join-Path $PSScriptRoot "..\ai\integration.system.ps1"
    if (Test-Path $aiScript) {
        try { . $aiScript; Write-Log "[LOADER] AI integration script sourced" "DEBUG" } catch { Write-Log "[LOADER] Failed sourcing AI integration: $($_.Exception.Message)" "WARN" }
        if (-not $global:AISystem) {
            if (Get-Command -Name 'Initialize-AISystem' -ErrorAction SilentlyContinue) {
                try { $global:AISystem = Initialize-AISystem -NoAutoStart; Write-Log "[LOADER] AISystem initialized (no auto-start)" "DEBUG" } catch { Write-Log "[LOADER] AISystem initialization failed: $($_.Exception.Message)" "WARN" }
            }
            elseif (Get-Variable -Name 'AISystemInstance' -Scope Script -ErrorAction SilentlyContinue) {
                $global:AISystem = $script:AISystemInstance; Write-Log "[LOADER] AISystem instance wired from script variable" "DEBUG"
            }
            else { Write-Log "[LOADER] AI integration script loaded but no initializer found" "DEBUG" }
        }
    }
}
catch { Write-Log "[LOADER] AISystem wiring error: $($_.Exception.Message)" "WARN" }

# Auto-load modules
$modulesPath = Join-Path $PSScriptRoot "..\modules"
if (Test-Path $modulesPath) {
    # Skip modules that are registered to avoid eager init (they will be loaded lazily by wrappers)
    Get-ChildItem -Path $modulesPath -Recurse -Filter "*.ps1" | Where-Object { $_.FullName -notmatch "\\modules\\emotional_ai\\" -and $_.FullName -notmatch "\\modules\\history\\" } | ForEach-Object {
        try { . $_.FullName; Write-Log "[LOADER] Loaded module: $($_.Name)" "DEBUG" } catch { Write-Log "[LOADER] Failed loading $($_.Name): $($_.Exception.Message)" "WARN" }
    }
}

Write-Log "[LOADER] Core initialization completed" "INFO"

}

Import-KnouxCore
