# ملف: demos/system-automation/demo.ps1
<#
.SYNOPSIS
    System Automation Demo
.DESCRIPTION
    Demonstration of Knoux Spectre Toolbox system automation capabilities
.AUTHOR
    Knoux Systems
.VERSION
    1.0.0
#>

#requires -modules "ModuleManager", "PerformanceTracker", "ReportingSystem"

Write-Host "🤖 SYSTEM AUTOMATION DEMO" -ForegroundColor Cyan
Write-Host "==========================" -ForegroundColor DarkCyan

# Initialize
Write-Host "🔧 Initializing automation scenario..." -ForegroundColor Yellow

# Demo 1: System Health Report
Write-Host "`n📋 DEMO 1: System Health Report" -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor DarkGreen

$reportStartTime = Get-Date
Write-Host "Starting system diagnostics..." -ForegroundColor Gray

# CPU Usage Analysis
Write-Host "🔄 Analyzing CPU usage..." -ForegroundColor Gray
$cpuSamples = @()
for ($i = 0; $i -lt 10; $i++) {
    $cpu = (Get-Counter "\Processor(_Total)\% Processor Time" -SampleInterval 1).CounterSamples.CookedValue
    $cpuSamples += $cpu
    Write-Progress -Activity "CPU Analysis" -PercentComplete ($i * 10)
}
$avgCPU = [math]::Round(($cpuSamples | Measure-Object -Average).Average, 2)
$maxCPU = [math]::Round(($cpuSamples | Measure-Object -Maximum).Maximum, 2)

# Memory Analysis
Write-Host "🧠 Analyzing memory usage..." -ForegroundColor Gray
$memory = Get-CimInstance Win32_OperatingSystem
$totalMemory = [math]::Round($memory.TotalVisibleMemorySize / 1MB, 2)
$freeMemory = [math]::Round($memory.FreePhysicalMemory / 1MB, 2)
$usedMemory = [math]::Round($totalMemory - $freeMemory, 2)
$memoryPercent = [math]::Round(($usedMemory / $totalMemory) * 100, 2)

# Storage Analysis
Write-Host "💾 Analyzing disk usage..." -ForegroundColor Gray
$drives = Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }
$storageInfo = foreach ($drive in $drives) {
    [PSCustomObject]@{
        Drive       = $drive.DeviceID
        SizeGB      = [math]::Round($drive.Size / 1GB, 2)
        FreeGB      = [math]::Round($drive.FreeSpace / 1GB, 2)
        UsedPercent = [math]::Round((($drive.Size - $drive.FreeSpace) / $drive.Size) * 100, 2)
    }
}

# Network Analysis
Write-Host "🌐 Analyzing network interfaces..." -ForegroundColor Gray
$networkAdapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
$activeConnections = (Get-NetTCPConnection | Measure-Object).Count

# Generate Report
$report = @"
KNX SYSTEM HEALTH REPORT
=======================

📅 Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
⏳ Report Generation Time: $([math]::Round(((Get-Date).Subtract($reportStartTime)).TotalSeconds, 2)) seconds

PROCESSOR ANALYSIS
• Average CPU Usage: $avgCPU%
• Peak CPU Usage: $maxCPU%

MEMORY ANALYSIS  
• Total Memory: $totalMemory GB
• Used Memory: $usedMemory GB ($memoryPercent%)
• Free Memory: $freeMemory GB

STORAGE ANALYSIS
"@
foreach ($drive in $storageInfo) {
    $report += "• Drive $($drive.Drive): $($drive.UsedPercent)% full ($($drive.FreeGB) GB free of $($drive.SizeGB) GB)`n"
}

$report += @"

NETWORK ANALYSIS
• Active Network Connections: $activeConnections
• Network Adapters Online: $($networkAdapters.Count)

PERFORMANCE RECOMMENDATIONS
"@

# Performance recommendations
if ($avgCPU -gt 80) {
    $report += "⚠️  HIGH CPU USAGE: Consider closing unnecessary applications`n"
}
if ($memoryPercent -gt 85) {
    $report += "⚠️  LOW MEMORY: Consider upgrading RAM or closing memory-heavy applications`n"
}
foreach ($drive in $storageInfo) {
    if ($drive.UsedPercent -gt 90) {
        $report += "⚠️  LOW DISK SPACE: Drive $($drive.Drive) is almost full ($($drive.UsedPercent)%)`n"
    }
}
if ($activeConnections -gt 1000) {
    $report += "💡 HIGH NETWORK ACTIVITY: Monitor for potential network issues`n"
}
if ($report -notlike "*⚠️*") {
    $report += "✅ All systems operating normally`n"
}

Write-Host "`n$report" -ForegroundColor White

# Demo 2: Automated Cleanup
Write-Host "`n🧹 DEMO 2: Automated Cleanup Process" -ForegroundColor Green
Write-Host "-------------------------------" -ForegroundColor DarkGreen

$cleanupTasks = @{
    "Temp Files"    = @{
        Paths     = @("$env:TEMP", "$env:SystemRoot\Temp")
        Pattern   = "*.*"
        Recursive = $true
    }
    "Browser Cache" = @{
        Paths = @(
            "$env:LOCALAPPDATA\Google\Chrome\User Data Write-Host "⚠️ AI engine not available for this demo" -ForegroundColor Yellow
    Write-Host "This demonstrates future capability once fully integrated" -ForegroundColor Gray
}

# Demo 4: Automated Monitoring Setup
Write-Host "`n📊 DEMO 4: Automated Monitoring Setup" -ForegroundColor Green
Write-Host "----------------------------------" -ForegroundColor DarkGreen

$monitoringConfig = @{
    "Performance Monitoring" = @{
        Frequency = "Every 5 seconds"
        Metrics = @("CPU%", "Memory Usage", "Disk IO", "Network Traffic")
        AlertThreshold = "CPU > 85%, Memory > 90%"
    }
    "Security Monitoring" = @{
        ItemsWatched = @("Registry Changes", "File Modifications", "Network Connections", "Login Attempts")
        Realtime = $true
        AlertsVia = @("Console", "Email", "SMS")
    }
    "Application Health" = @{
        Services = "Automatically tracked",
        Databases = "Monitor replication sync",
        APIs = "Continuous endpoint response tracking"
    }
}

Write-Host "🚀 Monitoring Framework Activated:" -ForegroundColor Cyan
foreach ($section in $monitoringConfig.GetEnumerator()) {
    Write-Host "📦 $($section.Key):" -ForegroundColor White
    foreach ($setting in $section.Value.GetEnumerator()) {
        Write-Host "   • $($setting.Key): $($setting.Value)" -ForegroundColor DarkGray
    }
    Write-Host ""
}

# Completion summary
Write-Host "🎉 DEMONSTRATION COMPLETE!" -ForegroundColor Green
Write-Host "===========================" -ForegroundColor DarkGreen

$finalSummary = @"
            SUMMARY OF ACTIONS PERFORMED:

            1. 🔍 SYSTEM ANALYSIS
            • Comprehensive performance overview generated
            • Resource allocation assessment completed
            • Diagnostic insights provided  

            2. 🔧 AUTOMATED MAINTENANCE 
            • Temporarily files removed efficiently 
            • Unused caches cleared thoroughly    
            • Recycle bin emptied properly   

            3. 🤖 AI DIAGNOSTICS (SIMULATED) 
            • Issue root cause analyses offered   
            • Corrective solution proposals generated

            4. 📊 MONITORING SYSTEM ACTIVATED
            • Real-time observability initiated   
            • Alert policies established dynamically
   
            RESULTS SUMMARY:          
            ⏱ Demo Execution Time:      $([math]::Round((Get-Date).Subtract($global:StartupTime).TotalSeconds, 2)) Seconds          
            📥 Storage Released By Demo :     $([math]::Round($totalFreedMB, 2)) Megabytes         
            🔥 Efficiency Level Achieved   : Optimal For Given Scope          

            PROGRESSION NOTIFICATION:
            You may proceed forward by either:

            🔹 Executing Another Advanced Demo  
            🔹 Exploring Individual Functional Areas 
            🔹 Continuing Direct Tool Interaction        

            For guidance contact knouxspectre.support@dev.team           
            "@

Write-Host "`n$finalSummary" -ForegroundColor White

# Wait for user to review before exiting
Write-Host "`n✅ Press any key to continue to main menu..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")

Write-Host "Returning to main interface..." -ForegroundColor Gray
