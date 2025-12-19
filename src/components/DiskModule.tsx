import React, { useState } from 'react';
import { Loader2, HardDrive } from 'lucide-react';

export const DiskModule: React.FC = () => {
  const [loading, setLoading] = useState(false);
  const [volumes, setVolumes] = useState<any[]>([]);

  const fetchDiskUsage = async () => {
    setLoading(true);
    try {
      const domain = process.env.REPL_OWNER ? `https://${process.env.REPL_SLUG}.${process.env.REPL_OWNER}.repl.co` : 'http://localhost:3001';
      const response = await fetch(`${domain}/api/modules/disk/usage`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' }
      });
      const data = await response.json();
      setVolumes(data.volumes || []);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-6">
      <div className="glass p-6 rounded-xl border-l-4 border-l-[#F59E0B]">
        <h2 className="text-2xl font-bold mb-2 flex items-center gap-2">
          <HardDrive className="text-[#F59E0B]" /> Disk Analyzer
        </h2>
        <p className="text-[#9CA3AF] text-sm">View disk usage across all volumes.</p>
      </div>

      <button
        onClick={fetchDiskUsage}
        disabled={loading}
        className="w-full py-3 px-6 bg-[#F59E0B] hover:bg-[#FCD34D] disabled:opacity-50 text-black font-bold rounded-lg flex items-center justify-center gap-2 transition-all"
      >
        {loading ? <Loader2 className="animate-spin" size={18} /> : <HardDrive size={18} />}
        {loading ? 'Fetching Volumes...' : 'Analyze Disk Usage'}
      </button>

      {volumes.length > 0 && (
        <div className="glass p-6 rounded-xl">
          <h3 className="text-lg font-semibold mb-4 text-[#F59E0B]">Volume Information</h3>
          <div className="space-y-4">
            {volumes.map((vol, idx) => (
              <div key={idx} className="p-4 bg-[#111827] rounded border border-[#1F2937]">
                <div className="flex justify-between items-center mb-2">
                  <p className="font-mono font-bold text-[#E5E7EB]">{vol.Drive}:</p>
                  <p className="text-[#F59E0B] font-semibold">{vol.Size_GB} GB</p>
                </div>
                <div className="w-full bg-[#1F2937] rounded-full h-2 overflow-hidden">
                  <div
                    className="h-full bg-gradient-to-r from-[#F59E0B] to-[#EF4444]"
                    style={{ width: `${(vol.Used_GB / vol.Size_GB) * 100}%` }}
                  />
                </div>
                <div className="flex justify-between mt-2 text-xs text-[#9CA3AF]">
                  <span>Used: {vol.Used_GB} GB</span>
                  <span>Free: {vol.Free_GB} GB</span>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
};
