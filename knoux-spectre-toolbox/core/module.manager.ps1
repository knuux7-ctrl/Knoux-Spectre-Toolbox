<#
# file: core/module.manager.ps1
.SYNOPSIS
    ModuleManager for loading and managing modules
#>

using namespace System.Collections.Concurrent
using namespace System.Threading.Tasks

class ModuleManager {
    [hashtable] $LoadedModules
    [ConcurrentDictionary[string, object]] $ModuleCache
    [hashtable] $Dependencies
    [bool] $LazyLoad

    ModuleManager([bool]$lazyLoad = $true) {
        $this.LoadedModules = @{}
        $this.ModuleCache = New-Object ConcurrentDictionary[string, object]
        $this.Dependencies = @{}
        $this.LazyLoad = $lazyLoad
    }

    [void] LoadModule([string]$moduleName) {
        if ($this.LoadedModules.ContainsKey($moduleName)) { Write-Verbose "🔄 Module $moduleName already loaded"; return }

        $modulePath = Join-Path $PSScriptRoot "..\modules\$moduleName"
        if (-not (Test-Path $modulePath)) { throw "Module $moduleName not found at $modulePath" }

        try {
            $ps1Files = Get-ChildItem -Path $modulePath -Filter "*.ps1" -Recurse
            foreach ($file in $ps1Files) { . $file.FullName; Write-Verbose "_IMPORTED: $($file.Name)" }

            $this.LoadedModules[$moduleName] = @{
                Path = $modulePath
                LoadedAt = Get-Date
                Files = $ps1Files.Count
            }

            Write-Host "✅ Module $moduleName loaded successfully" -ForegroundColor Green
        } catch { throw "Failed to load module $moduleName : $($_.Exception.Message)" }
    }

    [void] LoadAllModules() {
        $config = $global:ConfigManager.GetAll()
        $enabledModules = $config.modules.enabled

        Write-Host "📦 Loading $($enabledModules.Count) modules..." -ForegroundColor Cyan

        $tasks = foreach ($moduleName in $enabledModules) {
            [Task]::Run({
                try { $this.LoadModule($moduleName); return [PSCustomObject]@{ Module = $moduleName; Success = $true; Error = $null } }
                catch { return [PSCustomObject]@{ Module = $moduleName; Success = $false; Error = $_.Exception.Message } }
            })
        }

        [Task]::WaitAll($tasks) | Out-Null
        $results = $tasks | ForEach-Object { $_.Result }

        $successCount = ($results | Where-Object { $_.Success }).Count
        $failedCount = $results.Count - $successCount

        Write-Host "📊 Load Results: $successCount succeeded, $failedCount failed" -ForegroundColor ($failedCount -gt 0 ? "Yellow" : "Green")

        if ($failedCount -gt 0) {
            Write-Warning "Failed modules:"
            $results | Where-Object { -not $_.Success } | ForEach-Object { Write-Warning "  $($_.Module): $($_.Error)" }
        }
    }

    [object] GetCachedModule([string]$moduleName, [scriptblock]$loader) {
        $existing = $null
        if ($this.ModuleCache.TryGetValue($moduleName, [ref]$existing)) { return $existing }
        $module = & $loader
        $this.ModuleCache.TryAdd($moduleName, $module) | Out-Null
        return $module
    }

    [void] UnloadModule([string]$moduleName) {
        if ($this.LoadedModules.ContainsKey($moduleName)) {
            $this.ModuleCache.TryRemove($moduleName, [ref]$null) | Out-Null
            $this.LoadedModules.Remove($moduleName)
            Write-Host "⏏ Module $moduleName unloaded" -ForegroundColor Yellow
        }
    }

    [hashtable] GetModuleInfo([string]$moduleName) { return $this.LoadedModules[$moduleName] ?: $null }

    [string[]] GetLoadedModules() { return [string[]]($this.LoadedModules.Keys) }

    [bool] IsModuleLoaded([string]$moduleName) { return $this.LoadedModules.ContainsKey($moduleName) }

    [void] ReloadModule([string]$moduleName) { $this.UnloadModule($moduleName); $this.LoadModule($moduleName); Write-Host "🔄 Module $moduleName reloaded" -ForegroundColor Green }

    [void] RegisterDependency([string]$moduleName, [string[]]$dependencies) { $this.Dependencies[$moduleName] = $dependencies }

    [string[]] GetDependencies([string]$moduleName) { return $this.Dependencies[$moduleName] ?: @() }

    [hashtable] GetModuleStats() {
        return @{
            TotalLoaded = $this.LoadedModules.Count
            CacheSize = $this.ModuleCache.Count
            MemoryUsage = (Get-Process -Id $PID).WorkingSet64 / 1MB
            LoadTimeAvg = if ($this.LoadedModules.Count -gt 0) { ($this.LoadedModules.Values | ForEach-Object { $_.LoadedAt } | Measure-Object -Average).Average } else { 0 }
        }
    }
}

# Initialize global module manager
$global:ModuleManager = [ModuleManager]::new($true)
