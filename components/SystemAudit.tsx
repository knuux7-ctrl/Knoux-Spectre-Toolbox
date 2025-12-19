
import React, { useState, useEffect } from 'react';
import { 
  LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer,
  AreaChart, Area
} from 'recharts';
// Added Brain to the imports from lucide-react
import { Cpu, MemoryStick as Memory, Database, Activity, RefreshCw, Brain } from 'lucide-react';
import { geminiService } from '../services/gemini';

const generateMockData = () => {
  return Array.from({ length: 20 }, (_, i) => ({
    time: i,
    cpu: Math.floor(Math.random() * 40) + 10,
    memory: Math.floor(Math.random() * 20) + 60,
    disk: 45,
    network: Math.floor(Math.random() * 100)
  }));
};

export const SystemAudit: React.FC = () => {
  const [data, setData] = useState(generateMockData());
  const [insight, setInsight] = useState('Analyzing system health metrics...');
  const [loading, setLoading] = useState(false);

  const refreshAudit = async () => {
    setLoading(true);
    const newData = generateMockData();
    setData(newData);
    
    const lastMetrics = newData[newData.length - 1];
    const status = `CPU: ${lastMetrics.cpu}%, RAM: ${lastMetrics.memory}%, Disk: ${lastMetrics.disk}%, Net: ${lastMetrics.network}Mbps`;
    
    const text = await geminiService.auditSystem(status);
    setInsight(text || "No insights available.");
    setLoading(false);
  };

  useEffect(() => {
    refreshAudit();
  }, []);

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div className="glass p-4 rounded-xl border-l-4 border-l-[#22C55E] flex-1 mr-4">
          <h2 className="text-xl font-bold flex items-center gap-2">
            <Activity className="text-[#22C55E]" /> Live System Audit
          </h2>
          <p className="text-xs text-[#9CA3AF]">Real-time hardware telemetry and AI diagnostics</p>
        </div>
        <button 
          onClick={refreshAudit}
          disabled={loading}
          className="p-4 glass hover:bg-[#1F2937] rounded-xl transition-all border-[#374151]"
        >
          <RefreshCw className={`${loading ? 'animate-spin' : ''} text-[#7C3AED]`} />
        </button>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2 glass p-6 rounded-xl min-h-[400px]">
          <h3 className="text-sm font-medium text-[#9CA3AF] mb-6 uppercase tracking-wider">Performance Metrics</h3>
          <div className="h-[300px]">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={data}>
                <defs>
                  <linearGradient id="colorCpu" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#7C3AED" stopOpacity={0.3}/>
                    <stop offset="95%" stopColor="#7C3AED" stopOpacity={0}/>
                  </linearGradient>
                  <linearGradient id="colorMem" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#22C55E" stopOpacity={0.3}/>
                    <stop offset="95%" stopColor="#22C55E" stopOpacity={0}/>
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" stroke="#1F2937" vertical={false} />
                <XAxis dataKey="time" hide />
                <YAxis stroke="#4B5563" fontSize={12} tickLine={false} axisLine={false} />
                <Tooltip 
                  contentStyle={{ backgroundColor: '#111827', border: '1px solid #374151', borderRadius: '8px' }}
                  itemStyle={{ fontSize: '12px' }}
                />
                <Area type="monotone" dataKey="cpu" stroke="#7C3AED" fillOpacity={1} fill="url(#colorCpu)" name="CPU Load (%)" />
                <Area type="monotone" dataKey="memory" stroke="#22C55E" fillOpacity={1} fill="url(#colorMem)" name="Memory (%)" />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </div>

        <div className="space-y-4">
          <div className="glass p-6 rounded-xl">
            <h3 className="text-sm font-medium text-[#7C3AED] mb-4 flex items-center gap-2">
              <Brain size={16} /> AI INSIGHT
            </h3>
            <p className="text-sm text-[#E5E7EB] leading-relaxed italic">
              "{insight}"
            </p>
          </div>

          <div className="grid grid-cols-1 gap-4">
            <MetricCard icon={<Cpu size={20} />} label="Processor" value={`${data[data.length-1].cpu}%`} subValue="Peak: 88%" color="#7C3AED" />
            <MetricCard icon={<Memory size={20} />} label="Memory" value={`${data[data.length-1].memory}%`} subValue="12.4 GB / 16 GB" color="#22C55E" />
            <MetricCard icon={<Database size={20} />} label="Disk I/O" value={`${data[data.length-1].disk}%`} subValue="SSD Health: 99%" color="#F59E0B" />
          </div>
        </div>
      </div>
    </div>
  );
};

const MetricCard: React.FC<{ icon: React.ReactNode, label: string, value: string, subValue: string, color: string }> = ({
  icon, label, value, subValue, color
}) => (
  <div className="glass p-4 rounded-xl flex items-center justify-between group hover:border-opacity-50 transition-all">
    <div className="flex items-center gap-3">
      <div className="p-2 rounded-lg bg-opacity-10" style={{ backgroundColor: color, color: color }}>
        {icon}
      </div>
      <div>
        <p className="text-xs text-[#9CA3AF]">{label}</p>
        <p className="text-lg font-bold">{value}</p>
      </div>
    </div>
    <p className="text-[10px] text-[#4B5563] text-right">{subValue}</p>
  </div>
);
