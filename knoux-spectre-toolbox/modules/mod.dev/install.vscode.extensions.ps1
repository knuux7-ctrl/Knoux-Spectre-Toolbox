<#
.SYNOPSIS
    Knoux Spectre VS Code Extension Installer
.DESCRIPTION
    Installs recommended VS Code extensions for development
.AUTHOR
    Knoux Systems
.VERSION
    1.0.0
#>

function Install-VSCodeExtensions {
    [CmdletBinding()]
    param()
    
    Clear-ScreenWithBackground
    Write-Host "${ANSI.BG_DARK}${ANSI.PURPLE}${ANSI.BOLD}🛠 VS CODE EXTENSIONS INSTALLER${ANSI.RESET}"
    Write-Host "${ANSI.BORDER}────────────────────────────────────────${ANSI.RESET}"
    Write-Host ""
    
    # Check if VS Code is installed
    $vscodePaths = @(
        "${env:ProgramFiles}\Microsoft VS Code\bin\code.cmd",
        "${env:ProgramFiles(x86)}\Microsoft VS Code\bin\code.cmd",
        "${env:USERPROFILE}\AppData\Local\Programs\Microsoft VS Code\bin\code.cmd"
    )
    
    $vscodePath = $vscodePaths | Where-Object { Test-Path $_ } | Select-Object -First 1
    
    if (-not $vscodePath) {
        Write-Host "${ANSI.RED}× VS Code not found. Please install VS Code first.${ANSI.RESET}"
        Start-Sleep -Seconds 2
        return
    }
    
    Write-Host "${ANSI.GREEN}✓ VS Code found at: $vscodePath${ANSI.RESET}"
    Write-Host ""
    
    # Recommended extensions
    $extensions = @(
        @{ Id = "ms-vscode.powershell"; Name = "PowerShell" },
        @{ Id = "ms-python.python"; Name = "Python" },
        @{ Id = "ms vs-ce.theme-dimmed"; Name = "Dimmer" },
        @{ Id = "bradlc.vscode-tailwindcss"; Name = "Tailwind CSS IntelliSense" },
        @{ Id = "christian-kohler.path-intellisense"; Name = "Path Intellisense" },
        @{ Id = "ms-azuretools.vscode-docker"; Name = "Docker" },
        @{ Id = "ms-kubernetes-tools.vscode kubernetes-tools"; Name = "Kubernetes" },
        @{ Id = "gruntfuggly.todo-tree"; Name = "Todo Tree" }
    )
    
    Write-Host "${ANSI.TEXT_SECONDARY}Recommended Extensions:${ANSI.RESET}"
    for ($i = 0; $i -lt $extensions.Count; $i++) {
        $ext = $extensions[$i]
        Write-Host " ${ANSI.PURPLE}$($i + 1)${ANSI.RESET} ${ANSI.TEXT_PRIMARY}$($ext.Name)${ANSI.RESET}"
    }
    Write-Host ""
    
    $confirm = Confirm-KnouxAction "Install all recommended extensions?"
    
    if ($confirm) {
        Write-Host ""
        Write-Host "${ANSI.TEXT_SECONDARY}Installing extensions...${ANSI.RESET}"
        
        foreach ($ext in $extensions) {
            Write-Host "${ANSI.TEXT_SECONDARY} Installing $($ext.Name)...${ANSI.RESET}" -NoNewline
            try {
                & $vscodePath --install-extension $ext.Id --force 2>$null
                Write-Host " ${ANSI.GREEN}DONE${ANSI.RESET}"
            } catch {
                Write-Host " ${ANSI.RED}FAILED${ANSI.RESET}"
            }
        }
        
        Write-Host ""
        Write-Host "${ANSI.GREEN}✓ Extension installation complete!${ANSI.RESET}"
        Write-Host "${ANSI.TEXT_SECONDARY}Restart VS Code to see the changes.${ANSI.RESET}"
    }
    
    Write-Host ""
    Write-Host "${ANSI.TEXT_SECONDARY}Press any key to continue...${ANSI.RESET}"
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

Export-ModuleMember -Function @('Install-VSCodeExtensions')
