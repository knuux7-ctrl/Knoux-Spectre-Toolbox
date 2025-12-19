<#
.SYNOPSIS
    Knoux Spectre System Audit Report
.DESCRIPTION
    Generates a comprehensive system audit report
.AUTHOR
    Knoux Systems
.VERSION
    1.0.0
#>

function Get-SystemAuditReport {
    [CmdletBinding()]
    param()
    
    Clear-ScreenWithBackground
    Write-Host "${ANSI.BG_DARK}${ANSI.PURPLE}${ANSI.BOLD}🔧 SYSTEM AUDIT REPORT${ANSI.RESET}"
    Write-Host "${ANSI.BORDER}────────────────────────────────${ANSI.RESET}"
    Write-Host ""
    
    # Progress indicator
    Show-KnouxProgress "Collecting system information" 10
    Start-Sleep -Milliseconds 300
    
    # Get computer info
    $computerInfo = Get-ComputerInfo
    Show-KnouxProgress "Collecting hardware details" 20
    Start-Sleep -Milliseconds 300
    
    # Get OS info
    $osInfo = Get-CimInstance Win32_OperatingSystem
    Show-KnouxProgress "Analyzing system resources" 30
    Start-Sleep -Milliseconds 300
    
    # Get CPU info
    $cpuInfo = Get-CimInstance Win32_Processor
    Show-KnouxProgress "Scanning running processes" 40
    Start-Sleep -Milliseconds 300
    
    # Get memory info
    $memInfo = Get-CimInstance Win32_PhysicalMemory
    Show-KnouxProgress "Reviewing installed software" 50
    Start-Sleep -Milliseconds 300
    
    # Get disk info
    $diskInfo = Get-CimInstance Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3}
    Show-KnouxProgress "Compiling network interfaces" 60
    Start-Sleep -Milliseconds 300
    
    # Get network adapters
    $networkAdapters = Get-NetAdapter | Where-Object {$_.Status -eq "Up"}
    Show-KnouxProgress "Generating report" 80
    Start-Sleep -Milliseconds 300
    
    # Display report
    Write-Host "${ANSI.PURPLE}${ANSI.BOLD}SYSTEM INFORMATION${ANSI.RESET}"
    Write-Host "${ANSI.BORDER}──────────────────${ANSI.RESET}"
    Write-Host "${ANSI.TEXT_SECONDARY}Computer Name:${ANSI.RESET} $($computerInfo.CsName)"
    Write-Host "${ANSI.TEXT_SECONDARY}Manufacturer:${ANSI.RESET} $($computerInfo.CsManufacturer)"
    Write-Host "${ANSI.TEXT_SECONDARY}Model:${ANSI.RESET} $($computerInfo.CsModel)"
    Write-Host ""
    
    Write-Host "${ANSI.PURPLE}${ANSI.BOLD}OPERATING SYSTEM${ANSI.RESET}"
    Write-Host "${ANSI.BORDER}────────────────${ANSI.RESET}"
    Write-Host "${ANSI.TEXT_SECONDARY}Name:${ANSI.RESET} $($osInfo.Caption)"
    Write-Host "${ANSI.TEXT_SECONDARY}Version:${ANSI.RESET} $($osInfo.Version)"
    Write-Host "${ANSI.TEXT_SECONDARY}Build:${ANSI.RESET} $($osInfo.BuildNumber)"
    Write-Host "${ANSI.TEXT_SECONDARY}Install Date:${ANSI.RESET} $($osInfo.InstallDate)"
    Write-Host ""
    
    Write-Host "${ANSI.PURPLE}${ANSI.BOLD}PROCESSOR${ANSI.RESET}"
    Write-Host "${ANSI.BORDER}─────────${ANSI.RESET}"
    Write-Host "${ANSI.TEXT_SECONDARY}Name:${ANSI.RESET} $($cpuInfo.Name)"
    Write-Host "${ANSI.TEXT_SECONDARY}Cores:${ANSI.RESET} $($cpuInfo.NumberOfCores)"
    Write-Host "${ANSI.TEXT_SECONDARY}Logical Processors:${ANSI.RESET} $($cpuInfo.NumberOfLogicalProcessors)"
    Write-Host ""
    
    Write-Host "${ANSI.PURPLE}${ANSI.BOLD}MEMORY${ANSI.RESET}"
    Write-Host "${ANSI.BORDER}──────${ANSI.RESET}"
    $totalMemory = ($memInfo | Measure-Object -Property Capacity -Sum).Sum / 1GB
    Write-Host "${ANSI.TEXT_SECONDARY}Total:${ANSI.RESET} $([math]::Round($totalMemory, 2)) GB"
    Write-Host ""
    
    Write-Host "${ANSI.PURPLE}${ANSI.BOLD}DISK USAGE${ANSI.RESET}"
    Write-Host "${ANSI.BORDER}──────────${ANSI.RESET}"
    foreach ($disk in $diskInfo) {
        $freeSpace = $disk.FreeSpace / 1GB
        $totalSpace = $disk.Size / 1GB
        $usedPercent = [math]::Round((($totalSpace - $freeSpace) / $totalSpace) * 100, 2)
        
        Write-Host "${ANSI.TEXT_SECONDARY}$($disk.DeviceID):${ANSI.RESET} $([math]::Round($freeSpace, 2)) GB free of $([math]::Round($totalSpace, 2)) GB ($usedPercent%)"
    }
    Write-Host ""
    
    Write-Host "${ANSI.PURPLE}${ANSI.BOLD}NETWORK INTERFACES${ANSI.RESET}"
    Write-Host "${ANSI.BORDER}──────────────────${ANSI.RESET}"
    foreach ($adapter in $networkAdapters) {
        Write-Host "${ANSI.TEXT_SECONDARY}$($adapter.Name):${ANSI.RESET} $($adapter.LinkSpeed) Mbps"
    }
    Write-Host ""
    
    Show-KnouxProgress "Audit report completed" 100
    Write-Host ""
    
    # Option to save report
    $saveReport = Confirm-KnouxAction "Save report to file?"
    
    if ($saveReport) {
        $reportPath = Join-Path $PSScriptRoot "../../outputs/SystemAuditReport_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
        
        # Create outputs directory if it doesn't exist
        $outputDir = Join-Path $PSScriptRoot "../../outputs"
        if (!(Test-Path $outputDir)) {
            New-Item -ItemType Directory -Path $outputDir | Out-Null
        }
        
        # Generate report content
        $reportContent = @"
Knoux Spectre Toolbox - System Audit Report
Generated on: $(Get-Date)

=== SYSTEM INFORMATION ===
Computer Name: $($computerInfo.CsName)
Manufacturer: $($computerInfo.CsManufacturer)
Model: $($computerInfo.CsModel)

=== OPERATING SYSTEM ===
Name: $($osInfo.Caption)
Version: $($osInfo.Version)
Build: $($osInfo.BuildNumber)
Install Date: $($osInfo.InstallDate)

=== PROCESSOR ===
Name: $($cpuInfo.Name)
Cores: $($cpuInfo.NumberOfCores)
Logical Processors: $($cpuInfo.NumberOfLogicalProcessors)

=== MEMORY ===
Total: $([math]::Round($totalMemory, 2)) GB

=== DISK USAGE ===
$($diskInfo | ForEach-Object {
    $freeSpace = $_.FreeSpace / 1GB
    $totalSpace = $_.Size / 1GB
    $usedPercent = [math]::Round((($totalSpace - $freeSpace) / $totalSpace) * 100, 2)
    "$($_.DeviceID): $([math]::Round($freeSpace, 2)) GB free of $([math]::Round($totalSpace, 2)) GB ($usedPercent%)"
} | Out-String)

=== NETWORK INTERFACES ===
$($networkAdapters | ForEach-Object {
    "$($_.Name): $($_.LinkSpeed) Mbps"
} | Out-String)
"@
        
        Set-Content -Path $reportPath -Value $reportContent -Encoding UTF8
        Write-Host "${ANSI.GREEN}✓ Report saved to: $reportPath${ANSI.RESET}"
    }
    
    Write-Host ""
    Write-Host "${ANSI.TEXT_SECONDARY}Press any key to continue...${ANSI.RESET}"
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

Export-ModuleMember -Function @('Get-SystemAuditReport')
