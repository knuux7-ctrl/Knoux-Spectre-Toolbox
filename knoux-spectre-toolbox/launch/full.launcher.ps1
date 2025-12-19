# ملف: launch/full.launcher.ps1
<#
.SYNOPSIS
    Knoux Spectre Toolbox - Full Launch Script
.DESCRIPTION
    Complete launcher with all systems initialization
.AUTHOR
    Knoux Systems
.VERSION
    1.0.0
#>

#requires -version 5.1

param(
    [Parameter(Mandatory = $false)]
    [switch]$NoGUI,
    
    [Parameter(Mandatory = $false)]
    [switch]$DebugMode,
    
    [Parameter(Mandatory = $false)]
    [switch]$StartWebAPI,
    
    [Parameter(Mandatory = $false)]
    [switch]$StartBots,
    
    [Parameter(Mandatory = $false)]
    [string]$Profile = "default"
)

# Initialize global error handling
$ErrorActionPreference = "Stop"
if ($DebugMode) { $VerbosePreference = "Continue" }

# Global startup timestamp
$global:StartupTime = Get-Date
$global:SessionId = [guid]::NewGuid().ToString()

Write-Host @"
╔══════════════════════════════════════════════════════════════╗
║                KNX SPECTRE TOOLBOX LAUNCHER                  ║
║                       Version 1.0.0                          ║
╚══════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Magenta

Write-Host "⏱ Startup Time: $($global:StartupTime)" -ForegroundColor Cyan
Write-Host "🆔 Session ID: $($global:SessionId.Substring(0,8))..." -ForegroundColor Gray

# Initialize core systems
function Initialize-CoreSystems {
    Write-Host "🔧 Initializing core systems..." -ForegroundColor Yellow
    
    try {
        # 1. Load configuration manager
        Write-Verbose "Loading dynamic configuration manager..."
        . "$PSScriptRoot/../config/dynamic.config.ps1"
        
        # 2. Initialize module manager
        Write-Verbose "Initializing module manager..."
        . "$PSScriptRoot/../core/module.manager.ps1"
        
        # 3. Load helper functions
        Write-Verbose "Loading helper functions..."
        . "$PSScriptRoot/../lib/helper.functions.ps1"
        
        # 4. Initialize access control
        Write-Verbose "Setting up access control..."
        . "$PSScriptRoot/../security/access.control.ps1"
        
        # 5. Initialize performance tracking
        Write-Verbose "Starting performance monitoring..."
        . "$PSScriptRoot/../monitoring/performance.tracker.ps1"
        $global:PerformanceTracker.StartCollection()
        
        # 6. Initialize reporting system
        Write-Verbose "Setting up reporting system..."
        . "$PSScriptRoot/../data/reporting.system.ps1"
        
        # 7. Initialize updater system
        Write-Verbose "Loading update system..."
        . "$PSScriptRoot/../update/updater.system.ps1"
        
        # 8. Initialize AI integration
        Write-Verbose "Setting up AI integration..."
        . "$PSScriptRoot/../ai/integration.system.ps1"
        
        Write-Host "✅ Core systems initialized successfully" -ForegroundColor Green
        
    }
    catch {
        Write-Error "Failed to initialize core systems: $($_.Exception.Message)"
        exit 1
    }
}

# Load and initialize modules
function Initialize-Modules {
    Write-Host "📦 Loading modules..." -ForegroundColor Yellow
    
    try {
        $enabledModules = $global:ConfigManager.Get("modules.enabled", @())
        $disabledModules = $global:ConfigManager.Get("modules.disabled", @())
        
        # Filter out disabled modules
        $modulesToLoad = $enabledModules | Where-Object { $disabledModules -notcontains $_ }
        
        Write-Host "Loading $($modulesToLoad.Count) modules..." -ForegroundColor Cyan
        
        foreach ($moduleName in $modulesToLoad) {
            try {
                Write-Verbose "Loading module: $moduleName"
                $global:ModuleManager.LoadModule($moduleName)
            }
            catch {
                Write-Warning "Failed to load module $moduleName`: $($_.Exception.Message)"
            }
        }
        
        Write-Host "✅ Modules loaded: $($global:ModuleManager.GetLoadedModules().Count) loaded" -ForegroundColor Green
        
    }
    catch {
        Write-Error "Module loading failed: $($_.Exception.Message)"
    }
}

# Start optional services
function Start-OptionalServices {
    Write-Host "📡 Starting optional services..." -ForegroundColor Yellow
    
    # Web API Server
    if ($StartWebAPI) {
        try {
            Write-Verbose "Starting Web API server..."
            Start-Job -ScriptBlock {
                . "$using:PSScriptRoot/../web/api.server.ps1"
            } -Name "WebAPI" | Out-Null
            
            Write-Host "🌐 Web API server started on port 8080" -ForegroundColor Green
        }
        catch {
            Write-Warning "Failed to start Web API server: $($_.Exception.Message)"
        }
    }
    
    # Telegram Bot
    if ($StartBots -and $global:ConfigManager.Get("integrations.telegram.enabled", $false)) {
        try {
            Write-Verbose "Starting Telegram bot..."
            $token = $global:ConfigManager.Get("integrations.telegram.token", "")
            if ($token) {
                Start-Job -ScriptBlock {
                    param($token)
                    . "$using:PSScriptRoot/../bots/telegram.bot.ps1"
                    $bot = [TelegramBot]::new($token)
                    $bot.Start()
                } -ArgumentList $token -Name "TelegramBot" | Out-Null
                
                Write-Host "📱 Telegram bot started" -ForegroundColor Green
            }
        }
        catch {
            Write-Warning "Failed to start Telegram bot: $($_.Exception.Message)"
        }
    }
    
    # Discord Bot
    if ($StartBots -and $global:ConfigManager.Get("integrations.discord.enabled", $false)) {
        try {
            Write-Verbose "Starting Discord bot..."
            $token = $global:ConfigManager.Get("integrations.discord.token", "")
            if ($token) {
                Start-Job -ScriptBlock {
                    param($token)
                    . "$using:PSScriptRoot/../bots/discord.bot.ps1"
                    $bot = [DiscordBot]::new($token)
                    $bot.Start()
                } -ArgumentList $token -Name "DiscordBot" | Out-Null
                
                Write-Host "🎮 Discord bot started" -ForegroundColor Green
            }
        }
        catch {
            Write-Warning "Failed to start Discord bot: $($_.Exception.Message)"
        }
    }
}

# Performance and health check
function Show-SystemHealth {
    Write-Host "💉 Performing system health check..." -ForegroundColor Yellow
    
    $health = @{
        system_info      = @{
            computer_name = $env:COMPUTERNAME
            user_name     = $env:USERNAME
            os_version    = (Get-CimInstance Win32_OperatingSystem).Caption
            ps_version    = $PSVersionTable.PSVersion.ToString()
        }
        performance      = $global:PerformanceTracker.GetPerformanceStats()
        modules_loaded   = $global:ModuleManager.GetLoadedModules().Count
        startup_duration = (Get-Date).Subtract($global:StartupTime).TotalSeconds
    }
    
    Write-Host "📊 Health Check Results:" -ForegroundColor Cyan
    Write-Host "  System: $($health.system_info.computer_name) | $($health.system_info.os_version)" -ForegroundColor White
    Write-Host "  Modules: $($health.modules_loaded) loaded in $([math]::Round($health.startup_duration, 2))s" -ForegroundColor White
    Write-Host "  CPU Avg: $($health.performance.average_cpu)% | Memory: $($health.performance.average_memory_mb) MB" -ForegroundColor White
    
    # Log health check
    if ($global:ReportingSystem) {
        $global:ReportingSystem.LogSystemReport("startup_health", $health, "INFO", "launcher")
    }
}

# Setup graceful shutdown
function Setup-ShutdownHandler {
    $handler = Register-ObjectEvent -InputObject ([System.Console]) -EventName CancelKeyPress -Action {
        Write-Host "`n🛑 Shutdown signal received..." -ForegroundColor Yellow
        Cleanup-OnExit
        exit 0
    }
    
    Write-Verbose "🔌 Shutdown handler registered"
}

# Cleanup on exit
function Cleanup-OnExit {
    Write-Host "🧹 Cleaning up resources..." -ForegroundColor Yellow
    
    # Stop performance tracking
    if ($global:PerformanceTracker) {
        $global:PerformanceTracker.Close()
    }
    
    # Close database connections
    if ($global:ReportingSystem) {
        $global:ReportingSystem.Close()
    }
    
    # Stop background jobs
    Get-Job | Stop-Job -PassThru | Remove-Job
    
    Write-Host "✅ Cleanup completed" -ForegroundColor Green
}

# Interactive mode startup
function Start-InteractiveMode {
    if ($NoGUI) {
        Write-Host "🖥️ Starting in console-only mode..." -ForegroundColor Cyan
        . "$PSScriptRoot/../knoux.ps1" -NoGUI
    }
    else {
        Write-Host "🖥️ Starting interactive GUI mode..." -ForegroundColor Cyan
        . "$PSScriptRoot/../knoux.ps1"
    }
}

# Main execution
try {
    # Show startup banner
    Write-Host "🚀 Starting Knoux Spectre Toolbox..." -ForegroundColor Green
    
    # Load core systems
    Initialize-CoreSystems
    
    # Apply profile settings
    if ($Profile -ne "default") {
        Write-Host "🔧 Applying profile: $Profile" -ForegroundColor Cyan
        # Profile-specific initialization would go here
    }
    
    # Initialize modules
    Initialize-Modules
    
    # Start optional services
    Start-OptionalServices
    
    # Health check
    Show-SystemHealth
    
    # Setup shutdown handling
    Setup-ShutdownHandler
    
    # Auto-update check
    if ($global:ConfigManager.Get("updates.auto_check", $true)) {
        Write-Host "🔍 Checking for updates..." -ForegroundColor Cyan
        Start-Job -ScriptBlock {
            $global:Updater.AutoUpdate()
        } -Name "AutoUpdate" | Out-Null
    }
    
    # Show system info
    $elapsed = (Get-Date).Subtract($global:StartupTime).TotalSeconds
    Write-Host @"
🎉 Launch completed in $([math]::Round($elapsed, 2)) seconds!
📊 Session ID: $($global:SessionId.Substring(0,8))...
"@ -ForegroundColor Green
    
    # Start interactive mode
    Start-InteractiveMode
    
}
catch {
    Write-Error "Fatal error during startup: $($_.Exception.Message)"
    Write-Error $_.Exception.StackTrace
    exit 1
}
finally {
    # Register exit handler
    Register-EngineEvent -SourceIdentifier PowerShell.Exiting -Action {
        Cleanup-OnExit
    } | Out-Null
}
