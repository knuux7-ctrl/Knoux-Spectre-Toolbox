
export enum ModuleType {
  AI = 'mod.ai',
  DEV = 'mod.dev',
  POWERSHELL = 'mod.powershell',
  PYTHON = 'mod.python',
  SYSTEM = 'mod.system',
  DISK = 'mod.disk',
  NETWORK = 'mod.network',
  SECURITY = 'mod.security',
  PROCESS = 'mod.process',
  LOGS = 'mod.logs',
  CONTAINERS = 'mod.containers',
  BACKUP = 'mod.backup',
  SCRIPTGEN = 'mod.scriptgen',
  AUTOMATION = 'mod.automation',
  CLEAN = 'mod.clean',
  FILES = 'mod.files',
  DEVOPS = 'mod.devops',
  EXPERIMENTS = 'mod.experiments',
  SETTINGS = 'mod.settings',
  ABOUT = 'mod.about'
}

export interface ModuleDefinition {
  id: ModuleType;
  label: string;
  icon: string;
  description: string;
  category: string;
}

export interface AuditData {
  cpu: number;
  memory: number;
  disk: number;
  network: number;
}
