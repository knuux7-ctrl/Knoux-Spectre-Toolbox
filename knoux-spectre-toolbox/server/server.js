const express = require('express');
const bodyParser = require('body-parser');
const { spawn } = require('child_process');
const path = require('path');

const app = express();
app.use(bodyParser.json({ limit: '1mb' }));

const PORT = process.env.PORT || 3000;
const API_KEY = process.env.API_KEY || 'changeme';
const PWsh = process.env.PWSH || 'pwsh'; // fallback to 'powershell' if needed
const RUNNER = path.join(__dirname, 'ps-runner.ps1');

const ALLOWED_FUNCTIONS = new Set([
  'Get-SystemAuditReport',
  'Invoke-EmotionalAdjuster',
  'Invoke-RecordHistoryEvent'
]);

function runPowerShell(functionName, payloadJson, timeoutMs = 60000) {
  return new Promise((resolve, reject) => {
    const args = ['-NoProfile', '-NonInteractive', '-ExecutionPolicy', 'Bypass', '-File', RUNNER, '-FunctionName', functionName, '-PayloadJson', payloadJson];
    const child = spawn(PWsh, args, { windowsHide: true });

    let stdout = '';
    let stderr = '';
    let killed = false;

    const timer = setTimeout(() => {
      killed = true;
      child.kill();
      reject(new Error('Execution timed out'));
    }, timeoutMs);

    child.stdout.on('data', (d) => { stdout += d.toString(); });
    child.stderr.on('data', (d) => { stderr += d.toString(); });

    child.on('close', (code) => {
      clearTimeout(timer);
      if (killed) return;
      if (code !== 0) return reject(new Error(`Process exited ${code}: ${stderr}`));
      try {
        const parsed = JSON.parse(stdout);
        resolve(parsed);
      } catch (err) {
        // If JSON parse fails, return raw output
        resolve({ success: true, raw: stdout });
      }
    });
  });
}

// Simple API auth middleware
app.use((req, res, next) => {
  const key = req.header('x-api-key') || req.query.api_key;
  if (!key || key !== API_KEY) return res.status(401).json({ error: 'Unauthorized' });
  next();
});

app.post('/api/v1/execute', async (req, res) => {
  const { function: fn, params } = req.body || {};
  if (!fn) return res.status(400).json({ error: 'Missing `function` in body' });
  if (!ALLOWED_FUNCTIONS.has(fn)) return res.status(403).json({ error: 'Function not allowed' });

  const payloadJson = JSON.stringify(params || {});
  try {
    const result = await runPowerShell(fn, payloadJson, 60000);
    res.json(result);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/', (req, res) => res.send('Knoux Spectre API running'));

app.listen(PORT, () => console.log(`Server listening on ${PORT}`));
