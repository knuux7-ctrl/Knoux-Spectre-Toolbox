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
    
    # Append extra core menu item imports to support explicit submenu handlers
    try {
        $coreMenuDb = Join-Path $PSScriptRoot "coremenuitems.db"
        $menuHeredoc = @"
# Import submenu handlers mapped to main controller buttons shown via UI Navbars
# Required imports even though auto loaded indirectly from path recursion because PowerShell scoping boundaries don't recursively cascade nested module symbols outward implicitly during dot-sourcing unless forced with Export clause override directives done carefully module side
}
mod.automation/task.scheduler.ps1`, `Show-AutomationCenter`
@{ label = "🔐 SECURITY PENTEST"; scriptblock = {
        if (-not(Test-AdminPrivilege)) {
            Write-Host "${ANSI.RED}[!] Some tools might behave limitedly due to missing elevated execution context.${ANSI.RESET}" 
            Start-Sleep -Milliseconds 850 } ; return $( Show-HashToolkit )}
},
devops/env.manager.ps1, Show-DevOpsHelpers,
scripts/builder.generator.ps1, mod.scriptgen/batch.builder.ps1, backup/module.ps1
"@
<<<<<<< Updated upstream

        Add-Content -Path $coreMenuDb -Value $menuHeredoc -Encoding UTF8 -Force
        Write-Log "[LOADER] Appended core menu items stub to $coreMenuDb" "DEBUG"
    } catch {
        Write-Log "[LOADER] Failed to append core menu items: $($_.Exception.Message)" "WARN"
    }

    Write-Log "[LOADER] Core initialization completed" "INFO"
=======
>>>>>>> Stashed changes

        Add-Content -Path $coreMenuDb -Value $menuHeredoc -Encoding UTF8 -Force
        Write-Log "[LOADER] Appended core menu items stub to $coreMenuDb" "DEBUG"
    }
    catch {
        Write-Log "[LOADER] Failed to append core menu items: $($_.Exception.Message)" "WARN"
    }

    Write-Log "[LOADER] Core initialization completed" "INFO"

    # Automatically run on import
    Import-KnouxCore
