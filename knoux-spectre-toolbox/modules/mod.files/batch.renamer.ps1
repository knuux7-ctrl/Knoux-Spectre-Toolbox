<#
.SYNOPSIS
    Knoux Spectre File Utilities
.DESCRIPTION
    Comprehensive file management and manipulation tools
.AUTHOR
    Knoux Systems
.VERSION
    1.0.0
#>

function Show-FileUtilities {
    [CmdletBinding()]
    param()
    
    Clear-ScreenWithBackground
    Write-Host "${ANSI.BG_DARK}${ANSI.PURPLE}${ANSI.BOLD}📂 FILE UTILITIES${ANSI.RESET}"
    Write-Host "${ANSI.BORDER}────────────────────────────────${ANSI.RESET}"
    Write-Host ""
    
    do {
        Write-Host "${ANSI.TEXT_SECONDARY}File Utilities Options:${ANSI.RESET}"
        Write-Host " ${ANSI.PURPLE}1${ANSI.RESET} ${ANSI.TEXT_PRIMARY}Batch Renamer${ANSI.RESET}"
        Write-Host " ${ANSI.PURPLE}2${ANSI.RESET} ${ANSI.TEXT_PRIMARY}File Converter${ANSI.RESET}"
        Write-Host " ${ANSI.PURPLE}3${ANSI.RESET} ${ANSI.TEXT_PRIMARY}Duplicate Finder${ANSI.RESET}"
        Write-Host " ${ANSI.PURPLE}4${ANSI.RESET} ${ANSI.TEXT_PRIMARY}File Comparer${ANSI.RESET}"
        Write-Host " ${ANSI.PURPLE}5${ANSI.RESET} ${ANSI.TEXT_PRIMARY}File Organizer${ANSI.RESET}"
        Write-Host ""
        Write-Host " ${ANSI.RED}0${ANSI.RESET} ${ANSI.TEXT_PRIMARY}Back to Menu${ANSI.RESET}"
        Write-Host ""
        
        $choice = Read-ValidatedSubInput -Max 5
        
        switch ($choice) {
            0 { return }
            1 { Show-BatchRenamer }
            2 { Show-FileConverter }
            3 { Find-Duplicates }
            4 { Compare-Files }
            5 { Organize-Files }
        }
        
        Write-Host ""
        Write-Host "${ANSI.TEXT_SECONDARY}Press any key to continue...${ANSI.RESET}"
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        Clear-ScreenWithBackground
        
    } while ($true)
}

function Show-BatchRenamer {
    Write-Host ""
    Write-Host "${ANSI.PURPLE}${ANSI.BOLD}BATCH RENAMER${ANSI.RESET}"
    Write-Host "${ANSI.BORDER}─────────────${ANSI.RESET}"
    Write-Host ""
    
    Write-Host "${ANSI.TEXT_SECONDARY}Enter directory path:${ANSI.RESET}"
    Write-Host "${ANSI.PURPLE}>>${ANSI.RESET} " -NoNewline
    $directory = Read-Host
    
    if ([string]::IsNullOrWhiteSpace($directory)) {
        Write-Host "${ANSI.RED}× Directory path cannot be empty${ANSI.RESET}"
        return
    }
    
    if (-not (Test-Path $directory)) {
        Write-Host "${ANSI.RED}× Directory not found: $directory${ANSI.RESET}"
        return
    }
    
    Write-Host ""
    Write-Host "${ANSI.TEXT_SECONDARY}Select renaming pattern:${ANSI.RESET}"
    Write-Host " ${ANSI.PURPLE}1${ANSI.RESET} ${ANSI.TEXT_PRIMARY}Sequential numbering${ANSI.RESET}"
    Write-Host " ${ANSI.PURPLE}2${ANSI.RESET} ${ANSI.TEXT_PRIMARY}Add prefix${ANSI.RESET}"
    Write-Host " ${ANSI.PURPLE}3${ANSI.RESET} ${ANSI.TEXT_PRIMARY}Add suffix${ANSI.RESET}"
    Write-Host " ${ANSI.PURPLE}4${ANSI.RESET} ${ANSI.TEXT_PRIMARY}Replace text${ANSI.RESET}"
    Write-Host " ${ANSI.PURPLE}5${ANSI.RESET} ${ANSI.TEXT_PRIMARY}Change case${ANSI.RESET}"
    Write-Host ""
    
    $patternChoice = Read-ValidatedSubInput -Max 5
    
    # Get files in directory
    $files = Get-ChildItem -Path $directory -File
    
    if ($files.Count -eq 0) {
        Write-Host "${ANSI.TEXT_SECONDARY}No files found in directory${ANSI.RESET}"
        return
    }
    
    Write-Host ""
    Write-Host "${ANSI.TEXT_SECONDARY}Found $($files.Count) files${ANSI.RESET}"
    
    try {
        switch ($patternChoice) {
            1 {
                # Sequential numbering
                Write-Host ""
                Write-Host "${ANSI.TEXT_SECONDARY}Enter base name:${ANSI.RESET}"
                Write-Host "${ANSI.PURPLE}>>${ANSI.RESET} " -NoNewline
                $baseName = Read-Host
                
                Write-Host ""
                Write-Host "${ANSI.TEXT_SECONDARY}Enter start number:${ANSI.RESET}"
                Write-Host "${ANSI.PURPLE}>>${ANSI.RESET} " -NoNewline
                $startNum = Read-Host
                
                if (-not ($startNum -match "^\d+$")) {
                    $startNum = 1
                }
                else {
                    $startNum = [int]$startNum
                }
                
                Write-Host ""
                Write-Host "${ANSI.ORANGE}? Preview of changes:${ANSI.RESET}"
                for ($i = 0; $i -lt [math]::Min(5, $files.Count); $i++) {
                    $file = $files[$i]
                    $newName = "${baseName}_$('{0:D3}' -f ($startNum + $i))$($file.Extension)"
                    Write-Host " ${ANSI.TEXT_SECONDARY}$($file.Name)${ANSI.RESET} → ${ANSI.TEXT_PRIMARY}$newName${ANSI.RESET}"
                }
                
                if ($files.Count -gt 5) {
                    Write-Host " ${ANSI.TEXT_SECONDARY}... and $(($files.Count - 5)) more files${ANSI.RESET}"
                }
                
                $confirm = Confirm-KnouxAction "Apply these changes?" "N"
                if ($confirm) {
                    for ($i = 0; $i -lt $files.Count; $i++) {
                        $file = $files[$i]
                        $newName = "${baseName}_$('{0:D3}' -f ($startNum + $i))$($file.Extension)"
                        $newPath = Join-Path $directory $newName
                        
                        try {
                            Rename-Item -Path $file.FullName -NewName $newName -ErrorAction Stop
                            Write-Host " ${ANSI.GREEN}✓ Renamed: $($file.Name) → $newName${ANSI.RESET}"
                        }
                        catch {
                            Write-Host " ${ANSI.RED}× Failed: $($file.Name) → $newName${ANSI.RESET}"
                        }
                    }
                    Write-Host ""
                    Write-Host "${ANSI.GREEN}✓ Batch renaming completed${ANSI.RESET}"
                }
            }
            
            2 {
                # Add prefix
                Write-Host ""
                Write-Host "${ANSI.TEXT_SECONDARY}Enter prefix:${ANSI.RESET}"
                Write-Host "${ANSI.PURPLE}>>${ANSI.RESET} " -NoNewline
                $prefix = Read-Host
                
                Write-Host ""
                Write-Host "${ANSI.ORANGE}? Preview of changes:${ANSI.RESET}"
                for ($i = 0; $i -lt [math]::Min(5, $files.Count); $i++) {
                    $file = $files[$i]
                    $newName = "${prefix}$($file.Name)"
                    Write-Host " ${ANSI.TEXT_SECONDARY}$($file.Name)${ANSI.RESET} → ${ANSI.TEXT_PRIMARY}$newName${ANSI.RESET}"
                }
                
                if ($files.Count -gt 5) {
                    Write-Host " ${ANSI.TEXT_SECONDARY}... and $(($files.Count - 5)) more files${ANSI.RESET}"
                }
                
                $confirm = Confirm-KnouxAction "Apply these changes?" "N"
                if ($confirm) {
                    foreach ($file in $files) {
                        $newName = "${prefix}$($file.Name)"
                        $newPath = Join-Path $directory $newName
                        
                        try {
                            Rename-Item -Path $file.FullName -NewName $newName -ErrorAction Stop
                            Write-Host " ${ANSI.GREEN}✓ Renamed: $($file.Name) → $newName${ANSI.RESET}"
                        }
                        catch {
                            Write-Host " ${ANSI.RED}× Failed: $($file.Name) → $newName${ANSI.RESET}"
                        }
                    }
                    Write-Host ""
                    Write-Host "${ANSI.GREEN}✓ Prefix addition completed${ANSI.RESET}"
                }
            }
            
            3 {
                # Add suffix
                Write-Host ""
                Write-Host "${ANSI.TEXT_SECONDARY}Enter suffix:${ANSI.RESET}"
                Write-Host "${ANSI.PURPLE}>>${ANSI.RESET} " -NoNewline
                $suffix = Read-Host
                
                Write-Host ""
                Write-Host "${ANSI.ORANGE}? Preview of changes:${ANSI.RESET}"
                for ($i = 0; $i -lt [math]::Min(5, $files.Count); $i++) {
                    $file = $files[$i]
                    $newName = "$($file.BaseName)${suffix}$($file.Extension)"
                    Write-Host " ${ANSI.TEXT_SECONDARY}$($file.Name)${ANSI.RESET} → ${ANSI.TEXT_PRIMARY}$newName${ANSI.RESET}"
                }
                
                if ($files.Count -gt 5) {
                    Write-Host " ${ANSI.TEXT_SECONDARY}... and $(($files.Count - 5)) more files${ANSI.RESET}"
                }
                
                $confirm = Confirm-KnouxAction "Apply these changes?" "N"
                if ($confirm) {
                    foreach ($file in $files) {
                        $newName = "$($file.BaseName)${suffix}$($file.Extension)"
                        $newPath = Join-Path $directory $newName
                        
                        try {
                            Rename-Item -Path $file.FullName -NewName $newName -ErrorAction Stop
                            Write-Host " ${ANSI.GREEN}✓ Renamed: $($file.Name) → $newName${ANSI.RESET}"
                        }
                        catch {
                            Write-Host " ${ANSI.RED}× Failed: $($file.Name) → $newName${ANSI.RESET}"
                        }
                    }
                    Write-Host ""
                    Write-Host "${ANSI.GREEN}✓ Suffix addition completed${ANSI.RESET}"
                }
            }
            
            4 {
                # Replace text
                Write-Host ""
                Write-Host "${ANSI.TEXT_SECONDARY}Enter text to replace:${ANSI.RESET}"
                Write-Host "${ANSI.PURPLE}>>${ANSI.RESET} " -NoNewline
                $oldText = Read-Host
                
                Write-Host ""
                Write-Host "${ANSI.TEXT_SECONDARY}Enter replacement text:${ANSI.RESET}"
                Write-Host "${ANSI.PURPLE}>>${ANSI.RESET} " -NoNewline
                $newText = Read-Host
                
                Write-Host ""
                Write-Host "${ANSI.ORANGE}? Preview of changes:${ANSI.RESET}"
                $previewCount = 0
                foreach ($file in $files) {
                    if ($previewCount -ge 5) { break }
                    if ($file.Name -like "*$oldText*") {
                        $newName = $file.Name -replace [regex]::Escape($oldText), $newText
                        Write-Host " ${ANSI.TEXT_SECONDARY}$($file.Name)${ANSI.RESET} → ${ANSI.TEXT_PRIMARY}$newName${ANSI.RESET}"
                        $previewCount++
                    }
                }
                
                if ($previewCount -eq 0) {
                    Write-Host " ${ANSI.TEXT_SECONDARY}No files match the pattern${ANSI.RESET}"
                    return
                }
                
                $confirm = Confirm-KnouxAction "Apply these changes?" "N"
                if ($confirm) {
                    $renamedCount = 0
                    foreach ($file in $files) {
                        if ($file.Name -like "*$oldText*") {
                            $newName = $file.Name -replace [regex]::Escape($oldText), $newText
                            $newPath = Join-Path $directory $newName
                            
                            try {
                                Rename-Item -Path $file.FullName -NewName $newName -ErrorAction Stop
                                Write-Host " ${ANSI.GREEN}✓ Renamed: $($file.Name) → $newName${ANSI.RESET}"
                                $renamedCount++
                            }
                            catch {
                                Write-Host " ${ANSI.RED}× Failed: $($file.Name) → $newName${ANSI.RESET}"
                            }
                        }
                    }
                    Write-Host ""
                    Write-Host "${ANSI.GREEN}✓ Text replacement completed ($renamedCount files)${ANSI.RESET}"
                }
            }
            
            5 {
                # Change case
                Write-Host ""
                Write-Host "${ANSI.TEXT_SECONDARY}Select case conversion:${ANSI.RESET}"
                Write-Host " ${ANSI.PURPLE}1${ANSI.RESET} ${ANSI.TEXT_PRIMARY}UPPERCASE${ANSI.RESET}"
                Write-Host " ${ANSI.PURPLE}2${ANSI.RESET} ${ANSI.TEXT_PRIMARY}lowercase${ANSI.RESET}"
                Write-Host " ${ANSI.PURPLE}3${ANSI.RESET} ${ANSI.TEXT_PRIMARY}Title Case${ANSI.RESET}"
                Write-Host ""
                
                $caseChoice = Read-ValidatedSubInput -Max 3
                
                Write-Host ""
                Write-Host "${ANSI.ORANGE}? Preview of changes:${ANSI.RESET}"
                for ($i = 0; $i -lt [math]::Min(5, $files.Count); $i++) {
                    $file = $files[$i]
                    $newName = switch ($caseChoice) {
                        1 { $file.Name.ToUpper() }
                        2 { $file.Name.ToLower() }
                        3 { (Get-Culture).TextInfo.ToTitleCase($file.Name.ToLower()) }
                    }
                    Write-Host " ${ANSI.TEXT_SECONDARY}$($file.Name)${ANSI.RESET} → ${ANSI.TEXT_PRIMARY}$newName${ANSI.RESET}"
                }
                
                if ($files.Count -gt 5) {
                    Write-Host " ${ANSI.TEXT_SECONDARY}... and $(($files.Count - 5)) more files${ANSI.RESET}"
                }
                
                $confirm = Confirm-KnouxAction "Apply these changes?" "N"
                if ($confirm) {
                    $renamedCount = 0
                    foreach ($file in $files) {
                        $newName = switch ($caseChoice) {
                            1 { $file.Name.ToUpper() }
                            2 { $file.Name.ToLower() }
                            3 { (Get-Culture).TextInfo.ToTitleCase($file.Name.ToLower()) }
                        }
                        
                        if ($file.Name -ne $newName) {
                            $newPath = Join-Path $directory $newName
                            
                            try {
                                Rename-Item -Path $file.FullName -NewName $newName -ErrorAction Stop
                                Write-Host " ${ANSI.GREEN}✓ Renamed: $($file.Name) → $newName${ANSI.RESET}"
                                $renamedCount++
                            }
                            catch {
                                Write-Host " ${ANSI.RED}× Failed: $($file.Name) → $newName${ANSI.RESET}"
                            }
                        }
                    }
                    Write-Host ""
                    Write-Host "${ANSI.GREEN}✓ Case conversion completed ($renamedCount files)${ANSI.RESET}"
                }
            }
        }
    }
    catch {
        Write-Host "${ANSI.RED}× Error during batch renaming: $($_.Exception.Message)${ANSI.RESET}"
    }
}

function Show-FileConverter {
    Write-Host ""
    Write-Host "${ANSI.PURPLE}${ANSI.BOLD}FILE CONVERTER${ANSI.RESET}"
    Write-Host "${ANSI.BORDER}──────────────${ANSI.RESET}"
    Write-Host ""
    
    Write-Host "${ANSI.TEXT_SECONDARY}Select conversion type:${ANSI.RESET}"
    Write-Host " ${ANSI.PURPLE}1${ANSI.RESET} ${ANSI.TEXT_PRIMARY}Text Encoding Converter${ANSI.RESET}"
    Write-Host " ${ANSI.PURPLE}2${ANSI.RESET} ${ANSI.TEXT_PRIMARY}Line Ending Converter${ANSI.RESET}"
    Write-Host " ${ANSI.PURPLE}3${ANSI.RESET} ${ANSI.TEXT_PRIMARY}File Format Converter${ANSI.RESET}"
    Write-Host ""
    
    $convChoice = Read-ValidatedSubInput -Max 3
    
    switch ($convChoice) {
        1 {
            Convert-TextEncoding
        }
        2 {
            Convert-LineEndings
        }
        3 {
            Convert-FileFormats
        }
    }
}

function Convert-TextEncoding {
    Write-Host ""
    Write-Host "${ANSI.TEXT_SECONDARY}Enter file path or directory:${ANSI.RESET}"
    Write-Host "${ANSI.PURPLE}>>${ANSI.RESET} " -NoNewline
    $path = Read-Host
    
    if ([string]::IsNullOrWhiteSpace($path)) {
        Write-Host "${ANSI.RED}× Path cannot be empty${ANSI.RESET}"
        return
    }
    
    if (-not (Test-Path $path)) {
        Write-Host "${ANSI.RED}× Path not found: $path${ANSI.RESET}"
        return
    }
    
    $files = if (Test-Path $path -PathType Leaf) {
        @(Get-Item $path)
    }
    else {
        Get-ChildItem -Path $path -File -Recurse
    }
    
    Write-Host ""
    Write-Host "${ANSI.TEXT_SECONDARY}Select source encoding:${ANSI.RESET}"
    Write-Host " ${ANSI.PURPLE}1${ANSI.RESET} ${ANSI.TEXT_PRIMARY}UTF-8${ANSI.RESET}"
    Write-Host " ${ANSI.PURPLE}2${ANSI.RESET} ${ANSI.TEXT_PRIMARY}UTF-16${ANSI.RESET}"
    Write-Host " ${ANSI.PURPLE}3${ANSI.RESET} ${ANSI.TEXT_PRIMARY}ASCII${ANSI.RESET}"
    Write-Host " ${ANSI.PURPLE}4${ANSI.RESET} ${ANSI.TEXT_PRIMARY}Windows-1252${ANSI.RESET}"
    Write-Host ""
    
    $sourceEnc = Read-ValidatedSubInput -Max 4
    
    Write-Host ""
    Write-Host "${ANSI.TEXT_SECONDARY}Select target encoding:${ANSI.RESET}"
    Write-Host " ${ANSI.PURPLE}1${ANSI.RESET} ${ANSI.TEXT_PRIMARY}UTF-8${ANSI.RESET}"
    Write-Host " ${ANSI.PURPLE}2${ANSI.RESET} ${ANSI.TEXT_PRIMARY}UTF-16${ANSI.RESET}"
    Write-Host " ${ANSI.PURPLE}3${ANSI.RESET} ${ANSI.TEXT_PRIMARY}ASCII${ANSI.RESET}"
    Write-Host " ${ANSI.PURPLE}4${ANSI.RESET} ${ANSI.TEXT_PRIMARY}Windows-1252${ANSI.RESET}"
    Write-Host ""
    
    $targetEnc = Read-ValidatedSubInput -Max 4
    
    $encodingMap = @{
        1 = "UTF8"
        2 = "Unicode"
        3 = "ASCII"
        4 = "Windows-1252"
    }
    
    $sourceEncoding = $encodingMap[$sourceEnc]
    $targetEncoding = $encodingMap[$targetEnc]
    
    Write-Host ""
    Write-Host "${ANSI.TEXT_SECONDARY}Converting $($files.Count) files from $sourceEncoding to $targetEncoding...${ANSI.RESET}"
    
    $convertedCount = 0
    foreach ($file in $files) {
        if ($file.Extension -match "\.(txt|csv|log|md|xml)$") {
            Write-Host "${ANSI.TEXT_SECONDARY}Converting $($file.Name)...${ANSI.RESET}" -NoNewline
            
            try {
                $content = Get-Content -Path $file.FullName -Encoding $sourceEncoding -ErrorAction Stop
                $content | Out-File -FilePath $file.FullName -Encoding $targetEncoding -Force
                Write-Host " ${ANSI.GREEN}DONE${ANSI.RESET}"
                $convertedCount++
            }
            catch {
                Write-Host " ${ANSI.RED}FAILED${ANSI.RESET}"
            }
        }
    }
    
    Write-Host ""
    Write-Host "${ANSI.GREEN}✓ Converted $convertedCount files${ANSI.RESET}"
}

function Convert-LineEndings {
    Write-Host ""
    Write-Host "${ANSI.TEXT_SECONDARY}Enter file path or directory:${ANSI.RESET}"
    Write-Host "${ANSI.PURPLE}>>${ANSI.RESET} " -NoNewline
    $path = Read-Host
    
    if ([string]::IsNullOrWhiteSpace($path)) {
        Write-Host "${ANSI.RED}× Path cannot be empty${ANSI.RESET}"
        return
    }
    
    if (-not (Test-Path $path)) {
        Write-Host "${ANSI.RED}× Path not found: $path${ANSI.RESET}"
        return
    }
    
    $files = if (Test-Path $path -PathType Leaf) {
        @(Get-Item $path)
    }
    else {
        Get-ChildItem -Path $path -File -Recurse
    }
    
    Write-Host ""
    Write-Host "${ANSI.TEXT_SECONDARY}Select target line ending:${ANSI.RESET}"
    Write-Host " ${ANSI.PURPLE}1${ANSI.RESET} ${ANSI.TEXT_PRIMARY}Windows (CRLF)${ANSI.RESET}"
    Write-Host " ${ANSI.PURPLE}2${ANSI.RESET} ${ANSI.TEXT_PRIMARY}Unix/Linux (LF)${ANSI.RESET}"
    Write-Host " ${ANSI.PURPLE}3${ANSI.RESET} ${ANSI.TEXT_PRIMARY}Mac Classic (CR)${ANSI.RESET}"
    Write-Host ""
    
    $lineEndingChoice = Read-ValidatedSubInput -Max 3
    
    $lineEndings = @{
        1 = "`r`n"  # CRLF
        2 = "`n"    # LF
        3 = "`r"    # CR
    }
    
    $targetEnding = $lineEndings[$lineEndingChoice]
    $endingNames = @{
        1 = "Windows (CRLF)"
        2 = "Unix/Linux (LF)"
        3 = "Mac Classic (CR)"
    }
    
    Write-Host ""
    Write-Host "${ANSI.TEXT_SECONDARY}Converting $($files.Count) files to $($endingNames[$lineEndingChoice])...${ANSI.RESET}"
    
    $convertedCount = 0
    foreach ($file in $files) {
        if ($file.Extension -match "\.(txt|csv|log|md|xml|json|py|js|html|css)$") {
            Write-Host "${ANSI.TEXT_SECONDARY}Converting $($file.Name)...${ANSI.RESET}" -NoNewline
            
            try {
                $content = Get-Content -Path $file.FullName -Raw -ErrorAction Stop
                if ($content -ne $null) {
                    # Normalize to single line feeds first
                    $content = $content -replace "`r`n", "`n"
                    $content = $content -replace "`r", "`n"
                    
                    # Convert to target line ending
                    if ($targetEnding -ne "`n") {
                        $content = $content -replace "`n", $targetEnding
                    }
                    
                    Set-Content -Path $file.FullName -Value $content -NoNewline -Encoding UTF8
                }
                Write-Host " ${ANSI.GREEN}DONE${ANSI.RESET}"
                $convertedCount++
            }
            catch {
                Write-Host " ${ANSI.RED}FAILED${ANSI.RESET}"
            }
        }
    }
    
    Write-Host ""
    Write-Host "${ANSI.GREEN}✓ Converted $convertedCount files${ANSI.RESET}"
}

function Convert-FileFormats {
    Write-Host ""
    Write-Host "${ANSI.TEXT_SECONDARY}Advanced file format conversion coming soon...${ANSI.RESET}"
    Write-Host "${ANSI.TEXT_SECONDARY}This feature will include:${ANSI.RESET}"
    Write-Host " ${ANSI.GREEN}•${ANSI.RESET} ${ANSI.TEXT_PRIMARY}Image format conversion (PNG, JPG, BMP, etc.)${ANSI.RESET}"
    Write-Host " ${ANSI.GREEN}•${ANSI.RESET} ${ANSI.TEXT_PRIMARY}Audio format conversion (MP3, WAV, FLAC, etc.)${ANSI.RESET}"
    Write-Host " ${ANSI.GREEN}•${ANSI.RESET} ${ANSI.TEXT_PRIMARY}Video format conversion (MP4, AVI, MOV, etc.)${ANSI.RESET}"
    Write-Host " ${ANSI.GREEN}•${ANSI.RESET} ${ANSI.TEXT_PRIMARY}Document format conversion (DOCX, PDF, etc.)${ANSI.RESET}"
}

function Find-Duplicates {
    Write-Host ""
    Write-Host "${ANSI.PURPLE}${ANSI.BOLD}DUPLICATE FINDER${ANSI.RESET}"
    Write-Host "${ANSI.BORDER}────────────────${ANSI.RESET}"
    Write-Host ""
    
    Write-Host "${ANSI.TEXT_SECONDARY}Enter directory to scan:${ANSI.RESET}"
    Write-Host "${ANSI.PURPLE}>>${ANSI.RESET} " -NoNewline
    $directory = Read-Host
    
    if ([string]::IsNullOrWhiteSpace($directory)) {
        Write-Host "${ANSI.RED}× Directory cannot be empty${ANSI.RESET}"
        return
    }
    
    if (-not (Test-Path $directory)) {
        Write-Host "${ANSI.RED}× Directory not found: $directory${ANSI.RESET}"
        return
    }
    
    Write-Host ""
    Write-Host "${ANSI.TEXT_SECONDARY}Scanning for duplicates...${ANSI.RESET}"
    
    try {
        # Get all files with their sizes and hashes
        $files = Get-ChildItem -Path $directory -File -Recurse | Select-Object FullName, Length, Name
        
        # Group files by size first (optimization)
        $sizeGroups = $files | Group-Object Length | Where-Object { $_.Count -gt 1 }
        
        Write-Host "${ANSI.TEXT_SECONDARY}Found $($sizeGroups.Count) size groups with potential duplicates${ANSI.RESET}"
        
        $duplicates = @()
        
        foreach ($group in $sizeGroups) {
            $groupFiles = $group.Group
            
            # For files with same size, calculate hash
            foreach ($file in $groupFiles) {
                try {
                    $hash = Get-FileHash -Path $file.FullName -Algorithm SHA256 -ErrorAction Stop
                    $file | Add-Member -NotePropertyName Hash -NotePropertyValue $hash.Hash
                }
                catch {
                    Write-Host "${ANSI.RED}× Error hashing $($file.Name): $($_.Exception.Message)${ANSI.RESET}"
                }
            }
            
            # Group by hash
            $hashGroups = $groupFiles | Where-Object { $_.Hash } | Group-Object Hash | Where-Object { $_.Count -gt 1 }
            
            foreach ($hashGroup in $hashGroups) {
                $duplicates += [PSCustomObject]@{
                    Hash  = $hashGroup.Name
                    Files = $hashGroup.Group
                }
            }
        }
        
        if ($duplicates.Count -eq 0) {
            Write-Host ""
            Write-Host "${ANSI.TEXT_SECONDARY}No duplicate files found${ANSI.RESET}"
            return
        }
        
        Write-Host ""
        Write-Host "${ANSI.PURPLE}${ANSI.BOLD}DUPLICATE SETS FOUND ($($duplicates.Count))${ANSI.RESET}"
        Write-Host "${ANSI.BORDER}─────────────────────────────${ANSI.RESET}"
        
        for ($i = 0; $i -lt $duplicates.Count; $i++) {
            $dupSet = $duplicates[$i]
            Write-Host " ${ANSI.PURPLE}SET $($i + 1)${ANSI.RESET} ${ANSI.TEXT_SECONDARY}(SHA256: $($dupSet.Hash.Substring(0, 16))...)${ANSI.RESET}"
            
            for ($j = 0; $j -lt $dupSet.Files.Count; $j++) {
                $file = $dupSet.Files[$j]
                $fileSize = Format-KnouxBytes $file.Length
                
                if ($j -eq 0) {
                    Write-Host "   ${ANSI.GREEN}● KEEP: $($file.FullName)${ANSI.RESET}"
                }
                else {
                    Write-Host "   ${ANSI.RED}● DELETE: $($file.FullName)${ANSI.RESET}"
                }
                Write-Host "     ${ANSI.TEXT_SECONDARY}Size: $fileSize${ANSI.RESET}"
            }
            
            Write-Host ""
        }
        
        Write-Host "${ANSI.ORANGE}⚠ Total duplicate files: $(($duplicates | ForEach-Object { $_.Files.Count - 1 } | Measure-Object -Sum).Sum)${ANSI.RESET}"
        Write-Host "${ANSI.TEXT_SECONDARY}Potential space savings: $(Format-KnouxBytes ($duplicates | ForEach-Object { $_.Files[0].Length * ($_.Files.Count - 1) } | Measure-Object -Sum).Sum)${ANSI.RESET}"
        
        $deleteDupes = Confirm-KnouxAction "Delete duplicate files?" "N"
        if ($deleteDupes) {
            $deletedCount = 0
            $totalSaved = 0
            
            foreach ($dupSet in $duplicates) {
                # Keep the first file, delete the rest
                for ($j = 1; $j -lt $dupSet.Files.Count; $j++) {
                    $fileToDelete = $dupSet.Files[$j]
                    try {
                        Remove-Item -Path $fileToDelete.FullName -Force -ErrorAction Stop
                        Write-Host " ${ANSI.GREEN}✓ Deleted: $($fileToDelete.FullName)${ANSI.RESET}"
                        $deletedCount++
                        $totalSaved += $fileToDelete.Length
                    }
                    catch {
                        Write-Host " ${ANSI.RED}× Failed to delete: $($fileToDelete.FullName)${ANSI.RESET}"
                    }
                }
            }
            
            Write-Host ""
            Write-Host "${ANSI.GREEN}✓ Deleted $deletedCount duplicate files${ANSI.RESET}"
            Write-Host "${ANSI.TEXT_SECONDARY}Space freed: $(Format-KnouxBytes $totalSaved)${ANSI.RESET}"
        }
    }
    catch {
        Write-Host "${ANSI.RED}× Error finding duplicates: $($_.Exception.Message)${ANSI.RESET}"
    }
}

function Compare-Files {
    Write-Host ""
    Write-Host "${ANSI.PURPLE}${ANSI.BOLD}FILE COMPARER${ANSI.RESET}"
    Write-Host "${ANSI.BORDER}─────────────${ANSI.RESET}"
    Write-Host ""
    
    Write-Host "${ANSI.TEXT_SECONDARY}Enter first file path:${ANSI.RESET}"
    Write-Host "${ANSI.PURPLE}>>${ANSI.RESET} " -NoNewline
    $file1 = Read-Host
    
    Write-Host ""
    Write-Host "${ANSI.TEXT_SECONDARY}Enter second file path:${ANSI.RESET}"
    Write-Host "${ANSI.PURPLE}>>${ANSI.RESET} " -NoNewline
    $file2 = Read-Host
    
    if ([string]::IsNullOrWhiteSpace($file1) -or [string]::IsNullOrWhiteSpace($file2)) {
        Write-Host "${ANSI.RED}× Both file paths are required${ANSI.RESET}"
        return
    }
    
    if (-not (Test-Path $file1)) {
        Write-Host "${ANSI.RED}× First file not found: $file1${ANSI.RESET}"
        return
    }
    
    if (-not (Test-Path $file2)) {
        Write-Host "${ANSI.RED}× Second file not found: $file2${ANSI.RESET}"
        return
    }
    
    Write-Host ""
    Write-Host "${ANSI.TEXT_SECONDARY}Comparing files...${ANSI.RESET}"
    
    try {
        # Get file hashes
        $hash1 = Get-FileHash -Path $file1 -Algorithm SHA256
        $hash2 = Get-FileHash -Path $file2 -Algorithm SHA256
        
        Write-Host ""
        Write-Host "${ANSI.PURPLE}${ANSI.BOLD}FILE COMPARISON RESULTS${ANSI.RESET}"
        Write-Host "${ANSI.BORDER}────────────────────────${ANSI.RESET}"
        
        Write-Host "${ANSI.TEXT_SECONDARY}File 1:${ANSI.RESET} ${ANSI.TEXT_PRIMARY}$file1${ANSI.RESET}"
        Write-Host "${ANSI.TEXT_SECONDARY}File 2:${ANSI.RESET} ${ANSI.TEXT_PRIMARY}$file2${ANSI.RESET}"
        Write-Host ""
        
        Write-Host "${ANSI.TEXT_SECONDARY}SHA256 Comparison:${ANSI.RESET}"
        Write-Host " ${ANSI.TEXT_SECONDARY}File 1:${ANSI.RESET} ${ANSI.TEXT_PRIMARY}$($hash1.Hash)${ANSI.RESET}"
        Write-Host " ${ANSI.TEXT_SECONDARY}File 2:${ANSI.RESET} ${ANSI.TEXT_PRIMARY}$($hash2.Hash)${ANSI.RESET}"
        Write-Host ""
        
        if ($hash1.Hash -eq $hash2.Hash) {
            Write-Host " ${ANSI.GREEN}✓ Files are IDENTICAL${ANSI.RESET}"
        }
        else {
            Write-Host " ${ANSI.RED}× Files are DIFFERENT${ANSI.RESET}"
            
            # Compare file sizes
            $size1 = (Get-Item $file1).Length
            $size2 = (Get-Item $file2).Length
            
            Write-Host ""
            Write-Host "${ANSI.TEXT_SECONDARY}File Size Comparison:${ANSI.RESET}"
            Write-Host " ${ANSI.TEXT_SECONDARY}File 1:${ANSI.RESET} ${ANSI.TEXT_PRIMARY}$(Format-KnouxBytes $size1)${ANSI.RESET}"
            Write-Host " ${ANSI.TEXT_SECONDARY}File 2:${ANSI.RESET} ${ANSI.TEXT_PRIMARY}$(Format-KnouxBytes $size2)${ANSI.RESET}"
            
            # Text file comparison
            if ($file1 -match "\.(txt|log|md|csv)$" -and $file2 -match "\.(txt|log|md|csv)$") {
                $content1 = Get-Content -Path $file1 -ErrorAction SilentlyContinue
                $content2 = Get-Content -Path $file2 -ErrorAction SilentlyContinue
                
                if ($content1 -and $content2) {
                    Write-Host ""
                    Write-Host "${ANSI.TEXT_SECONDARY}Text Difference Analysis:${ANSI.RESET}"
                    
                    # Simple line-by-line comparison
                    $maxLength = [math]::Max($content1.Count, $content2.Count)
                    $diffCount = 0
                    
                    for ($i = 0; $i -lt $maxLength; $i++) {
                        $line1 = if ($i -lt $content1.Count) { $content1[$i] } else { $null }
                        $line2 = if ($i -lt $content2.Count) { $content2[$i] } else { $null }
                        
                        if ($line1 -ne $line2) {
                            $diffCount++
                            if ($diffCount -le 10) {
                                # Limit output for readability
                                Write-Host " ${ANSI.TEXT_SECONDARY}Line $($i + 1):${ANSI.RESET}"
                                Write-Host "   ${ANSI.RED}- $line1${ANSI.RESET}"
                                Write-Host "   ${ANSI.GREEN}+ $line2${ANSI.RESET}"
                            }
                        }
                    }
                    
                    if ($diffCount -gt 10) {
                        Write-Host " ${ANSI.TEXT_SECONDARY}... and $(($diffCount - 10)) more differences${ANSI.RESET}"
                    }
                    
                    Write-Host " ${ANSI.TEXT_SECONDARY}Total differences: $diffCount${ANSI.RESET}"
                }
            }
        }
    }
    catch {
        Write-Host "${ANSI.RED}× Error comparing files: $($_.Exception.Message)${ANSI.RESET}"
    }
}

function Organize-Files {
    Write-Host ""
    Write-Host "${ANSI.PURPLE}${ANSI.BOLD}FILE ORGANIZER${ANSI.RESET}"
    Write-Host "${ANSI.BORDER}──────────────${ANSI.RESET}"
    Write-Host ""
    
    Write-Host "${ANSI.TEXT_SECONDARY}Enter directory to organize:${ANSI.RESET}"
    Write-Host "${ANSI.PURPLE}>>${ANSI.RESET} " -NoNewline
    $directory = Read-Host
    
    if ([string]::IsNullOrWhiteSpace($directory)) {
        Write-Host "${ANSI.RED}× Directory cannot be empty${ANSI.RESET}"
        return
    }
    
    if (-not (Test-Path $directory)) {
        Write-Host "${ANSI.RED}× Directory not found: $directory${ANSI.RESET}"
        return
    }
    
    Write-Host ""
    Write-Host "${ANSI.TEXT_SECONDARY}Select organization method:${ANSI.RESET}"
    Write-Host " ${ANSI.PURPLE}1${ANSI.RESET} ${ANSI.TEXT_PRIMARY}By file type${ANSI.RESET}"
    Write-Host " ${ANSI.PURPLE}2${ANSI.RESET} ${ANSI.TEXT_PRIMARY}By date created${ANSI.RESET}"
    Write-Host " ${ANSI.PURPLE}3${ANSI.RESET} ${ANSI.TEXT_PRIMARY}By file size${ANSI.RESET}"
    Write-Host " ${ANSI.PURPLE}4${ANSI.RESET} ${ANSI.TEXT_PRIMARY}Custom rules${ANSI.RESET}"
    Write-Host ""
    
    $orgChoice = Read-ValidatedSubInput -Max 4
    
    try {
        $files = Get-ChildItem -Path $directory -File -Recurse
        
        if ($files.Count -eq 0) {
            Write-Host "${ANSI.TEXT_SECONDARY}No files found in directory${ANSI.RESET}"
            return
        }
        
        Write-Host ""
        Write-Host "${ANSI.TEXT_SECONDARY}Found $($files.Count) files to organize${ANSI.RESET}"
        
        switch ($orgChoice) {
            1 {
                # By file type
                Write-Host ""
                Write-Host "${ANSI.TEXT_SECONDARY}Organizing by file type...${ANSI.RESET}"
                
                $fileTypes = @{
                    "Images"    = @(".jpg", ".jpeg", ".png", ".gif", ".bmp", ".tiff", ".webp")
                    "Documents" = @(".pdf", ".doc", ".docx", ".txt", ".md", ".rtf", ".odt")
                    "Audio"     = @(".mp3", ".wav", ".flac", ".aac", ".ogg", ".wma")
                    "Video"     = @(".mp4", ".avi", ".mkv", ".mov", ".wmv", ".flv")
                    "Archives"  = @(".zip", ".rar", ".7z", ".tar", ".gz")
                    "Programs"  = @(".exe", ".msi", ".bat", ".cmd", ".ps1")
                    "Code"      = @(".py", ".js", ".html", ".css", ".java", ".cpp", ".cs", ".php")
                }
                
                $organizedCount = 0
                
                foreach ($file in $files) {
                    $moved = $false
                    foreach ($category in $fileTypes.Keys) {
                        if ($fileTypes[$category] -contains $file.Extension.ToLower()) {
                            $categoryPath = Join-Path $directory $category
                            if (-not (Test-Path $categoryPath)) {
                                New-Item -ItemType Directory -Path $categoryPath | Out-Null
                            }
                            
                            $destination = Join-Path $categoryPath $file.Name
                            try {
                                Move-Item -Path $file.FullName -Destination $destination -Force
                                Write-Host " ${ANSI.GREEN}✓ Moved $($file.Name) to $category${ANSI.RESET}"
                                $organizedCount++
                                $moved = $true
                                break
                            }
                            catch {
                                Write-Host " ${ANSI.RED}× Failed to move $($file.Name)${ANSI.RESET}"
                            }
                        }
                    }
                    
                    if (-not $moved) {
                        # Uncategorized files go to "Others"
                        $otherPath = Join-Path $directory "Others"
                        if (-not (Test-Path $otherPath)) {
                            New-Item -ItemType Directory -Path $otherPath | Out-Null
                        }
                        
                        $destination = Join-Path $otherPath $file.Name
                        try {
                            Move-Item -Path $file.FullName -Destination $destination -Force
                            Write-Host " ${ANSI.GREEN}✓ Moved $($file.Name) to Others${ANSI.RESET}"
                            $organizedCount++
                        }
                        catch {
                            Write-Host " ${ANSI.RED}× Failed to move $($file.Name)${ANSI.RESET}"
                        }
                    }
                }
                
                Write-Host ""
                Write-Host "${ANSI.GREEN}✓ Organized $organizedCount files${ANSI.RESET}"
            }
            
            2 {
                # By date created
                Write-Host ""
                Write-Host "${ANSI.TEXT_SECONDARY}Organizing by date created...${ANSI.RESET}"
                
                $organizedCount = 0
                
                foreach ($file in $files) {
                    $year = $file.CreationTime.Year
                    $month = $file.CreationTime.ToString("MM - $file.CreationTime.ToString("MMMM")
                    
                    $yearPath = Join-Path $directory $year
                    if (-not (Test-Path $yearPath)) {
                        New-Item -ItemType Directory -Path $yearPath | Out-Null
                    }
                    
                    $monthPath = Join-Path $yearPath $month
                    if (-not (Test-Path $monthPath)) {
                        New-Item -ItemType Directory -Path $monthPath | Out-Null
                    }
                    
                    $destination = Join-Path $monthPath $file.Name
                    try {
                        Move-Item -Path $file.FullName -Destination $destination -Force
                        Write-Host " ${ANSI.GREEN}✓ Moved $($file.Name) to $year/$month${ANSI.RESET}"
                        $organizedCount++
                    } catch {
                        Write-Host " ${ANSI.RED}× Failed to move $($file.Name)${ANSI.RESET}"
                    }
                }
                
                Write-Host ""
                Write-Host "${ANSI.GREEN}✓ Organized $organizedCount files${ANSI.RESET}"
            }
            
            3 {
                # By file size
                Write-Host ""
                Write-Host "${ANSI.TEXT_SECONDARY}Organizing by file size...${ANSI.RESET}"
                
                $organizedCount = 0
                
                foreach ($file in $files) {
                    $category = if ($file.Length -lt 1MB) { 
                        "Small (<1MB)" 
                    } elseif ($file.Length -lt 10MB) { 
                        "Medium (1 - 10MB)" 
                    } elseif ($file.Length -lt 100MB) { 
                        "Large (10 - 100MB)" 
                    } else { 
                        "Extra Large (>100MB)" 
                    }
                    
                    $categoryPath = Join-Path $directory $category
                    if (-not (Test-Path $categoryPath)) {
                        New-Item -ItemType Directory -Path $categoryPath | Out-Null
                    }
                    
                    $destination = Join-Path $categoryPath $file.Name
                    try {
                        Move-Item -Path $file.FullName -Destination $destination -Force
                        Write-Host " ${ANSI.GREEN}✓ Moved $($file.Name) to $category${ANSI.RESET}"
                        $organizedCount++
                    } catch {
                        Write-Host " ${ANSI.RED}× Failed to move $($file.Name)${ANSI.RESET}"
                    }
                }
                
                Write-Host ""
                Write-Host "${ANSI.GREEN}✓ Organized $organizedCount files${ANSI.RESET}"
            }
            
            4 {
                # Custom rules
                Write-Host ""
                Write-Host "${ANSI.TEXT_SECONDARY}Custom organization rules setup...${ANSI.RESET}"
                Write-Host "${ANSI.TEXT_SECONDARY}This advanced feature allows you to define custom patterns${ANSI.RESET}"
                Write-Host ""
                Write-Host " ${ANSI.GREEN}Example rules:${ANSI.RESET}"
                Write-Host "   ${ANSI.TEXT_SECONDARY}Move all '*.log' files to 'Logs' folder${ANSI.RESET}"
                Write-Host "   ${ANSI.TEXT_SECONDARY}Move files larger than 50MB to 'Large_Files'${ANSI.RESET}"
                Write-Host "   ${ANSI.TEXT_SECONDARY}Move files modified in last 7 days to 'Recent'${ANSI.RESET}"
                Write-Host ""
                Write-Host "${ANSI.TEXT_SECONDARY}Custom rule editor would be implemented here${ANSI.RESET}"
                Write-Host "${ANSI.TEXT_SECONDARY}Feature reserved for future release${ANSI.RESET}"
            }
        }
    } catch {
        Write-Host "${ANSI.RED}× Error organizing files: $($_.Exception.Message)${ANSI.RESET}"
    }
}

Export-ModuleMember -Function @('Show-FileUtilities')
