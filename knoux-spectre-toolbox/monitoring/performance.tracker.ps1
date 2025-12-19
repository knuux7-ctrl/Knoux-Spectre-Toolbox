<#
# file: monitoring/performance.tracker.ps1
.SYNOPSIS
    PerformanceTracker for collecting system metrics
#>

using namespace System.Diagnostics
using namespace System.Collections.Concurrent

class PerformanceTracker {
    [ConcurrentQueue[object]] $MetricsQueue
    [Timer] $CollectionTimer
    [hashtable] $Counters
    [int] $CollectionIntervalMs
    [bool] $IsCollecting

    PerformanceTracker([int]$collectionIntervalMs = 5000) {
        $this.MetricsQueue = New-Object ConcurrentQueue[object]
        $this.Counters = @{}
        $this.CollectionIntervalMs = $collectionIntervalMs
        $this.IsCollecting = $false
        $this.InitializeCounters()
    }

    [void] InitializeCounters() {
        try {
            $this.Counters["cpu"] = New-Object System.Diagnostics.PerformanceCounter("Processor", "% Processor Time", "_Total")
            $this.Counters["memory_used"] = New-Object System.Diagnostics.PerformanceCounter("Memory", "Committed Bytes")
            $this.Counters["memory_available"] = New-Object System.Diagnostics.PerformanceCounter("Memory", "Available Bytes")
            $this.Counters["disk_reads"] = New-Object System.Diagnostics.PerformanceCounter("PhysicalDisk", "Disk Reads/sec", "_Total")
            $this.Counters["disk_writes"] = New-Object System.Diagnostics.PerformanceCounter("PhysicalDisk", "Disk Writes/sec", "_Total")
            $netAdapter = (Get-CimInstance Win32_NetworkAdapter | Where-Object {$_.NetEnabled} | Select-Object -First 1).Name
            if ($netAdapter) {
                $this.Counters["network_bytes_sent"] = New-Object System.Diagnostics.PerformanceCounter("Network Interface", "Bytes Sent/sec", $netAdapter)
                $this.Counters["network_bytes_received"] = New-Object System.Diagnostics.PerformanceCounter("Network Interface", "Bytes Received/sec", $netAdapter)
            }
            Write-Verbose "📈 Performance counters initialized"
        } catch { Write-Warning "Failed to initialize performance counters: $($_.Exception.Message)" }
    }

    [void] StartCollection() {
        if ($this.IsCollecting) { Write-Warning "Performance collection already started"; return }
        $this.IsCollecting = $true
        $callback = [TimerCallback]{ param($state) $state.CollectMetrics() }
        $this.CollectionTimer = New-Object Timers.Timer $this.CollectionIntervalMs
        $this.CollectionTimer.Elapsed.Add({ $this.CollectMetrics() })
        $this.CollectionTimer.Start()
        Write-Host "🚀 Performance monitoring started (interval: $($this.CollectionIntervalMs)ms)" -ForegroundColor Green
    }

    [void] StopCollection() {
        if ($this.CollectionTimer) { $this.CollectionTimer.Stop(); $this.CollectionTimer.Dispose(); $this.CollectionTimer = $null }
        $this.IsCollecting = $false
        Write-Host "🛑 Performance monitoring stopped" -ForegroundColor Yellow
    }

    [void] CollectMetrics() {
        try {
            $metrics = @{
                timestamp = Get-Date
                cpu_percent = [math]::Round($this.Counters["cpu"].NextValue(), 2)
                memory_used_mb = [math]::Round($this.Counters["memory_used"].NextValue() / 1MB, 2)
                memory_available_mb = [math]::Round($this.Counters["memory_available"].NextValue() / 1MB, 2)
                disk_reads_per_sec = [math]::Round($this.Counters["disk_reads"].NextValue(), 2)
                disk_writes_per_sec = [math]::Round($this.Counters["disk_writes"].NextValue(), 2)
                process_count = (Get-Process).Count
                module_count = if ($global:ModuleManager) { $global:ModuleManager.GetLoadedModules().Count } else { 0 }
            }

            try {
                $metrics.network_bytes_sent = [math]::Round($this.Counters["network_bytes_sent"].NextValue(), 2)
                $metrics.network_bytes_received = [math]::Round($this.Counters["network_bytes_received"].NextValue(), 2)
            } catch { $metrics.network_bytes_sent = 0; $metrics.network_bytes_received = 0 }

            $this.MetricsQueue.Enqueue($metrics)

            if ($global:ReportingSystem) { $global:ReportingSystem.LogSystemReport("performance", $metrics, "INFO", "system_monitor") }
        } catch { Write-Warning "Error collecting metrics: $($_.Exception.Message)" }
    }

    [object] GetLatestMetrics([int]$count = 10) {
        $metrics = @()
        $temp = New-Object Collections.Generic.Queue[object]
        while ($this.MetricsQueue.TryDequeue([ref]$null) -and $metrics.Count -lt $count) {
            $m = $null
            if ($this.MetricsQueue.TryPeek([ref]$m)) { $metrics += $m; $temp.Enqueue($m) }
        }
        while ($temp.Count -gt 0) { $this.MetricsQueue.Enqueue($temp.Dequeue()) }
        return $metrics
    }

    [hashtable] GetPerformanceStats() {
        $recentMetrics = $this.GetLatestMetrics(100)
        if ($recentMetrics.Count -eq 0) { return @{ message = "No metrics collected yet" } }
        $cpuAvg = ($recentMetrics | ForEach-Object { $_.cpu_percent } | Measure-Object -Average).Average
        $memAvg = ($recentMetrics | ForEach-Object { $_.memory_used_mb } | Measure-Object -Average).Average
        $procsAvg = ($recentMetrics | ForEach-Object { $_.process_count } | Measure-Object -Average).Average
        return @{ average_cpu = [math]::Round($cpuAvg,2); average_memory_mb = [math]::Round($memAvg,2); average_processes = [math]::Round($procsAvg,0); total_samples = $recentMetrics.Count; uptime_minutes = [math]::Round(((Get-Date) - $recentMetrics[0].timestamp).TotalMinutes,2) }
    }

    [void] GenerateReport([string]$outputPath = $null) {
        $stats = $this.GetPerformanceStats()
        $latest = $this.GetLatestMetrics(5)
        $report = @"Knoux Spectre Toolbox - Performance Report
=========================================
Generated: $(Get-Date)

SUMMARY:
--------
Average CPU Usage: $($stats.average_cpu)%
Average Memory Usage: $($stats.average_memory_mb) MB
Average Process Count: $($stats.average_processes)
Total Samples: $($stats.total_samples)
Monitoring Uptime: $($stats.uptime_minutes) minutes

RECENT METRICS:
---------------
"@
        foreach ($metric in $latest) {
            $report += "Time: $($metric.timestamp.ToString('HH:mm:ss'))`nCPU: $($metric.cpu_percent)%`nMemory: $($metric.memory_used_mb) MB`nProcesses: $($metric.process_count)`nDisk R/W: $($metric.disk_reads_per_sec)/$($metric.disk_writes_per_sec) ops/sec`n`n"
        }
        if ($outputPath) { $report | Out-File -FilePath $outputPath -Encoding UTF8; Write-Host "📊 Performance report saved to: $outputPath" -ForegroundColor Green } else { Write-Host $report }
    }

    [void] AlertOnThreshold([string]$metricName, [double]$threshold, [string]$operator = "gt") {
        $latest = $this.GetLatestMetrics(1)
        if ($latest.Count -eq 0) { return }
        $value = $latest[0].$metricName
        $alert = switch ($operator) { 'gt' { $value -gt $threshold } 'lt' { $value -lt $threshold } 'gte' { $value -ge $threshold } 'lte' { $value -le $threshold } 'eq' { $value -eq $threshold } default { $false } }
        if ($alert) {
            Write-Warning "🚨 Performance Alert: $metricName = $value (threshold: $operator $threshold)"
            if ($global:ReportingSystem) { $global:ReportingSystem.LogSystemReport('performance_alert', @{ metric = $metricName; value = $value; threshold = $threshold; operator = $operator }, 'WARNING', 'performance_tracker') }
        }
    }

    [void] Close() { $this.StopCollection(); if ($this.Counters) { foreach ($counter in $this.Counters.Values) { if ($counter -is [PerformanceCounter]) { $counter.Dispose() } } } }
}

# Initialize global performance tracker
$global:PerformanceTracker = [PerformanceTracker]::new(5000)
