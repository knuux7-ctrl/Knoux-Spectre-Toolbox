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

## Desktop (Electron wrapper)

This repo includes a minimal Electron wrapper that **loads the existing web UI from the running backend**.

- Main process: `electron-main.js`
- Preload (secure bridge): `preload.js`

### How Electron connects to the server

Electron creates a `BrowserWindow` and calls:

- `win.loadURL(API_BASE)`

Where `API_BASE` defaults to:

- `http://192.168.1.220:5000/`

Override if needed:

```bash
set API_BASE=http://192.168.1.220:5000/
# or e.g. http://localhost:5000/
```

Navigation is restricted to the same origin as `API_BASE`; anything else is opened externally in your normal browser.

### Run (backend already running elsewhere)

From `knoux-spectre-toolbox/server`:

```bash
npm install
set API_BASE=http://192.168.1.220:5000/
npm run desktop
```
