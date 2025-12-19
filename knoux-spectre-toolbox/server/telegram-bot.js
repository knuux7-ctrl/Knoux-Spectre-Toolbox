const TelegramBot = require('node-telegram-bot-api');
const axios = require('axios');
const token = process.env.TELEGRAM_BOT_TOKEN;
const SERVER = process.env.SERVER_URL || 'http://localhost:3000';
const API_KEY = process.env.API_KEY || 'changeme';

if (!token) {
  console.error('TELEGRAM_BOT_TOKEN not set');
  process.exit(1);
}

const bot = new TelegramBot(token, { polling: true });

// Accept messages like {Get-SystemAuditReport} or /run Get-SystemAuditReport
bot.on('message', async (msg) => {
  const chatId = msg.chat.id;
  const text = (msg.text || '').trim();
  let fn = null;

  const brace = text.match(/\{\s*([^}]+)\s*\}/);
  if (brace) fn = brace[1].trim();
  if (!fn && text.startsWith('/run')) fn = text.split(' ')[1];
  if (!fn) return bot.sendMessage(chatId, 'Send a command like {Get-SystemAuditReport} or /run Get-SystemAuditReport');

  try {
    await bot.sendMessage(chatId, `Executing ${fn}...`);
    const resp = await axios.post(`${SERVER}/api/v1/execute`, { function: fn, params: {} }, { headers: { 'x-api-key': API_KEY } });
    const data = resp.data;
    await bot.sendMessage(chatId, `Result:\n${JSON.stringify(data, null, 2)}`);
  } catch (err) {
    await bot.sendMessage(chatId, `Error: ${err.message}`);
  }
});
