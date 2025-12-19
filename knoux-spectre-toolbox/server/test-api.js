const axios = require('axios');
require('dotenv').config();

const SERVER = process.env.SERVER_URL || 'http://localhost:3000';
const API_KEY = process.env.API_KEY || 'changeme';

async function run() {
  try {
    console.log('Calling /api/v1/execute -> Get-SystemAuditReport');
    const res = await axios.post(`${SERVER}/api/v1/execute`, { function: 'Get-SystemAuditReport', params: {} }, { headers: { 'x-api-key': API_KEY } });
    console.log('Response:', JSON.stringify(res.data, null, 2));
  } catch (err) {
    if (err.response) console.error('API error:', err.response.status, err.response.data);
    else console.error('Request failed:', err.message);
  }
}

run();
