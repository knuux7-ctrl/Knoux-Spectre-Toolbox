# TODO: Enhance Script Injection Phase, Logging Panel, Neon UI Bindings, and Electron Improvements

## 1. Enhance PowerShell Injection Phase (`core/injection.phase.ps1`) - IN PROGRESS

- [x] Introduce a Task class for managing tasks within injection phases.
- [x] Integrate task queuing and execution in hooks (e.g., PreExecution, PostExecution).
- [x] Add task status tracking (pending, running, completed, failed).

## 2. Improve Logging in Injection Phase

- [ ] Add more detailed logging levels (DEBUG, INFO, WARN, ERROR, TRACE).
- [ ] Implement log export to files (e.g., CSV or JSON format).
- [ ] Integrate logging with UI logging panel via API calls (e.g., send logs to backend for UI display).

## 3. Integrate Logging Panel in UI (`server/renderer/index.html`)

- [ ] Update UI to display injection logs in real-time (using WebSocket or polling).
- [ ] Add filters and search functionality for logs.
- [ ] Enhance log display with color-coding based on log levels.

## 4. Add Neon UI Bindings

- [ ] Update CSS in `index.html` for Neon-inspired styles (glowing effects, modern gradients, animations).
- [ ] Add JavaScript bindings for dynamic UI updates (e.g., animate log entries, task progress bars).
- [ ] Implement futuristic visual effects like pulsing borders or shadow animations.

## 5. Additional Improvements for Electron Wrapper and Production (`server/electron-main.js`)

- [ ] Add auto-updater functionality for production builds.
- [ ] Enhance error handling and crash reporting.
- [ ] Add environment-specific configurations (dev vs. prod).
- [ ] Improve security: Add CSP headers, validate API calls, enhance sandboxing.

## 6. Followup Steps

- [ ] Test the enhanced injection system with sample tasks.
- [ ] Verify UI updates and logging integration.
- [ ] Build and test the Electron app in production mode.
