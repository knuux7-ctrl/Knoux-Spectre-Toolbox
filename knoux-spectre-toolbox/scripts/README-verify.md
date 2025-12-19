# Verification script: `verify-project.ps1`

Purpose: Run a one-shot verification of the repository locally. The script runs:

- `npm install` (if `npm` available)
- `npx tsc --noEmit` to run TypeScript checks
- `npx eslint` where configured
- `npx prettier --check` where configured
- `npm run build` (fallback to `npx vite build`)
- PowerShell static analysis: `Invoke-ScriptAnalyzer` (PSScriptAnalyzer)
- Runs `scripts/run-smoke-tests.ps1` if present

How to run (PowerShell Core / pwsh recommended):

```powershell
# From repo root
pwsh -NoProfile -File .\knoux-spectre-toolbox\scripts\verify-project.ps1

# To skip Node checks (useful on CI agents with only PowerShell checks):
pwsh -NoProfile -File .\knoux-spectre-toolbox\scripts\verify-project.ps1 -SkipNodeChecks

# To skip PSScriptAnalyzer step:
pwsh -NoProfile -File .\knoux-spectre-toolbox\knoux-spectre-toolbox\scripts\verify-project.ps1 -SkipPSAnalyzer
```

Output:

- Exits `0` when all checks pass, otherwise exits `1` and writes a short summary.
- When PSScriptAnalyzer finds issues, a JSON report `psscriptanalyzer-report.json` will be created at the repo root.

Notes:

- The script attempts to be non-destructive and will skip checks when required tooling is missing.
- For CI integration, call the script from the workspace and ensure Node and pwsh are installed on the runner.
