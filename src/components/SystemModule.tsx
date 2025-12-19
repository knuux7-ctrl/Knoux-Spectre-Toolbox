import React, { useState } from 'react';
import { Loader2, Play } from 'lucide-react';

export const SystemModule: React.FC = () => {
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<any>(null);

  const fetchServices = async () => {
    setLoading(true);
    try {
      const domain = process.env.REPL_OWNER ? `https://${process.env.REPL_SLUG}.${process.env.REPL_OWNER}.repl.co` : 'http://localhost:3001';
      const response = await fetch(`${domain}/api/modules/system/running-services`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' }
      });
      const data = await response.json();
      setResult(data);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-6">
      <div className="glass p-6 rounded-xl border-l-4 border-l-[#7C3AED]">
        <h2 className="text-2xl font-bold mb-2 flex items-center gap-2">
          <Play className="text-[#7C3AED]" /> System Control
        </h2>
        <p className="text-[#9CA3AF] text-sm">Monitor and control system services in real-time.</p>
      </div>

      <button
        onClick={fetchServices}
        disabled={loading}
        className="w-full py-3 px-6 bg-[#7C3AED] hover:bg-[#A855F7] disabled:opacity-50 text-white font-bold rounded-lg flex items-center justify-center gap-2 transition-all"
      >
        {loading ? <Loader2 className="animate-spin" size={18} /> : <Play size={18} />}
        {loading ? 'Fetching Services...' : 'Get Running Services'}
      </button>

      {result && (
        <div className="glass p-6 rounded-xl">
          <h3 className="text-lg font-semibold mb-4 text-[#7C3AED]">Running Services</h3>
          <div className="space-y-2 max-h-[400px] overflow-auto">
            {result.services?.map((service: any, idx: number) => (
              <div key={idx} className="flex items-center justify-between p-2 bg-[#111827] rounded border border-[#1F2937]">
                <div>
                  <p className="font-mono text-sm text-[#E5E7EB]">{service.Name}</p>
                  <p className="text-xs text-[#9CA3AF]">{service.DisplayName}</p>
                </div>
                <span className="px-2 py-1 bg-[#22C55E]/20 text-[#22C55E] text-xs font-semibold rounded">
                  {service.Status}
                </span>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
};
