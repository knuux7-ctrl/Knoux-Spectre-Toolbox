<#
.SYNOPSIS
    Script Injection Phase Manager for Knoux Spectre Toolbox
.DESCRIPTION
    Provides lifecycle hooks for modules to inject custom logic at specific execution phases.
    Supports pre-execution, post-execution, validation, and transform hooks.
.AUTHOR
    Knoux Systems
.VERSION
    1.0.0
#>

using namespace System.Collections.Generic

class InjectionPhase {
    [string] $Name
    [hashtable] $Hooks
    [List[object]] $ExecutionLog
    [bool] $Enabled

    InjectionPhase([string]$name) {
        $this.Name = $name
        $this.Hooks = @{
            PreExecution  = [List[scriptblock]]::new()
            PostExecution = [List[scriptblock]]::new()
            Validation    = [List[scriptblock]]::new()
            Transform     = [List[scriptblock]]::new()
            OnError       = [List[scriptblock]]::new()
        }
        $this.ExecutionLog = [List[object]]::new()
        $this.Enabled = $true
    }

    [void] RegisterHook([string]$phase, [scriptblock]$hook, [string]$name = '') {
        if (-not $this.Hooks.ContainsKey($phase)) {
            throw "Invalid hook phase: $phase. Valid phases: PreExecution, PostExecution, Validation, Transform, OnError"
        }
        
        $hookWrapper = @{
            Name         = if ($name) { $name } else { "Hook_$([guid]::NewGuid().ToString().Substring(0,8))" }
            Script       = $hook
            RegisteredAt = Get-Date
        }
        
        $this.Hooks[$phase].Add($hookWrapper)
        $this.Log("Registered hook '$($hookWrapper.Name)' for phase '$phase'", 'INFO')
    }

    [object] ExecutePhase([string]$phase, [object]$context) {
        if (-not $this.Enabled) {
            $this.Log("Injection phase disabled, skipping $phase", 'DEBUG')
            return $context
        }

        if (-not $this.Hooks.ContainsKey($phase)) {
            throw "Invalid phase: $phase"
        }

        $hooks = $this.Hooks[$phase]
        if ($hooks.Count -eq 0) {
            $this.Log("No hooks registered for phase '$phase'", 'DEBUG')
            return $context
        }

        $this.Log("Executing $($hooks.Count) hooks for phase '$phase'", 'DEBUG')
        
        foreach ($hookWrapper in $hooks) {
            try {
                $startTime = Get-Date
                
                # Execute hook with context
                $result = & $hookWrapper.Script $context
                
                # Update context if hook returns a value
                if ($null -ne $result) {
                    $context = $result
                }
                
                $duration = ((Get-Date) - $startTime).TotalMilliseconds
                $this.Log("Hook '$($hookWrapper.Name)' completed in ${duration}ms", 'DEBUG')
                
            }
            catch {
                $error = "Hook '$($hookWrapper.Name)' failed: $($_.Exception.Message)"
                $this.Log($error, 'ERROR')
                
                # Execute error handlers
                if ($this.Hooks['OnError'].Count -gt 0) {
                    $errorContext = @{
                        OriginalContext = $context
                        Error           = $_
                        HookName        = $hookWrapper.Name
                        Phase           = $phase
                    }
                    
                    foreach ($errorHook in $this.Hooks['OnError']) {
                        try {
                            & $errorHook.Script $errorContext
                        }
                        catch {
                            $this.Log("Error hook '$($errorHook.Name)' failed: $($_.Exception.Message)", 'ERROR')
                        }
                    }
                }
                
                # Re-throw to stop execution chain
                throw
            }
        }
        
        return $context
    }

    [void] Log([string]$message, [string]$level = 'INFO') {
        $entry = @{
            Timestamp = Get-Date
            Level     = $level
            Message   = $message
            Phase     = $this.Name
        }
        $this.ExecutionLog.Add($entry)
        
        # Keep log size manageable (last 1000 entries)
        if ($this.ExecutionLog.Count -gt 1000) {
            $this.ExecutionLog.RemoveAt(0)
        }
    }

    [void] ClearHooks([string]$phase = $null) {
        if ($phase) {
            if ($this.Hooks.ContainsKey($phase)) {
                $this.Hooks[$phase].Clear()
                $this.Log("Cleared all hooks for phase '$phase'", 'INFO')
            }
        }
        else {
            foreach ($key in $this.Hooks.Keys) {
                $this.Hooks[$key].Clear()
            }
            $this.Log("Cleared all hooks", 'INFO')
        }
    }

    [hashtable] GetStats() {
        return @{
            Name       = $this.Name
            Enabled    = $this.Enabled
            HookCounts = @{
                PreExecution  = $this.Hooks['PreExecution'].Count
                PostExecution = $this.Hooks['PostExecution'].Count
                Validation    = $this.Hooks['Validation'].Count
                Transform     = $this.Hooks['Transform'].Count
                OnError       = $this.Hooks['OnError'].Count
            }
            LogEntries = $this.ExecutionLog.Count
        }
    }

    [object[]] GetExecutionLog([int]$last = 100) {
        $count = [Math]::Min($last, $this.ExecutionLog.Count)
        $startIndex = [Math]::Max(0, $this.ExecutionLog.Count - $count)
        return $this.ExecutionLog.GetRange($startIndex, $count)
    }
}

class InjectionManager {
    [hashtable] $Phases
    [bool] $GlobalEnabled
    [List[object]] $AuditLog

    InjectionManager() {
        $this.Phases = @{}
        $this.GlobalEnabled = $true
        $this.AuditLog = [List[object]]::new()
        
        # Initialize default phases
        $this.CreatePhase('ModuleLoader')
        $this.CreatePhase('FunctionExecution')
        $this.CreatePhase('APIHandler')
        $this.CreatePhase('Security')
    }

    [void] CreatePhase([string]$name) {
        if ($this.Phases.ContainsKey($name)) {
            Write-Verbose "Phase '$name' already exists"
            return
        }
        
        $this.Phases[$name] = [InjectionPhase]::new($name)
        $this.AuditLog.Add(@{
                Timestamp = Get-Date
                Action    = 'PhaseCreated'
                Phase     = $name
            })
    }

    [void] RegisterHook([string]$phaseName, [string]$hookPhase, [scriptblock]$hook, [string]$hookName = '') {
        if (-not $this.Phases.ContainsKey($phaseName)) {
            throw "Phase '$phaseName' does not exist. Create it first with CreatePhase."
        }
        
        $this.Phases[$phaseName].RegisterHook($hookPhase, $hook, $hookName)
        
        $this.AuditLog.Add(@{
                Timestamp = Get-Date
                Action    = 'HookRegistered'
                Phase     = $phaseName
                HookPhase = $hookPhase
                HookName  = $hookName
            })
    }

    [object] ExecuteInjection([string]$phaseName, [string]$hookPhase, [object]$context) {
        if (-not $this.GlobalEnabled) {
            Write-Verbose "Injection system globally disabled"
            return $context
        }
        
        if (-not $this.Phases.ContainsKey($phaseName)) {
            Write-Verbose "Phase '$phaseName' not found, skipping injection"
            return $context
        }
        
        return $this.Phases[$phaseName].ExecutePhase($hookPhase, $context)
    }

    [void] EnablePhase([string]$phaseName, [bool]$enabled = $true) {
        if ($this.Phases.ContainsKey($phaseName)) {
            $this.Phases[$phaseName].Enabled = $enabled
            $action = if ($enabled) { 'Enabled' } else { 'Disabled' }
            Write-Verbose "Phase '$phaseName' $action"
        }
    }

    [hashtable] GetAllStats() {
        $stats = @{
            GlobalEnabled = $this.GlobalEnabled
            TotalPhases   = $this.Phases.Count
            Phases        = @{}
        }
        
        foreach ($phaseName in $this.Phases.Keys) {
            $stats.Phases[$phaseName] = $this.Phases[$phaseName].GetStats()
        }
        
        return $stats
    }

    [void] Reset() {
        foreach ($phase in $this.Phases.Values) {
            $phase.ClearHooks()
        }
        $this.AuditLog.Clear()
        Write-Verbose "Injection manager reset"
    }
}

# Initialize global injection manager
if (-not $global:InjectionManager) {
    $global:InjectionManager = [InjectionManager]::new()
    Write-Verbose "✅ InjectionManager initialized"
}

# Helper functions for easy access
function Register-InjectionHook {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Phase,
        
        [Parameter(Mandatory)]
        [ValidateSet('PreExecution', 'PostExecution', 'Validation', 'Transform', 'OnError')]
        [string]$HookPhase,
        
        [Parameter(Mandatory)]
        [scriptblock]$Script,
        
        [Parameter()]
        [string]$Name = ''
    )
    
    $global:InjectionManager.RegisterHook($Phase, $HookPhase, $Script, $Name)
}

function Invoke-InjectionPhase {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Phase,
        
        [Parameter(Mandatory)]
        [ValidateSet('PreExecution', 'PostExecution', 'Validation', 'Transform', 'OnError')]
        [string]$HookPhase,
        
        [Parameter()]
        [object]$Context = @{}
    )
    
    return $global:InjectionManager.ExecuteInjection($Phase, $HookPhase, $Context)
}

function Get-InjectionStats {
    [CmdletBinding()]
    param()
    
    return $global:InjectionManager.GetAllStats()
}

Export-ModuleMember -Function Register-InjectionHook, Invoke-InjectionPhase, Get-InjectionStats
