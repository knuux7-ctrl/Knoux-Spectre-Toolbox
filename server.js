const express = require('express');
const { spawn } = require('child_process');
const path = require('path');
const cors = require('cors');
const fs = require('fs');

const app = express();
app.use(cors());
app.use(express.json());

const PS_SCRIPTS_DIR = path.join(__dirname, 'ps-scripts');
const PORT = 3001;

// ========== MODULE ENDPOINTS ==========

// System Control
app.post('/api/modules/system/services', (req, res) => {
  const { action, serviceName } = req.body;
  const script = `
    function ${action === 'start' ? 'Start' : 'Stop'}-ServiceKnoux {
        param([string]$Name)
        try {
            $service = Get-Service -Name $Name -ErrorAction Stop
            if ($service.Status -eq 'Running' -and '${action}' -eq 'start') {
                return @{success = $true; message = 'Service already running'; service = $service.Name}
            }
            ${action === 'start' ? 'Start-Service -Name $Name -ErrorAction Stop' : 'Stop-Service -Name $Name -Force -ErrorAction Stop'}
            Start-Sleep -Milliseconds 500
            return @{success = $true; message = "Service ${action}ed"; service = $service.Name}
        } catch {
            return @{success = $false; error = $_.Exception.Message}
        }
    }
    ${action === 'start' ? 'Start' : 'Stop'}-ServiceKnoux -Name '${serviceName}' | ConvertTo-Json
  `;
  
  runPowerShellScript(script, res);
});

app.post('/api/modules/system/running-services', (req, res) => {
  const script = `
    try {
        $services = Get-Service | Where-Object {$_.Status -eq 'Running'} | Select-Object -First 20 Name, DisplayName, Status
        @{success = $true; services = @($services); count = $services.Count} | ConvertTo-Json
    } catch {
        @{success = $false; error = $_.Exception.Message} | ConvertTo-Json
    }
  `;
  runPowerShellScript(script, res);
});

// Disk Management
app.post('/api/modules/disk/usage', (req, res) => {
  const script = `
    try {
        $volumes = Get-Volume | Where-Object {$_.Size -gt 0} | Select-Object @{Name='Drive';Expression={$_.DriveLetter}}, @{Name='Size_GB';Expression={[Math]::Round($_.Size/1GB,2)}}, @{Name='Used_GB';Expression={[Math]::Round(($_.Size - $_.SizeRemaining)/1GB,2)}}, @{Name='Free_GB';Expression={[Math]::Round($_.SizeRemaining/1GB,2)}}
        @{success = $true; volumes = @($volumes)} | ConvertTo-Json
    } catch {
        @{success = $false; error = $_.Exception.Message} | ConvertTo-Json
    }
  `;
  runPowerShellScript(script, res);
});

app.post('/api/modules/disk/cleanup', (req, res) => {
  const { targetPath } = req.body;
  const script = `
    try {
        $path = '${targetPath}' -replace '\\\$', '$'
        if (-not (Test-Path $path)) { throw 'Path not found' }
        $before = (Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Sum -Property Length).Sum
        Remove-Item -Path "$path\\*" -Recurse -Force -ErrorAction SilentlyContinue
        $after = (Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Sum -Property Length).Sum
        $freed = if ($before) { $before - $after } else { 0 }
        @{success = $true; freed_bytes = $freed; freed_mb = [Math]::Round($freed/1MB, 2)} | ConvertTo-Json
    } catch {
        @{success = $false; error = $_.Exception.Message} | ConvertTo-Json
    }
  `;
  runPowerShellScript(script, res);
});

// Network Tools
app.post('/api/modules/network/ports', (req, res) => {
  const script = `
    try {
        $tcpPorts = Get-NetTCPConnection | Where-Object {$_.State -eq 'Listen'} | Select-Object -First 20 LocalPort, @{Name='Process';Expression={(Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).ProcessName}}
        @{success = $true; ports = @($tcpPorts); count = $tcpPorts.Count} | ConvertTo-Json
    } catch {
        @{success = $false; error = $_.Exception.Message} | ConvertTo-Json
    }
  `;
  runPowerShellScript(script, res);
});

// Security & Hash Tools
app.post('/api/modules/security/file-hash', (req, res) => {
  const { filePath, algorithm } = req.body;
  const script = `
    try {
        if (-not (Test-Path '${filePath}')) { throw 'File not found' }
        $hash = Get-FileHash -Path '${filePath}' -Algorithm '${algorithm || 'SHA256'}'
        @{success = $true; file = $hash.Path; hash = $hash.Hash; algorithm = $hash.Algorithm} | ConvertTo-Json
    } catch {
        @{success = $false; error = $_.Exception.Message} | ConvertTo-Json
    }
  `;
  runPowerShellScript(script, res);
});

// Process Management
app.post('/api/modules/process/list', (req, res) => {
  const script = `
    try {
        $processes = Get-Process | Sort-Object -Property WorkingSet -Descending | Select-Object -First 20 Id, ProcessName, @{Name='Memory_MB';Expression={[Math]::Round($_.WorkingSet/1MB,2)}}
        @{success = $true; processes = @($processes); count = $processes.Count} | ConvertTo-Json
    } catch {
        @{success = $false; error = $_.Exception.Message} | ConvertTo-Json
    }
  `;
  runPowerShellScript(script, res);
});

app.post('/api/modules/process/kill', (req, res) => {
  const { processId } = req.body;
  const script = `
    try {
        $proc = Get-Process -Id ${processId} -ErrorAction Stop
        Stop-Process -Id ${processId} -Force -ErrorAction Stop
        @{success = $true; killed = $proc.ProcessName; pid = ${processId}} | ConvertTo-Json
    } catch {
        @{success = $false; error = $_.Exception.Message} | ConvertTo-Json
    }
  `;
  runPowerShellScript(script, res);
});

// Logs
app.post('/api/modules/logs/system', (req, res) => {
  const script = `
    try {
        $events = Get-EventLog -LogName System -Newest 50 -ErrorAction SilentlyContinue | Select-Object @{Name='Time';Expression={$_.TimeGenerated}}, EntryType, Source, EventID, @{Name='Message';Expression={$_.Message.Substring(0, [Math]::Min(100, $_.Message.Length))}}
        @{success = $true; events = @($events); count = $events.Count} | ConvertTo-Json
    } catch {
        @{success = $false; error = $_.Exception.Message} | ConvertTo-Json
    }
  `;
  runPowerShellScript(script, res);
});

app.post('/api/modules/logs/application', (req, res) => {
  const script = `
    try {
        $events = Get-EventLog -LogName Application -Newest 50 -ErrorAction SilentlyContinue | Select-Object @{Name='Time';Expression={$_.TimeGenerated}}, EntryType, Source, EventID, @{Name='Message';Expression={$_.Message.Substring(0, [Math]::Min(100, $_.Message.Length))}}
        @{success = $true; events = @($events); count = $events.Count} | ConvertTo-Json
    } catch {
        @{success = $false; error = $_.Exception.Message} | ConvertTo-Json
    }
  `;
  runPowerShellScript(script, res);
});

// Docker
app.post('/api/modules/containers/docker-status', (req, res) => {
  const script = `
    try {
        $docker = Get-Command docker -ErrorAction SilentlyContinue
        if (-not $docker) { throw 'Docker not installed' }
        $containers = docker ps -a --format "json" 2>$null | ConvertFrom-Json -ErrorAction SilentlyContinue
        $images = docker images --format "json" 2>$null | ConvertFrom-Json -ErrorAction SilentlyContinue
        @{success = $true; containers = @($containers); images = @($images)} | ConvertTo-Json
    } catch {
        @{success = $false; error = "Docker: $($_.Exception.Message)"} | ConvertTo-Json
    }
  `;
  runPowerShellScript(script, res);
});

// Backup Module
app.post('/api/modules/backup/create', (req, res) => {
  const { sourcePath, destPath } = req.body;
  const script = `
    try {
        if (-not (Test-Path '${sourcePath}')) { throw 'Source path not found' }
        if (-not (Test-Path '${destPath}')) { New-Item -ItemType Directory -Path '${destPath}' -Force | Out-Null }
        $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
        $backupName = "$(Split-Path '${sourcePath}' -Leaf)_$timestamp.zip"
        $backupPath = Join-Path '${destPath}' $backupName
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::CreateFromDirectory('${sourcePath}', $backupPath, [System.IO.Compression.CompressionLevel]::Optimal, $false)
        @{success = $true; backup_path = $backupPath; timestamp = $timestamp} | ConvertTo-Json
    } catch {
        @{success = $false; error = $_.Exception.Message} | ConvertTo-Json
    }
  `;
  runPowerShellScript(script, res);
});

// Module Discovery
app.get('/api/modules', (req, res) => {
  res.json({
    system: { name: 'System Control', icon: 'Cpu', path: 'mod.system' },
    disk: { name: 'Disk Analyzer', icon: 'HardDrive', path: 'mod.disk' },
    network: { name: 'Network Tools', icon: 'Network', path: 'mod.network' },
    security: { name: 'Security Core', icon: 'Shield', path: 'mod.security' },
    process: { name: 'Process Inspector', icon: 'Activity', path: 'mod.process' },
    logs: { name: 'Event Logs', icon: 'FileText', path: 'mod.logs' },
    containers: { name: 'Container Manager', icon: 'Box', path: 'mod.containers' },
    backup: { name: 'Backup System', icon: 'Save', path: 'mod.backup' },
    automation: { name: 'Task Automation', icon: 'Zap', path: 'mod.automation' }
  });
});

// Health Check
app.get('/api/health', (req, res) => {
  res.json({ status: 'healthy', version: '1.0.0', timestamp: new Date() });
});

// Helper function to run PowerShell scripts
function runPowerShellScript(script, res) {
  const ps = spawn('powershell.exe', [
    '-ExecutionPolicy', 'Bypass',
    '-Command', script
  ]);

  let stdout = '';
  let stderr = '';

  ps.stdout.on('data', (data) => {
    stdout += data.toString();
  });

  ps.stderr.on('data', (data) => {
    stderr += data.toString();
  });

  ps.on('close', (code) => {
    try {
      const result = JSON.parse(stdout);
      res.json(result);
    } catch (e) {
      res.json({ success: false, error: stderr || 'Invalid JSON response', raw: stdout });
    }
  });

  ps.on('error', (err) => {
    res.status(500).json({ error: err.message });
  });
}

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`✓ Knoux Spectre Backend running on port ${PORT}`);
  console.log(`✓ API: http://0.0.0.0:${PORT}/api`);
});
