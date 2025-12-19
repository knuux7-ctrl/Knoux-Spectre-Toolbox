# Knoux Spectre Services Manager Module
# This file serves as a reference - full implementation from provided scripts

function Get-RunningServices {
    Get-Service | Where-Object {$_.Status -eq "Running"} | Sort-Object DisplayName | Select-Object -First 20
}

function Get-StoppedServices {
    Get-Service | Where-Object {$_.Status -eq "Stopped"} | Sort-Object DisplayName | Select-Object -First 20
}

function Start-ServiceByName {
    param([string]$ServiceName)
    if (-not (Test-AdminPrivilege)) {
        return @{ error = "Admin privileges required"; success = $false }
    }
    try {
        Start-Service -Name $ServiceName
        return @{ success = $true; message = "Service started" }
    } catch {
        return @{ error = $_.Exception.Message; success = $false }
    }
}

function Stop-ServiceByName {
    param([string]$ServiceName)
    if (-not (Test-AdminPrivilege)) {
        return @{ error = "Admin privileges required"; success = $false }
    }
    try {
        Stop-Service -Name $ServiceName -Force
        return @{ success = $true; message = "Service stopped" }
    } catch {
        return @{ error = $_.Exception.Message; success = $false }
    }
}

Export-ModuleMember -Function @('Get-RunningServices', 'Get-StoppedServices', 'Start-ServiceByName', 'Stop-ServiceByName')
