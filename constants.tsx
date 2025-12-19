
import React from 'react';
import { 
  Brain, Code, Terminal, Cpu, HardDrive, Network, Shield, Activity, 
  FileText, Box, Save, Wand2, Zap, Eraser, Folder, Settings, Info, 
  FlaskConical, Layers, Database, Construction
} from 'lucide-react';
import { ModuleType, ModuleDefinition } from './types';

export const THEME = {
  background: '#0E1117',
  primary: '#E5E7EB',
  secondary: '#9CA3AF',
  faded: '#6B7280',
  accent: '#7C3AED',
  hover: '#A855F7',
  success: '#22C55E',
  warning: '#F59E0B',
  error: '#EF4444'
};

export const MODULES: ModuleDefinition[] = [
  { id: ModuleType.AI, label: 'AI Prompt Engine', icon: 'Brain', description: 'Natural language to code generation', category: 'Intelligence' },
  { id: ModuleType.DEV, label: 'Dev Tools', icon: 'Code', description: 'IDE and build configurations', category: 'Development' },
  { id: ModuleType.POWERSHELL, label: 'PowerShell Arsenal', icon: 'Terminal', description: 'Advanced administrative commands', category: 'Automation' },
  { id: ModuleType.PYTHON, label: 'Python Toolbox', icon: 'Database', description: 'Venv and script management', category: 'Development' },
  { id: ModuleType.SYSTEM, label: 'System Audit', icon: 'Cpu', description: 'Resource monitoring and reporting', category: 'Analysis' },
  { id: ModuleType.DISK, label: 'Disk Analyzer', icon: 'HardDrive', description: 'Storage cleanup and optimization', category: 'Maintenance' },
  { id: ModuleType.NETWORK, label: 'Network Ops', icon: 'Network', description: 'Connectivity diagnostics', category: 'Analysis' },
  { id: ModuleType.SECURITY, label: 'Security Core', icon: 'Shield', description: 'Audit logs and vulnerability scan', category: 'Security' },
  { id: ModuleType.PROCESS, label: 'Process Inspector', icon: 'Activity', description: 'Deep process tree analysis', category: 'Analysis' },
  { id: ModuleType.LOGS, label: 'Event Logs', icon: 'FileText', description: 'Real-time log aggregation', category: 'Analysis' },
  { id: ModuleType.CONTAINERS, label: 'Container Manager', icon: 'Box', description: 'Docker and K8s orchestration', category: 'Development' },
  { id: ModuleType.BACKUP, label: 'Backup System', icon: 'Save', description: 'Automated snapshot management', category: 'Maintenance' },
  { id: ModuleType.SCRIPTGEN, label: 'Script Generator', icon: 'Wand2', description: 'Template-based script creation', category: 'Automation' },
  { id: ModuleType.AUTOMATION, label: 'Task Automation', icon: 'Zap', description: 'Scheduled job configuration', category: 'Automation' },
  { id: ModuleType.CLEAN, label: 'System Cleaner', icon: 'Eraser', description: 'Temp file and cache removal', category: 'Maintenance' },
  { id: ModuleType.FILES, label: 'File Explorer', icon: 'Folder', description: 'Advanced file manipulation', category: 'Analysis' },
  { id: ModuleType.DEVOPS, label: 'DevOps Pipelines', icon: 'Layers', description: 'CI/CD status and controls', category: 'Development' },
  { id: ModuleType.EXPERIMENTS, label: 'Lab Experiments', icon: 'FlaskConical', description: 'New features and testing', category: 'Intelligence' },
  { id: ModuleType.SETTINGS, label: 'Global Settings', icon: 'Settings', description: 'Toolbox configuration', category: 'System' },
  { id: ModuleType.ABOUT, label: 'About Spectre', icon: 'Info', description: 'Version and author info', category: 'System' }
];

export const getIcon = (iconName: string, className?: string) => {
  const icons: Record<string, any> = {
    Brain, Code, Terminal, Cpu, HardDrive, Network, Shield, Activity, 
    FileText, Box, Save, Wand2, Zap, Eraser, Folder, Settings, Info,
    FlaskConical, Layers, Database, Construction
  };
  const Icon = icons[iconName] || Construction;
  return <Icon className={className} />;
};
