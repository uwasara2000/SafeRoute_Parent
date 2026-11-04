import { useState } from 'react';
import {
  Search,
  Calendar,
  SlidersHorizontal,
  Download,
  MoreHorizontal,
  X,
  ShieldCheck,
} from 'lucide-react';
import { cn } from '@/utils/cn';

interface AuditLogRecord {
  id: string;
  timestamp: string;
  staffMember: string;
  action: string;
  resource: 'Trip' | 'Student' | 'Notification' | 'Attendance' | 'Payment' | 'Security';
  reference: string;
  result: 'Success' | 'Failed';
  ipAddress?: string;
  details?: string;
}

const initialAuditLogs: AuditLogRecord[] = [
  {
    id: 'a-1',
    timestamp: 'Today, 08:42',
    staffMember: 'Dinuka Silva',
    action: 'Driver changed',
    resource: 'Trip',
    reference: 'TR-1052',
    result: 'Success',
    ipAddress: '192.168.1.104',
    details: 'Reassigned route driver from Unassigned to M. Perera due to morning shift swap.',
  },
  {
    id: 'a-2',
    timestamp: 'Today, 08:31',
    staffMember: 'Ayesha Perera',
    action: 'Parent linked',
    resource: 'Student',
    reference: 'ST-2042',
    result: 'Success',
    ipAddress: '192.168.1.115',
    details: 'Verified birth certificate and linked guardian M. Ramanathan to student Nethum R.',
  },
  {
    id: 'a-3',
    timestamp: 'Today, 08:16',
    staffMember: 'System',
    action: 'Sync retried',
    resource: 'Notification',
    reference: 'NT-8210',
    result: 'Failed',
    ipAddress: 'Internal Worker Daemon',
    details: 'FCM push token expired for recipient device +9477***229. Queued for SMS fallback.',
  },
  {
    id: 'a-4',
    timestamp: 'Yesterday, 17:42',
    staffMember: 'Kasun Fernando',
    action: 'Status corrected',
    resource: 'Attendance',
    reference: 'AT-6502',
    result: 'Success',
    ipAddress: '192.168.1.108',
    details: 'Corrected false absence mark for student Yasara F. after bus attendant manual re-verification.',
  },
];

type TabType = 'All activity' | 'Assignments' | 'Security' | 'Finance' | 'Failures';

export default function AuditLogsPage() {
  const [activeTab, setActiveTab] = useState<TabType>('All activity');
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedLogs, setSelectedLogs] = useState<string[]>([]);
  const [logsList] = useState<AuditLogRecord[]>(initialAuditLogs);
  const [activeLogDetails, setActiveLogDetails] = useState<AuditLogRecord | null>(null);

  // Filtering
  const filteredLogs = logsList.filter((item) => {
    // Tab filter
    if (activeTab === 'Assignments' && item.resource !== 'Trip' && item.resource !== 'Student') return false;
    if (activeTab === 'Security' && item.resource !== 'Security') return false;
    if (activeTab === 'Finance' && item.resource !== 'Payment') return false;
    if (activeTab === 'Failures' && item.result !== 'Failed') return false;

    // Search filter
    const q = searchQuery.toLowerCase();
    return (
      item.staffMember.toLowerCase().includes(q) ||
      item.action.toLowerCase().includes(q) ||
      item.resource.toLowerCase().includes(q) ||
      item.reference.toLowerCase().includes(q) ||
      item.result.toLowerCase().includes(q)
    );
  });

  const handleSelectAll = (checked: boolean) => {
    if (checked) {
      setSelectedLogs(filteredLogs.map((l) => l.id));
    } else {
      setSelectedLogs([]);
    }
  };

  const handleToggleSelect = (id: string) => {
    setSelectedLogs((prev) =>
      prev.includes(id) ? prev.filter((l) => l !== id) : [...prev, id]
    );
  };

  return (
    <div className="w-full p-8 space-y-6 max-w-[1600px] mx-auto overflow-x-hidden">
      {/* 1. Page Header */}
      <div>
        <span className="text-[11px] font-bold tracking-wider text-[#3B5DF0] uppercase">
          TRANSPORT OPERATIONS
        </span>
        <h1 className="text-2xl md:text-3xl font-extrabold text-slate-900 mt-1 tracking-tight">
          Audit Logs
        </h1>
        <p className="text-slate-500 text-xs md:text-sm mt-1">
          Review protected records of sensitive platform changes.
        </p>
      </div>

      {/* 2. Main White Card Container */}
      <div className="bg-white border border-slate-200/80 rounded-2xl p-6 shadow-xs space-y-6">
        {/* Navigation Tabs */}
        <div className="flex items-center gap-8 border-b border-slate-100 text-xs font-semibold text-slate-500 pb-0 overflow-x-auto">
          {(['All activity', 'Assignments', 'Security', 'Finance', 'Failures'] as TabType[]).map(
            (tab) => {
              const isActive = activeTab === tab;
              return (
                <button
                  key={tab}
                  type="button"
                  onClick={() => setActiveTab(tab)}
                  className={cn(
                    'pb-3.5 transition-all relative cursor-pointer whitespace-nowrap',
                    isActive
                      ? 'text-[#3B5DF0] font-bold'
                      : 'text-slate-500 hover:text-slate-800'
                  )}
                >
                  <span>{tab}</span>
                  {isActive && (
                    <span className="absolute bottom-0 left-0 right-0 h-0.5 bg-[#3B5DF0] rounded-full" />
                  )}
                </button>
              );
            }
          )}
        </div>

        {/* Search & Actions Bar */}
        <div className="flex flex-col sm:flex-row items-center justify-between gap-4">
          {/* Search box */}
          <div className="relative w-full sm:w-80">
            <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search audit logs..."
              className="w-full pl-9 pr-4 py-2 text-xs bg-white border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 placeholder:text-slate-400 text-slate-700 shadow-2xs transition-all"
            />
          </div>

          {/* Action buttons on right */}
          <div className="flex items-center gap-2.5 w-full sm:w-auto self-end sm:self-auto">
            <button
              type="button"
              className="inline-flex items-center gap-1.5 px-3 py-2 rounded-xl border border-slate-200 bg-white hover:bg-slate-50 text-xs font-semibold text-slate-700 shadow-2xs transition-colors cursor-pointer"
            >
              <Calendar className="w-3.5 h-3.5 text-slate-400" />
              <span>Date range</span>
            </button>

            <button
              type="button"
              className="inline-flex items-center gap-1.5 px-3 py-2 rounded-xl border border-slate-200 bg-white hover:bg-slate-50 text-xs font-semibold text-slate-700 shadow-2xs transition-colors cursor-pointer"
            >
              <SlidersHorizontal className="w-3.5 h-3.5 text-slate-400" />
              <span>Filters</span>
              <span className="w-4 h-4 rounded-full bg-slate-100 text-slate-600 text-[10px] font-bold flex items-center justify-center">
                2
              </span>
            </button>

            <button
              type="button"
              className="inline-flex items-center gap-1.5 px-3 py-2 rounded-xl border border-slate-200 bg-white hover:bg-slate-50 text-xs font-semibold text-slate-700 shadow-2xs transition-colors cursor-pointer"
            >
              <Download className="w-3.5 h-3.5 text-slate-400" />
              <span>Export</span>
            </button>
          </div>
        </div>

        {/* 3. Data Table */}
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs border-collapse">
            <thead>
              <tr className="border-b border-slate-100 text-[11px] font-bold text-slate-400 uppercase tracking-wider">
                <th className="py-3 px-3 w-10">
                  <input
                    type="checkbox"
                    checked={
                      filteredLogs.length > 0 &&
                      selectedLogs.length === filteredLogs.length
                    }
                    onChange={(e) => handleSelectAll(e.target.checked)}
                    className="w-4 h-4 rounded border-slate-300 text-[#3B5DF0] focus:ring-blue-500 cursor-pointer"
                  />
                </th>
                <th className="py-3 px-4 font-bold">TIMESTAMP</th>
                <th className="py-3 px-4 font-bold">STAFF MEMBER</th>
                <th className="py-3 px-4 font-bold">ACTION</th>
                <th className="py-3 px-4 font-bold">RESOURCE</th>
                <th className="py-3 px-4 font-bold">REFERENCE</th>
                <th className="py-3 px-4 font-bold">RESULT</th>
                <th className="py-3 px-4 w-12 text-right"></th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 text-slate-700">
              {filteredLogs.map((item) => (
                <tr
                  key={item.id}
                  className="hover:bg-slate-50/70 transition-colors group cursor-pointer"
                  onClick={() => setActiveLogDetails(item)}
                >
                  <td className="py-3 px-3" onClick={(e) => e.stopPropagation()}>
                    <input
                      type="checkbox"
                      checked={selectedLogs.includes(item.id)}
                      onChange={() => handleToggleSelect(item.id)}
                      className="w-4 h-4 rounded border-slate-300 text-[#3B5DF0] focus:ring-blue-500 cursor-pointer"
                    />
                  </td>
                  <td className="py-3 px-4 text-slate-500 font-medium whitespace-nowrap">
                    {item.timestamp}
                  </td>
                  <td className="py-3 px-4 font-medium text-slate-800">
                    {item.staffMember}
                  </td>
                  <td className="py-3 px-4 font-medium text-slate-700">
                    {item.action}
                  </td>
                  <td className="py-3 px-4 text-slate-600 font-medium">
                    {item.resource}
                  </td>
                  <td className="py-3 px-4 font-mono font-bold text-slate-900">
                    {item.reference}
                  </td>
                  <td className="py-3 px-4">
                    {item.result === 'Success' && (
                      <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-semibold bg-emerald-50 text-emerald-700 border border-emerald-200/60">
                        <span className="w-1.5 h-1.5 rounded-full bg-emerald-500" />
                        Success
                      </span>
                    )}
                    {item.result === 'Failed' && (
                      <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-semibold bg-rose-50 text-rose-700 border border-rose-200/60">
                        <span className="w-1.5 h-1.5 rounded-full bg-rose-500" />
                        Failed
                      </span>
                    )}
                  </td>
                  <td className="py-3 px-4 text-right" onClick={(e) => e.stopPropagation()}>
                    <button
                      type="button"
                      onClick={() => setActiveLogDetails(item)}
                      className="p-1 rounded-lg text-slate-400 hover:text-slate-600 hover:bg-slate-100 transition-colors cursor-pointer"
                    >
                      <MoreHorizontal className="w-4 h-4" />
                    </button>
                  </td>
                </tr>
              ))}

              {filteredLogs.length === 0 && (
                <tr>
                  <td colSpan={8} className="py-12 text-center text-slate-400">
                    No audit records found matching the filter criteria.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>

        {/* 4. Pagination Footer */}
        <div className="flex flex-col sm:flex-row items-center justify-between gap-4 pt-4 border-t border-slate-100 text-xs text-slate-500 font-medium">
          <span>Showing {filteredLogs.length} sample records</span>

          <div className="flex items-center gap-1">
            <button
              type="button"
              className="px-3 py-1.5 rounded-lg border border-slate-200 hover:bg-slate-50 disabled:opacity-50 text-slate-600 transition-colors cursor-pointer"
            >
              Previous
            </button>
            <button
              type="button"
              className="w-8 h-8 rounded-lg bg-[#3B5DF0] text-white font-bold flex items-center justify-center cursor-pointer shadow-xs"
            >
              1
            </button>
            <button
              type="button"
              className="px-3 py-1.5 rounded-lg border border-slate-200 hover:bg-slate-50 disabled:opacity-50 text-slate-600 transition-colors cursor-pointer"
            >
              Next
            </button>
          </div>
        </div>
      </div>

      {/* MODAL: Audit Entry Inspector */}
      {activeLogDetails && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/40 backdrop-blur-xs p-4">
          <div className="bg-white rounded-2xl max-w-md w-full p-6 shadow-xl border border-slate-100 space-y-4 animate-in fade-in-50 zoom-in-95 duration-150 text-xs">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div className="flex items-center gap-2">
                <div className="w-8 h-8 rounded-lg bg-blue-50 text-[#3B5DF0] flex items-center justify-center font-bold">
                  <ShieldCheck className="w-4 h-4" />
                </div>
                <div>
                  <h3 className="font-bold text-slate-900 text-base">
                    Audit Entry Details
                  </h3>
                  <span className="text-[10px] text-slate-400">
                    Ref: {activeLogDetails.reference}
                  </span>
                </div>
              </div>
              <button
                type="button"
                onClick={() => setActiveLogDetails(null)}
                className="text-slate-400 hover:text-slate-600 p-1 rounded-lg hover:bg-slate-100 transition-colors"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <div className="space-y-2.5">
              <div className="flex justify-between py-1 border-b border-slate-50">
                <span className="text-slate-400">Timestamp:</span>
                <span className="font-medium text-slate-700">{activeLogDetails.timestamp}</span>
              </div>
              <div className="flex justify-between py-1 border-b border-slate-50">
                <span className="text-slate-400">Actor / Member:</span>
                <span className="font-bold text-slate-800">{activeLogDetails.staffMember}</span>
              </div>
              <div className="flex justify-between py-1 border-b border-slate-50">
                <span className="text-slate-400">Action:</span>
                <span className="font-bold text-[#3B5DF0]">{activeLogDetails.action}</span>
              </div>
              <div className="flex justify-between py-1 border-b border-slate-50">
                <span className="text-slate-400">Target Resource:</span>
                <span className="font-medium text-slate-700">{activeLogDetails.resource} ({activeLogDetails.reference})</span>
              </div>
              <div className="flex justify-between py-1 border-b border-slate-50">
                <span className="text-slate-400">IP / Origin:</span>
                <span className="font-mono text-slate-600">{activeLogDetails.ipAddress}</span>
              </div>
              <div className="flex justify-between py-1 border-b border-slate-50">
                <span className="text-slate-400">Result:</span>
                <span className="font-bold text-slate-800">{activeLogDetails.result}</span>
              </div>
              <div className="pt-2">
                <span className="text-slate-400 block mb-1">State Mutation Log:</span>
                <p className="p-3 bg-slate-50 rounded-xl text-slate-700 border border-slate-100 text-[11px] leading-relaxed font-mono">
                  {activeLogDetails.details}
                </p>
              </div>
            </div>

            <div className="flex items-center justify-end pt-3 border-t border-slate-100">
              <button
                type="button"
                onClick={() => setActiveLogDetails(null)}
                className="px-4 py-2 bg-slate-900 text-white rounded-xl font-semibold hover:bg-slate-800 transition-colors"
              >
                Close
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

