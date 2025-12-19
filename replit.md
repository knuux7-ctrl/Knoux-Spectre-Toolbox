# Knoux Spectre Toolbox - Complete Integration

## Project Overview
A full-featured desktop-style web application integrating React frontend with PowerShell backend scripts for system administration, monitoring, and automation tasks.

## Architecture

### Frontend (React + Vite)
- **Port**: 5000
- **Framework**: React 19 with TypeScript
- **UI**: Tailwind CSS with Knoux Dark Cosmic Neon theme
- **Components**: Desktop-style interface with sidebar, panels, windowed modules

### Backend (Node.js + Express)
- **Port**: 3001
- **Purpose**: Execute PowerShell scripts from web interface
- **API**: REST endpoints for script execution and module discovery

### PowerShell Scripts
Located in `/ps-scripts/` directory:
- **config/**: Theme and configuration files
- **core/**: Core loaders and menu engine
- **lib/**: Helper functions and utilities
- **modules/**: 20+ functional modules for system tools

## Module Structure
Each module provides real system administration capabilities:
1. **AI & Coding Tools** - Script generation
2. **System Control** - Services and processes
3. **Network Tools** - Port scanning and diagnostics
4. **Security & Pentest** - Hash tools, permissions audit
5. **Storage Management** - Disk cleanup, backups
6. **Process Manager** - Memory analysis, process control
7. **Event Logs** - Log viewer and monitoring
8. **Containers** - Docker integration
9. **Backup & Restore** - Folder backup with scheduling
10. And 11+ more modules

## Recent Changes
- **2024-12-19**: Complete integration of PowerShell scripts
  - Created full directory structure for 20+ modules
  - Integrated theme engine and core utilities
  - Created Express backend API for PowerShell execution
  - Wired React frontend to backend services
  - All scripts ready for execution

## Technology Stack
- Frontend: React 19, TypeScript, Vite, Tailwind CSS
- Backend: Node.js, Express, PowerShell integration
- Desktop UI: Glassmorphism, neon accents, real tool execution
- Theme: Dark Cosmic Neon (Knoux branding)

## Workflows
- **Frontend**: `npm run dev` on port 5000
- **Backend**: `node server.js` on port 3001 (available via API)

## Next Steps
1. Start both frontend and backend
2. Navigate to modules through sidebar
3. Execute real system administration tasks
4. View live output and logs
5. Access all 20+ integrated tools
