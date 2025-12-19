# Knoux Spectre Server

This folder contains a minimal Express wrapper and a Telegram bot scaffold that can invoke PowerShell module functions.

Setup

1. Install dependencies:

```bash
cd server
npm install
```

2. Copy `.env.example` to `.env` and set `API_KEY` and `TELEGRAM_BOT_TOKEN`.

3. Start the API server:

```bash
API_KEY=changeme node server.js
```

4. (Optional) Start the Telegram bot (in another shell):

```bash
API_KEY=changeme TELEGRAM_BOT_TOKEN=xxx SERVER_URL=http://localhost:3000 node telegram-bot.js
```

Usage

Send to the bot a message like:

```
{Get-SystemAuditReport}
```

Or call the API directly:

```http
POST /api/v1/execute
Headers: x-api-key: changeme
Body: { "function": "Get-SystemAuditReport", "params": {} }
```

Security

- The server checks `x-api-key` header. Use a strong API key in production.
- Only functions listed in `server.js` `ALLOWED_FUNCTIONS` are permitted.
