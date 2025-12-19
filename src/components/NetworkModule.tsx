import React, { useState } from 'react';
import { Loader2, Network } from 'lucide-react';

export const NetworkModule: React.FC = () => {
  const [loading, setLoading] = useState(false);
  const [ports, setPorts] = useState<any[]>([]);

  const fetchOpenPorts = async () => {
    setLoading(true);
    try {
      const domain = process.env.REPL_OWNER ? `https://${process.env.REPL_SLUG}.${process.env.REPL_OWNER}.repl.co` : 'http://localhost:3001';
      const response = await fetch(`${domain}/api/modules/network/ports`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' }
      });
      const data = await response.json();
      setPorts(data.ports || []);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-6">
      <div className="glass p-6 rounded-xl border-l-4 border-l-[#22C55E]">
        <h2 className="text-2xl font-bold mb-2 flex items-center gap-2">
          <Network className="text-[#22C55E]" /> Network Tools
        </h2>
        <p className="text-[#9CA3AF] text-sm">Monitor open ports and network connections.</p>
      </div>

      <button
        onClick={fetchOpenPorts}
        disabled={loading}
        className="w-full py-3 px-6 bg-[#22C55E] hover:bg-[#4ADE80] disabled:opacity-50 text-black font-bold rounded-lg flex items-center justify-center gap-2 transition-all"
      >
        {loading ? <Loader2 className="animate-spin" size={18} /> : <Network size={18} />}
        {loading ? 'Scanning Ports...' : 'Scan Open Ports'}
      </button>

      {ports.length > 0 && (
        <div className="glass p-6 rounded-xl">
          <h3 className="text-lg font-semibold mb-4 text-[#22C55E]">Open Ports ({ports.length})</h3>
          <div className="space-y-2 max-h-[400px] overflow-auto">
            {ports.map((port, idx) => (
              <div key={idx} className="flex items-center justify-between p-3 bg-[#111827] rounded border border-[#1F2937]">
                <p className="font-mono text-[#E5E7EB] font-bold">:{port.LocalPort}</p>
                <p className="text-xs text-[#9CA3AF] bg-[#1F2937] px-2 py-1 rounded">{port.Process}</p>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
};
