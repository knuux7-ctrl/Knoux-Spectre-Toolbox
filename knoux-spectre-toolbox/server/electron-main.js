const { app, BrowserWindow, nativeTheme, shell } = require('electron');
const path = require('path');

// Electron should *only* wrap the existing web UI served by the running backend.
// Default to your provided LAN URL; override with API_BASE when needed.
const API_BASE = process.env.API_BASE || 'http://192.168.1.220:5000/';

function isAllowedNavigation(urlString) {
  try {
    const target = new URL(urlString);
    const allowed = new URL(API_BASE);
    return (
      target.protocol === allowed.protocol &&
      target.hostname === allowed.hostname &&
      target.port === allowed.port
    );
  } catch {
    return false;
  }
}

function createWindow() {
  const win = new BrowserWindow({
    width: 1280,
    height: 820,
    minWidth: 1100,
    minHeight: 720,
    backgroundColor: '#0b1020',
    show: false,
    title: 'Knoux Spectre Toolbox',
    autoHideMenuBar: true,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      nodeIntegration: false,
      contextIsolation: true,
      sandbox: true,
      webSecurity: true
    }
  });

  win.once('ready-to-show', () => win.show());

  // Match Electron theme to OS theme.
  nativeTheme.themeSource = 'system';

  // Block popups; open external links in the default browser.
  win.webContents.setWindowOpenHandler(({ url }) => {
    if (!isAllowedNavigation(url)) shell.openExternal(url);
    return { action: 'deny' };
  });

  // Prevent navigation away from the allowed origin.
  win.webContents.on('will-navigate', (event, url) => {
    if (!isAllowedNavigation(url)) {
      event.preventDefault();
      shell.openExternal(url);
    }
  });

  win.loadURL(API_BASE);
}

app.whenReady().then(() => {
  createWindow();

  app.on('activate', function () {
    if (BrowserWindow.getAllWindows().length === 0) createWindow();
  });
});

app.on('window-all-closed', function () {
  if (process.platform !== 'darwin') app.quit();
});
