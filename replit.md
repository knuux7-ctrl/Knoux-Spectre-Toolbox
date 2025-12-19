# Knoux Spectre Toolbox

## Overview
A React-based web application providing a systems toolbox with AI-powered features for script generation and system analysis. Built with Vite, React 19, TypeScript, and Tailwind CSS.

## Project Structure
- `index.html` - Main HTML entry point
- `index.tsx` - React app entry point
- `App.tsx` - Main application component with navigation and layout
- `components/` - React components
  - `PromptEngine.tsx` - AI-powered script generation
  - `SystemAudit.tsx` - System analysis module
  - `ThemeSystem.tsx` - Theme settings
- `services/` - Backend services
  - `gemini.ts` - Google Gemini AI integration
- `constants.tsx` - App constants and module definitions
- `types.ts` - TypeScript type definitions

## Development
- **Framework**: React 19 with TypeScript
- **Build Tool**: Vite
- **Styling**: Tailwind CSS (via CDN)
- **Port**: 5000

### Running Locally
```bash
npm install
npm run dev
```

## Environment Variables
- `GEMINI_API_KEY` - Required for AI features (Google Gemini API)

## Recent Changes
- 2024-12-19: Initial setup for Replit environment
  - Configured Vite to use port 5000 with host 0.0.0.0
  - Added allowedHosts: true for Replit proxy compatibility
  - Added script entry point to index.html
  - Updated Gemini service to handle missing API key gracefully
  - Updated AI model to gemini-2.0-flash
