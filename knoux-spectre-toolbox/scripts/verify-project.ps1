<#
.SYNOPSIS
  Repository verification and CI-style checks for local runs.
.DESCRIPTION
  Runs TypeScript checks, build, lint, Prettier, and PSScriptAnalyzer across the workspace.
  Intended for local use on Windows (PowerShell Core / pwsh).
.NOTES
  - Safe: skips steps when required tools are missing and reports a summary exit code.
  - Designed to be idempotent and easy to run manually or from CI.
#>

param(
    [switch]$SkipNodeChecks,
    [switch]$SkipPSAnalyzer
)

Set-StrictMode -Version Latest

function Log { param($m) Write-Host "[verify] $m" }

$errors = @()

if (-not $SkipNodeChecks) {
    if (Get-Command npm -ErrorAction SilentlyContinue) {
        Log 'Running `npm install` (may take a while)'
        npm install 2>&1 | Write-Host

        Log 'TypeScript check: `npx tsc --noEmit`'
        try { npx tsc --noEmit; if ($LASTEXITCODE -ne 0) { $errors += 'TypeScript check failed'; Log 'TS check: FAILED' } else { Log 'TS check: OK' } } catch { $errors += 'TypeScript check failed' ; Log 'TS check: FAILED' }

        Log 'Attempting ESLint (if configured)'
        try {
            pwsh -NoProfile -Command "& { npx --no-install eslint --version }" 2>$null
            try { npx eslint . --ext .ts, .tsx, .js 2>&1 | Write-Host } catch { $errors += 'ESLint run failed'; Log 'ESLint run failed' }
        }
        catch { Log 'ESLint not installed locally; skipping lint step' ; $errors += 'ESLint not installed' }

        Log 'Attempting Prettier check (if available)'
        try {
            pwsh -NoProfile -Command "& { npx --no-install prettier --version }" 2>$null
            try { npx prettier --check . 2>&1 | Write-Host } catch { $errors += 'Prettier run failed'; Log 'Prettier run failed' }
        }
        catch { Log 'Prettier not installed locally; skipping prettier check' ; $errors += 'Prettier not installed' }

        Log 'Build step: prefer `npm run build`, fallback to `npx vite build`'
        try { npm run build 2>&1 | Write-Host } catch { try { npx vite build 2>&1 | Write-Host } catch { $errors += 'Build failed'; Log 'Build: FAILED' } }
    }
    else { Log 'npm not found — skipping Node/TS checks' }
}
else { Log 'Skipping Node checks (requested)' }

if (-not $SkipPSAnalyzer) {
    if (Get-Command pwsh -ErrorAction SilentlyContinue) {
        try {
            if (-not (Get-Module -ListAvailable -Name PSScriptAnalyzer)) {
                Log 'Installing PSScriptAnalyzer (CurrentUser)'
                pwsh -NoProfile -Command "Install-Module -Name PSScriptAnalyzer -Force -Scope CurrentUser -AllowClobber" | Write-Host
            }
            Log 'Running Invoke-ScriptAnalyzer on PowerShell sources'
            $psReport = pwsh -NoProfile -Command "Import-Module PSScriptAnalyzer; Invoke-ScriptAnalyzer -Path .\ -Recurse -Severity Warning | ConvertTo-Json -Depth 4"
            if ($psReport -and $psReport -ne '[]') {
                $reportPath = Join-Path -Path $PSScriptRoot -ChildPath '..\psscriptanalyzer-report.json'
                $resolved = $null
                try { $resolved = Resolve-Path -Path $reportPath -ErrorAction SilentlyContinue } catch { }
                if ($resolved) { $reportPath = $resolved.Path }
                $psReport | Out-File -FilePath $reportPath -Encoding utf8
                $errors += 'PSScriptAnalyzer found issues (see psscriptanalyzer-report.json)'
                Log "PSScriptAnalyzer: issues written to $reportPath"
            }
            else { Log 'PSScriptAnalyzer: No warnings or errors found' }
        }
        catch { Log "PSScriptAnalyzer run failed: $($_.Exception.Message)"; $errors += 'PSScriptAnalyzer failure' }
    }
    else { Log 'pwsh not available — skipping PSScriptAnalyzer' }
}
else { Log 'Skipping PSScriptAnalyzer (requested)' }

# Run smoke-tests script if present
$smokePaths = @(Join-Path $PSScriptRoot '..\scripts\run-smoke-tests.ps1')
foreach ($p in $smokePaths) {
    if (Test-Path $p) {
        Log "Running smoke tests: $p"
        try { pwsh -NoProfile -File $p; Log 'Smoke tests: completed' } catch { $errors += 'Smoke tests failed'; Log 'Smoke tests: FAILED' }
        break
    }
}

if ($errors.Count -gt 0) {
    Write-Host "`n=== VERIFICATION SUMMARY: FAILURES FOUND ===`n" -ForegroundColor Red
    $errors | ForEach-Object { Write-Host "- $_" }
    exit 1
}
else {
    Write-Host "`n=== VERIFICATION SUMMARY: ALL CHECKS PASSED ===`n" -ForegroundColor Green
    exit 0
}
