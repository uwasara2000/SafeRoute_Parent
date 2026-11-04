import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Plus,
  Search,
  Calendar,
  SlidersHorizontal,
  Download,
  MoreHorizontal,
  X,
  AlertTriangle,
} from 'lucide-react';
import { cn } from '@/utils/cn';

interface AttendanceRecord {
  id: string;
  student: string;
  trip: string;
  boarded: string;
  dropOff: string;
  method: string;
  status: 'On board' | 'Absent' | 'Dropped off' | 'Unresolved';
}

const initialAttendance: AttendanceRecord[] = [
  {
    id: 'att1',
    student: 'Aanya S.',
    trip: 'TR-1042',
    boarded: '07:21',
    dropOff: '—',
    method: 'Staff verified',
    status: 'On board',
  },
  {
    id: 'att2',
    student: 'Kavindu P.',
    trip: 'TR-1041',
    boarded: '—',
    dropOff: '—',
    method: 'Parent report',
    status: 'Absent',
  },
  {
    id: 'att3',
    student: 'Yasara F.',
    trip: 'TR-1040',
    boarded: '06:58',
    dropOff: '07:42',
    method: 'Staff verified',
    status: 'Dropped off',
  },
  {
    id: 'att4',
    student: 'Dulani M.',
    trip: 'TR-1042',
    boarded: '—',
    dropOff: '—',
    method: 'No event',
    status: 'Unresolved',
  },
];

type TabType = 'Live attendance' | 'Absences' | 'Unresolved' | 'History';

export default function AssignmentsPage() {
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = useState<TabType>('Live attendance');
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedRecords, setSelectedRecords] = useState<string[]>([]);
  const [isExceptionModalOpen, setIsExceptionModalOpen] = useState(false);

  const [recordsList, setRecordsList] = useState<AttendanceRecord[]>(initialAttendance);

  // Filtering
  const filteredRecords = recordsList.filter((item) => {
    // Tab filter
    if (activeTab === 'Absences' && item.status !== 'Absent') return false;
    if (activeTab === 'Unresolved' && item.status !== 'Unresolved') return false;
    if (activeTab === 'History' && item.status !== 'Dropped off') return false;

    // Search filter
    const q = searchQuery.toLowerCase();
    return (
      item.student.toLowerCase().includes(q) ||
      item.trip.toLowerCase().includes(q) ||
      item.method.toLowerCase().includes(q) ||
      item.status.toLowerCase().includes(q)
    );
  });

  const handleSelectAll = (checked: boolean) => {
    if (checked) {
      setSelectedRecords(filteredRecords.map((r) => r.id));
    } else {
      setSelectedRecords([]);
    }
  };

  const handleToggleSelect = (id: string) => {
    setSelectedRecords((prev) =>
      prev.includes(id) ? prev.filter((item) => item !== id) : [...prev, id]
    );
  };

  const handleResolveException = (id: string, newStatus: 'On board' | 'Absent' | 'Dropped off') => {
    setRecordsList((prev) =>
      prev.map((r) => (r.id === id ? { ...r, status: newStatus, method: 'Operator verified' } : r))
    );
    setIsExceptionModalOpen(false);
  };

  return (
    <div className="w-full p-8 space-y-6 max-w-[1600px] mx-auto overflow-x-hidden">
      {/* 1. Page Header & Action Button */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 shrink-0">
        <div>
          <span className="text-[11px] font-bold tracking-wider text-[#3B5DF0] uppercase">
            TRANSPORT OPERATIONS
          </span>
          <h1 className="text-2xl md:text-3xl font-extrabold text-slate-900 mt-1 tracking-tight">
            Attendance & Absences
          </h1>
          <p className="text-slate-500 text-xs md:text-sm mt-1">
            Monitor boarding, drop-off and parent-reported absences.
          </p>
        </div>

        {/* Right CTA Button */}
        <button
          type="button"
          onClick={() => setIsExceptionModalOpen(true)}
          className="inline-flex items-center gap-2 bg-[#3B5DF0] hover:bg-[#2F4DCB] text-white text-xs font-semibold px-4 py-2.5 rounded-xl shadow-sm shadow-[#3B5DF0]/30 transition-all self-start md:self-auto cursor-pointer"
        >
          <Plus className="w-4 h-4" />
          <span>Review exceptions</span>
        </button>
      </div>

      {/* 2. Top Segmented KPI Summary Bar */}
      <div className="bg-white border border-slate-200/80 rounded-2xl p-4 shadow-xs">
        <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5 divide-y sm:divide-y-0 sm:divide-x divide-slate-100 text-center">
          <div className="p-3">
            <span className="text-xs font-medium text-slate-500">Expected</span>
            <p className="text-2xl font-extrabold text-slate-900 mt-1">322</p>
          </div>
          <div className="p-3">
            <span className="text-xs font-medium text-slate-500">Boarded</span>
            <p className="text-2xl font-extrabold text-slate-900 mt-1">286</p>
          </div>
          <div className="p-3">
            <span className="text-xs font-medium text-slate-500">Absent</span>
            <p className="text-2xl font-extrabold text-slate-900 mt-1">12</p>
          </div>
          <div className="p-3">
            <span className="text-xs font-medium text-slate-500">Dropped off</span>
            <p className="text-2xl font-extrabold text-slate-900 mt-1">119</p>
          </div>
          <div className="p-3">
            <span className="text-xs font-medium text-slate-500">Unresolved</span>
            <p className="text-2xl font-extrabold text-rose-600 mt-1">4</p>
          </div>
        </div>
      </div>

      {/* 3. Main Data Table Card */}
      <div className="bg-white border border-slate-200/80 rounded-2xl p-6 shadow-xs space-y-6">
        {/* Navigation Tabs */}
        <div className="flex items-center gap-8 border-b border-slate-100 text-xs font-semibold text-slate-500 pb-0">
          {(['Live attendance', 'Absences', 'Unresolved', 'History'] as TabType[]).map((tab) => {
            const isActive = activeTab === tab;
            return (
              <button
                key={tab}
                type="button"
                onClick={() => setActiveTab(tab)}
                className={cn(
                  'pb-3.5 transition-all relative cursor-pointer',
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
          })}
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
              placeholder="Search attendance & absences..."
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

        {/* 4. Data Table */}
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs border-collapse">
            <thead>
              <tr className="border-b border-slate-100 text-[11px] font-bold text-slate-400 uppercase tracking-wider">
                <th className="py-3 px-3 w-10">
                  <input
                    type="checkbox"
                    checked={
                      filteredRecords.length > 0 &&
                      selectedRecords.length === filteredRecords.length
                    }
                    onChange={(e) => handleSelectAll(e.target.checked)}
                    className="w-4 h-4 rounded border-slate-300 text-[#3B5DF0] focus:ring-blue-500 cursor-pointer"
                  />
                </th>
                <th className="py-3 px-4 font-bold">STUDENT</th>
                <th className="py-3 px-4 font-bold">TRIP</th>
                <th className="py-3 px-4 font-bold">BOARDED</th>
                <th className="py-3 px-4 font-bold">DROP-OFF</th>
                <th className="py-3 px-4 font-bold">METHOD</th>
                <th className="py-3 px-4 font-bold">STATUS</th>
                <th className="py-3 px-4 w-12 text-right"></th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {filteredRecords.map((item) => {
                const isSelected = selectedRecords.includes(item.id);
                return (
                  <tr
                    key={item.id}
                    className={cn(
                      'hover:bg-slate-50/70 transition-colors group',
                      isSelected && 'bg-blue-50/30'
                    )}
                  >
                    <td className="py-3.5 px-3">
                      <input
                        type="checkbox"
                        checked={isSelected}
                        onChange={() => handleToggleSelect(item.id)}
                        className="w-4 h-4 rounded border-slate-300 text-[#3B5DF0] focus:ring-blue-500 cursor-pointer"
                      />
                    </td>
                    <td className="py-3.5 px-4 font-bold text-slate-900">
                      {item.student}
                    </td>
                    <td className="py-3.5 px-4 font-bold text-slate-700">
                      <button
                        type="button"
                        onClick={() => navigate('/monitoring')}
                        className="hover:text-[#3B5DF0] hover:underline transition-colors text-left"
                        title="View trip on Live Map"
                      >
                        {item.trip}
                      </button>
                    </td>
                    <td className="py-3.5 px-4 text-slate-600 font-medium">
                      {item.boarded}
                    </td>
                    <td className="py-3.5 px-4 text-slate-600 font-medium">
                      {item.dropOff}
                    </td>
                    <td className="py-3.5 px-4 text-slate-600 font-medium">
                      {item.method}
                    </td>
                    <td className="py-3.5 px-4">
                      {item.status === 'On board' && (
                        <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-semibold bg-emerald-50 text-emerald-700 border border-emerald-200">
                          <span className="w-1.5 h-1.5 rounded-full bg-emerald-500" />
                          On board
                        </span>
                      )}
                      {item.status === 'Absent' && (
                        <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-semibold bg-slate-100 text-slate-600 border border-slate-200">
                          <span className="w-1.5 h-1.5 rounded-full bg-slate-400" />
                          Absent
                        </span>
                      )}
                      {item.status === 'Dropped off' && (
                        <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-semibold bg-slate-100 text-slate-600 border border-slate-200">
                          <span className="w-1.5 h-1.5 rounded-full bg-slate-400" />
                          Dropped off
                        </span>
                      )}
                      {item.status === 'Unresolved' && (
                        <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-semibold bg-rose-50 text-rose-700 border border-rose-200">
                          <span className="w-1.5 h-1.5 rounded-full bg-rose-500" />
                          Unresolved
                        </span>
                      )}
                    </td>
                    <td className="py-3.5 px-4 text-right">
                      <button
                        type="button"
                        onClick={() => setIsExceptionModalOpen(true)}
                        className="p-1 rounded-lg text-slate-400 hover:text-slate-600 hover:bg-slate-100 transition-colors cursor-pointer"
                        title="Attendance Options"
                      >
                        <MoreHorizontal className="w-4 h-4" />
                      </button>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>

        {/* 5. Table Pagination Footer */}
        <div className="flex flex-col sm:flex-row items-center justify-between gap-4 pt-4 border-t border-slate-100 text-xs text-slate-400">
          <span>Showing {filteredRecords.length} records</span>

          <div className="flex items-center gap-2">
            <button
              type="button"
              className="px-3 py-1.5 rounded-lg border border-slate-200 bg-white hover:bg-slate-50 text-slate-700 font-medium transition-colors cursor-pointer"
            >
              Previous
            </button>
            <button
              type="button"
              className="w-8 h-8 rounded-lg bg-[#3B5DF0] text-white font-bold text-xs flex items-center justify-center shadow-xs"
            >
              1
            </button>
            <button
              type="button"
              className="px-3 py-1.5 rounded-lg border border-slate-200 bg-white hover:bg-slate-50 text-slate-700 font-medium transition-colors cursor-pointer"
            >
              Next
            </button>
          </div>
        </div>
      </div>

      {/* 6. Review Exceptions Modal */}
      {isExceptionModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-xs p-4">
          <div className="bg-white rounded-2xl shadow-xl border border-slate-200 w-full max-w-lg p-6 space-y-5 animate-in fade-in zoom-in-95 duration-150">
            <div className="flex items-center justify-between pb-3 border-b border-slate-100">
              <div className="flex items-center gap-2.5">
                <div className="w-8 h-8 rounded-lg bg-rose-50 text-rose-600 flex items-center justify-center">
                  <AlertTriangle className="w-4 h-4" />
                </div>
                <div>
                  <h3 className="text-base font-extrabold text-slate-900">Review Attendance Exceptions</h3>
                  <p className="text-xs text-slate-500 mt-0.5">
                    Resolve unverified boarding or missing student events.
                  </p>
                </div>
              </div>
              <button
                type="button"
                onClick={() => setIsExceptionModalOpen(false)}
                className="p-1 rounded-lg text-slate-400 hover:text-slate-600 hover:bg-slate-100 transition-colors cursor-pointer"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <div className="space-y-3 text-xs">
              <div className="p-3.5 rounded-xl border border-rose-200 bg-rose-50/30 space-y-2">
                <div className="flex items-center justify-between">
                  <span className="font-bold text-slate-900">Dulani M.</span>
                  <span className="text-[10px] font-bold text-rose-600 uppercase bg-rose-100 px-2 py-0.5 rounded">
                    Unresolved Event
                  </span>
                </div>
                <p className="text-slate-500 text-[11px]">
                  Scheduled for <strong>TR-1042</strong> (North Ridge AM). No scan or parent absence was recorded at pickup stop.
                </p>
                <div className="pt-2 flex items-center gap-2">
                  <button
                    type="button"
                    onClick={() => handleResolveException('att4', 'Absent')}
                    className="px-3 py-1.5 rounded-lg border border-slate-200 bg-white hover:bg-slate-50 text-slate-700 font-semibold text-xs shadow-2xs transition-colors cursor-pointer"
                  >
                    Mark Absent
                  </button>
                  <button
                    type="button"
                    onClick={() => handleResolveException('att4', 'On board')}
                    className="px-3 py-1.5 rounded-lg bg-[#3B5DF0] hover:bg-[#2F4DCB] text-white font-semibold text-xs shadow-2xs transition-colors cursor-pointer"
                  >
                    Confirm On Board
                  </button>
                </div>
              </div>
            </div>

            <div className="pt-3 border-t border-slate-100 flex items-center justify-end">
              <button
                type="button"
                onClick={() => setIsExceptionModalOpen(false)}
                className="px-4 py-2 rounded-xl border border-slate-200 text-slate-700 font-semibold hover:bg-slate-50 transition-colors cursor-pointer"
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
