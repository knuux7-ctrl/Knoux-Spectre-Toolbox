# Knoux Spectre Disk Cleanup Module

function Get-DiskUsage {
    Get-Volume | Where-Object {$_.Size -gt 0} | Select-Object @{
        Name = "Drive"
        Expression = {$_.DriveLetter}
    }, @{
        Name = "Size (GB)"
        Expression = {[Math]::Round($_.Size / 1GB, 2)}
    }, @{
        Name = "Used (GB)"
        Expression = {[Math]::Round(($_.Size - $_.SizeRemaining) / 1GB, 2)}
    }, @{
        Name = "Free (GB)"
        Expression = {[Math]::Round($_.SizeRemaining / 1GB, 2)}
    }, @{
        Name = "Usage %"
        Expression = {[Math]::Round((($_.Size - $_.SizeRemaining) / $_.Size) * 100, 2)}
    }
}

function Clean-TempFiles {
    $tempPaths = @("$env:TEMP", "$env:SystemRoot\Temp")
    $totalFreed = 0
    
    foreach ($path in $tempPaths) {
        if (Test-Path $path) {
            $beforeSize = (Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
            Remove-Item -Path "$path\*" -Recurse -Force -ErrorAction SilentlyContinue
            $afterSize = (Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
            $totalFreed += ($beforeSize - $afterSize)
        }
    }
    
    return @{ freed = $totalFreed; success = $true }
}

Export-ModuleMember -Function @('Get-DiskUsage', 'Clean-TempFiles')
