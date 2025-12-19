<#
# file: config/dynamic.config.ps1
.SYNOPSIS
    Dynamic configuration manager with hot-reload support
#>

class DynamicConfigManager {
    [hashtable] $Config
    [string] $ConfigPath
    [System.IO.FileSystemWatcher] $Watcher
    [bool] $AutoReload

    DynamicConfigManager([string]$configPath, [bool]$autoReload = $true) {
        $this.ConfigPath = $configPath
        $this.AutoReload = $autoReload
        $this.LoadConfig()

        if ($autoReload) { $this.SetupWatcher() }
    }

    [void] LoadConfig() {
        if (Test-Path $this.ConfigPath) {
            $content = Get-Content -Path $this.ConfigPath -Raw
            $this.Config = $content | ConvertFrom-Json -AsHashtable
            Write-Host "🔧 Configuration loaded from $($this.ConfigPath)" -ForegroundColor Green
        }
        else {
            $this.Config = @{}
            Write-Warning "Configuration file not found. Using defaults."
        }
    }

    [void] SetupWatcher() {
        $this.Watcher = New-Object System.IO.FileSystemWatcher
        $this.Watcher.Path = Split-Path $this.ConfigPath -Parent
        $this.Watcher.Filter = Split-Path $this.ConfigPath -Leaf
        $this.Watcher.NotifyFilter = [System.IO.NotifyFilters]::LastWrite

        Register-ObjectEvent -InputObject $this.Watcher -EventName Changed -Action {
            Write-Host "🔄 Configuration file changed. Reloading..." -ForegroundColor Yellow
            $global:ConfigManager.LoadConfig()
        } | Out-Null

        $this.Watcher.EnableRaisingEvents = $true
    }

    [object] Get([string]$key, [object]$defaultValue = $null) {
        $keys = $key -split '\.'
        $current = $this.Config

        foreach ($k in $keys) {
            if ($current -and $current.ContainsKey($k)) { $current = $current[$k] } else { return $defaultValue }
        }

        return $current
    }

    [void] Set([string]$key, [object]$value) {
        $keys = $key -split '\.'
        $current = $this.Config

        for ($i = 0; $i -lt $keys.Length - 1; $i++) {
            $k = $keys[$i]
            if (-not $current.ContainsKey($k)) { $current[$k] = @{} }
            $current = $current[$k]
        }

        $current[$keys[-1]] = $value
        $this.SaveConfig()
    }

    [void] SaveConfig() {
        $json = $this.Config | ConvertTo-Json -Depth 10
        $json | Out-File -FilePath $this.ConfigPath -Encoding UTF8
        Write-Host "💾 Configuration saved to $($this.ConfigPath)" -ForegroundColor Green
    }

    [hashtable] GetAll() { return $this.Config.Clone() }

    [void] Merge([hashtable]$newConfig) { $this.MergeHashtables($this.Config, $newConfig); $this.SaveConfig() }

    [void] MergeHashtables([hashtable]$target, [hashtable]$source) {
        foreach ($key in $source.Keys) {
            if ($target.ContainsKey($key) -and $target[$key] -is [hashtable] -and $source[$key] -is [hashtable]) {
                $this.MergeHashtables($target[$key], $source[$key])
            }
            else { $target[$key] = $source[$key] }
        }
    }

    [void] Close() {
        if ($this.Watcher) { $this.Watcher.EnableRaisingEvents = $false; $this.Watcher.Dispose() }
    }
}

# Initialize global config manager
$global:ConfigManager = [DynamicConfigManager]::new((Join-Path $PSScriptRoot 'knoux.config.json'))
