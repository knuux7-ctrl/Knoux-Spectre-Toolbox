import React, { useState } from 'react';
import { Loader2, Play, AlertCircle, CheckCircle2 } from 'lucide-react';

interface ModuleResult {
  success: boolean;
  error?: string;
  [key: string]: any;
}

export const ModuleContainer: React.FC<{ moduleName: string; endpoint: string }> = ({ moduleName, endpoint }) => {
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<ModuleResult | null>(null);
  const [error, setError] = useState('');

  const executeModule = async () => {
    setLoading(true);
    setError('');
    try {
      const domain = process.env.REPL_OWNER ? `https://${process.env.REPL_SLUG}.${process.env.REPL_OWNER}.repl.co` : 'http://localhost:3001';
      const response = await fetch(`${domain}/api${endpoint}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
      });
      const data = await response.json();
      setResult(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Module execution failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="glass p-6 rounded-xl space-y-4">
      <button
        onClick={executeModule}
        disabled={loading}
        className="w-full py-2 px-4 bg-[#7C3AED] hover:bg-[#A855F7] disabled:opacity-50 text-white font-semibold rounded-lg flex items-center justify-center gap-2 transition-all"
      >
        {loading ? <Loader2 className="animate-spin" size={18} /> : <Play size={18} />}
        {loading ? 'Executing...' : 'Execute'}
      </button>

      {error && (
        <div className="flex gap-2 p-3 bg-[#EF4444]/20 border border-[#EF4444]/50 rounded-lg text-[#EF4444]">
          <AlertCircle size={18} />
          <span className="text-sm">{error}</span>
        </div>
      )}

      {result && (
        <div className="space-y-2">
          <div className="flex gap-2 p-3 bg-[#22C55E]/20 border border-[#22C55E]/50 rounded-lg text-[#22C55E]">
            <CheckCircle2 size={18} />
            <span className="text-sm font-semibold">{result.success ? 'Success' : 'Failed'}</span>
          </div>
          <pre className="bg-[#111827] p-4 rounded-lg text-[#E5E7EB] text-xs overflow-auto max-h-[300px]">
            {JSON.stringify(result, null, 2)}
          </pre>
        </div>
      )}
    </div>
  );
};
