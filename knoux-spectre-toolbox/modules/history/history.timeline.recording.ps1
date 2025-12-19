<#
.FILE: modules/history/history.timeline.recording.ps1
.SYNOPSIS
    Historical Command Logger / Timeline Recorder
.DESCRIPTION
    Lightweight timeline recorder that captures events (commands, context,
    stack traces) into append-only JSONL with rotation, indexing, and query API.

Schema (event JSON)
{
  "id": "<uuid>",
  "timestamp": "2025-12-19T12:34:56Z",
  "type": "command|process_start|error|custom",
  "actor": "<hashed_user_or_system>",
  "command": "Get-Process -Name foo",
  "context": { "cwd": "C:\\repo", "session": "..." },
  "stack": [ "frame1", "frame2" ],
  "metadata": { ... }
}

Storage & rotation
- Location: ./data/history/ (JSONL files)
- Rotation: files rotate when > 50 MB or older than 7 days (configurable)
- Index: small index file with last N offsets for fast recent queries

API
- RecordEvent([hashtable]$event)
- QueryEvents([hashtable]$filter, [int]$limit)
- ExportTimeline([datetime]$from, [datetime]$to, [string]$outPath)

#>

using namespace System.IO

class HistoricalCommandLogger {
    [string] $BasePath
    [string] $CurrentFile
    [string] $IndexFile
    [int] $MaxFileMB
    [int] $RetentionDays

    HistoricalCommandLogger() {
        $this.BasePath = (Join-Path $PSScriptRoot "../../data/history")
        if (-not (Test-Path $this.BasePath)) { New-Item -ItemType Directory -Path $this.BasePath -Force | Out-Null }
        $this.IndexFile = Join-Path $this.BasePath "index.json"
        $this.CurrentFile = Join-Path $this.BasePath "history-$(Get-Date -Format 'yyyyMMdd').jsonl"
        $this.MaxFileMB = 50
        $this.RetentionDays = 90
    }

    [string] NewId() { return [guid]::NewGuid().ToString() }

    [void] RecordEvent([hashtable]$evt) {
        if (-not $evt.id) { $evt.id = $this.NewId() }
        if (-not $evt.timestamp) { $evt.timestamp = (Get-Date).ToString('o') }

        # Sanitize actor to hashed token if present
        if ($evt.actor -and $evt.actor.Length -gt 0) { $evt.actor = (Get-FileHash -Algorithm SHA256 -InputStream ([System.IO.MemoryStream]::new([Text.Encoding]::UTF8.GetBytes($evt.actor)))).Hash } 

        $line = $evt | ConvertTo-Json -Depth 10
        Add-Content -Path $this.CurrentFile -Value $line

        # Update simple index (append id + byte offset)
        $indexEntry = @{ id = $evt.id; ts = $evt.timestamp }
        Add-Content -Path $this.IndexFile -Value ($indexEntry | ConvertTo-Json -Depth 3)

        # Rotate if needed
        $this.RotateIfNeeded()

        if ($global:ReportingSystem) { $global:ReportingSystem.LogSystemReport('history.record', $evt, 'INFO', 'history') }
    }

    [void] RotateIfNeeded() {
        try {
            $fi = Get-Item $this.CurrentFile -ErrorAction SilentlyContinue
            if ($fi) {
                if (($fi.Length / 1MB) -ge $this.MaxFileMB) {
                    $dst = Join-Path $this.BasePath ("history-$(Get-Date -Format 'yyyyMMdd-HHmmss').jsonl")
                    Move-Item -Path $this.CurrentFile -Destination $dst
                    New-Item -Path $this.CurrentFile -ItemType File | Out-Null
                }
            }
        }
        catch { Write-Verbose "Rotation check failed: $($_.Exception.Message)" }
    }

    [object[]] QueryEvents([hashtable]$filter, [int]$limit = 100) {
        # Simple recent-first scan across today's file then older files until limit reached
        $results = @()
        $files = Get-ChildItem -Path $this.BasePath -Filter '*.jsonl' | Sort-Object LastWriteTime -Descending
        foreach ($f in $files) {
            $lines = Get-Content $f.FullName -Raw -ErrorAction SilentlyContinue | Select-String -Pattern '.' -AllMatches | ForEach-Object { $_.Line }
            foreach ($l in $lines) {
                $obj = $null
                try { $obj = $l | ConvertFrom-Json } catch { continue }
                $ok = $true
                foreach ($k in $filter.Keys) {
                    if ($filter[$k] -and ($obj.$k -ne $filter[$k])) { $ok = $false; break }
                }
                if ($ok) { $results += $obj }
                if ($results.Count -ge $limit) { return $results }
            }
        }
        return $results
    }

    [void] ExportTimeline([datetime]$from, [datetime]$to, [string]$outPath) {
        $out = @()
        $files = Get-ChildItem -Path $this.BasePath -Filter '*.jsonl' | Sort-Object LastWriteTime
        foreach ($f in $files) {
            foreach ($l in Get-Content $f.FullName) {
                try { $obj = $l | ConvertFrom-Json } catch { continue }
                $ts = [datetime]$obj.timestamp
                if ($ts -ge $from -and $ts -le $to) { $out += ($l) }
            }
        }
        $out | Out-File -FilePath $outPath -Encoding UTF8
    }

    [void] CleanupOld([int]$keepDays = $null) {
        $keep = $keepDays ?: $this.RetentionDays
        $files = Get-ChildItem -Path $this.BasePath -Filter '*.jsonl'
        foreach ($f in $files) {
            if (($f.LastWriteTime) -lt (Get-Date).AddDays(-$keep)) { Remove-Item -Path $f.FullName -Force }
        }
    }
}

function Get-HistoryRecorderInstance {
    if (-not (Get-Variable -Name 'HistoryRecorder' -Scope Global -ErrorAction SilentlyContinue)) {
        $inst = [HistoricalCommandLogger]::new()
        Set-Variable -Name 'HistoryRecorder' -Value $inst -Scope Global -Force
    }
    return (Get-Variable -Name 'HistoryRecorder' -Scope Global -ValueOnly)
}

# Runner wrappers will call Get-HistoryRecorderInstance() lazily. No globals on import.
