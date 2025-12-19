<#
.SYNOPSIS
    Knoux Spectre Event Log Viewer
.DESCRIPTION
    View and analyze Windows event logs
.AUTHOR
    Knoux Systems
.VERSION
    1.0.0
#>

function Get-SystemEventLogs {
    param(
        [int]$MaxEvents = 50
    )
    try {
        $events = Get-EventLog -LogName System -Newest $MaxEvents -ErrorAction SilentlyContinue | Select-Object TimeGenerated, EntryType, Source, Message
        return @{ success = $true; data = $events; count = $events.Count }
    } catch {
        return @{ success = $false; error = $_.Exception.Message }
    }
}

function Show-EventLogViewer {
    param(
        [string]$LogName = "System",
        [int]$MaxEvents = 50
    )
    
    $result = switch($LogName) {
        "System" { Get-SystemEventLogs -MaxEvents $MaxEvents }
        "Application" { 
            try {
                $events = Get-EventLog -LogName Application -Newest $MaxEvents -ErrorAction SilentlyContinue
                @{ success = $true; data = $events; count = $events.Count }
            } catch {
                @{ success = $false; error = $_.Exception.Message }
            }
        }
        default { @{ success = $false; error = "Unknown log: $LogName" } }
    }
    
    return $result | ConvertTo-Json
}

Export-ModuleMember -Function @('Show-EventLogViewer', 'Get-SystemEventLogs')
