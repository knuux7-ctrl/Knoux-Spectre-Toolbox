<#
.SYNOPSIS
    Shared helper functions for Knoux Spectre Toolbox
#>

function Test-AdminPrivilege {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Format-KnouxBytes {
    param([double]$Bytes)
    $units = 'B','KB','MB','GB','TB'
    $i = 0
    while ($Bytes -gt 1024 -and $i -lt ($units.Length - 1)) { $Bytes /= 1024; $i++ }
    "{0:N2} {1}" -f $Bytes, $units[$i]
}

function Show-KnouxProgress {
    param([string]$Message,[int]$PercentComplete=0)
    Write-Host $Message -NoNewline
    if ($PercentComplete -gt 0) { Write-Host " ($PercentComplete%)" }
}

function Confirm-KnouxAction {
    param([string]$Prompt,[string]$DefaultChoice='N')
    do {
        Write-Host "$Prompt ($DefaultChoice): " -NoNewline
        $r = Read-Host
        if ([string]::IsNullOrWhiteSpace($r)) { $r = $DefaultChoice }
        switch ($r.ToUpper()) { 'Y' { return $true } 'N' { return $false } default { Write-Host "Please answer Y or N" } }
    } while ($true)
}

function Write-Log {
    param([string]$Message,[string]$Level='INFO')
    $ts = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $log = "[$ts] [$Level] $Message"
    $logsDir = Join-Path $PSScriptRoot "..\logs"
    if (!(Test-Path $logsDir)) { New-Item -Path $logsDir -ItemType Directory -Force | Out-Null }
    $logFile = Join-Path $logsDir "knoux_$(Get-Date -Format 'yyyyMMdd').log"
    Add-Content -Path $logFile -Value $log -Encoding UTF8
}

function Clear-ScreenWithBackground { Clear-Host }

Export-ModuleMember -Function @('Test-AdminPrivilege','Format-KnouxBytes','Show-KnouxProgress','Confirm-KnouxAction','Write-Log','Clear-ScreenWithBackground')
<#
.SYNOPSIS
    Knoux Spectre Toolbox Shared Helper Functions
.DESCRIPTION
    Collection of reusable utility functions for modules
.AUTHOR
    Knoux Systems
.VERSION
    1.0.0
#>

function Test-AdminPrivilege {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Format-KnouxBytes {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [double]$Bytes
    )
    
    $units = "B", "KB", "MB", "GB", "TB"
    $unitIndex = 0
    
    while ($Bytes -gt 1024 -and $unitIndex -lt ($units.Length - 1)) {
        $Bytes /= 1024
        $unitIndex++
    }
    
    return "{0:N2} {1}" -f $Bytes, $units[$unitIndex]
}

function Show-KnouxProgress {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [int]$PercentComplete = 0
    )
    
    Write-Host "${ANSI.TEXT_SECONDARY}${Message}${ANSI.RESET}" -NoNewline
    
    if ($PercentComplete -gt 0) {
        Write-Host " (${ANSI.PURPLE}${PercentComplete}%${ANSI.RESET})" -NoNewline
    }
    
    Write-Host ""
}

function Confirm-KnouxAction {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Prompt,
        [string]$DefaultChoice = "N"
    )
    
    do {
        Write-Host "${ANSI.ORANGE}? ${Prompt} ${ANSI.RESET}" -NoNewline
        
        if ($DefaultChoice -eq "Y") {
            Write-Host "${ANSI.TEXT_SECONDARY}(Y/n)${ANSI.RESET}: " -NoNewline
        }
        else {
            Write-Host "${ANSI.TEXT_SECONDARY}(y/N)${ANSI.RESET}: " -NoNewline
        }
        
        $response = Read-Host
        
        if ([string]::IsNullOrWhiteSpace($response)) {
            $response = $DefaultChoice
        }
        
        switch ($response.ToUpper()) {
            "Y" { return $true }
            "N" { return $false }
            default { 
                Write-Host "${ANSI.RED}× Please answer Y or N.${ANSI.RESET}"
            }
        }
    } while ($true)
}

Export-ModuleMember -Function @(
    'Test-AdminPrivilege',
    'Format-KnouxBytes',
    'Show-KnouxProgress',
    'Confirm-KnouxAction'
)
