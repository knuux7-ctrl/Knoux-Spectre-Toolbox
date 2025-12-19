
import React, { useState } from 'react';
import { MODULES, getIcon, THEME } from './constants';
import { ModuleType } from './types';
import { PromptEngine } from './components/PromptEngine';
import { SystemAudit } from './components/SystemAudit';
import { ThemeSystem } from './components/ThemeSystem';
import { SystemModule } from './src/components/SystemModule';
import { DiskModule } from './src/components/DiskModule';
import { NetworkModule } from './src/components/NetworkModule';
import { 
  Search, Bell, User, LayoutGrid, 
  Menu, X, ExternalLink, ChevronRight,
  ShieldCheck, Zap, Globe
} from 'lucide-react';

const App: React.FC = () => {
  const [activeModule, setActiveModule] = useState<ModuleType>(ModuleType.AI);
  const [sidebarOpen, setSidebarOpen] = useState(true);

  const renderModule = () => {
    switch (activeModule) {
      case ModuleType.AI:
        return <PromptEngine />;
      case ModuleType.SYSTEM:
        return <SystemModule />;
      case ModuleType.DISK:
        return <DiskModule />;
      case ModuleType.NETWORK:
        return <NetworkModule />;
      case ModuleType.SETTINGS:
        return <ThemeSystem />;
      default:
        return (
          <div className="flex flex-col items-center justify-center h-[60vh] text-center space-y-4">
            <div className="p-6 rounded-full bg-[#111827] text-[#7C3AED] neon-glow">
              {getIcon(MODULES.find(m => m.id === activeModule)?.icon || '', "w-12 h-12")}
            </div>
            <div>
              <h2 className="text-2xl font-bold text-[#E5E7EB]">{MODULES.find(m => m.id === activeModule)?.label}</h2>
              <p className="text-[#9CA3AF] max-w-md mt-2">
                This module is currently in development. Knoux Systems is working to port the PowerShell functionalities to this web interface.
              </p>
            </div>
            <button 
              onClick={() => setActiveModule(ModuleType.AI)}
              className="mt-6 px-6 py-2 bg-[#7C3AED] rounded-lg text-sm font-medium text-white hover:bg-[#A855F7] transition-all shadow-[0_0_15px_rgba(124,58,237,0.3)]"
            >
              Back to Prompt Engine
            </button>
          </div>
        );
    }
  };

  return (
    <div className="flex h-screen bg-[#0E1117] overflow-hidden text-[#E5E7EB]">
      {/* Sidebar */}
      <aside 
        className={`${sidebarOpen ? 'w-72' : 'w-20'} h-full bg-[#111827] border-r border-[#1F2937] transition-all duration-300 flex flex-col z-20`}
      >
        <div className="p-6 flex items-center gap-3">
          <div className="w-8 h-8 rounded-lg bg-[#7C3AED] flex items-center justify-center text-white font-bold shadow-[0_0_15px_rgba(124,58,237,0.5)]">
            K
          </div>
          {sidebarOpen && (
            <div className="animate-in fade-in duration-500">
              <h1 className="text-lg font-bold tracking-tight text-[#E5E7EB]">KNOUX SPECTRE</h1>
              <p className="text-[10px] text-[#7C3AED] font-bold tracking-[0.2em]">SYSTEMS TOOLBOX</p>
            </div>
          )}
        </div>

        <nav className="flex-1 overflow-y-auto px-4 space-y-1 py-4 scrollbar-hide">
          {Object.entries(
            MODULES.reduce((acc, m) => {
              (acc[m.category] = acc[m.category] || []).push(m);
              return acc;
            }, {} as Record<string, typeof MODULES>)
          ).map(([category, items]) => (
            <div key={category} className="mb-6">
              {sidebarOpen && (
                <p className="px-3 text-[10px] font-bold text-[#6B7280] uppercase tracking-widest mb-2">
                  {category}
                </p>
              )}
              {items.map((module) => (
                <button
                  key={module.id}
                  onClick={() => setActiveModule(module.id)}
                  className={`w-full flex items-center gap-3 px-3 py-2 rounded-lg transition-all group ${
                    activeModule === module.id 
                    ? 'bg-[#1F2937] text-[#7C3AED] shadow-sm border border-[#7C3AED]/20' 
                    : 'text-[#9CA3AF] hover:bg-[#1F2937] hover:text-[#E5E7EB]'
                  }`}
                >
                  <div className={`${activeModule === module.id ? 'text-[#7C3AED]' : 'text-[#6B7280] group-hover:text-[#7C3AED]'} transition-colors`}>
                    {getIcon(module.icon, "w-5 h-5")}
                  </div>
                  {sidebarOpen && <span className="text-sm font-medium">{module.label}</span>}
                  {activeModule === module.id && sidebarOpen && (
                    <div className="ml-auto w-1 h-1 rounded-full bg-[#7C3AED] neon-glow"></div>
                  )}
                </button>
              ))}
            </div>
          ))}
        </nav>

        <div className="p-4 border-t border-[#1F2937]">
          <button 
            onClick={() => setSidebarOpen(!sidebarOpen)}
            className="w-full flex items-center justify-center p-2 rounded-lg text-[#6B7280] hover:bg-[#1F2937] hover:text-[#7C3AED] transition-all"
          >
            {sidebarOpen ? <X size={20} /> : <Menu size={20} />}
          </button>
        </div>
      </aside>

      {/* Main Content */}
      <main className="flex-1 flex flex-col overflow-hidden">
        {/* Header */}
        <header className="h-16 bg-[#111827] border-b border-[#1F2937] flex items-center justify-between px-8 z-10">
          <div className="flex items-center gap-4 text-[#9CA3AF]">
            <div className="hidden md:flex items-center bg-[#0E1117] border border-[#1F2937] px-3 py-1.5 rounded-lg w-64 group focus-within:border-[#7C3AED]/50 transition-colors">
              <Search size={16} className="group-focus-within:text-[#7C3AED]" />
              <input 
                type="text" 
                placeholder="Search modules..." 
                className="bg-transparent border-none text-xs ml-2 w-full focus:outline-none focus:ring-0 text-[#E5E7EB] placeholder-[#4B5563]"
              />
            </div>
            <div className="flex gap-2 text-[10px] font-mono">
              <span className="px-2 py-0.5 rounded bg-[#0E1117] border border-[#1F2937] text-[#6B7280]">v1.0.4-stable</span>
              <span className="px-2 py-0.5 rounded bg-[#0E1117] border border-[#1F2937] flex items-center gap-1 text-[#22C55E]">
                <ShieldCheck size={10} /> SECURE
              </span>
            </div>
          </div>

          <div className="flex items-center gap-4">
            <button className="relative p-2 text-[#9CA3AF] hover:text-[#E5E7EB] transition-colors group">
              <Bell size={20} />
              <span className="absolute top-2 right-2 w-2 h-2 bg-[#EF4444] rounded-full border-2 border-[#111827]"></span>
            </button>
            <div className="h-8 w-px bg-[#1F2937]"></div>
            <div className="flex items-center gap-3 pl-2">
              <div className="text-right hidden sm:block">
                <p className="text-sm font-bold leading-none text-[#E5E7EB]">ADMINISTRATOR</p>
                <p className="text-[10px] text-[#22C55E] mt-1 flex items-center justify-end gap-1 font-bold">
                  <span className="w-1.5 h-1.5 rounded-full bg-[#22C55E] animate-pulse"></span> ONLINE
                </p>
              </div>
              <div className="w-10 h-10 rounded-full bg-[#1F2937] border border-[#1F2937] hover:border-[#7C3AED]/50 transition-colors flex items-center justify-center overflow-hidden cursor-pointer group">
                <User size={20} className="text-[#9CA3AF] group-hover:text-[#E5E7EB] transition-colors" />
              </div>
            </div>
          </div>
        </header>

        {/* Content Area */}
        <div className="flex-1 overflow-y-auto p-8 bg-[#0E1117]">
          <div className="max-w-6xl mx-auto space-y-8 animate-in fade-in duration-700">
            {/* Breadcrumb */}
            <div className="flex items-center gap-2 text-[10px] text-[#6B7280] uppercase tracking-widest font-bold">
              <LayoutGrid size={12} />
              <span className="hover:text-[#9CA3AF] cursor-pointer transition-colors">DASHBOARD</span>
              <ChevronRight size={12} />
              <span className="text-[#7C3AED]">{MODULES.find(m => m.id === activeModule)?.label.toUpperCase()}</span>
            </div>

            {/* Dynamic View */}
            {renderModule()}

            {/* Bottom Status Bar */}
            <footer className="mt-12 pt-8 border-t border-[#1F2937] flex flex-wrap justify-between items-center gap-4">
              <div className="flex gap-6">
                <div className="flex items-center gap-2">
                  <Globe size={14} className="text-[#6B7280]" />
                  <span className="text-[11px] text-[#9CA3AF] font-mono">IP: 192.168.1.104</span>
                </div>
                <div className="flex items-center gap-2">
                  <Zap size={14} className="text-[#F59E0B]" />
                  <span className="text-[11px] text-[#9CA3AF] font-mono">LATENCY: 14MS</span>
                </div>
              </div>
              <div className="flex gap-6">
                <a href="#" className="text-[11px] text-[#6B7280] hover:text-[#7C3AED] flex items-center gap-1 transition-colors font-medium">
                  DOCUMENTATION <ExternalLink size={12} />
                </a>
                <span className="text-[11px] text-[#4B5563] font-mono">© 2024 KNOUX SYSTEMS. PROPRIETARY.</span>
              </div>
            </footer>
          </div>
        </div>
      </main>
    </div>
  );
};

export default App;
