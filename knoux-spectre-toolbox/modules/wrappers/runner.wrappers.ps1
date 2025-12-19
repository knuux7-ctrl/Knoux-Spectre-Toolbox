<#
Runner-safe wrappers for API-exposed functions.
These are non-interactive, silent, and idempotent wrappers that lazily
instantiate underlying modules when called.
#>

function Invoke-EmotionalAdjuster {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$user_id,
        [Parameter(Mandatory=$true)][string]$text,
        [Parameter(Mandatory=$false)][hashtable]$context = $null
    )

    try {
        $adj = Get-Command -Name Get-EmotionalAdjusterInstance -ErrorAction SilentlyContinue
        if (-not $adj) { throw "EmotionalAdjuster module not available" }
        $inst = Get-EmotionalAdjusterInstance
        $res = $inst.AnalyzeText($user_id, $text, $context)
        return $res
    } catch {
        return @{ status = 'error'; message = $_.Exception.Message }
    }
}

function Invoke-RecordHistoryEvent {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][hashtable]$evt
    )

    try {
        $recCmd = Get-Command -Name Get-HistoryRecorderInstance -ErrorAction SilentlyContinue
        if (-not $recCmd) { throw "History recorder module not available" }
        $rec = Get-HistoryRecorderInstance
        # ensure minimal schema
        if (-not $evt.id) { $evt.id = [guid]::NewGuid().ToString() }
        if (-not $evt.timestamp) { $evt.timestamp = (Get-Date).ToString('o') }
        $rec.RecordEvent($evt)
        return @{ status = 'ok'; id = $evt.id }
    } catch {
        return @{ status = 'error'; message = $_.Exception.Message }
    }
}
