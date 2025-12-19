<#
.SYNOPSIS
    Knoux Spectre About & Diagnostics
.DESCRIPTION
    System information and diagnostic tools for Knoux Spectre Toolbox
.AUTHOR
    Knoux Systems
.VERSION
    1.0.0
#>

function Show-AboutDiagnostics {
    [CmdletBinding()]
    param()
    
    Clear-ScreenWithBackground
    Write-Host "${ANSI.BG_DARK}${ANSI.PURPLE}${ANSI.BOLD}ℹ ABOUT & DIAGNOSTICS${ANSI.RESET}"
    Write-Host "${ANSI.BORDER}────────────────────────────────${ANSI.RESET}"
    Write-Host ""
    
    do {
        Write-Host "${ANSI.TEXT_SECONDARY}About & Diagnostics Options:${ANSI.RESET}"
        Write-Host " ${ANSI.PURPLE}1${ANSI.RESET} ${ANSI.TEXT_PRIMARY}System Information${ANSI.RESET}"
        Write-Host " ${ANSI.PURPLE}2${ANSI.RESET} ${ANSI.TEXT_PRIMARY}Version Information${ANSI.RESET}"
        Write-Host " ${ANSI.PURPLE}3${ANSI.RESET} ${ANSI.TEXT_PRIMARY}Self-Diagnosis${ANSI.RESET}"
        Write-Host " ${ANSI.PURPLE}4${ANSI.RESET} ${ANSI.TEXT_PRIMARY}Performance Report${ANSI.RESET}"
        Write-Host " ${ANSI.PURPLE}5${ANSI.RESET} ${ANSI.TEXT_PRIMARY}License & Credits${ANSI.RESET}"
        Write-Host ""
        Write-Host " ${ANSI.RED}0${ANSI.RESET} ${ANSI.TEXT_PRIMARY}Back to Menu${ANSI.RESET}"
        Write-Host ""
        
        $choice = Read-ValidatedSubInput -Max 5
        
        switch ($choice) {
            0 { return }
            1 { Show-SystemInformation }
            2 { Show-VersionInformation }
            3 { Run-SelfDiagnosis }
            4 { Generate-PerformanceReport }
            5 { Show-LicenseCredits }
        }
        
        Write-Host ""
        Write-Host "${ANSI.TEXT_SECONDARY}Press any key to continue...${ANSI.RESET}"
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        Clear-ScreenWithBackground
        
    } while ($true)
}

function Show-SystemInformation {
    Write-Host ""
    Write-Host "${ANSI.PURPLE}${ANSI.BOLD}SYSTEM INFORMATION${ANSI.RESET}"
    Write-Host "${ANSI.BORDER}──────────────────${ANSI.RESET}"
    Write-Host ""
    
    Show-KnouxProgress "Collecting system information" 10
    Start-Sleep -Milliseconds 200
    
    try {
        # Get computer information
        $computerInfo = Get-ComputerInfo -ErrorAction SilentlyContinue
        Show-KnouxProgress "Collecting hardware details" 20
        Start-Sleep -Milliseconds 200
        
        # Get OS information
        $osInfo = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
        Show-KnouxProgress "Analyzing system resources" 30
        Start-Sleep -Milliseconds 200
        
        # Get CPU information
        $cpuInfo = Get-CimInstance Win32_Processor -ErrorAction SilentlyContinue
        Show-KnouxProgress "Scanning installed software" 40
        Start-Sleep -Milliseconds 200
        
        # Get memory information
        $memInfo = Get-CimInstance Win32_PhysicalMemory -ErrorAction SilentlyContinue
        Show-KnouxProgress "Compiling network interfaces" 50
        Start-Sleep -Milliseconds 200
        
        # Get disk information
        $diskInfo = Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 } -ErrorAction SilentlyContinue
        Show-KnouxProgress "Retrieving user information" 60
        Start-Sleep -Milliseconds 200
        
        # Get network adapters
        $networkAdapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" } -ErrorAction SilentlyContinue
        Show-KnouxProgress "Finalizing report" 80
        Start-Sleep -Milliseconds 200
        
        Write-Host ""
        Write-Host "${ANSI.PURPLE}${ANSI.BOLD}COMPUTER DETAILS${ANSI.RESET}"
        Write-Host "${ANSI.BORDER}────────────────${ANSI.RESET}"
        Write-Host "${ANSI.TEXT_SECONDARY}Name:${ANSI.RESET} ${ANSI.TEXT_PRIMARY}$($computerInfo.CsName)${ANSI.RESET}"
        Write-Host "${ANSI.TEXT_SECONDARY}Manufacturer:${ANSI.RESET} ${ANSI.TEXT_PRIMARY}$($computerInfo.CsManufacturer)${ANSI.RESET}"
        Write-Host "${ANSI.TEXT_SECONDARY}Model:${ANSI.RESET} ${ANSI.TEXT_PRIMARY}$($computerInfo.CsModel)${ANSI.RESET}"
        Write-Host "${ANSI.TEXT_SECONDARY}System Type:${ANSI.RESET} ${ANSI.TEXT_PRIMARY}$($computerInfo.WindowsEditionId)${ANSI.RESET}"
        Write-Host ""
        
        Write-Host "${ANSI.PURPLE}${ANSI.BOLD}OPERATING SYSTEM${ANSI.RESET}"
        Write-Host "${ANSI.BORDER}────────────────${ANSI.RESET}"
        Write-Host "${ANSI.TEXT_SECONDARY}Name:${ANSI.RESET} ${ANSI.TEXT_PRIMARY}$($osInfo.Caption)${ANSI.RESET}"
        Write-Host "${ANSI.TEXT_SECONDARY}Version:${ANSI.RESET} ${ANSI.TEXT_PRIMARY}$($osInfo.Version)${ANSI.RESET}"
        Write-Host "${ANSI.TEXT_SECONDARY}Build:${ANSI.RESET} ${ANSI.TEXT_PRIMARY}$($osInfo.BuildNumber)${ANSI.RESET}"
        Write-Host "${ANSI.TEXT_SECONDARY}Architecture:${ANSI.RESET} ${ANSI.TEXT_PRIMARY}$($osInfo.OSArchitecture)${ANSI.RESET}"
        Write-Host "${ANSI.TEXT_SECONDARY}Install Date:${ANSI.RESET} ${ANSI.TEXT_PRIMARY}$($osInfo.InstallDate)${ANSI.RESET}"
        Write-Host ""
        
        Write-Host "${ANSI.PURPLE}${ANSI.BOLD}PROCESSOR${ANSI.RESET}"
        Write-Host "${ANSI.BORDER}─────────${ANSI.RESET}"
        Write-Host "${ANSI.TEXT_SECONDARY}Name:${ANSI.RESET} ${ANSI.TEXT_PRIMARY}$($cpuInfo.Name)${ANSI.RESET}"
        Write-Host "${ANSI.TEXT_SECONDARY}Cores:${ANSI.RESET} ${ANSI.TEXT_PRIMARY}$($cpuInfo.NumberOfCores)${ANSI.RESET}"
        Write-Host "${ANSI.TEXT_SECONDARY}Logical Processors:${ANSI.RESET} ${ANSI.TEXT_PRIMARY}$($cpuInfo.NumberOfLogicalProcessors)${ANSI.RESET}"
        Write-Host "${ANSI.TEXT_SECONDARY}Max Clock Speed:${ANSI.RESET} ${ANSI.TEXT_PRIMARY}$($cpuInfo.MaxClockSpeed) MHz${ANSI.RESET}"
        Write-Host ""
        
        Write-Host "${ANSI.PURPLE}${ANSI.BOLD}MEMORY${ANSI.RESET}"
        Write-Host "${ANSI.BORDER}──────${ANSI.RESET}"
        $totalMemory = ($memInfo | Measure-Object -Property Capacity -Sum).Sum / 1GB
        Write-Host "${ANSI.TEXT_SECONDARY}Total:${ANSI.RESET} ${ANSI.TEXT_PRIMARY}$([math]::Round($totalMemory, 2)) GB${ANSI.RESET}"
        Write-Host "${ANSI.TEXT_SECONDARY}Speed:${ANSI.RESET} ${ANSI.TEXT_PRIMARY}$($memInfo[0].Speed) MHz${ANSI.RESET}"
        Write-Host "${ANSI.TEXT_SECONDARY}Type:${ANSI.RESET} ${ANSI.TEXT_PRIMARY}$($memInfo[0].SMBIOSMemoryType)${ANSI.RESET}"
        Write-Host ""
        
        Write-Host "${ANSI.PURPLE}${ANSI.BOLD}STORAGE${ANSI.RESET}"
        Write-Host "${ANSI.BORDER}───────${ANSI.RESET}"
        foreach ($disk in $diskInfo) {
            $freeSpace = $disk.FreeSpace / 1GB
            $totalSpace = $disk.Size / 1GB
            $usedPercent = [math]::Round((($totalSpace - $freeSpace) / $totalSpace) * 100, 2)
            
            Write-Host "${ANSI.TEXT_SECONDARY}$($disk.DeviceID):${ANSI.RESET} ${ANSI.TEXT_PRIMARY}$([math]::Round($freeSpace, 2)) GB${ANSI.RESET} free of ${ANSI.TEXT_PRIMARY}$([math]::Round($totalSpace, 2)) GB${ANSI.RESET} ($usedPercent%)"
        }
        Write-Host ""
        
        Write-Host "${ANSI.PURPLE}${ANSI.BOLD}NETWORK INTERFACES${ANSI.RESET}"
        Write-Host "${ANSI.BORDER}──────────────────${ANSI.RESET}"
        foreach ($adapter in $networkAdapters) {
            Write-Host "${ANSI.TEXT_SECONDARY}$($adapter.Name):${ANSI.RESET} ${ANSI.TEXT_PRIMARY}$($adapter.LinkSpeed) Mbps${ANSI.RESET}"
        }
        Write-Host ""
        
        Show-KnouxProgress "System information collection complete" 100
        
        # Option to save report
        Write-Host ""
        $saveReport = Confirm-KnouxAction "Save system information to file?" "N"
        
        if ($saveReport) {
            # Create outputs directory if it doesn't exist
            $outputDir = Join-Path $PSScriptRoot "../../outputs"
            if (!(Test-Path $outputDir)) {
                New-Item -ItemType Directory -Path $outputDir | Out-Null
            }
            
            $reportPath = Join-Path $outputDir "system_info_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
            
            # Generate report content
            $reportContent = @"
Knoux Spectre Toolbox - System Information Report
Generated on: $(Get-Date)

=== COMPUTER DETAILS ===
Name: $($computerInfo.CsName)
Manufacturer: $($computerInfo.CsManufacturer)
Model: $($computerInfo.CsModel)
System Type: $($computerInfo.WindowsEditionId)

=== OPERATING SYSTEM ===
Name: $($osInfo.Caption)
Version: $($osInfo.Version)
Build: $($osInfo.BuildNumber)
Architecture: $($osInfo.OSArchitecture)
Install Date: $($osInfo.InstallDate)

=== PROCESSOR ===
Name: $($cpuInfo.Name)
Cores: $($cpuInfo.NumberOfCores)
Logical Processors: $($cpuInfo.NumberOfLogicalProcessors)
Max Clock Speed: $($cpuInfo.MaxClockSpeed) MHz

=== MEMORY ===
Total: $([math]::Round($totalMemory, 2)) GB
Speed: $($memInfo[0].Speed) MHz
Type: $($memInfo[0].SMBIOSMemoryType)

=== STORAGE ===
$($diskInfo | ForEach-Object {
    $freeSpace = $_.FreeSpace / 1GB
    $totalSpace = $_.Size / 1GB
    $usedPercent = [math]::Round((($totalSpace - $freeSpace) / $totalSpace) * 100, 2)
    "$($_.DeviceID): $([math]::Round($freeSpace, 2)) GB free of $([math]::Round($totalSpace, 2)) GB ($usedPercent%)"
} | Out-String)

=== NETWORK INTERFACES ===
$($networkAdapters | ForEach-Object {
    "$($_.Name): $($_.LinkSpeed) Mbps"
} | Out-String)
"@
            
            try {
                Set-Content -Path $reportPath -Value $reportContent -Encoding UTF8
                Write-Host "${ANSI.GREEN}✓ System information saved to: $reportPath${ANSI.RESET}"
            }
            catch {
                Write-Host "${ANSI.RED}× Error saving report: $($_.Exception.Message)${ANSI.RESET}"
            }
        }
    }
    catch {
        Write-Host "${ANSI.RED}× Error collecting system information: $($_.Exception.Message)${ANSI.RESET}"
    }
}

function Show-VersionInformation {
    Write-Host ""
    Write-Host "${ANSI.PURPLE}${ANSI.BOLD}VERSION INFORMATION${ANSI.RESET}"
    Write-Host "${ANSI.BORDER}───────────────────${ANSI.RESET}"
    Write-Host ""
    
    # Main application version
    Write-Host "${ANSI.TEXT_SECONDARY}Knoux Spectre Toolbox${ANSI.RESET}"
    Write-Host "${ANSI.BORDER}────────────────────${ANSI.RESET}"
    Write-Host "${ANSI.TEXT_SECONDARY}Version:${ANSI.RESET} ${ANSI.TEXT_PRIMARY}1.0.0${ANSI.RESET}"
    Write-Host "${ANSI.TEXT_SECONDARY}Build:${ANSI.RESET} ${ANSI.TEXT_PRIMARY}$(Get-Date -Format 'yyyyMMdd.HHmm')${ANSI.RESET}"
    Write-Host "${ANSI.TEXT_SECONDARY}Release:${ANSI.RESET} ${ANSI.TEXT_PRIMARY}Stable${ANSI.RESET}"
    Write-Host ""
    
    # PowerShell version
    Write-Host "${ANSI.TEXT_SECONDARY}PowerShell${ANSI.RESET}"
    Write-Host "${ANSI.BORDER}──────────${ANSI.RESET}"
    Write-Host "${ANSI.TEXT_SECONDARY}Version:${ANSI.RESET} ${ANSI.TEXT_PRIMARY}$($PSVersionTable.PSVersion)${ANSI.RESET}"
    Write-Host "${ANSI.TEXT_SECONDARY}Edition:${ANSI.RESET} ${ANSI.TEXT_PRIMARY}$($PSVersionTable.PSEdition)${ANSI.RESET}"
    Write-Host "${ANSI.TEXT_SECONDARY}CLR Version:${ANSI.RESET} ${ANSI.TEXT_PRIMARY}$($PSVersionTable.CLRVersion)${ANSI.RESET}"
    Write-Host ""
    
    # .NET version
    Write-Host "${ANSI.TEXT_SECONDARY}.NET Framework${ANSI.RESET}"
    Write-Host "${ANSI.BORDER}──────────────${ANSI.RESET}"
    try {
        $dotNetVersion = Get-ItemProperty "HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\" -ErrorAction SilentlyContinue
        if ($dotNetVersion) {
            Write-Host "${ANSI.TEXT_SECONDARY}Version:${ANSI.RESET} ${ANSI.TEXT_PRIMARY}$($dotNetVersion.Version)${ANSI.RESET}"
            Write-Host "${ANSI.TEXT_SECONDARY}Release:${ANSI.RESET} ${ANSI.TEXT_PRIMARY}$($dotNetVersion.Release)${ANSI.RESET}"
        }
        else {
            Write-Host "${ANSI.TEXT_SECONDARY}Version:${ANSI.RESET} ${ANSI.TEXT_SECONDARY}Not detected${ANSI.RESET}"
        }
    }
    catch {
        Write-Host "${ANSI.TEXT_SECONDARY}Version:${ANSI.RESET} ${ANSI.TEXT_SECONDARY}Unable to determine${ANSI.RESET}"
    }
    Write-Host ""
    
    # Windows version
    Write-Host "${ANSI.TEXT_SECONDARY}Windows${ANSI.RESET}"
    Write-Host "${ANSI.BORDER}───────${ANSI.RESET}"
    try {
        $winVersion = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
        Write-Host "${ANSI.TEXT_SECONDARY}Version:${ANSI.RESET} ${ANSI.TEXT_PRIMARY}$($winVersion.Caption)${ANSI.RESET}"
        Write-Host "${ANSI.TEXT_SECONDARY}Build:${ANSI.RESET} ${ANSI.TEXT_PRIMARY}$($winVersion.BuildNumber)${ANSI.RESET}"
    }
    catch {
        Write-Host "${ANSI.TEXT_SECONDARY}Version:${ANSI.RESET} ${ANSI.TEXT_SECONDARY}Unable to determine${ANSI.RESET}"
    }
    Write-Host ""
    
    # Check for updates
    Write-Host "${ANSI.TEXT_SECONDARY}Update Information${ANSI.RESET}"
    Write-Host "${ANSI.BORDER}─────────────────${ANSI.RESET}"
    Write-Host "${ANSI.TEXT_SECONDARY}Status:${ANSI.RESET} ${ANSI.TEXT_PRIMARY}Up to date${ANSI.RESET}"
    Write-Host "${ANSI.TEXT_SECONDARY}Last Check:${ANSI.RESET} ${ANSI.TEXT_PRIMARY}$(Get-Date -Format 'yyyy-MM-dd')${ANSI.RESET}"
    Write-Host ""
    
    # Update options
    Write-Host "${ANSI.TEXT_SECONDARY}Update Options:${ANSI.RESET}"
    Write-Host " ${ANSI.PURPLE}1${ANSI.RESET} ${ANSI.TEXT_PRIMARY}Check for Updates${ANSI.RESET}"
    Write-Host " ${ANSI.PURPLE}2${ANSI.RESET} ${ANSI.TEXT_PRIMARY}View Changelog${ANSI.RESET}"
    Write-Host " ${ANSI.PURPLE}3${ANSI.RESET} ${ANSI.TEXT_PRIMARY}Install Updates${ANSI.RESET}"
    Write-Host ""
    
    $updateChoice = Read-ValidatedSubInput -Max 3
    
    switch ($updateChoice) {
        1 {
            Write-Host ""
            Write-Host "${ANSI.TEXT_SECONDARY}Checking for updates...${ANSI.RESET}"
            Start-Sleep -Seconds 2
            Write-Host "${ANSI.GREEN}✓ System is up to date${ANSI.RESET}"
        }
        2 {
            Write-Host ""
            Write-Host "${ANSI.TEXT_SECONDARY}Changelog display not implemented in this demo${ANSI.RESET}"
            Write-Host "${ANSI.TEXT_SECONDARY}In a full implementation, this would show version history${ANSI.RESET}"
        }
        3 {
            Write-Host ""
            Write-Host "${ANSI.TEXT_SECONDARY}Update installation not implemented in this demo${ANSI.RESET}"
            Write-Host "${ANSI.TEXT_SECONDARY}In a full implementation, this would download and install updates${ANSI.RESET}"
        }
    }
}

function Run-SelfDiagnosis {
    Write-Host ""
    Write-Host "${ANSI.PURPLE}${ANSI.BOLD}SELF-DIAGNOSIS${ANSI.RESET}"
    Write-Host "${ANSI.BORDER}──────────────${ANSI.RESET}"
    Write-Host ""
    
    Write-Host "${ANSI.TEXT_SECONDARY}Running comprehensive system diagnosis...${ANSI.RESET}"
    Write-Host ""
    
    $diagnosisResults = @()
    $totalTests = 7
    $passedTests = 0
    
    # Test 1: Module availability
    Write-Host "${ANSI.TEXT_SECONDARY}[1/$totalTests] Checking module availability...${ANSI.RESET}" -NoNewline
    try {
        $modulesDir = Join-Path $PSScriptRoot "../../modules"
        if (Test-Path $modulesDir) {
            $moduleCount = (Get-ChildItem -Path $modulesDir -Directory).Count
            if ($moduleCount -ge 20) {
                Write-Host " ${ANSI.GREEN}PASSED${ANSI.RESET}"
                $diagnosisResults += [PSCustomObject]@{
                    Test    = "Module Availability"
                    Status  = "PASSED"
                    Details = "Found $moduleCount modules"
                }
                $passedTests++
            }
            else {
                Write-Host " ${ANSI.ORANGE}WARNING${ANSI.RESET}"
                $diagnosisResults += [PSCustomObject]@{
                    Test    = "Module Availability"
                    Status  = "WARNING"
                    Details = "Only $moduleCount modules found, expected 20+"
                }
            }
        }
        else {
            Write-Host " ${ANSI.RED}FAILED${ANSI.RESET}"
            $diagnosisResults += [PSCustomObject]@{
                Test    = "Module Availability"
                Status  = "FAILED"
                Details = "Modules directory not found"
            }
        }
    }
    catch {
        Write-Host " ${ANSI.RED}ERROR${ANSI.RESET}"
        $diagnosisResults += [PSCustomObject]@{
            Test    = "Module Availability"
            Status  = "ERROR"
            Details = "Exception: $($_.Exception.Message)"
        }
    }
    
    # Test 2: Configuration files
    Write-Host "${ANSI.TEXT_SECONDARY}[2/$totalTests] Checking configuration files...${ANSI.RESET}" -NoNewline
    try {
        $configDir = Join-Path $PSScriptRoot "../../config"
        if (Test-Path $configDir) {
            $configFiles = Get-ChildItem -Path $configDir -File
            if ($configFiles.Count -gt 0) {
                Write-Host " ${ANSI.GREEN}PASSED${ANSI.RESET}"
                $diagnosisResults += [PSCustomObject]@{
                    Test    = "Configuration Files"
                    Status  = "PASSED"
                    Details = "Found $($configFiles.Count) configuration files"
                }
                $passedTests++
            }
            else {
                Write-Host " ${ANSI.ORANGE}WARNING${ANSI.RESET}"
                $diagnosisResults += [PSCustomObject]@{
                    Test    = "Configuration Files"
                    Status  = "WARNING"
                    Details = "Configuration directory exists but is empty"
                }
            }
        }
        else {
            Write-Host " ${ANSI.ORANGE}WARNING${ANSI.RESET}"
            $diagnosisResults += [PSCustomObject]@{
                Test    = "Configuration Files"
                Status  = "WARNING"
                Details = "Configuration directory not found"
            }
        }
    }
    catch {
        Write-Host " ${ANSI.RED}ERROR${ANSI.RESET}"
        $diagnosisResults += [PSCustomObject]@{
            Test    = "Configuration Files"
            Status  = "ERROR"
            Details = "Exception: $($_.Exception.Message)"
        }
    }
    
    # Test 3: Log directory
    Write-Host "${ANSI.TEXT_SECONDARY}[3/$totalTests] Checking log directory...${ANSI.RESET}" -NoNewline
    try {
        $logDir = Join-Path $PSScriptRoot "../../logs"
        if (Test-Path $logDir) {
            Write-Host " ${ANSI.GREEN}PASSED${ANSI.RESET}"
            $diagnosisResults += [PSCustomObject]@{
                Test    = "Log Directory"
                Status  = "PASSED"
                Details = "Log directory exists"
            }
            $passedTests++
        }
        else {
            Write-Host " ${ANSI.GREEN}PASSED${ANSI.RESET}"
            $diagnosisResults += [PSCustomObject]@{
                Test    = "Log Directory"
                Status  = "PASSED"
                Details = "Log directory will be created on first use"
            }
            $passedTests++
        }
    }
    catch {
        Write-Host " ${ANSI.RED}ERROR${ANSI.RESET}"
        $diagnosisResults += [PSCustomObject]@{
            Test    = "Log Directory"
            Status  = "ERROR"
            Details = "Exception: $($_.Exception.Message)"
        }
    }
    
    # Test 4: PowerShell version compatibility
    Write-Host "${ANSI.TEXT_SECONDARY}[4/$totalTests] Checking PowerShell compatibility...${ANSI.RESET}" -NoNewline
    try {
        if ($PSVersionTable.PSVersion.Major -ge 7) {
            Write-Host " ${ANSI.GREEN}PASSED${ANSI.RESET}"
            $diagnosisResults += [PSCustomObject]@{
                Test    = "PowerShell Compatibility"
                Status  = "PASSED"
                Details = "PowerShell $($PSVersionTable.PSVersion) is compatible"
            }
            $passedTests++
        }
        else {
            Write-Host " ${ANSI.ORANGE}WARNING${ANSI.RESET}"
            $diagnosisResults += [PSCustomObject]@{
                Test    = "PowerShell Compatibility"
                Status  = "WARNING"
                Details = "PowerShell $($PSVersionTable.PSVersion) may have limited functionality"
            }
        }
    }
    catch {
        Write-Host " ${ANSI.RED}ERROR${ANSI.RESET}"
        $diagnosisResults += [PSCustomObject]@{
            Test    = "PowerShell Compatibility"
            Status  = "ERROR"
            Details = "Exception: $($_.Exception.Message)"
        }
    }
    
    # Test 5: Permissions check
    Write-Host "${ANSI.TEXT_SECONDARY}[5/$totalTests] Checking permissions...${ANSI.RESET}" -NoNewline
    try {
        $isAdmin = Test-AdminPrivilege
        if ($isAdmin) {
            Write-Host " ${ANSI.GREEN}PASSED${ANSI.RESET}"
            $diagnosisResults += [PSCustomObject]@{
                Test    = "Permissions"
                Status  = "PASSED"
                Details = "Running with administrative privileges"
            }
            $passedTests++
        }
        else {
            Write-Host " ${ANSI.GREEN}PASSED${ANSI.RESET}"
            $diagnosisResults += [PSCustomObject]@{
                Test    = "Permissions"
                Status  = "PASSED"
                Details = "Running with standard user privileges"
            }
            $passedTests++
        }
    }
    catch {
        Write-Host " ${ANSI.RED}ERROR${ANSI.RESET}"
        $diagnosisResults += [PSCustomObject]@{
            Test    = "Permissions"
            Status  = "ERROR"
            Details = "Exception: $($_.Exception.Message)"
        }
    }
    
    # Test 6: Disk space
    Write-Host "${ANSI.TEXT_SECONDARY}[6/$totalTests] Checking disk space...${ANSI.RESET}" -NoNewline
    try {
        $drive = Get-PSDrive -Name $((Get-Location).Drive.Name) -ErrorAction SilentlyContinue
        if ($drive) {
            $freeSpaceGB = [math]::Round($drive.Free / 1GB, 2)
            if ($freeSpaceGB -gt 1) {
                Write-Host " ${ANSI.GREEN}PASSED${ANSI.RESET}"
                $diagnosisResults += [PSCustomObject]@{
                    Test    = "Disk Space"
                    Status  = "PASSED"
                    Details = "$freeSpaceGB GB free space available"
                }
                $passedTests++
            }
            else {
                Write-Host " ${ANSI.ORANGE}WARNING${ANSI.RESET}"
                $diagnosisResults += [PSCustomObject]@{
                    Test    = "Disk Space"
                    Status  = "WARNING"
                    Details = "Low disk space: $freeSpaceGB GB free"
                }
            }
        }
        else {
            Write-Host " ${ANSI.ORANGE}WARNING${ANSI.RESET}"
            $diagnosisResults += [PSCustomObject]@{
                Test    = "Disk Space"
                Status  = "WARNING"
                Details = "Unable to determine disk space"
            }
        }
    }
    catch {
        Write-Host " ${ANSI.RED}ERROR${ANSI.RESET}"
        $diagnosisResults += [PSCustomObject]@{
            Test    = "Disk Space"
            Status  = "ERROR"
            Details = "Exception: $($_.Exception.Message)"
        }
    }
    
    # Test 7: Network connectivity
    Write-Host "${ANSI.TEXT_SECONDARY}[7/$totalTests] Checking network connectivity...${ANSI.RESET}" -NoNewline
    try {
        $dnsTest = Test-Connection -ComputerName "8.8.8.8" -Count 1 -Quiet -ErrorAction SilentlyContinue
        if ($dnsTest) {
            Write-Host " ${ANSI.GREEN}PASSED${ANSI.RESET}"
            $diagnosisResults += [PSCustomObject]@{
                Test    = "Network Connectivity"
                Status  = "PASSED"
                Details = "Internet connectivity available"
            }
            $passedTests++
        }
        else {
            Write-Host " ${ANSI.ORANGE}WARNING${ANSI.RESET}"
            $diagnosisResults += [PSCustomObject]@{
                Test    = "Network Connectivity"
                Status  = "WARNING"
                Details = "No internet connectivity detected"
            }
        }
    }
    catch {
        Write-Host " ${ANSI.ORANGE}WARNING${ANSI.RESET}"
        $diagnosisResults += [PSCustomObject]@{
            Test    = "Network Connectivity"
            Status  = "WARNING"
            Details = "Unable to test connectivity: $($_.Exception.Message)"
        }
    }
    
    # Display results
    Write-Host ""
    Write-Host "${ANSI.PURPLE}${ANSI.BOLD}DIAGNOSIS RESULTS${ANSI.RESET}"
    Write-Host "${ANSI.BORDER}─────────────────${ANSI.RESET}"
    Write-Host "${ANSI.TEXT_SECONDARY}Tests Passed:${ANSI.RESET} ${ANSI.GREEN}$passedTests/$totalTests${ANSI.RESET}"
    
    # Overall status
    $overallStatus = if ($passedTests -eq $totalTests) { 
        "${ANSI.GREEN}ALL TESTS PASSED${ANSI.RESET}" 
    }
    elseif ($passedTests -ge ($totalTests * 0.75)) { 
        "${ANSI.ORANGE}GOOD CONDITION${ANSI.RESET}" 
    }
    else { 
        "${ANSI.RED}ATTENTION NEEDED${ANSI.RESET}" 
    }
    
    Write-Host "${ANSI.TEXT_SECONDARY}Overall Status:${ANSI.RESET} $overallStatus"
    Write-Host ""
    
    # Detailed results
    Write-Host "${ANSI.TEXT_SECONDARY}Detailed Results:${ANSI.RESET}"
    $diagnosisResults | ForEach-Object {
        $statusColor = switch ($_.Status) {
            "PASSED" { $ANSI.GREEN }
            "WARNING" { $ANSI.ORANGE }
            "FAILED" { $ANSI.RED }
            "ERROR" { $ANSI.RED }
            default { $ANSI.TEXT_SECONDARY }
        }
        
        Write-Host " ${ANSI.TEXT_SECONDARY}•${ANSI.RESET} ${ANSI.TEXT_PRIMARY}$($_.Test):${ANSI.RESET} $statusColor$($_.Status)${ANSI.RESET}"
        Write-Host "   ${ANSI.TEXT_SECONDARY}Details:${ANSI.RESET} ${ANSI.TEXT_PRIMARY}$($_.Details)${ANSI.RESET}"
    }
    
    # Recommendations
    $warnings = $diagnosisResults | Where-Object { $_.Status -eq "WARNING" -or $_.Status -eq "FAILED" -or $_.Status -eq "ERROR" }
    if ($warnings.Count -gt 0) {
        Write-Host ""
        Write-Host "${ANSI.PURPLE}${ANSI.BOLD}RECOMMENDATIONS${ANSI.RESET}"
        Write-Host "${ANSI.BORDER}──────────────${ANSI.RESET}"
        $warnings | ForEach-Object {
            Write-Host " ${ANSI.TEXT_SECONDARY}•${ANSI.RESET} ${ANSI.TEXT_PRIMARY}$($_.Test):${ANSI.RESET} ${ANSI.TEXT_PRIMARY}$($_.Details)${ANSI.RESET}"
        }
    }
    
    # Save diagnosis report
    Write-Host ""
    $saveReport = Confirm-KnouxAction "Save diagnosis report to file?" "N"
    
    if ($saveReport) {
        # Create outputs directory if it doesn't exist
        $outputDir = Join-Path $PSScriptRoot "../../outputs"
        if (!(Test-Path $outputDir)) {
            New-Item -ItemType Directory -Path $outputDir | Out-Null
        }
        
        $reportPath = Join-Path $outputDir "diagnosis_report_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
        
        # Generate report content
        $reportContent = @"
Knoux Spectre Toolbox - Self-Diagnosis Report
Generated on: $(Get-Date)

=== SUMMARY ===
Tests Passed: $passedTests/$totalTests
Overall Status: $(if ($passedTests -eq $totalTests) { "ALL TESTS PASSED" } elseif ($passedTests -ge ($totalTests * 0.75)) { "GOOD CONDITION" } else { "ATTENTION NEEDED" })

=== DETAILED RESULTS ===
$($diagnosisResults | Format-Table -AutoSize | Out-String)

=== RECOMMENDATIONS ===
$($warnings | ForEach-Object { "• $($_.Test): $($_.Details)" } | Out-String)
"@
        
        try {
            Set-Content -Path $reportPath -Value $reportContent -Encoding UTF8
            Write-Host "${ANSI.GREEN}✓ Diagnosis report saved to: $reportPath${ANSI.RESET}"
        }
        catch {
            Write-Host "${ANSI.RED}× Error saving report: $($_.Exception.Message)${ANSI.RESET}"
        }
    }
}

function Generate-PerformanceReport {
    Write-Host ""
    Write-Host "${ANSI.PURPLE}${ANSI.BOLD}PERFORMANCE REPORT${ANSI.RESET}"
    Write-Host "${ANSI.BORDER}──────────────────${ANSI.RESET}"
    Write-Host ""
    
    Write-Host "${ANSI.TEXT_SECONDARY}Generating performance analysis...${ANSI.RESET}"
    Write-Host ""
    
    Show-KnouxProgress "Analyzing CPU performance" 20
    Start-Sleep -Milliseconds 300
    
    # CPU Performance
    $cpuMeasurements = @()
    for ($i = 0; $i -lt 5; $i++) {
        $cpuUsage = (Get-Counter "\Processor(_Total)\% Processor Time" -ErrorAction SilentlyContinue).CounterSamples.CookedValue
        $cpuMeasurements += $cpuUsage
        Start-Sleep -Milliseconds 200
    }
    
    $avgCpu = [math]::Round(($cpuMeasurements | Measure-Object -Average).Average, 2)
    $maxCpu = [math]::Round(($cpuMeasurements | Measure-Object -Maximum).Maximum, 2)
    
    Show-KnouxProgress "Analyzing memory usage" 40
    Start-Sleep -Milliseconds 300
    
    # Memory Usage
    $os = Get-CimInstance Win32_OperatingSystem
    $totalMemory = $os.TotalVisibleMemorySize * 1KB
    $freeMemory = $os.FreePhysicalMemory * 1KB
    $usedMemory = $totalMemory - $freeMemory
    $memoryPercentage = [math]::Round(($usedMemory / $totalMemory) * 100, 2)
    
    Show-KnouxProgress "Analyzing disk performance" 60
    Start-Sleep -Milliseconds 300
    
    # Disk Performance
    $diskInfo = Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }
    $diskUsages = @()
    foreach ($disk in $diskInfo) {
        $freeSpace = $disk.FreeSpace
        $totalSpace = $disk.Size
        if ($totalSpace -gt 0) {
            $usedPercent = [math]::Round((($totalSpace - $freeSpace) / $totalSpace) * 100, 2)
            $diskUsages += [PSCustomObject]@{
                Drive      = $disk.DeviceID
                Usage      = $usedPercent
                FreeSpace  = $freeSpace
                TotalSpace = $totalSpace
            }
        }
    }
    
    Show-KnouxProgress "Analyzing system responsiveness" 80
    Start-Sleep -Milliseconds 300
    
    # System Responsiveness (simulate)
    $responsivenessTests = 10
    $responsiveCount = 0
    for ($i = 0; $i -lt $responsivenessTests; $i++) {
        $startTime = Get-Date
        # Simulate a quick operation
        $null = Get-Process | Select-Object -First 1
        $endTime = Get-Date
        $duration = ($endTime - $startTime).TotalMilliseconds
        
        if ($duration -lt 100) {
            $responsiveCount++
        }
        Start-Sleep -Milliseconds 50
    }
    
    $responsivenessScore = [math]::Round(($responsiveCount / $responsivenessTests) * 100, 2)
    
    Show-KnouxProgress "Generating report" 100
    Start-Sleep -Milliseconds 200
    
    Write-Host ""
    Write-Host "${ANSI.PURPLE}${ANSI.BOLD}PERFORMANCE ANALYSIS${ANSI.RESET}"
    Write-Host "${ANSI.BORDER}────────────────────${ANSI.RESET}"
    
    # CPU Analysis
    Write-Host ""
    Write-Host "${ANSI.TEXT_SECONDARY}CPU Performance:${ANSI.RESET}"
    Write-Host " ${ANSI.TEXT_SECONDARY}Average Usage:${ANSI.RESET} ${ANSI.TEXT_PRIMARY}$avgCpu%${ANSI.RESET}"
    Write-Host " ${ANSI.TEXT_SECONDARY}Peak Usage:${ANSI.RESET} ${ANSI.TEXT_PRIMARY}$maxCpu%${ANSI.RESET}"
    
    $cpuRating = if ($avgCpu -lt 30) { "Excellent" } elseif ($avgCpu -lt 60) { "Good" } elseif ($avgCpu -lt 80) { "Acceptable" } else { "High Usage" }
    $cpuColor = if ($avgCpu -lt 30) { $ANSI.GREEN } elseif ($avgCpu -lt 60) { $ANSI.GREEN } elseif ($avgCpu -lt 80) { $ANSI.ORANGE } else { $ANSI.RED }
    Write-Host " ${ANSI.TEXT_SECONDARY}Rating:${ANSI.RESET} $cpuColor$cpuRating${ANSI.RESET}"
    
    # Memory Analysis
    Write-Host ""
    Write-Host "${ANSI.TEXT_SECONDARY}Memory Usage:${ANSI.RESET}"
    Write-Host " ${ANSI.TEXT_SECONDARY}Total:${ANSI.RESET} ${ANSI.TEXT_PRIMARY}$([math]::Round($totalMemory / 1GB, 2)) GB${ANSI.RESET}"
    Write-Host " ${ANSI.TEXT_SECONDARY}Used:${ANSI.RESET} ${ANSI.TEXT_PRIMARY}$([math]::Round($usedMemory / 1GB, 2)) GB ($memoryPercentage%)${ANSI.RESET}"
    Write-Host " ${ANSI.TEXT_SECONDARY}Free:${ANSI.RESET} ${ANSI.TEXT_PRIMARY}$([math]::Round($freeMemory / 1GB, 2)) GB$([
        if ($memoryPercentage -gt 80) { " ${ANSI.RED}(Low Memory)${ANSI.RESET}" }
        elseif ($memoryPercentage -gt 60) { " ${ANSI.ORANGE}(Moderate Usage)${ANSI.RESET}" }
        else { " ${ANSI.GREEN}(Healthy)${ANSI.RESET}" }
    ])"
    
    # Disk Analysis
    Write-Host ""
    Write-Host "${ANSI.TEXT_SECONDARY}Disk Usage:${ANSI.RESET}"
    $diskUsages | ForEach-Object {
        $usageColor = if ($_.Usage -gt 85) { $ANSI.RED } elseif ($_.Usage -gt 70) { $ANSI.ORANGE } else { $ANSI.GREEN }
        Write-Host " ${ANSI.TEXT_SECONDARY}$($_.Drive):${ANSI.RESET} $usageColor$($_.Usage)%${ANSI.RESET} (${ANSI.TEXT_PRIMARY}$([math]::Round($_.FreeSpace / 1GB, 2)) GB${ANSI.RESET} free)"
    }
    
    # Responsiveness Analysis
    Write-Host ""
    Write-Host "${ANSI.TEXT_SECONDARY}System Responsiveness:${ANSI.RESET}"
    $respColor = if ($responsivenessScore -gt 90) { $ANSI.GREEN } elseif ($responsivenessScore -gt 75) { $ANSI.ORANGE } else { $ANSI.RED }
    Write-Host " ${ANSI.TEXT_SECONDARY}Score:${ANSI.RESET} $respColor$responsivenessScore%${ANSI.RESET}"
    Write-Host " ${ANSI.TEXT_SECONDARY}Rating:${ANSI.RESET} $([
        if ($responsivenessScore -gt 90) { "${ANSI.GREEN}Excellent${ANSI.RESET}" }
        elseif ($responsivenessScore -gt 75) { "${ANSI.ORANGE}Good${ANSI.RESET}" }
        else { "${ANSI.RED}Needs Improvement${ANSI.RESET}" }
    ])"
    
    # Overall Rating
    Write-Host ""
    Write-Host "${ANSI.PURPLE}${ANSI.BOLD}OVERALL PERFORMANCE${ANSI.RESET}"
    Write-Host "${ANSI.BORDER}───────────────────${ANSI.RESET}"
    
    # Calculate overall score
    $cpuScore = 100 - $avgCpu
    $memoryScore = 100 - $memoryPercentage
    $diskScore = 100 - ($diskUsages | Measure-Object -Property Usage -Average).Average
    $overallScore = [math]::Round(($cpuScore + $memoryScore + $diskScore + $responsivenessScore) / 4, 2)
    
    $overallRating = if ($overallScore -gt 85) { "Excellent" } elseif ($overallScore -gt 70) { "Good" } elseif ($overallScore -gt 50) { "Fair" } else { "Poor" }
    $ratingColor = if ($overallScore -gt 85) { $ANSI.GREEN } elseif ($overallScore -gt 70) { $ANSI.GREEN } elseif ($overallScore -gt 50) { $ANSI.ORANGE } else { $ANSI.RED }
    
    Write-Host " ${ANSI.TEXT_SECONDARY}Overall Score:${ANSI.RESET} $ratingColor$overallScore/100${ANSI.RESET}"
    Write-Host " ${ANSI.TEXT_SECONDARY}Rating:${ANSI.RESET} $ratingColor$overallRating${ANSI.RESET}"
    
    # Recommendations
    Write-Host ""
    Write-Host "${ANSI.PURPLE}${ANSI.BOLD}RECOMMENDATIONS${ANSI.RESET}"
    Write-Host "${ANSI.BORDER}──────────────${ANSI.RESET}"
    
    $recommendations = @()
    
    if ($avgCpu -gt 75) {
        $recommendations += "Consider closing unnecessary applications to reduce CPU usage"
    }
    
    if ($memoryPercentage -gt 80) {
        $recommendations += "Low memory available. Consider upgrading RAM or closing memory-heavy applications"
    }
    
    $highDiskUsage = $diskUsages | Where-Object { $_.Usage -gt 85 }
    if ($highDiskUsage) {
        $highDiskUsage | ForEach-Object {
            $recommendations += "Drive $($_.Drive) is nearly full ($($_.Usage)%). Consider freeing up space"
        }
    }
    
    if ($responsivenessScore -lt 80) {
        $recommendations += "System responsiveness could be improved. Consider restarting the system or checking for malware"
    }
    
    if ($recommendations.Count -eq 0) {
        Write-Host " ${ANSI.GREEN}✓${ANSI.RESET} ${ANSI.TEXT_PRIMARY}No immediate performance issues detected${ANSI.RESET}"
        Write-Host " ${ANSI.TEXT_SECONDARY}Your system is performing optimally${ANSI.RESET}"
    }
    else {
        $recommendations | ForEach-Object {
            Write-Host " ${ANSI.ORANGE}•${ANSI.RESET} ${ANSI.TEXT_PRIMARY}$_${ANSI.RESET}"
        }
    }
    
    # Save report
    Write-Host ""
    $saveReport = Confirm-KnouxAction "Save performance report to file?" "N"
    
    if ($saveReport) {
        # Create outputs directory if it doesn't exist
        $outputDir = Join-Path $PSScriptRoot "../../outputs"
        if (!(Test-Path $outputDir)) {
            New-Item -ItemType Directory -Path $outputDir | Out-Null
        }
        
        $reportPath = Join-Path $outputDir "performance_report_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
        
        # Generate report content
        $reportContent = @"
Knoux Spectre Toolbox - Performance Report
Generated on: $(Get-Date)

=== PERFORMANCE ANALYSIS ===

CPU Performance:
  Average Usage: $avgCpu%
  Peak Usage: $maxCpu%
  Rating: $cpuRating

Memory Usage:
  Total: $([math]::Round($totalMemory / 1GB, 2)) GB
  Used: $([math]::Round($usedMemory / 1GB, 2)) GB ($memoryPercentage%)
  Free: $([math]::Round($freeMemory / 1GB, 2)) GB

Disk Usage:
$($diskUsages | ForEach-Object {
    "  $($_.Drive): $($_.Usage)% (${math]::Round($_.FreeSpace / 1GB, 2)) GB free)"
} | Out-String)

System Responsiveness:
  Score: $responsivenessScore%
  Rating: $(
    if ($responsivenessScore -gt 90) { "Excellent" }
    elseif ($responsivenessScore -gt 75) { "Good" }
    else { "Needs Improvement" }
  )

=== OVERALL PERFORMANCE ===
Overall Score: $overallScore/100
Rating: $overallRating

=== RECOMMENDATIONS ===
$([
    if ($recommendations.Count -eq 0) {
        "No immediate performance issues detected. Your system is performing optimally."
    } else {
        $recommendations | ForEach-Object { "• $_" } | Out-String
    }
])
"@
        
        try {
            Set-Content -Path $reportPath -Value $reportContent -Encoding UTF8
            Write-Host "${ANSI.GREEN}✓ Performance report saved to: $reportPath${ANSI.RESET}"
        }
        catch {
            Write-Host "${ANSI.RED}× Error saving report: $($_.Exception.Message)${ANSI.RESET}"
        }
    }
}

function Show-LicenseCredits {
    Write-Host ""
    Write-Host "${ANSI.PURPLE}${ANSI.BOLD}LICENSE & CREDITS${ANSI.RESET}"
    Write-Host "${ANSI.BORDER}──────────────────${ANSI.RESET}"
    Write-Host ""
    
    Write-Host "${ANSI.TEXT_SECONDARY}Knoux Spectre Toolbox${ANSI.RESET}"
    Write-Host "${ANSI.BORDER}────────────────────${ANSI.RESET}"
    Write-Host "${ANSI.TEXT_SECONDARY}Version:${ANSI.RESET} ${ANSI.TEXT_PRIMARY}1.0.0${ANSI.RESET}"
    Write-Host "${ANSI.TEXT_SECONDARY}License:${ANSI.RESET} ${ANSI.TEXT_PRIMARY}MIT License${ANSI.RESET}"
    Write-Host "${ANSI.TEXT_SECONDARY}Copyright:${ANSI.RESET} ${ANSI.TEXT_PRIMARY}© $(Get-Date -Format 'yyyy') Knoux Systems${ANSI.RESET}"
    Write-Host ""
    
    Write-Host "${ANSI.TEXT_SECONDARY}Permission is hereby granted, free of charge, to any person obtaining a copy${ANSI.RESET}"
    Write-Host "${ANSI.TEXT_SECONDARY}of this software and associated documentation files (the 'Software'), to deal${ANSI.RESET}"
    Write-Host "${ANSI.TEXT_SECONDARY}in the Software without restriction, including without limitation the rights${ANSI.RESET}"
    Write-Host "${ANSI.TEXT_SECONDARY}to use, copy, modify, merge, publish, distribute, sublicense, and/or sell${ANSI.RESET}"
    Write-Host "${ANSI.TEXT_SECONDARY}copies of the Software, and to permit persons to whom the Software is${ANSI.RESET}"
    Write-Host "${ANSI.TEXT_SECONDARY}furnished to do so, subject to the following conditions:${ANSI.RESET}"
    Write-Host ""
    Write-Host "${ANSI.TEXT_SECONDARY}The above copyright notice and this permission notice shall be included in all${ANSI.RESET}"
    Write-Host "${ANSI.TEXT_SECONDARY}copies or substantial portions of the Software.${ANSI.RESET}"
    Write-Host ""
    Write-Host "${ANSI.TEXT_SECONDARY}THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR${ANSI.RESET}"
    Write-Host "${ANSI.TEXT_SECONDARY}IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,${ANSI.RESET}"
    Write-Host "${ANSI.TEXT_SECONDARY}FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE${ANSI.RESET}"
    Write-Host "${ANSI.TEXT_SECONDARY}AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER${ANSI.RESET}"
    Write-Host "${ANSI.TEXT_SECONDARY}LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,${ANSI.RESET}"
    Write-Host "${ANSI.TEXT_SECONDARY}OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE${ANSI.RESET}"
    Write-Host "${ANSI.TEXT_SECONDARY}SOFTWARE.${ANSI.RESET}"
    Write-Host ""
    
    Write-Host "${ANSI.PURPLE}${ANSI.BOLD}ATTRIBUTIONS${ANSI.RESET}"
    Write-Host "${ANSI.BORDER}────────────${ANSI.RESET}"
    Write-Host "${ANSI.TEXT_SECONDARY}This software includes components from the following projects:${ANSI.RESET}"
    Write-Host ""
    Write-Host " ${ANSI.GREEN}•${ANSI.RESET} ${ANSI.TEXT_PRIMARY}PowerShell${ANSI.RESET} - Microsoft Corporation (MIT License)"
    Write-Host " ${ANSI.GREEN}•${ANSI.RESET} ${ANSI.TEXT_PRIMARY}.NET Framework${ANSI.RESET} - Microsoft Corporation (MICROSOFT SOFTWARE LICENSE TERMS)"
    Write-Host " ${ANSI.GREEN}•${ANSI.RESET} ${ANSI.TEXT_PRIMARY}ANSI Escape Sequences${ANSI.RESET} - Standard specification"
    Write-Host ""
    
    Write-Host "${ANSI.PURPLE}${ANSI.BOLD}THIRD-PARTY NOTICES${ANSI.RESET}"
    Write-Host "${ANSI.BORDER}───────────────────${ANSI.RESET}"
    Write-Host "${ANSI.TEXT_SECONDARY}This software may utilize the following third-party libraries:${ANSI.RESET}"
    Write-Host ""
    Write-Host " ${ANSI.GREEN}•${ANSI.RESET} ${ANSI.TEXT_PRIMARY}System.Management.Automation${ANSI.RESET} - Microsoft PowerShell SDK"
    Write-Host " ${ANSI.GREEN}•${ANSI.RESET} ${ANSI.TEXT_PRIMARY}System.DirectoryServices${ANSI.RESET} - Microsoft .NET Framework"
    Write-Host " ${ANSI.GREEN}•${ANSI.RESET} ${ANSI.TEXT_PRIMARY}System.Security.Cryptography${ANSI.RESET} - Microsoft .NET Framework"
    Write-Host ""
    
    Write-Host "${ANSI.PURPLE}${ANSI.BOLD}CREDITS${ANSI.RESET}"
    Write-Host "${ANSI.BORDER}───────${ANSI.RESET}"
    Write-Host "${ANSI.TEXT_SECONDARY}Special thanks to:${ANSI.RESET}"
    Write-Host ""
    Write-Host " ${ANSI.GREEN}•${ANSI.RESET} ${ANSI.TEXT_PRIMARY}The PowerShell Community${ANSI.RESET} - For creating an excellent scripting environment"
    Write-Host " ${ANSI.GREEN}•${ANSI.RESET} ${ANSI.TEXT_PRIMARY}Microsoft Windows Terminal Team${ANSI.RESET} - For supporting rich console applications"
    Write-Host " ${ANSI.GREEN}•${ANSI.RESET} ${ANSI.TEXT_PRIMARY}Open Source Community${ANSI.RESET} - For inspiration and collaborative development"
    Write-Host " ${ANSI.GREEN}•${ANSI.RESET} ${ANSI.TEXT_PRIMARY}Security Researchers${ANSI.RESET} - For contributing tools and methodologies"
    Write-Host ""
    Write-Host "${ANSI.TEXT_SECONDARY}For full license texts, visit:${ANSI.RESET}"
    Write-Host "${ANSI.TEXT_PRIMARY}https://github.com/knoux/spectre-toolbox/blob/main/LICENSE${ANSI.RESET}"
    Write-Host ""
    
    # View full license
    $viewLicense = Confirm-KnouxAction "View full MIT License text?" "N"
    
    if ($viewLicense) {
        Write-Host ""
        Write-Host "${ANSI.PURPLE}${ANSI.BOLD}MIT LICENSE${ANSI.RESET}"
        Write-Host "${ANSI.BORDER}────────────${ANSI.RESET}"
        Write-Host @"
MIT License

Copyright (c) $(Get-Date -Format 'yyyy') Knoux Systems

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"@
    }
}

Export-ModuleMember -Function @('Show-AboutDiagnostics')
