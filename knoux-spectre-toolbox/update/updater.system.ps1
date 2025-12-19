using namespace System.Net.Http
using namespace System.Security.Cryptography
using namespace System.IO.Compression

class SmartUpdater {
    [string] $CurrentVersion
    [string] $UpdateChannel
    [string] $ApiEndpoint
    [HttpClient] $HttpClient
    [hashtable] $UpdateConfig
    [bool] $AutoUpdateEnabled
    
    SmartUpdater([string]$currentVersion = "1.0.0", [string]$channel = "stable") {
        $this.CurrentVersion = $currentVersion
        $this.UpdateChannel = $channel
        $this.ApiEndpoint = "https://api.knoux.io/updates"
        $this.HttpClient = New-Object HttpClient
        $this.AutoUpdateEnabled = $global:ConfigManager.Get("updates.auto", $false)
        $this.LoadUpdateConfig()
    }
    
    [void] LoadUpdateConfig() {
        $configPath = "./config/update.config.json"
        if (Test-Path $configPath) {
            $content = Get-Content $configPath -Raw
            $this.UpdateConfig = $content | ConvertFrom-Json -AsHashtable
        }
        else {
            $this.UpdateConfig = @{
                last_check       = (Get-Date).AddDays(-1)
                last_update      = $null
                ignored_versions = @()
                proxy_settings   = @{
                    enabled  = $false
                    address  = ""
                    username = ""
                }
            }
            $this.SaveUpdateConfig()
        }
    }
    
    [void] SaveUpdateConfig() {
        $configPath = "./config/update.config.json"
        $dir = Split-Path $configPath -Parent
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir | Out-Null
        }
        
        $json = $this.UpdateConfig | ConvertTo-Json -Depth 5
        $json | Out-File -FilePath $configPath -Encoding UTF8
    }
    
    [object] CheckForUpdates([bool]$force = $false) {
        # Check if we should skip based on config
        if (-not $force) {
            $hoursSinceLastCheck = (Get-Date).Subtract($this.UpdateConfig.last_check).TotalHours
            if ($hoursSinceLastCheck -lt 24) {
                Write-Verbose "⏭ Skipping update check (checked recently)"
                return $null
            }
        }
        
        try {
            Write-Host "🔍 Checking for updates..." -ForegroundColor Cyan
            
            $url = "$($this.ApiEndpoint)/check?version=$($this.CurrentVersion)&channel=$($this.UpdateChannel)&os=windows&arch=x64"
            $response = $this.HttpClient.GetAsync($url).Result
            $content = $response.Content.ReadAsStringAsync().Result
            
            if ($response.IsSuccessStatusCode) {
                $updateInfo = $content | ConvertFrom-Json
                $this.UpdateConfig.last_check = Get-Date
                $this.SaveUpdateConfig()
                
                if ($updateInfo.available -and $updateInfo.version -ne $this.CurrentVersion) {
                    # Check if version is ignored
                    if ($this.UpdateConfig.ignored_versions -contains $updateInfo.version) {
                        Write-Host "⏭ Ignored update version: $($updateInfo.version)" -ForegroundColor Yellow
                        return $null
                    }
                    
                    Write-Host "🆕 Update available: $($updateInfo.version)" -ForegroundColor Green
                    return $updateInfo
                }
                else {
                    Write-Host "✅ System is up to date (v$($this.CurrentVersion))" -ForegroundColor Green
                    return $null
                }
            }
            else {
                Write-Warning "Failed to check for updates: HTTP $($response.StatusCode)"
                return $null
            }
        }
        catch {
            Write-Warning "Error checking for updates: $($_.Exception.Message)"
            return $null
        }
    }
    
    [bool] DownloadUpdate([object]$updateInfo) {
        if (-not $updateInfo.download_url) {
            Write-Error "No download URL provided in update info"
            return $false
        }
        
        try {
            Write-Host "📥 Downloading update v$($updateInfo.version)..." -ForegroundColor Cyan
            
            # Create temp directory
            $tempDir = Join-Path $env:TEMP "knoux_update_$(Get-Random)"
            if (-not (Test-Path $tempDir)) {
                New-Item -ItemType Directory -Path $tempDir | Out-Null
            }
            
            $downloadPath = Join-Path $tempDir "update.zip"
            
            # Download with progress
            $progressPreference = 'Continue'
            Invoke-WebRequest -Uri $updateInfo.download_url -OutFile $downloadPath -Verbose
            
            # Verify checksum if provided
            if ($updateInfo.checksum) {
                $fileHash = (Get-FileHash -Path $downloadPath -Algorithm SHA256).Hash
                if ($fileHash -ne $updateInfo.checksum) {
                    Write-Error "Checksum mismatch. Expected: $($updateInfo.checksum), Got: $fileHash"
                    Remove-Item -Path $tempDir -Recurse -Force
                    return $false
                }
                Write-Host "✅ Checksum verified" -ForegroundColor Green
            }
            
            # Extract update
            $extractPath = Join-Path $tempDir "extracted"
            Expand-Archive -Path $downloadPath -DestinationPath $extractPath -Force
            
            # Store update info for installation
            $updateInfo | Add-Member -NotePropertyName "temp_path" -NotePropertyValue $tempDir
            $updateInfo | Add-Member -NotePropertyName "extract_path" -NotePropertyValue $extractPath
            
            Write-Host "✅ Update downloaded successfully" -ForegroundColor Green
            return $true
            
        }
        catch {
            Write-Error "Failed to download update: $($_.Exception.Message)"
            return $false
        }
    }
    
    [bool] InstallUpdate([object]$updateInfo) {
        try {
            Write-Host "⚡ Installing update v$($updateInfo.version)..." -ForegroundColor Yellow
            
            # Backup current installation
            $backupPath = "./backups/knoux_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
            if (-not (Test-Path "./backups")) {
                New-Item -ItemType Directory -Path "./backups" | Out-Null
            }
            
            Write-Host "💾 Creating backup..." -ForegroundColor Cyan
            Copy-Item -Path "." -Destination $backupPath -Recurse -Exclude @("temp", "logs", "backups") | Out-Null
            
            # Install new files
            Write-Host "🔄 Installing new files..." -ForegroundColor Cyan
            $filesToUpdate = Get-ChildItem -Path $updateInfo.extract_path -Recurse -File
            
            foreach ($file in $filesToUpdate) {
                $relativePath = $file.FullName.Substring($updateInfo.extract_path.Length + 1)
                $destinationPath = Join-Path "." $relativePath
                
                # Create directory if needed
                $destinationDir = Split-Path $destinationPath -Parent
                if (-not (Test-Path $destinationDir)) {
                    New-Item -ItemType Directory -Path $destinationDir | Out-Null
                }
                
                Copy-Item -Path $file.FullName -Destination $destinationPath -Force
            }
            
            # Update version info
            $this.CurrentVersion = $updateInfo.version
            $this.UpdateConfig.last_update = Get-Date
            $this.SaveUpdateConfig()
            
            # Clean up temp files
            Remove-Item -Path $updateInfo.temp_path -Recurse -Force
            
            Write-Host "✅ Update v$($updateInfo.version) installed successfully!" -ForegroundColor Green
            Write-Host "🔄 Please restart the application to apply changes" -ForegroundColor Yellow
            
            return $true
            
        }
        catch {
            Write-Error "Failed to install update: $($_.Exception.Message)"
            return $false
        }
    }
    
    [void] AutoUpdate() {
        if (-not $this.AutoUpdateEnabled) {
            return
        }
        
        $updateInfo = $this.CheckForUpdates()
        if ($updateInfo -and $updateInfo.available) {
            if ($this.DownloadUpdate($updateInfo)) {
                # Ask for installation permission in auto-update mode
                $installUpdate = Confirm-KnouxAction "Install update v$($updateInfo.version)?" "Y"
                if ($installUpdate) {
                    $this.InstallUpdate($updateInfo)
                }
            }
        }
    }
    
    [void] ScheduleUpdateCheck([int]$intervalHours = 24) {
        $timer = New-Object Timers.Timer
        $timer.Interval = $intervalHours * 60 * 60 * 1000 # Convert to milliseconds
        
        Register-ObjectEvent -InputObject $timer -EventName Elapsed -Action {
            $this.AutoUpdate()
        } | Out-Null
        
        $timer.Start()
        Write-Host "⏰ Scheduled update check every $intervalHours hours" -ForegroundColor Green
    }
    
    [void] IgnoreVersion([string]$version) {
        if (-not ($this.UpdateConfig.ignored_versions -contains $version)) {
            $this.UpdateConfig.ignored_versions += $version
            $this.SaveUpdateConfig()
            Write-Host "🔕 Ignored version: $version" -ForegroundColor Yellow
        }
    }
    
    [void] ListIgnoredVersions() {
        if ($this.UpdateConfig.ignored_versions.Count -gt 0) {
            Write-Host "📋 Ignored versions:" -ForegroundColor Cyan
            $this.UpdateConfig.ignored_versions | ForEach-Object {
                Write-Host "  - $_" -ForegroundColor Yellow
            }
        }
        else {
            Write-Host "📋 No ignored versions" -ForegroundColor Gray
        }
    }
    
    [object] GetUpdateHistory() {
        $historyFile = "./logs/update_history.log"
        if (Test-Path $historyFile) {
            $lines = Get-Content $historyFile | Select-Object -Last 20
            return $lines | ForEach-Object {
                if ($_ -match "^(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}) \| (.+) \| (.+)$") {
                    [PSCustomObject]@{
                        timestamp = [DateTime]$matches[1]
                        action    = $matches[2]
                        details   = $matches[3]
                    }
                }
            }
        }
        return @()
    }
    
    [void] LogUpdateAction([string]$action, [string]$details) {
        $logLine = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') | $action | $details"
        $logFile = "./logs/update_history.log"
        
        $dir = Split-Path $logFile -Parent
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir | Out-Null
        }
        
        Add-Content -Path $logFile -Value $logLine
    }
    
    [void] RollbackToPreviousVersion() {
        $backups = Get-ChildItem -Path "./backups" -Directory | Sort-Object LastWriteTime -Descending
        if ($backups.Count -eq 0) {
            Write-Warning "No backups found for rollback"
            return
        }
        
        Write-Host "🔙 Available backups for rollback:" -ForegroundColor Cyan
        for ($i = 0; $i -lt [Math]::Min(5, $backups.Count); $i++) {
            Write-Host "$($i + 1). $($backups[$i].Name) (Modified: $($backups[$i].LastWriteTime))" -ForegroundColor White
        }
        
        $choice = Read-Host "Select backup to restore (1-$([Math]::Min(5, $backups.Count)))"
        if ($choice -match "^\d+$" -and [int]$choice -ge 1 -and [int]$choice -le [Math]::Min(5, $backups.Count)) {
            $selectedBackup = $backups[[int]$choice - 1]
            $confirm = Confirm-KnouxAction "Rollback to $($selectedBackup.Name)? This will overwrite current files." "N"
            
            if ($confirm) {
                Write-Host "🔄 Rolling back to $($selectedBackup.Name)..." -ForegroundColor Yellow
                
                # Create current backup before rollback
                $rollbackBackup = "./backups/pre_rollback_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
                Copy-Item -Path "." -Destination $rollbackBackup -Recurse -Exclude @("temp", "logs", "backups") | Out-Null
                
                # Restore selected backup
                Get-ChildItem -Path $selectedBackup.FullName | ForEach-Object {
                    Copy-Item -Path $_.FullName -Destination "." -Recurse -Force
                }
                
                Write-Host "✅ Rollback completed successfully!" -ForegroundColor Green
                Write-Host "🔄 Please restart the application" -ForegroundColor Yellow
            }
        }
    }
    
    [void] CleanupOldBackups([int]$keepCount = 10) {
        $backups = Get-ChildItem -Path "./backups" -Directory | Sort-Object LastWriteTime -Descending
        if ($backups.Count -gt $keepCount) {
            $oldBackups = $backups | Select-Object -Skip $keepCount
            foreach ($backup in $oldBackups) {
                try {
                    Remove-Item -Path $backup.FullName -Recurse -Force
                    Write-Verbose "🧹 Removed old backup: $($backup.Name)"
                }
                catch {
                    Write-Warning "Failed to remove backup $($backup.Name): $($_.Exception.Message)"
                }
            }
        }
    }
}

# Initialize global updater
$global:Updater = [SmartUpdater]::new("1.0.0", "stable")
