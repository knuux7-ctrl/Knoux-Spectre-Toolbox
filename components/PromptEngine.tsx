
import React, { useState } from 'react';
import { geminiService } from '../services/gemini';
import { Terminal, Copy, Check, Loader2, Wand2 } from 'lucide-react';

export const PromptEngine: React.FC = () => {
  const [prompt, setPrompt] = useState('');
  const [language, setLanguage] = useState<'powershell' | 'python' | 'batch'>('powershell');
  const [output, setOutput] = useState('');
  const [loading, setLoading] = useState(false);
  const [copied, setCopied] = useState(false);

  const handleGenerate = async () => {
    if (!prompt.trim()) return;
    setLoading(true);
    try {
      const code = await geminiService.generateCode(prompt, language);
      setOutput(code || '');
    } catch (err) {
      setOutput('Failed to generate code. Please check your API key.');
    } finally {
      setLoading(false);
    }
  };

  const handleCopy = () => {
    navigator.clipboard.writeText(output);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="space-y-6">
      <div className="glass p-6 rounded-xl border-l-4 border-l-[#7C3AED] animate-in fade-in slide-in-from-left duration-500">
        <h2 className="text-2xl font-bold mb-2 flex items-center gap-2">
          <Wand2 className="text-[#7C3AED]" /> Prompt Engine
        </h2>
        <p className="text-[#9CA3AF] text-sm">Convert natural language requirements into professional-grade script scaffolds.</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div className="space-y-4 glass p-6 rounded-xl">
          <div>
            <label className="block text-sm font-medium mb-2 text-[#9CA3AF]">Target Language</label>
            <div className="flex gap-2">
              {(['powershell', 'python', 'batch'] as const).map((lang) => (
                <button
                  key={lang}
                  onClick={() => setLanguage(lang)}
                  className={`px-4 py-2 rounded-lg text-sm font-medium transition-all ${
                    language === lang 
                    ? 'bg-[#7C3AED] text-white shadow-[0_0_10px_rgba(124,58,237,0.4)]' 
                    : 'bg-[#1F2937] text-[#9CA3AF] hover:bg-[#374151]'
                  }`}
                >
                  {lang.charAt(0).toUpperCase() + lang.slice(1)}
                </button>
              ))}
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium mb-2 text-[#9CA3AF]">What should the script do?</label>
            <textarea
              value={prompt}
              onChange={(e) => setPrompt(e.target.value)}
              placeholder="e.g., Scan C: drive for large files and export to CSV"
              className="w-full h-32 bg-[#0E1117] border border-[#374151] rounded-lg p-3 focus:outline-none focus:ring-2 focus:ring-[#7C3AED] text-[#E5E7EB] placeholder-[#4B5563] resize-none"
            />
          </div>

          <button
            onClick={handleGenerate}
            disabled={loading || !prompt}
            className="w-full py-3 bg-[#7C3AED] hover:bg-[#A855F7] disabled:opacity-50 disabled:hover:bg-[#7C3AED] text-white font-bold rounded-lg flex items-center justify-center gap-2 transition-all shadow-[0_0_15px_rgba(124,58,237,0.2)]"
          >
            {loading ? <Loader2 className="animate-spin" /> : <Terminal size={18} />}
            {loading ? 'Thinking...' : 'Generate Code'}
          </button>
        </div>

        <div className="glass rounded-xl overflow-hidden flex flex-col min-h-[400px]">
          <div className="bg-[#1F2937] px-4 py-2 flex justify-between items-center border-b border-[#374151]">
            <span className="text-xs font-mono text-[#9CA3AF]">OUTPUT: {language.toUpperCase()}</span>
            {output && (
              <button onClick={handleCopy} className="text-[#9CA3AF] hover:text-white transition-colors">
                {copied ? <Check size={16} className="text-[#22C55E]" /> : <Copy size={16} />}
              </button>
            )}
          </div>
          <div className="flex-1 p-4 mono text-xs overflow-auto bg-[#0E1117]">
            {output ? (
              <pre className="text-[#E5E7EB] whitespace-pre-wrap">{output}</pre>
            ) : (
              <div className="h-full flex flex-col items-center justify-center text-[#4B5563] space-y-2">
                <Terminal size={48} className="opacity-20" />
                <p>Awaiting generation...</p>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};
