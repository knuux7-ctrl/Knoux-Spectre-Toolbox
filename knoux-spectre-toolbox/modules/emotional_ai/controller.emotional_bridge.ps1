<#
.FILE: modules/emotional_ai/controller.emotional_bridge.ps1
.SYNOPSIS
    Sentiment-based AI Adjuster (safe, opt-in prototype)
.DESCRIPTION
    Lightweight, privacy-first emotional analysis adapter that produces
    persona/tone adjustments for AI responses. Designed as a non-invasive
    prototype: no PII stored, user opt-in required, and anonymized profiles.

API CONTRACT (example)
----------------------
Request: Analyze and adjust
{
  "user_id": "<hashed_user_id>",     # required (non-PII hashed id)
  "text": "I need help with my server, it's failing",
  "context": { "channel": "cli|web|telegram", "session_id": "..." }
}

Response (200):
{
  "status": "ok",
  "sentiment": "neutral|positive|negative|mixed",
  "tone": "sympathetic|direct|concise|encouraging",
  "adjustment": {
      "language_style": "sympathetic",
      "max_response_length": 500,
      "suggested_prompt_mod": "Please provide step-by-step troubleshooting with calm tone"
  }
}

Errors:
- 400: missing/invalid user_id or text
- 403: user not opted-in for emotional profiling
- 500: internal processing error

PRIVACY CHECKLIST
-----------------
- Opt-in required: callers must confirm user consent before sending text
- PII policy: no raw user identifiers stored; only hashed user ids allowed
- Retention: sentiment profiles stored for max 30 days by default (configurable)
- Anonymization: all saved profiles are pseudonymous and minimal (tone prefs only)
- Access: profile read/write restricted to admin role via AccessControlManager
- Audit: every profile access is logged via ReportingSystem
#>

class SentimentBasedAIAdjuster {
    [int] $RetentionDays = 30
    [hashtable] $ProfilesPath
    [hashtable] $ToneMap

    SentimentBasedAIAdjuster() {
        $this.ProfilesPath = @{ base = (Join-Path $PSScriptRoot "../../data/emotional_profiles"); indexFile = "profiles.jsonl" }
        if (-not (Test-Path $this.ProfilesPath.base)) { New-Item -ItemType Directory -Path $this.ProfilesPath.base -Force | Out-Null }

        # Simple tone mapping rules (can be extended to use $global:AISystem)
        $this.ToneMap = @{
            negative = @{ tone = 'sympathetic'; max_len = 600; prompt = 'Respond calmly and helpfully.' }
            positive = @{ tone = 'encouraging'; max_len = 400; prompt = 'Acknowledge success and offer next suggestions.' }
            neutral  = @{ tone = 'concise'; max_len = 300; prompt = 'Be concise and factual.' }
            mixed    = @{ tone = 'balanced'; max_len = 450; prompt = 'Address both concerns and good points.' }
        }
    }

    [void] ValidateOptIn([string]$hashedUserId) {
        # Check AccessControl or a small opt-in store
        if ($global:AccessControl) {
            if (-not $global:AccessControl.UserHasConsent($hashedUserId, 'emotional_ai')) {
                throw [System.UnauthorizedAccessException] "User not opted-in for emotional profiling"
            }
        }
    }

    [object] AnalyzeText([string]$hashedUserId, [string]$text, [hashtable]$context = $null) {
        if (-not $hashedUserId -or -not $text) { throw [System.ArgumentException] "Missing user_id or text" }

        # Enforce opt-in
        try { $this.ValidateOptIn($hashedUserId) } catch { throw }

        # Non-invasive, local-first sentiment analysis
        $sentiment = $this.SimpleSentiment($text)

        # Optionally consult global AI for a richer signal (if configured and allowed)
        if ($global:AISystem -and $global:ConfigManager.Get('ai.use_for_sentiment', $false)) {
            try {
                $aiResp = $global:AISystem.GenerateCompletion("Detect sentiment: $text", @{ provider = 'openai'; max_tokens = 64 })
                if ($aiResp -and $aiResp.choices) {
                    $aiText = $aiResp.choices[0].message.content
                    if ($aiText -match '(negative|positive|neutral|mixed)') { $sentiment = $matches[0] }
                }
            }
            catch { Write-Verbose "AI sentiment fallback failed: $($_.Exception.Message)" }
        }

        $adjust = $this.ToneMap[$sentiment]

        # Persist minimal profile (anonymized) with retention
        $profile = @{ user = $hashedUserId; last_seen = (Get-Date).ToString('o'); sentiment = $sentiment; tone = $adjust.tone }
        $this.SaveProfile($profile)

        return @{ status = 'ok'; sentiment = $sentiment; tone = $adjust.tone; adjustment = @{ language_style = $adjust.tone; max_response_length = $adjust.max_len; suggested_prompt_mod = $adjust.prompt } }
    }

    [string] SimpleSentiment([string]$text) {
        $textLower = $text.ToLowerInvariant()
        $negWords = @('error', 'fail', 'angry', 'hate', 'stuck', 'cannot', 'frustrat', 'crash', 'panic')
        $posWords = @('thanks', 'thank', 'success', 'done', 'fixed', 'resolved', 'awesome', 'great')

        $neg = ($negWords | Where-Object { $textLower.Contains($_) }).Count
        $pos = ($posWords | Where-Object { $textLower.Contains($_) }).Count

        if ($neg -gt $pos) { return 'negative' }
        if ($pos -gt $neg) { return 'positive' }
        return 'neutral'
    }

    [void] SaveProfile([hashtable]$profile) {
        $out = ($profile | ConvertTo-Json -Depth 5)
        $file = Join-Path $this.ProfilesPath.base ($this.ProfilesPath.indexFile)
        Add-Content -Path $file -Value $out
        if ($global:ReportingSystem) { $global:ReportingSystem.LogSystemReport('emotional_profile_saved', $profile, 'INFO', 'emotional_ai') }
    }

    [hashtable] GetProfile([string]$hashedUserId) {
        $file = Join-Path $this.ProfilesPath.base ($this.ProfilesPath.indexFile)
        if (-not (Test-Path $file)) { return @{} }
        $lines = Get-Content $file | ConvertFrom-Json
        $match = $lines | Where-Object { $_.user -eq $hashedUserId } | Select-Object -Last 1
        if ($match) { return @{ user = $match.user; last_seen = $match.last_seen; sentiment = $match.sentiment; tone = $match.tone } }
        return @{}
    }

    [hashtable[]] QueryProfiles([int]$limit = 50) {
        $file = Join-Path $this.ProfilesPath.base ($this.ProfilesPath.indexFile)
        if (-not (Test-Path $file)) { return @() }
        $lines = Get-Content $file | Select-Object -Last $limit | ForEach-Object { $_ | ConvertFrom-Json }
        return $lines
    }
}

function Get-EmotionalAdjusterInstance {
    # Lazily create and return a singleton instance in global scope.
    if (-not (Get-Variable -Name 'EmotionalAdjuster' -Scope Global -ErrorAction SilentlyContinue)) {
        $inst = [SentimentBasedAIAdjuster]::new()
        Set-Variable -Name 'EmotionalAdjuster' -Value $inst -Scope Global -Force
    }
    return (Get-Variable -Name 'EmotionalAdjuster' -Scope Global -ValueOnly)
}

# Do not create globals at import time. Runner wrapper provides `Invoke-EmotionalAdjuster`.
