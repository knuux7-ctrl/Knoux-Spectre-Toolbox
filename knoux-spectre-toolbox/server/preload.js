const { contextBridge } = require('electron');

// Preload should expose as little as possible.
// We only expose the backend base URL for the existing web UI (if it wants it).
const apiBase = process.env.API_BASE || 'http://192.168.1.220:5000/';

contextBridge.exposeInMainWorld('knoux', Object.freeze({
  apiBase: String(apiBase)
}));
