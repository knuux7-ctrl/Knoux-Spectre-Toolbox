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
    param([double]$Bytes)
    $units = "B", "KB", "MB", "GB", "TB"
    $unitIndex = 0
    while ($Bytes -gt 1024 -and $unitIndex -lt ($units.Length - 1)) {
        $Bytes /= 1024
        $unitIndex++
    }
    return "{0:N2} {1}" -f $Bytes, $units[$unitIndex]
}

function Confirm-KnouxAction {
    param(
        [string]$Prompt,
        [string]$DefaultChoice = "N"
    )
    $response = Read-Host "$Prompt (y/N)"
    if ([string]::IsNullOrWhiteSpace($response)) { $response = $DefaultChoice }
    return $response -eq "Y" -or $response -eq "y"
}

Export-ModuleMember -Function @('Test-AdminPrivilege', 'Format-KnouxBytes', 'Confirm-KnouxAction')
