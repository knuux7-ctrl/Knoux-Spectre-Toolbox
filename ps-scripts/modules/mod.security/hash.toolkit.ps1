# Knoux Spectre Hash Toolkit Module

function Get-FileHash-Knoux {
    param(
        [string]$FilePath,
        [string]$Algorithm = "SHA256"
    )
    
    if (-not (Test-Path $FilePath)) {
        return @{ error = "File not found"; success = $false }
    }
    
    try {
        $hash = Get-FileHash -Path $FilePath -Algorithm $Algorithm
        return @{ 
            success = $true
            file = $FilePath
            algorithm = $Algorithm
            hash = $hash.Hash
        }
    } catch {
        return @{ error = $_.Exception.Message; success = $false }
    }
}

function Compare-FileHashes {
    param(
        [string]$File1,
        [string]$File2,
        [string]$Algorithm = "SHA256"
    )
    
    $hash1 = Get-FileHash -Path $File1 -Algorithm $Algorithm
    $hash2 = Get-FileHash -Path $File2 -Algorithm $Algorithm
    
    return @{
        file1 = $File1
        file1Hash = $hash1.Hash
        file2 = $File2
        file2Hash = $hash2.Hash
        match = ($hash1.Hash -eq $hash2.Hash)
    }
}

Export-ModuleMember -Function @('Get-FileHash-Knoux', 'Compare-FileHashes')
