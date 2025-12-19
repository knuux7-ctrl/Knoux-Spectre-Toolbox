const express = require('express');
const { spawn } = require('child_process');
const path = require('path');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

const PS_SCRIPTS_DIR = path.join(__dirname, 'ps-scripts');

app.post('/api/execute-script', (req, res) => {
  const { script, args } = req.body;
  
  if (!script) {
    return res.status(400).json({ error: 'Script name required' });
  }

  const scriptPath = path.join(PS_SCRIPTS_DIR, script);
  
  const ps = spawn('powershell.exe', [
    '-ExecutionPolicy', 'Bypass',
    '-File', scriptPath,
    ...(args || [])
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
    res.json({
      success: code === 0,
      output: stdout,
      error: stderr,
      exitCode: code
    });
  });

  ps.on('error', (err) => {
    res.status(500).json({ error: err.message });
  });
});

app.get('/api/modules', (req, res) => {
  const modules = {
    'AI & Coding': { path: 'modules/mod.ai/', icon: '🧠' },
    'System Control': { path: 'modules/mod.system/', icon: '🖥' },
    'Network Tools': { path: 'modules/mod.network/', icon: '🌐' },
    'Security': { path: 'modules/mod.security/', icon: '🛡' },
    'Storage': { path: 'modules/mod.disk/', icon: '💾' },
    'Process Manager': { path: 'modules/mod.process/', icon: '📊' },
    'Event Logs': { path: 'modules/mod.logs/', icon: '📝' },
    'Containers': { path: 'modules/mod.containers/', icon: '🐳' },
    'Backup': { path: 'modules/mod.backup/', icon: '📦' }
  };
  res.json(modules);
});

const PORT = 3001;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Knoux Spectre Backend running on port ${PORT}`);
});
