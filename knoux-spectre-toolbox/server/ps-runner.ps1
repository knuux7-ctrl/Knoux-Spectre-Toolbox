param(
    [Parameter(Mandatory = $true)][string]$FunctionName,
    [Parameter(Mandatory = $false)][string]$PayloadJson = '{}',
    [Parameter(Mandatory = $false)][switch]$AllowInteractive
)

try {
    $script:ModuleRoot = Join-Path $PSScriptRoot '..\modules'
    if (Test-Path $script:ModuleRoot) {
        Get-ChildItem -Path $script:ModuleRoot -Recurse -Filter "*.ps1" | ForEach-Object { try { . $_.FullName } catch {} }
    }

    $payload = $null
    if ($PayloadJson) {
        $payload = $PayloadJson | ConvertFrom-Json -ErrorAction SilentlyContinue
    }

    $cmd = Get-Command -Name $FunctionName -ErrorAction SilentlyContinue
    if (-not $cmd) {
        $out = @{ success = $false; error = "Function '$FunctionName' not found" }
        $out | ConvertTo-Json -Depth 5
        exit 1
    }

    # Inspect function body to prevent API hangs from interactive prompts
    try {
        $src = $cmd.ScriptBlock.ToString()
        if (-not $AllowInteractive) {
            if ($src -match 'Read-Host' -or $src -match 'ReadKey' -or $src -match 'Confirm-KnouxAction') {
                $out = @{ success = $false; error = "Function '$FunctionName' appears interactive and cannot be executed via API. Create a non-interactive wrapper or call with AllowInteractive switch." }
                $out | ConvertTo-Json -Depth 5
                exit 2
            }
        }
    }
    catch { }

    try {
        if ($payload -and ($payload -is [hashtable] -or $payload -is [psobject])) {
            $args = @{}
            foreach ($p in $payload.PSObject.Properties) { $args[$p.Name] = $p.Value }
            $result = & $FunctionName @args
        }
        else {
            $result = & $FunctionName
        }

        $response = @{ success = $true; result = $result }
        $response | ConvertTo-Json -Depth 10
    }
    catch {
        $err = $_.Exception.Message
        $response = @{ success = $false; error = $err }
        $response | ConvertTo-Json -Depth 5
        exit 1
    }
}
catch {
    $response = @{ success = $false; error = $_.Exception.Message }
    $response | ConvertTo-Json -Depth 5
    exit 1
}
