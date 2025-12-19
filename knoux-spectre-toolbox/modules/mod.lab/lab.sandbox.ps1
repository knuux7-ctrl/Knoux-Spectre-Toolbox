<#
.SYNOPSIS
    Knoux Lab Sandbox - safe experiment runner
.DESCRIPTION
    Provides a lightweight sandbox menu for running experiments, snippets,
    and diagnostics without affecting production files. Includes transient
    temp folders, isolated PowerShell sessions, and simple container runners.
.NOTES
    Designed for local use only; does not implement hardened isolation.
#>

function Show-LabSandbox {
    [CmdletBinding()]
    param()

    Clear-ScreenWithBackground
    Write-Host "${ANSI.BG_DARK}${ANSI.CYAN}${ANSI.BOLD}🧪 LAB SANDBOX${ANSI.RESET}"
    Write-Host "${ANSI.BORDER}────────────────────────${ANSI.RESET}"
    Write-Host ""

    do {
        Write-Host "${ANSI.TEXT_SECONDARY}Sandbox Actions:${ANSI.RESET}"
        Write-Host " ${ANSI.CYAN}1${ANSI.RESET} ${ANSI.TEXT_PRIMARY}Run Script in Isolated Session${ANSI.RESET}"
        Write-Host " ${ANSI.CYAN}2${ANSI.RESET} ${ANSI.TEXT_PRIMARY}Run Quick Command (Transient)${ANSI.RESET}"
        Write-Host " ${ANSI.CYAN}3${ANSI.RESET} ${ANSI.TEXT_PRIMARY}Create Temporary Workspace${ANSI.RESET}"
        Write-Host " ${ANSI.CYAN}4${ANSI.RESET} ${ANSI.TEXT_PRIMARY}Start Lightweight Container (Docker)${ANSI.RESET}"
        Write-Host " ${ANSI.CYAN}5${ANSI.RESET} ${ANSI.TEXT_PRIMARY}Collect Diagnostics${ANSI.RESET}"
        Write-Host ""
        Write-Host " ${ANSI.RED}0${ANSI.RESET} ${ANSI.TEXT_PRIMARY}Back${ANSI.RESET}"
        Write-Host ""

        $choice = Read-ValidatedSubInput -Max 5

        switch ($choice) {
            0 { return }
            1 { Invoke-InIsolatedSession }
            2 { Run-TransientCommand }
            3 { New-TempWorkspace }
            4 { Start-LightContainer }
            5 { Collect-Diagnostics }
        }

        Write-Host ""
        Write-Host "${ANSI.TEXT_SECONDARY}Press any key to continue...${ANSI.RESET}"
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        Clear-ScreenWithBackground
    } while ($true)
}

function Invoke-InIsolatedSession {
    Write-Host ""
    Write-Host "${ANSI.PURPLE}${ANSI.BOLD}RUN SCRIPT IN ISOLATED SESSION${ANSI.RESET}"
    Write-Host "${ANSI.BORDER}──────────────────────────${ANSI.RESET}"
    Write-Host ""

    Write-Host "${ANSI.TEXT_SECONDARY}Enter path to script to run (or paste script content):${ANSI.RESET}"
    Write-Host "${ANSI.PURPLE}>>${ANSI.RESET} " -NoNewline
    $input = Read-Host

    if ([string]::IsNullOrWhiteSpace($input)) {
        Write-Host "${ANSI.RED}× No input provided${ANSI.RESET}"
        return
    }

    # If path exists, read file; otherwise treat input as inline script
    if (Test-Path $input) {
        $scriptContent = Get-Content -Path $input -Raw
    }
    else {
        $scriptContent = $input
    }

    Write-Host "${ANSI.TEXT_SECONDARY}Launching isolated PowerShell session...${ANSI.RESET}"

    $tempFile = Join-Path $env:TEMP "knx_lab_$(Get-Random).ps1"
    Set-Content -Path $tempFile -Value $scriptContent -Encoding UTF8

    try {
        # Start a new PowerShell process with no-profile to reduce cross-talk
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = (Get-Command pwsh -ErrorAction SilentlyContinue).Source
        if (-not $psi.FileName) { $psi.FileName = (Get-Command powershell -ErrorAction SilentlyContinue).Source }
        $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$tempFile`""
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true
        $psi.UseShellExecute = $false
        $proc = [System.Diagnostics.Process]::Start($psi)
        $out = $proc.StandardOutput.ReadToEnd()
        $err = $proc.StandardError.ReadToEnd()
        $proc.WaitForExit(60000) # 60s timeout

        Write-Host ""
        if ($out) { Write-Host "${ANSI.GREEN}--- OUTPUT ---${ANSI.RESET}`n$out" }
        if ($err) { Write-Host "${ANSI.RED}--- ERRORS ---${ANSI.RESET}`n$err" }
    }
    catch {
        Write-Host "${ANSI.RED}× Error running isolated session: $($_.Exception.Message)${ANSI.RESET}"
    }
    finally {
        Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
    }
}

function Run-TransientCommand {
    Write-Host ""
    Write-Host "${ANSI.PURPLE}${ANSI.BOLD}RUN TRANSIENT COMMAND${ANSI.RESET}"
    Write-Host "${ANSI.BORDER}─────────────────────${ANSI.RESET}"
    Write-Host ""
    Write-Host "${ANSI.TEXT_SECONDARY}Enter the command to run:${ANSI.RESET}"
    Write-Host "${ANSI.PURPLE}>>${ANSI.RESET} " -NoNewline
    $cmd = Read-Host

    if ([string]::IsNullOrWhiteSpace($cmd)) { Write-Host "${ANSI.RED}× No command provided${ANSI.RESET}"; return }

    try {
        $result = Invoke-Expression $cmd 2>&1
        Write-Host ""
        Write-Host "${ANSI.GREEN}--- RESULT ---${ANSI.RESET}"
        $result | ForEach-Object { Write-Host "$_" }
    }
    catch {
        Write-Host "${ANSI.RED}× Command failed: $($_.Exception.Message)${ANSI.RESET}"
    }
}

function New-TempWorkspace {
    Write-Host ""
    Write-Host "${ANSI.PURPLE}${ANSI.BOLD}CREATE TEMPORARY WORKSPACE${ANSI.RESET}"
    Write-Host "${ANSI.BORDER}──────────────────────────${ANSI.RESET}"
    Write-Host ""

    $tmp = Join-Path $env:TEMP "knx_lab_ws_$(Get-Random)"
    New-Item -ItemType Directory -Path $tmp | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $tmp "src") | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $tmp "data") | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $tmp "logs") | Out-Null

    Write-Host "${ANSI.GREEN}✓ Created temporary workspace: $tmp${ANSI.RESET}"
    Write-Host "${ANSI.TEXT_SECONDARY}This folder will be removed when you choose 'Clean Temp Workspaces'${ANSI.RESET}"
}

function Start-LightContainer {
    Write-Host ""
    Write-Host "${ANSI.PURPLE}${ANSI.BOLD}START LIGHTWEIGHT CONTAINER${ANSI.RESET}"
    Write-Host "${ANSI.BORDER}──────────────────────────${ANSI.RESET}"
    Write-Host ""

    # Ensure Docker is available
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        Write-Host "${ANSI.RED}× Docker not found in PATH. Install Docker to use this feature.${ANSI.RESET}"
        return
    }

    Write-Host "${ANSI.TEXT_SECONDARY}Enter Docker image (default: busybox:latest):${ANSI.RESET}"
    Write-Host "${ANSI.PURPLE}>>${ANSI.RESET} " -NoNewline
    $image = Read-Host
    if ([string]::IsNullOrWhiteSpace($image)) { $image = "busybox:latest" }

    Write-Host ""
    Write-Host "${ANSI.TEXT_SECONDARY}Running container in ephemeral mode...${ANSI.RESET}"

    try {
        $output = docker run --rm -it $image sh -c "echo 'Container started'; sleep 1; echo 'Exiting'" 2>&1
        Write-Host "$output"
    }
    catch {
        Write-Host "${ANSI.RED}× Error starting container: $($_.Exception.Message)${ANSI.RESET}"
    }
}

function Collect-Diagnostics {
    Write-Host ""
    Write-Host "${ANSI.PURPLE}${ANSI.BOLD}COLLECT DIAGNOSTICS${ANSI.RESET}"
    Write-Host "${ANSI.BORDER}──────────────────────${ANSI.RESET}"
    Write-Host ""

    $outputDir = Join-Path $PSScriptRoot "../../outputs/diagnostics_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    New-Item -ItemType Directory -Path $outputDir | Out-Null

    Write-Host "${ANSI.TEXT_SECONDARY}Gathering system info...${ANSI.RESET}"
    Get-ComputerInfo | Out-File -FilePath (Join-Path $outputDir "computerinfo.txt") -Encoding UTF8
    Get-Process | Sort-Object CPU -Descending | Select-Object -First 50 | Out-File (Join-Path $outputDir "top_processes.txt") -Encoding UTF8
    Get-Service | Out-File (Join-Path $outputDir "services.txt") -Encoding UTF8
    ipconfig /all | Out-File (Join-Path $outputDir "network.txt") -Encoding UTF8

    Write-Host "${ANSI.GREEN}✓ Diagnostics collected to: $outputDir${ANSI.RESET}"
}

Export-ModuleMember -Function @('Show-LabSandbox')
