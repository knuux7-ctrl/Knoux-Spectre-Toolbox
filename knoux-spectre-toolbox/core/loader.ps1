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

function Import-KnouxCore {
    [CmdletBinding()]
    param()
    
    Write-Log "[LOADER] Starting core module initialization" "DEBUG"
    
    # Load theme configuration
    $script:ThemeConfig = Get-Content -Path "$PSScriptRoot\..\config\theme.json" | ConvertFrom-Json
    
    # Recreate ANSI hashtable from theme config
    $script:ANSI = @{
        RESET         = $script:ThemeConfig.ansi.reset
        BOLD          = $script:ThemeConfig.ansi.bold
        DIM           = $script:ThemeConfig.ansi.dim
        BG_DARK       = $script:ThemeConfig.ansi.bg_dark
        TEXT_PRIMARY  = $script:ThemeConfig.ansi.text_primary
        TEXT_SECONDARY= $script:ThemeConfig.ansi.text_secondary
        TEXT_FADED    = $script:ThemeConfig.ansi.text_faded
        PURPLE        = $script:ThemeConfig.ansi.purple
        PURPLE_HOVER  = $script:ThemeConfig.ansi.purple_hover
        GREEN         = $script:ThemeConfig.ansi.green
        ORANGE        = $script:ThemeConfig.ansi.orange
        RED           = $script:ThemeConfig.ansi.red
        BORDER        = $script:ThemeConfig.ansi.border
    }
    
    Write-Log "[LOADER] Theme engine loaded successfully" "DEBUG"
    
    # Load shared helper functions
    $helperPath = "$PSScriptRoot\..\lib\helper.functions.ps1"
    if (Test-Path $helperPath) {
        . $helperPath
        Write-Log "[LOADER] Shared helpers loaded" "DEBUG"
    }
    
    Write-Log "[LOADER] Core initialization completed" "INFO"
}

# Automatically run on import
Import-KnouxCore
