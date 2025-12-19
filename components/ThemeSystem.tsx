
import React, { useState } from 'react';
import { Palette, Copy, Check, Terminal, ExternalLink, Type as TypeIcon } from 'lucide-react';
import { THEME } from '../constants';

const ANSI_COLORS = [
  { name: 'Purple (Primary)', hex: '#7C3AED', ansi: '\\u001b[38;2;124;58;237m', desc: 'Main accent color for borders and highlights' },
  { name: 'Purple Hover', hex: '#A855F7', ansi: '\\u001b[38;2;168;85;247m', desc: 'Interactive elements hover state' },
  { name: 'Success Green', hex: '#22C55E', ansi: '\\u001b[38;2;34;197;94m', desc: 'Operations success and system online status' },
  { name: 'Warning Orange', hex: '#F59E0B', ansi: '\\u001b[38;2;245;158;11m', desc: 'Non-critical system alerts' },
  { name: 'Error Red', hex: '#EF4444', ansi: '\\u001b[38;2;239;68;68m', desc: 'Critical errors and system failure' },
  { name: 'Text Primary', hex: '#E5E7EB', ansi: '\\u001b[38;2;229;231;235m', desc: 'Default primary text color' },
  { name: 'Text Secondary', hex: '#9CA3AF', ansi: '\\u001b[38;2;156;163;175m', desc: 'Secondary labels and descriptions' },
  { name: 'Background', hex: '#0E1117', ansi: '\\u001b[48;2;14;17;23m', desc: 'Main terminal background color' },
];

export const ThemeSystem: React.FC = () => {
  const [copiedAnsi, setCopiedAnsi] = useState<string | null>(null);

  const copyToClipboard = (text: string) => {
    navigator.clipboard.writeText(text);
    setCopiedAnsi(text);
    setTimeout(() => setCopiedAnsi(null), 2000);
  };

  return (
    <div className="space-y-8 animate-in fade-in slide-in-from-bottom duration-500">
      <div className="glass p-6 rounded-xl border-l-4 border-l-[#7C3AED]">
        <h2 className="text-2xl font-bold mb-2 flex items-center gap-2">
          <Palette className="text-[#7C3AED]" /> Theme Engine: DarkPremiumNeon
        </h2>
        <p className="text-[#9CA3AF] text-sm">
          Technical specifications for the Knoux Spectre visual identity. These values are synchronized with <code className="text-[#7C3AED] px-1">colors.psm1</code> for cross-platform consistency.
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        {ANSI_COLORS.map((color) => (
          <div key={color.name} className="glass p-4 rounded-xl flex flex-col group hover:border-[#7C3AED] transition-all">
            <div 
              className="w-full h-24 rounded-lg mb-4 shadow-inner relative overflow-hidden flex items-end p-2"
              style={{ backgroundColor: color.hex }}
            >
              <div className="absolute inset-0 bg-gradient-to-t from-black/40 to-transparent"></div>
              <span className="relative text-[10px] font-bold text-white uppercase tracking-tighter">{color.hex}</span>
            </div>
            <h3 className="font-bold text-sm mb-1">{color.name}</h3>
            <p className="text-[10px] text-[#4B5563] mb-4 flex-1">{color.desc}</p>
            
            <button 
              onClick={() => copyToClipboard(color.ansi)}
              className="mt-2 w-full flex items-center justify-between px-3 py-2 bg-[#0E1117] rounded-lg border border-[#1F2937] hover:border-[#7C3AED] transition-all group/btn"
            >
              <span className="text-[9px] mono text-[#6B7280] group-hover/btn:text-[#E5E7EB] truncate mr-2">
                {color.ansi}
              </span>
              {copiedAnsi === color.ansi ? (
                <Check size={12} className="text-[#22C55E]" />
              ) : (
                <Copy size={12} className="text-[#4B5563] group-hover/btn:text-[#7C3AED]" />
              )}
            </button>
          </div>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="glass p-6 rounded-xl">
          <h3 className="text-sm font-bold mb-4 flex items-center gap-2 uppercase tracking-widest text-[#7C3AED]">
            <TypeIcon size={16} /> Typography & Text Styles
          </h3>
          <div className="space-y-4 p-4 bg-[#0E1117] rounded-lg border border-[#1F2937]">
            <div className="flex items-center justify-between border-b border-[#1F2937] pb-2">
              <span className="text-sm font-bold">Bold Text</span>
              <span className="mono text-[10px] text-[#4B5563]">\u001b[1m</span>
            </div>
            <div className="flex items-center justify-between border-b border-[#1F2937] pb-2">
              <span className="text-sm opacity-50">Dimmed Text</span>
              <span className="mono text-[10px] text-[#4B5563]">\u001b[2m</span>
            </div>
            <div className="flex items-center justify-between border-b border-[#1F2937] pb-2 text-[#7C3AED] underline">
              <span className="text-sm font-medium">Underlined Primary</span>
              <span className="mono text-[10px] text-[#4B5563]">\u001b[4m</span>
            </div>
            <div className="flex items-center justify-between text-[#EF4444] line-through">
              <span className="text-sm">Error Highlight</span>
              <span className="mono text-[10px] text-[#4B5563]">\u001b[9m</span>
            </div>
          </div>
        </div>

        <div className="glass p-6 rounded-xl flex flex-col">
          <h3 className="text-sm font-bold mb-4 flex items-center gap-2 uppercase tracking-widest text-[#7C3AED]">
            <Terminal size={16} /> PS Integration Example
          </h3>
          <div className="flex-1 bg-[#0E1117] p-4 rounded-lg border border-[#1F2937] mono text-[11px] overflow-auto">
            <p className="text-[#6B7280]"># Import Knoux Spectre Colors</p>
            <p className="text-[#E5E7EB] mt-1">
              <span className="text-[#7C3AED]">$ANSI</span> = @{'{'}<br />
              &nbsp;&nbsp;PURPLE = <span className="text-[#F59E0B]">"`e[38;2;124;58;237m"</span><br />
              &nbsp;&nbsp;GREEN  = <span className="text-[#F59E0B]">"`e[38;2;34;197;94m"</span><br />
              &nbsp;&nbsp;RESET  = <span className="text-[#F59E0B]">"`e[0m"</span><br />
              {'}'}
            </p>
            <p className="text-[#E5E7EB] mt-4">
              <span className="text-[#22C55E]">Write-Host</span> <span className="text-[#F59E0B]">"$($ANSI.PURPLE)[KNOUX]$($ANSI.RESET) System Booting..."</span>
            </p>
          </div>
          <button className="mt-4 text-xs text-[#7C3AED] hover:text-[#A855F7] flex items-center gap-1 font-medium transition-colors">
            View full colors.psm1 source <ExternalLink size={12} />
          </button>
        </div>
      </div>
    </div>
  );
};
