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

function Get-ANSIValue {
    param([string]$Key)
    if ($null -ne $script:ANSI -and $script:ANSI.ContainsKey($Key)) { return $script:ANSI[$Key] }
    return ''
}

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
    while ($Bytes -gt 1024 -and $unitIndex -lt ($units.Length - 1)) { $Bytes /= 1024; $unitIndex++ }
    return "{0:N2} {1}" -f $Bytes, $units[$unitIndex]
}

function Show-KnouxProgress {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$Message,
        [int]$PercentComplete = 0
    )
    $textSec = Get-ANSIValue -Key 'TEXT_SECONDARY'
    $reset = Get-ANSIValue -Key 'RESET'
    Write-Host "${textSec}${Message}${reset}" -NoNewline
    if ($PercentComplete -gt 0) { $purple = Get-ANSIValue -Key 'PURPLE'; $reset = Get-ANSIValue -Key 'RESET'; Write-Host " (${purple}${PercentComplete}%${reset})" -NoNewline }
    Write-Host ""
}

function Confirm-KnouxAction {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$Prompt,
        [string]$DefaultChoice = "N"
    )
    do {
        $orange = Get-ANSIValue -Key 'ORANGE'
        $textSec = Get-ANSIValue -Key 'TEXT_SECONDARY'
        $reset = Get-ANSIValue -Key 'RESET'
        Write-Host "${orange}? ${Prompt} ${reset}" -NoNewline
        if ($DefaultChoice -eq "Y") { Write-Host "${textSec}(Y/n)${reset}: " -NoNewline } else { Write-Host "${textSec}(y/N)${reset}: " -NoNewline }
        $response = Read-Host
        if ([string]::IsNullOrWhiteSpace($response)) { $response = $DefaultChoice }
        switch ($response.ToUpper()) { "Y" { return $true } "N" { return $false } default { Write-Host "Please answer Y or N" } }
    } while ($true)
}

function Write-Log {
    [CmdletBinding()]
    param([string]$Message, [string]$Level = 'INFO')
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    $logsDir = Join-Path $PSScriptRoot "..\logs"
    if (!(Test-Path $logsDir)) { New-Item -ItemType Directory -Path $logsDir -Force | Out-Null }
    $logFile = Join-Path $logsDir "knoux_$(Get-Date -Format 'yyyyMMdd').log"
    Add-Content -Path $logFile -Value $logMessage -Encoding UTF8
}

function Clear-ScreenWithBackground { Clear-Host }

Export-ModuleMember -Function @(
    'Test-AdminPrivilege',
    'Format-KnouxBytes',
    'Show-KnouxProgress',
    'Confirm-KnouxAction',
    'Write-Log',
    'Clear-ScreenWithBackground'
)
