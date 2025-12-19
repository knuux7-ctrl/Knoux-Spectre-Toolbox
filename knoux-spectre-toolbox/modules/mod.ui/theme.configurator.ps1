<#
.SYNOPSIS
    Theme Configurator for Knoux Spectre
.DESCRIPTION
    Tools to view and modify the theme configuration used by the console UI.
    Edits are performed against config/theme.json with validation and a preview.
#>

function Show-ThemeConfigurator {
    [CmdletBinding()]
    param()

    Clear-ScreenWithBackground
    Write-Host "${ANSI.BG_DARK}${ANSI.YELLOW}${ANSI.BOLD}🎨 THEME CONFIGURATOR${ANSI.RESET}"
    Write-Host "${ANSI.BORDER}────────────────────────${ANSI.RESET}"
    Write-Host ""

    do {
        Write-Host "${ANSI.TEXT_SECONDARY}Theme Options:${ANSI.RESET}"
        Write-Host " ${ANSI.YELLOW}1${ANSI.RESET} ${ANSI.TEXT_PRIMARY}View Theme${ANSI.RESET}"
        Write-Host " ${ANSI.YELLOW}2${ANSI.RESET} ${ANSI.TEXT_PRIMARY}Edit Color Palette${ANSI.RESET}"
        Write-Host " ${ANSI.YELLOW}3${ANSI.RESET} ${ANSI.TEXT_PRIMARY}Import Theme File${ANSI.RESET}"
        Write-Host " ${ANSI.YELLOW}4${ANSI.RESET} ${ANSI.TEXT_PRIMARY}Export Theme File${ANSI.RESET}"
        Write-Host " ${ANSI.YELLOW}5${ANSI.RESET} ${ANSI.TEXT_PRIMARY}Preview Theme${ANSI.RESET}"
        Write-Host ""
        Write-Host " ${ANSI.RED}0${ANSI.RESET} ${ANSI.TEXT_PRIMARY}Back${ANSI.RESET}"
        Write-Host ""

        $choice = Read-ValidatedSubInput -Max 5

        switch ($choice) {
            0 { return }
            1 { View-Theme }
            2 { Edit-ColorPalette }
            3 { Import-ThemeFile }
            4 { Export-ThemeFile }
            5 { Preview-Theme }
        }

        Write-Host ""
        Write-Host "${ANSI.TEXT_SECONDARY}Press any key to continue...${ANSI.RESET}"
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        Clear-ScreenWithBackground
    } while ($true)
}

function Get-ThemePath {
    # Return the canonical path to config/theme.json
    $candidate = Join-Path $PSScriptRoot "../../config/theme.json"
    if (Test-Path $candidate) { return (Resolve-Path $candidate).Path }
    return $null
}

function Show-Theme {
    $path = Get-ThemePath
    if (-not $path) { Write-Host "${ANSI.RED}× theme.json not found in config/${ANSI.RESET}"; return }

    try {
        $json = Get-Content -Path $path -Raw | ConvertFrom-Json
        Write-Host "${ANSI.PURPLE}${ANSI.BOLD}CURRENT THEME:${ANSI.RESET}"
        Write-Host "${ANSI.BORDER}────────────────${ANSI.RESET}"
        $json | ConvertTo-Json -Depth 10 | Write-Host
    }
    catch {
        Write-Host "${ANSI.RED}× Error reading theme: $($_.Exception.Message)${ANSI.RESET}"
    }
}

function Edit-ColorPalette {
    $path = Get-ThemePath
    if (-not $path) { Write-Host "${ANSI.RED}× theme.json not found in config/${ANSI.RESET}"; return }

    try {
        $json = Get-Content -Path $path -Raw | ConvertFrom-Json
    }
    catch {
        Write-Host "${ANSI.RED}× Error reading theme: $($_.Exception.Message)${ANSI.RESET}"; return
    }

    Write-Host "${ANSI.TEXT_SECONDARY}Available color keys:${ANSI.RESET}"
    $keys = $json.PSObject.Properties.Name
    for ($i = 0; $i -lt $keys.Count; $i++) {
        Write-Host " ${ANSI.YELLOW}$($i+1)${ANSI.RESET} ${ANSI.TEXT_PRIMARY}$($keys[$i])${ANSI.RESET}"
    }

    Write-Host ""
    Write-Host "${ANSI.TEXT_SECONDARY}Select key number to edit:${ANSI.RESET}"
    $choice = Read-ValidatedSubInput -Max $keys.Count
    if ($choice -le 0) { return }

    $selectedKey = $keys[$choice - 1]
    Write-Host "${ANSI.TEXT_SECONDARY}Current value for $selectedKey: ${ANSI.RESET}$($json.$selectedKey)"
    Write-Host "${ANSI.TEXT_SECONDARY}Enter new value (e.g. \"#RRGGBB\" or ANSI code):${ANSI.RESET}"
    Write-Host "${ANSI.PURPLE}>>${ANSI.RESET} " -NoNewline
    $newValue = Read-Host

    if ([string]::IsNullOrWhiteSpace($newValue)) { Write-Host "${ANSI.RED}× No value entered${ANSI.RESET}"; return }

    # Update and validate minimal format
    $json.$selectedKey = $newValue

    try {
        $json | ConvertTo-Json -Depth 10 | Set-Content -Path $path -Encoding UTF8
        Write-Host "${ANSI.GREEN}✓ Theme updated: $selectedKey = $newValue${ANSI.RESET}"
    }
    catch {
        Write-Host "${ANSI.RED}× Error saving theme: $($_.Exception.Message)${ANSI.RESET}"
    }
}

function Import-ThemeFile {
    Write-Host "${ANSI.TEXT_SECONDARY}Enter path to theme JSON file to import:${ANSI.RESET}"
    Write-Host "${ANSI.PURPLE}>>${ANSI.RESET} " -NoNewline
    $file = Read-Host
    if (-not (Test-Path $file)) { Write-Host "${ANSI.RED}× File not found${ANSI.RESET}"; return }

    $path = Get-ThemePath
    if (-not $path) { Write-Host "${ANSI.RED}× theme.json not found in config/${ANSI.RESET}"; return }

    try {
        $content = Get-Content -Path $file -Raw
        # Validate JSON
        $obj = $content | ConvertFrom-Json
        $content | Set-Content -Path $path -Encoding UTF8
        Write-Host "${ANSI.GREEN}✓ Theme imported successfully from $file${ANSI.RESET}"
    }
    catch {
        Write-Host "${ANSI.RED}× Invalid JSON or import failed: $($_.Exception.Message)${ANSI.RESET}"
    }
}

function Export-ThemeFile {
    $path = Get-ThemePath
    if (-not $path) { Write-Host "${ANSI.RED}× theme.json not found in config/${ANSI.RESET}"; return }

    Write-Host "${ANSI.TEXT_SECONDARY}Enter path to export theme to (will overwrite if exists):${ANSI.RESET}"
    Write-Host "${ANSI.PURPLE}>>${ANSI.RESET} " -NoNewline
    $file = Read-Host
    if ([string]::IsNullOrWhiteSpace($file)) { Write-Host "${ANSI.RED}× No path provided${ANSI.RESET}"; return }

    try {
        Copy-Item -Path $path -Destination $file -Force
        Write-Host "${ANSI.GREEN}✓ Theme exported to $file${ANSI.RESET}"
    }
    catch {
        Write-Host "${ANSI.RED}× Export failed: $($_.Exception.Message)${ANSI.RESET}"
    }
}

function Preview-Theme {
    $path = Get-ThemePath
    if (-not $path) { Write-Host "${ANSI.RED}× theme.json not found in config/${ANSI.RESET}"; return }

    try {
        $json = Get-Content -Path $path -Raw | ConvertFrom-Json
    }
    catch {
        Write-Host "${ANSI.RED}× Error reading theme: $($_.Exception.Message)${ANSI.RESET}"; return
    }

    Write-Host ""
    Write-Host "${ANSI.BG_DARK}${ANSI.BOLD} Theme Preview ${ANSI.RESET}"
    Write-Host ""

    # Attempt to apply simple preview using keys if present
    if ($json.TEXT_PRIMARY) { Write-Host "Primary Text" -ForegroundColor Yellow }
    if ($json.TEXT_SECONDARY) { Write-Host "Secondary Text" -ForegroundColor DarkGray }
    if ($json.GREEN) { Write-Host "Success" -ForegroundColor Green }
    if ($json.RED) { Write-Host "Error" -ForegroundColor Red }
    if ($json.ORANGE) { Write-Host "Warning" -ForegroundColor Magenta }

    Write-Host ""
    Write-Host "${ANSI.TEXT_SECONDARY}Preview completed (limited to console colors)${ANSI.RESET}"
}

Export-ModuleMember -Function @('Show-ThemeConfigurator')
