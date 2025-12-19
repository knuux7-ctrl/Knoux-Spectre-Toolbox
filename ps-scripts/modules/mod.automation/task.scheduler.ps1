<#
.SYNOPSIS
    Knoux Spectre Automation Center
.DESCRIPTION
    Automate repetitive tasks and create scheduled jobs
.AUTHOR
    Knoux Systems
.VERSION
    1.0.0
#>

function Show-AutomationCenter {
    [CmdletBinding()]
    param()
    
    Write-Output @{
        modules = "Scheduled Tasks, PowerShell Jobs, Script Automation, System Maintenance, Workflow Designer"
        version = "1.0.0"
        status = "active"
    } | ConvertTo-Json
}

Export-ModuleMember -Function @('Show-AutomationCenter')
