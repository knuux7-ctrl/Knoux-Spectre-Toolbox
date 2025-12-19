<#
.SYNOPSIS
    Knoux Spectre Toolbox Menu Engine
.DESCRIPTION
    Provides advanced menu navigation and rendering capabilities
.AUTHOR
    Knoux Systems
.VERSION
    1.0.0
#>

function Show-KnouxSubMenu {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$Title,
        [Parameter(Mandatory = $true)][array]$MenuItems,
        [string]$BackLabel = "Back to Main Menu"
    )

    do {
        Clear-ScreenWithBackground

        # Display title
        $bg = if ($script:ANSI.ContainsKey('BG_DARK')) { $script:ANSI['BG_DARK'] } else { '' }
        $purple = if ($script:ANSI.ContainsKey('PURPLE')) { $script:ANSI['PURPLE'] } else { '' }
        $reset = if ($script:ANSI.ContainsKey('RESET')) { $script:ANSI['RESET'] } else { '' }
        $border = if ($script:ANSI.ContainsKey('BORDER')) { $script:ANSI['BORDER'] } else { '' }

        Write-Host "${bg}${purple}${Title}${reset}"
        $line = (1..($Title.Length + 4) | ForEach-Object { '─' }) -join ''
        Write-Host "${border}$line${reset}"
        Write-Host ""

        # Display menu items
        for ($i = 0; $i -lt $MenuItems.Count; $i++) {
            $item = $MenuItems[$i]
            $indexColor = if ($script:ANSI.ContainsKey('PURPLE')) { $script:ANSI['PURPLE'] } else { '' }
            $textPrimary = if ($script:ANSI.ContainsKey('TEXT_PRIMARY')) { $script:ANSI['TEXT_PRIMARY'] } else { '' }
            Write-Host " ${indexColor}$($i + 1)${reset}  ${textPrimary}$($item.Label)${reset}"
        }

        Write-Host ""
        Write-Host " ${ (if ($script:ANSI.ContainsKey('RED')) { $script:ANSI['RED'] } else { '' }) }0${reset}  ${ (if ($script:ANSI.ContainsKey('TEXT_PRIMARY')) { $script:ANSI['TEXT_PRIMARY'] } else { '' }) }$BackLabel${reset}"
        Write-Host ""

        $choice = Read-ValidatedSubInput -Max $MenuItems.Count

        if ($choice -eq 0) { return }

        $selectedItem = $MenuItems[$choice - 1]
        if ($selectedItem.Action -and (Get-Command $selectedItem.Action -ErrorAction SilentlyContinue)) { & $selectedItem.Action }
        elseif ($selectedItem.ScriptBlock) { & $selectedItem.ScriptBlock }
        else { Write-Host "× Action not found" }

        Write-Host ""
        Write-Host "Press any key to continue..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

    } while ($true)
}

function Read-ValidatedSubInput {
    [CmdletBinding()]
    param([int]$Max)
    do {
        $promptColor = if ($script:ANSI.ContainsKey('PURPLE')) { $script:ANSI['PURPLE'] } else { '' }
        $textSec = if ($script:ANSI.ContainsKey('TEXT_SECONDARY')) { $script:ANSI['TEXT_SECONDARY'] } else { '' }
        $reset = if ($script:ANSI.ContainsKey('RESET')) { $script:ANSI['RESET'] } else { '' }

        Write-Host "${promptColor}┌─ Select Option${reset}" -NoNewline
        Write-Host "${textSec} (0-$Max)${reset}" -NoNewline
        Write-Host "${promptColor}:${reset} " -NoNewline

        $input = Read-Host
        if ([string]::IsNullOrWhiteSpace($input)) { Write-Host "Invalid selection" ; continue }
        if ($input -match '^\d+$') { $number = [int]$input; if ($number -ge 0 -and $number -le $Max) { return $number } }
        Write-Host "Invalid selection. Please enter a number between 0-$Max.";
    } while ($true)
}

Export-ModuleMember -Function @('Show-KnouxSubMenu', 'Read-ValidatedSubInput')
