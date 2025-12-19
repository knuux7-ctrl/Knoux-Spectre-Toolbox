<#
.SYNOPSIS
  Smoke test for ps-runner.ps1 invoking Get-SystemAuditReport
.DESCRIPTION
  This script invokes the ps-runner.ps1 with the function name and prints JSON result.
#>
param()

$runner = Join-Path $PSScriptRoot 'ps-runner.ps1'
if (-not (Test-Path $runner)) { Write-Error "ps-runner.ps1 not found at $runner"; exit 2 }

Write-Host "Running ps-runner test -> Get-SystemAuditReport..."

$proc = & pwsh -NoProfile -NonInteractive -ExecutionPolicy Bypass -File $runner -FunctionName 'Get-SystemAuditReport' -PayloadJson '{}'

Write-Host "Raw output:`n$proc"

try { $obj = $proc | ConvertFrom-Json -ErrorAction Stop; Write-Host "Parsed JSON:`n"; $obj | ConvertTo-Json -Depth 5 | Write-Host } catch { Write-Warning "Output not valid JSON" }
