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
  Check,
} from 'lucide-react';
import { cn } from '@/utils/cn';

interface StudentRecord {
  id: string;
  name: string;
  reference: string;
  school: string;
  route: string;
  stop: string;
  status: 'On board' | 'Absent' | 'Dropped off' | 'Needs setup';
}

const initialStudents: StudentRecord[] = [
  {
    id: 'st1',
    name: 'Aanya S.',
    reference: 'ST-2084',
    school: 'Lakeland College',
    route: 'North Ridge',
    stop: 'Oak Junction',
    status: 'On board',
  },
  {
    id: 'st2',
    name: 'Kavindu P.',
    reference: 'ST-2071',
    school: 'Central Academy',
    route: 'Lakeside',
    stop: 'Lake Road',
    status: 'Absent',
  },
  {
    id: 'st3',
    name: 'Yasara F.',
    reference: 'ST-2065',
    school: 'Lakeland College',
    route: 'Hillview',
    stop: 'Temple Lane',
    status: 'Dropped off',
  },
  {
    id: 'st4',
    name: 'Nethum R.',
    reference: 'ST-2042',
    school: 'Central Academy',
    route: 'Unassigned',
    stop: '—',
    status: 'Needs setup',
  },
];

type TabType = 'All students' | 'Active' | 'On board' | 'Absent' | 'Needs setup';

export default function StudentsPage() {
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = useState<TabType>('All students');
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedStudents, setSelectedStudents] = useState<string[]>([]);
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);

  // Form State
  const [newName, setNewName] = useState('Amaya Silva');
  const [newReference, setNewReference] = useState('ST-2090');
  const [newSchool, setNewSchool] = useState('Royal College');
  const [newRoute, setNewRoute] = useState('North Ridge');
  const [newStop, setNewStop] = useState('Nawala Road stop');
  const [newStatus, setNewStatus] = useState<'On board' | 'Absent' | 'Dropped off' | 'Needs setup'>('On board');

  const [studentsList, setStudentsList] = useState<StudentRecord[]>(initialStudents);

  // Filtering
  const filteredStudents = studentsList.filter((student) => {
    // Tab filter
    if (activeTab === 'Active' && student.status === 'Needs setup') return false;
    if (activeTab === 'On board' && student.status !== 'On board') return false;
    if (activeTab === 'Absent' && student.status !== 'Absent') return false;
    if (activeTab === 'Needs setup' && student.status !== 'Needs setup') return false;

    // Search filter
    const q = searchQuery.toLowerCase();
    return (
      student.name.toLowerCase().includes(q) ||
      student.reference.toLowerCase().includes(q) ||
      student.school.toLowerCase().includes(q) ||
      student.route.toLowerCase().includes(q) ||
      student.stop.toLowerCase().includes(q)
    );
  });

  const handleSelectAll = (checked: boolean) => {
    if (checked) {
      setSelectedStudents(filteredStudents.map((s) => s.id));
    } else {
      setSelectedStudents([]);
    }
  };

  const handleToggleSelect = (id: string) => {
    setSelectedStudents((prev) =>
      prev.includes(id) ? prev.filter((item) => item !== id) : [...prev, id]
    );
  };

  const handleAddStudent = (e: React.FormEvent) => {
    e.preventDefault();
    const newRecord: StudentRecord = {
      id: `st_${Date.now()}`,
      name: newName,
      reference: newReference,
      school: newSchool,
      route: newRoute,
      stop: newStop,
      status: newStatus,
    };
    setStudentsList((prev) => [newRecord, ...prev]);
    setIsAddModalOpen(false);
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
            Students
          </h1>
          <p className="text-slate-500 text-xs md:text-sm mt-1">
            Manage protected student records and transport assignments.
          </p>
        </div>

        {/* Right CTA Button */}
        <button
          type="button"
          onClick={() => setIsAddModalOpen(true)}
          className="inline-flex items-center gap-2 bg-[#3B5DF0] hover:bg-[#2F4DCB] text-white text-xs font-semibold px-4 py-2.5 rounded-xl shadow-sm shadow-[#3B5DF0]/30 transition-all self-start md:self-auto cursor-pointer"
        >
          <Plus className="w-4 h-4" />
          <span>Add student</span>
        </button>
      </div>

      {/* 2. Main White Card Container */}
      <div className="bg-white border border-slate-200/80 rounded-2xl p-6 shadow-xs space-y-6">
        {/* Navigation Tabs */}
        <div className="flex items-center gap-8 border-b border-slate-100 text-xs font-semibold text-slate-500 pb-0">
          {(['All students', 'Active', 'On board', 'Absent', 'Needs setup'] as TabType[]).map(
            (tab) => {
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
              placeholder="Search students..."
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
                      filteredStudents.length > 0 &&
                      selectedStudents.length === filteredStudents.length
                    }
                    onChange={(e) => handleSelectAll(e.target.checked)}
                    className="w-4 h-4 rounded border-slate-300 text-[#3B5DF0] focus:ring-blue-500 cursor-pointer"
                  />
                </th>
                <th className="py-3 px-4 font-bold">STUDENT</th>
                <th className="py-3 px-4 font-bold">REFERENCE</th>
                <th className="py-3 px-4 font-bold">SCHOOL</th>
                <th className="py-3 px-4 font-bold">ROUTE</th>
                <th className="py-3 px-4 font-bold">STOP</th>
                <th className="py-3 px-4 font-bold">STATUS</th>
                <th className="py-3 px-4 w-12 text-right"></th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {filteredStudents.map((student) => {
                const isSelected = selectedStudents.includes(student.id);
                return (
                  <tr
                    key={student.id}
                    className={cn(
                      'hover:bg-slate-50/70 transition-colors group',
                      isSelected && 'bg-blue-50/30'
                    )}
                  >
                    <td className="py-3.5 px-3">
                      <input
                        type="checkbox"
                        checked={isSelected}
                        onChange={() => handleToggleSelect(student.id)}
                        className="w-4 h-4 rounded border-slate-300 text-[#3B5DF0] focus:ring-blue-500 cursor-pointer"
                      />
                    </td>
                    <td className="py-3.5 px-4 font-bold text-slate-900">
                      {student.name}
                    </td>
                    <td className="py-3.5 px-4 text-slate-500 font-mono text-[11px]">
                      {student.reference}
                    </td>
                    <td className="py-3.5 px-4 text-slate-600 font-medium">
                      {student.school}
                    </td>
                    <td className="py-3.5 px-4 text-slate-600 font-medium">
                      {student.route !== 'Unassigned' ? (
                        <button
                          type="button"
                          onClick={() => navigate('/routes')}
                          className="hover:text-[#3B5DF0] hover:underline transition-colors font-medium text-left"
                          title="View route"
                        >
                          {student.route}
                        </button>
                      ) : (
                        <span className="text-slate-400">Unassigned</span>
                      )}
                    </td>
                    <td className="py-3.5 px-4 text-slate-600 font-medium">
                      {student.stop}
                    </td>
                    <td className="py-3.5 px-4">
                      {student.status === 'On board' && (
                        <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-semibold bg-emerald-50 text-emerald-700 border border-emerald-200">
                          <span className="w-1.5 h-1.5 rounded-full bg-emerald-500" />
                          On board
                        </span>
                      )}
                      {student.status === 'Absent' && (
                        <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-semibold bg-slate-100 text-slate-600 border border-slate-200">
                          <span className="w-1.5 h-1.5 rounded-full bg-slate-400" />
                          Absent
                        </span>
                      )}
                      {student.status === 'Dropped off' && (
                        <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-semibold bg-slate-100 text-slate-600 border border-slate-200">
                          <span className="w-1.5 h-1.5 rounded-full bg-slate-400" />
                          Dropped off
                        </span>
                      )}
                      {student.status === 'Needs setup' && (
                        <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-semibold bg-slate-50 text-slate-500 border border-slate-200">
                          <span className="w-1.5 h-1.5 rounded-full bg-slate-400" />
                          Needs setup
                        </span>
                      )}
                    </td>
                    <td className="py-3.5 px-4 text-right">
                      <button
                        type="button"
                        onClick={() => navigate('/monitoring')}
                        className="p-1 rounded-lg text-slate-400 hover:text-slate-600 hover:bg-slate-100 transition-colors cursor-pointer"
                        title="Student Options"
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

        {/* 4. Table Pagination Footer */}
        <div className="flex flex-col sm:flex-row items-center justify-between gap-4 pt-4 border-t border-slate-100 text-xs text-slate-400">
          <span>Showing {filteredStudents.length} records</span>

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

      {/* 5. Add Student Modal */}
      {isAddModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-xs p-4">
          <div className="bg-white rounded-2xl shadow-xl border border-slate-200 w-full max-w-lg p-6 space-y-5 animate-in fade-in zoom-in-95 duration-150">
            <div className="flex items-center justify-between pb-3 border-b border-slate-100">
              <div>
                <h3 className="text-base font-extrabold text-slate-900">Add New Student</h3>
                <p className="text-xs text-slate-500 mt-0.5">
                  Register student record and transport stop assignment.
                </p>
              </div>
              <button
                type="button"
                onClick={() => setIsAddModalOpen(false)}
                className="p-1 rounded-lg text-slate-400 hover:text-slate-600 hover:bg-slate-100 transition-colors cursor-pointer"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleAddStudent} className="space-y-4 text-xs">
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-bold text-slate-700 mb-1">Student Name</label>
                  <input
                    type="text"
                    value={newName}
                    onChange={(e) => setNewName(e.target.value)}
                    required
                    placeholder="e.g. Amaya Silva"
                    className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 font-bold"
                  />
                </div>

                <div>
                  <label className="block font-bold text-slate-700 mb-1">Reference ID</label>
                  <input
                    type="text"
                    value={newReference}
                    onChange={(e) => setNewReference(e.target.value)}
                    required
                    placeholder="e.g. ST-2090"
                    className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 font-mono"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-bold text-slate-700 mb-1">School</label>
                  <select
                    value={newSchool}
                    onChange={(e) => setNewSchool(e.target.value)}
                    className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
                  >
                    <option value="Lakeland College">Lakeland College</option>
                    <option value="Central Academy">Central Academy</option>
                    <option value="Royal College">Royal College</option>
                  </select>
                </div>

                <div>
                  <label className="block font-bold text-slate-700 mb-1">Assigned Route</label>
                  <select
                    value={newRoute}
                    onChange={(e) => setNewRoute(e.target.value)}
                    className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
                  >
                    <option value="North Ridge">North Ridge</option>
                    <option value="Lakeside">Lakeside</option>
                    <option value="Hillview">Hillview</option>
                    <option value="Unassigned">Unassigned</option>
                  </select>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-bold text-slate-700 mb-1">Pickup / Drop Stop</label>
                  <input
                    type="text"
                    value={newStop}
                    onChange={(e) => setNewStop(e.target.value)}
                    required
                    placeholder="e.g. Nawala Road stop"
                    className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
                  />
                </div>

                <div>
                  <label className="block font-bold text-slate-700 mb-1">Status</label>
                  <select
                    value={newStatus}
                    onChange={(e) =>
                      setNewStatus(e.target.value as 'On board' | 'Absent' | 'Dropped off' | 'Needs setup')
                    }
                    className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
                  >
                    <option value="On board">On board</option>
                    <option value="Dropped off">Dropped off</option>
                    <option value="Absent">Absent</option>
                    <option value="Needs setup">Needs setup</option>
                  </select>
                </div>
              </div>

              <div className="pt-3 border-t border-slate-100 flex items-center justify-end gap-2.5">
                <button
                  type="button"
                  onClick={() => setIsAddModalOpen(false)}
                  className="px-4 py-2 rounded-xl border border-slate-200 text-slate-700 font-semibold hover:bg-slate-50 transition-colors cursor-pointer"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="inline-flex items-center gap-1.5 px-4 py-2 rounded-xl bg-[#3B5DF0] hover:bg-[#2F4DCB] text-white font-semibold shadow-xs transition-colors cursor-pointer"
                >
                  <Check className="w-4 h-4" />
                  <span>Save Student</span>
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
