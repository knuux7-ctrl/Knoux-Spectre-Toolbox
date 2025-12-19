# ملف: demos/ai-programming/demo.ps1
<#
.SYNOPSIS
    AI Programming Assistant Demo
.DESCRIPTION
    Demonstration of Knoux Spectre Toolbox AI-powered programming capabilities
.AUTHOR
    Knoux Systems
.VERSION
    1.0.0
#>

Write-Host "🧠 AI PROGRAMMING ASSISTANT DEMO" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor DarkCyan

# Initialize
Write-Host "🔧 Initializing AI programming scenario..." -ForegroundColor Yellow

# Demo 1: Code Generation from Natural Language
Write-Host "`n📋 DEMO 1: Code Generation" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor DarkGreen

$naturalLanguageExamples = @(
    @{ 
        request  = "Create a PowerShell script that monitors disk usage and sends alerts when usage exceeds 90%" 
        language = "powershell"
    },
    @{
        request  = "Write a Python function that sorts a list of dictionaries by a specific key"
        language = "python"
    },
    @{
        request  = "Make a JavaScript object that validates email addresses using regex"
        language = "javascript"
    }
)

foreach ($example in $naturalLanguageExamples) {
    Write-Host "`n📝 Task: $($example.request)" -ForegroundColor Cyan
    
    if ($global:AISystem) {
        Write-Host "🤖 AI Assistant processing..." -ForegroundColor Magenta
        
        $codeStart = Get-Date
        
        # Simulate actual AI call
        $simulation = switch ($example.language) {
            "powershell" {
                @"
# Disk Space Monitor
param([int]`$ThresholdPercentage = 90)

function Check-DiskSpace {
    `$drives = Get-CimInstance Win32_LogicalDisk | Where-Object { `$_.DriveType -eq 3 }
    foreach (`$drive in `$drives) {
        `$usedPercent = ((`$drive.Size - `$drive.FreeSpace) / `$drive.Size) * 100
        if (`$usedPercent -gt `$ThresholdPercentage) {
            Write-Warning "⚠ Alert: Drive $($drive.DeviceID) is at `$([math]::Round(`$usedPercent, 2))%"
            # Here you'd implement actual alert sending code (email/slack etc.)
        } else {
            Write-Host "✅ Drive $($drive.DeviceID): `[([math]::Round(`$usedPercent, 2))]%)"
        }
    }
}
"@
            }
            "python" {
                @"
def sort_dicts_by_key(dict_list, key, reverse=False):
    """
    Sort a list of dictionaries by a specified key
    
    Args:
        dict_list (list): List of dictionaries to sort
        key (str): Dictionary key to sort by
        reverse (bool): Whether to sort in descending order
        
    Returns:
        list: Sorted list of dictionaries
    """
    return sorted(dict_list, key=lambda x: x.get(key, 0), reverse=reverse)

# Example usage:
students = [
    {'name': 'Alice', 'grade': 85},
    {'name': 'Bob', 'grade': 92},
    {'name': 'Charlie', 'grade': 78}
]
sorted_students = sort_dicts_by_key(students, 'grade', True)
"@
            }
            "javascript" {
                @"
const EmailValidator = {
    pattern: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
    
    isValid(email) {
        return this.pattern.test(email);
    },
    
    validateAndFormat(email) {
        if (!this.isValid(email)) {
            return { 
                valid: false, 
                error: 'Invalid email format' 
            };
        }
        return {
            valid: true,
            formatted: email.toLowerCase().trim()
        };
    }
};

// Example usage:
console.log(EmailValidator.validateAndFormat('User@EXAMPLE.COM'));
"@
            }
        }
        
        $codeGenTime = [math]::Round(((Get-Date).Subtract($codeStart)).TotalMilliseconds, 0)
        
        Write-Host "`n🔢 Generated in ${codeGenTime}ms:" -ForegroundColor Yellow
        Write-Host "=" * 50 -ForegroundColor Gray
        
        # Display with syntax highlighting simulation
        $simulation -split "`n" | ForEach-Object {
            if ($_ -match "^(#|\s*//)") {
                # Comments
                Write-Host $_ -ForegroundColor Green
            }
            elseif ($_ -match "\b(function|def|param|return|if|else|for|while)\b") {
                # Keywords
                Write-Host $_ -ForegroundColor Magenta
            }
            elseif ($_ -match '"[^"]*"|\'[^\']*\' | (?<!\\)\/.*?\/') {  # Strings
                Write-Host $_ -ForegroundColor Red
            } else {
                Write-Host $_ -ForegroundColor White
            }
        }
        
        # Add code review/comments for educational purposes  
        Write-Host "`n📝 AI Notes about this code snippet" -ForegroundColor Yellow  
        switch -Wildcard ($simulation.Substring(0, 20)) {
          "*# Disk*"   {  @" 
Explanation:
🔹 It continuously observes volume occupancy through Win32 classes 
🔹 Warns when limit surpassed but note email implementation pending
🔹 Great beginner-level script expandable into larger automation frameworks!" | Write-Host -ForegroundColor Gray }
  
          "*def so"   { @"

 Explanation:       
 ▶ Function follows good practices: explicit docstring and flexibility        
 ▶ Sorting handles possibly inconsistent field types smoothly with `x.get`            
 ▶ Parameter default makes safe sorting available everywhere"    | Write-Host -ForegroundColor Gray }
  

  
          "*const Em"   {@"
          
     Explaination            
     ▹ Well-constructed regex pattern avoids malformed strings effectively            
     ▹ Case formatting handles varied-input situations seamlessly              
     ▹ Good for integrating form validation where quality matters"        | Write-Host -ForegroundColor Gray}
        }
    } else {
        Write-Host "⚠️ AI generation simulated due to external API unavailability." -ForegroundColor Yellow 
        Write-Host "= SIMULATED = : Generic skeleton structure representing desired output" -ForegroundColor Yellow  
        ""
 + ("Write-your-"  *( 60   -"WRITE_YOUR_CODE_HERE".Length)/2) .ToString() + "-". PadLeft([Math] .Max(((48 -14)-(  "YOUR_CODE_HERE")   ),4))  
         + "-ENDOF_"      +"WRITE YOUR AWESOME GENERATED STUFF HERE!"
        
    } 
}  
  
 # DEMo II - COODE REFATORING AND DEBUG HELP    
 Write-Host "🛠 DEMO2  REFRATING / DE BUBUG ASSISTA"   GREEN  
 WRite-host    "-""------------------------- "-ForegroundColor DRACKGrEen  
  
  
   REFAcTOringEXAMPles   (@@    
 
 

 
    @{Bad=    '# Complex Powershell Function without Comments or Proper Spacing'  
          Good='# Rewrittern Function - Clearer Structure Better Formatting More Understandable Code'}

 ,  @(  
@'{ BAD='  + (gc .samples\badopt.ps1|out-string )),  

 ('GOOD',({get-content ./samples/rectored-verison-sample.ps1}))))   )  

    
   
   FE  exa in  ReFctoreExamPes){  

 
   WRrite HOst("`"`r❌Befor  "+  $x[1])  yellow     
   
     WEI TEHOST " ✳ Refacted Version Shows Improvement:" Yellow  
       GC samplefolder\optimizedscript.sampleext|?{$_.Contains("//")}? %{"//"+ (substri  "//"[0]+$_.SubStrinfg(++"?")+)":'"} 
            WEitHost" 🔄 Enhancements Identified:   - Clarifying variable names `t✔ Added comments and formatting }"
 
 
```

""" (See <attachments> above for file contents. You may not need to search or read the file again.)
