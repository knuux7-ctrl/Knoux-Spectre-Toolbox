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
        [Parameter(Mandatory=$true)]
        [string]$Title,
        
        [Parameter(Mandatory=$true)]
        [array]$MenuItems,
        
        [string]$BackLabel = "Back to Main Menu"
    )
    
    do {
        Clear-ScreenWithBackground
        
        # Display title
        Write-Host "${ANSI.BG_DARK}${ANSI.PURPLE}${ANSI.BOLD}$Title${ANSI.RESET}"
        Write-Host "${ANSI.BORDER}$((-join (1..($Title.Length + 4) | ForEach-Object { "─" }))])${ANSI.RESET}"
        Write-Host ""
        
        # Display menu items
        for ($i = 0; $i -lt $MenuItems.Count; $i++) {
            $item = $MenuItems[$i]
            Write-Host " ${ANSI.PURPLE}$($i + 1)${ANSI.RESET}  ${ANSI.TEXT_PRIMARY}$($item.Label)${ANSI.RESET}"
        }
        
        Write-Host ""
        Write-Host " ${ANSI.RED}0${ANSI.RESET}  ${ANSI.TEXT_PRIMARY}$BackLabel${ANSI.RESET}"
        Write-Host ""
        
        $choice = Read-ValidatedSubInput -Max $MenuItems.Count
        
        if ($choice -eq 0) {
            return
        }
        
        # Execute the selected action
        $selectedItem = $MenuItems[$choice - 1]
        if ($selectedItem.Action -and (Get-Command $selectedItem.Action -ErrorAction SilentlyContinue)) {
            & $selectedItem.Action
        } elseif ($selectedItem.ScriptBlock) {
            & $selectedItem.ScriptBlock
        } else {
            Write-Host "${ANSI.RED}× Action not found${ANSI.RESET}"
            Start-Sleep -Milliseconds 500
        }
        
        Write-Host ""
        Write-Host "${ANSI.TEXT_SECONDARY}Press any key to continue...${ANSI.RESET}"
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        
    } while ($true)
}

function Read-ValidatedSubInput {
    [CmdletBinding()]
    param(
        [int]$Max
    )
    
    do {
        Write-Host "${ANSI.PURPLE}┌─ Select Option${ANSI.RESET}" -NoNewline
        Write-Host "${ANSI.TEXT_SECONDARY} (0-$Max)${ANSI.RESET}" -NoNewline
        Write-Host "${ANSI.PURPLE}:${ANSI.RESET} " -NoNewline
        
        $input = Read-Host
        
        if ([string]::IsNullOrWhiteSpace($input)) {
            Write-Host "${ANSI.RED}× Invalid selection. Please try again.${ANSI.RESET}"
            continue
        }
        
        if ($input -match '^\d+$') {
            $number = [int]$input
            if ($number -ge 0 -and $number -le $Max) {
                return $number
            }
        }
        
        Write-Host "${ANSI.RED}× Invalid selection. Please enter a number between 0-$Max.${ANSI.RESET}"
    } while ($true)
}

Export-ModuleMember -Function @('Show-KnouxSubMenu', 'Read-ValidatedSubInput')
