import { useState } from 'react';
import {
  Plus,
  Search,
  Calendar,
  SlidersHorizontal,
  Download,
  MoreHorizontal,
  X,
  ShieldAlert,
} from 'lucide-react';
import { Link } from 'react-router-dom';
import { cn } from '@/utils/cn';

interface IncidentRecord {
  id: string;
  reference: string;
  category: string;
  trip: string;
  reported: string;
  owner: string;
  status: 'Investigating' | 'Resolved' | 'Escalated' | 'Closed';
  severity?: 'High' | 'Medium' | 'Low' | 'Critical';
  notes?: string;
}

const initialIncidents: IncidentRecord[] = [
  {
    id: 'inc-1',
    reference: 'INC-029',
    category: 'Route disruption',
    trip: 'TR-1041',
    reported: '07:16',
    owner: 'Dispatch team',
    status: 'Investigating',
    severity: 'Medium',
    notes: 'Road construction near Baseline road detour.',
  },
  {
    id: 'inc-2',
    reference: 'INC-028',
    category: 'Medical concern',
    trip: 'TR-1032',
    reported: 'Yesterday',
    owner: 'S. Fernando',
    status: 'Resolved',
    severity: 'High',
    notes: 'Student mild motion sickness. Attendant notified parent.',
  },
  {
    id: 'inc-3',
    reference: 'SAFE-014',
    category: 'Unresolved student',
    trip: 'TR-1042',
    reported: '07:38',
    owner: 'Unassigned',
    status: 'Escalated',
    severity: 'Critical',
    notes: 'Student missing boarding confirmation at Oak Junction.',
  },
  {
    id: 'inc-4',
    reference: 'INC-026',
    category: 'Vehicle breakdown',
    trip: 'TR-1018',
    reported: '12 Jun',
    owner: 'A. Perera',
    status: 'Closed',
    severity: 'Medium',
    notes: 'Radiator overheat. Replacement bus dispatched within 12 mins.',
  },
];

type TabType = 'Active incidents' | 'Safety reconciliation' | 'Resolved' | 'All';

export default function EmergenciesPage() {
  const [activeTab, setActiveTab] = useState<TabType>('Active incidents');
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedIncidents, setSelectedIncidents] = useState<string[]>([]);
  const [incidentsList, setIncidentsList] = useState<IncidentRecord[]>(initialIncidents);

  // Modals state
  const [isCreateModalOpen, setIsCreateModalOpen] = useState(false);
  const [isReconciliationModalOpen, setIsReconciliationModalOpen] = useState(false);
  const [activeIncidentDetails, setActiveIncidentDetails] = useState<IncidentRecord | null>(null);

  // Create form state
  const [newReference, setNewReference] = useState('INC-030');
  const [newCategory, setNewCategory] = useState('Route disruption');
  const [newTrip, setNewTrip] = useState('TR-1042');
  const [newOwner, setNewOwner] = useState('Dispatch team');
  const [newStatus, setNewStatus] = useState<'Investigating' | 'Resolved' | 'Escalated' | 'Closed'>('Investigating');
  const [newSeverity, setNewSeverity] = useState<'Critical' | 'High' | 'Medium' | 'Low'>('Medium');
  const [newNotes, setNewNotes] = useState('');

  // Filtering
  const filteredIncidents = incidentsList.filter((item) => {
    // Tab filter
    if (activeTab === 'Active incidents' && (item.status === 'Resolved' || item.status === 'Closed')) return false;
    if (activeTab === 'Safety reconciliation' && item.category !== 'Unresolved student') return false;
    if (activeTab === 'Resolved' && item.status !== 'Resolved' && item.status !== 'Closed') return false;

    // Search filter
    const q = searchQuery.toLowerCase();
    return (
      item.reference.toLowerCase().includes(q) ||
      item.category.toLowerCase().includes(q) ||
      item.trip.toLowerCase().includes(q) ||
      item.owner.toLowerCase().includes(q) ||
      item.status.toLowerCase().includes(q)
    );
  });

  const handleSelectAll = (checked: boolean) => {
    if (checked) {
      setSelectedIncidents(filteredIncidents.map((i) => i.id));
    } else {
      setSelectedIncidents([]);
    }
  };

  const handleToggleSelect = (id: string) => {
    setSelectedIncidents((prev) =>
      prev.includes(id) ? prev.filter((i) => i !== id) : [...prev, id]
    );
  };

  const handleCreateIncident = (e: React.FormEvent) => {
    e.preventDefault();
    const newRecord: IncidentRecord = {
      id: `inc-${Date.now()}`,
      reference: newReference || `INC-${Math.floor(100 + Math.random() * 900)}`,
      category: newCategory,
      trip: newTrip,
      reported: 'Just now',
      owner: newOwner,
      status: newStatus,
      severity: newSeverity,
      notes: newNotes,
    };
    setIncidentsList((prev) => [newRecord, ...prev]);
    setIsCreateModalOpen(false);
    setNewReference(`INC-0${incidentsList.length + 31}`);
    setNewNotes('');
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
            Incidents & Safety
          </h1>
          <p className="text-slate-500 text-xs md:text-sm mt-1">
            Resolve safety exceptions with accountable, audited workflows.
          </p>
        </div>

        {/* Right CTA Button */}
        <button
          type="button"
          onClick={() => setIsCreateModalOpen(true)}
          className="inline-flex items-center gap-2 bg-[#3B5DF0] hover:bg-[#2F4DCB] text-white text-xs font-semibold px-4 py-2.5 rounded-xl shadow-sm shadow-[#3B5DF0]/30 transition-all self-start md:self-auto cursor-pointer"
        >
          <Plus className="w-4 h-4" />
          <span>Create incident</span>
        </button>
      </div>

      {/* 2. Safety Reconciliation Alert Banner */}
      <div className="bg-[#FEECEC] border border-[#FCD2D2] rounded-2xl p-4.5 flex flex-col sm:flex-row sm:items-center justify-between gap-4 shadow-2xs">
        <div className="flex items-center gap-3.5">
          <div className="w-9 h-9 rounded-xl bg-[#F04438] flex items-center justify-center text-white shrink-0 shadow-xs font-bold text-base">
            !
          </div>
          <div>
            <h2 className="text-sm font-bold text-slate-900">
              4 students require reconciliation
            </h2>
            <p className="text-xs text-slate-600 mt-0.5 font-medium">
              No student will be marked safe automatically. An authorized resolution and audit entry are required.
            </p>
          </div>
        </div>

        <button
          type="button"
          onClick={() => setIsReconciliationModalOpen(true)}
          className="bg-white border border-[#FCD2D2] text-[#B42318] hover:bg-rose-50 font-semibold px-4 py-2 rounded-xl text-xs transition-colors shadow-2xs self-start sm:self-auto cursor-pointer"
        >
          Review now
        </button>
      </div>

      {/* 3. Main White Card Container */}
      <div className="bg-white border border-slate-200/80 rounded-2xl p-6 shadow-xs space-y-6">
        {/* Navigation Tabs */}
        <div className="flex items-center gap-8 border-b border-slate-100 text-xs font-semibold text-slate-500 pb-0">
          {(['Active incidents', 'Safety reconciliation', 'Resolved', 'All'] as TabType[]).map(
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
              placeholder="Search incidents & safety..."
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
                      filteredIncidents.length > 0 &&
                      selectedIncidents.length === filteredIncidents.length
                    }
                    onChange={(e) => handleSelectAll(e.target.checked)}
                    className="w-4 h-4 rounded border-slate-300 text-[#3B5DF0] focus:ring-blue-500 cursor-pointer"
                  />
                </th>
                <th className="py-3 px-4 font-bold">REFERENCE</th>
                <th className="py-3 px-4 font-bold">CATEGORY</th>
                <th className="py-3 px-4 font-bold">TRIP</th>
                <th className="py-3 px-4 font-bold">REPORTED</th>
                <th className="py-3 px-4 font-bold">OWNER</th>
                <th className="py-3 px-4 font-bold">STATUS</th>
                <th className="py-3 px-4 w-12 text-right"></th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 text-slate-700">
              {filteredIncidents.map((item) => (
                <tr
                  key={item.id}
                  className="hover:bg-slate-50/70 transition-colors group cursor-pointer"
                  onClick={() => setActiveIncidentDetails(item)}
                >
                  <td className="py-3 px-3" onClick={(e) => e.stopPropagation()}>
                    <input
                      type="checkbox"
                      checked={selectedIncidents.includes(item.id)}
                      onChange={() => handleToggleSelect(item.id)}
                      className="w-4 h-4 rounded border-slate-300 text-[#3B5DF0] focus:ring-blue-500 cursor-pointer"
                    />
                  </td>
                  <td className="py-3 px-4 font-bold text-slate-900">
                    {item.reference}
                  </td>
                  <td className="py-3 px-4 font-medium text-slate-800">
                    {item.category}
                  </td>
                  <td className="py-3 px-4">
                    <Link
                      to="/journeys"
                      onClick={(e) => e.stopPropagation()}
                      className="text-slate-600 hover:text-[#3B5DF0] font-medium hover:underline"
                    >
                      {item.trip}
                    </Link>
                  </td>
                  <td className="py-3 px-4 text-slate-500 font-medium">
                    {item.reported}
                  </td>
                  <td className="py-3 px-4 text-slate-700 font-medium">
                    {item.owner}
                  </td>
                  <td className="py-3 px-4">
                    {item.status === 'Investigating' && (
                      <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-semibold bg-slate-100 text-slate-700 border border-slate-200/60">
                        <span className="w-1.5 h-1.5 rounded-full bg-blue-500" />
                        Investigating
                      </span>
                    )}
                    {item.status === 'Resolved' && (
                      <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-semibold bg-emerald-50 text-emerald-700 border border-emerald-200/60">
                        <span className="w-1.5 h-1.5 rounded-full bg-emerald-500" />
                        Resolved
                      </span>
                    )}
                    {item.status === 'Escalated' && (
                      <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-semibold bg-rose-50 text-rose-700 border border-rose-200/60">
                        <span className="w-1.5 h-1.5 rounded-full bg-rose-500" />
                        Escalated
                      </span>
                    )}
                    {item.status === 'Closed' && (
                      <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-semibold bg-slate-100 text-slate-500 border border-slate-200/60">
                        <span className="w-1.5 h-1.5 rounded-full bg-slate-400" />
                        Closed
                      </span>
                    )}
                  </td>
                  <td className="py-3 px-4 text-right" onClick={(e) => e.stopPropagation()}>
                    <button
                      type="button"
                      onClick={() => setActiveIncidentDetails(item)}
                      className="p-1 rounded-lg text-slate-400 hover:text-slate-600 hover:bg-slate-100 transition-colors cursor-pointer"
                    >
                      <MoreHorizontal className="w-4 h-4" />
                    </button>
                  </td>
                </tr>
              ))}

              {filteredIncidents.length === 0 && (
                <tr>
                  <td colSpan={8} className="py-12 text-center text-slate-400">
                    No incidents match the active filter or search criteria.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>

        {/* 5. Pagination Footer */}
        <div className="flex flex-col sm:flex-row items-center justify-between gap-4 pt-4 border-t border-slate-100 text-xs text-slate-500 font-medium">
          <span>Showing {filteredIncidents.length} sample records</span>

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

      {/* MODAL 1: Create Incident */}
      {isCreateModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/40 backdrop-blur-xs p-4">
          <div className="bg-white rounded-2xl max-w-lg w-full p-6 shadow-xl border border-slate-100 space-y-4 animate-in fade-in-50 zoom-in-95 duration-150">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div className="flex items-center gap-2">
                <div className="w-8 h-8 rounded-lg bg-rose-50 text-[#F04438] flex items-center justify-center font-bold">
                  <ShieldAlert className="w-4 h-4" />
                </div>
                <h3 className="font-bold text-slate-900 text-base">Create Incident Report</h3>
              </div>
              <button
                type="button"
                onClick={() => setIsCreateModalOpen(false)}
                className="text-slate-400 hover:text-slate-600 p-1 rounded-lg hover:bg-slate-100 transition-colors"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <form onSubmit={handleCreateIncident} className="space-y-4 text-xs">
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold text-slate-700 mb-1">
                    Reference ID
                  </label>
                  <input
                    type="text"
                    required
                    value={newReference}
                    onChange={(e) => setNewReference(e.target.value)}
                    className="w-full px-3 py-2 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
                  />
                </div>
                <div>
                  <label className="block font-semibold text-slate-700 mb-1">
                    Category
                  </label>
                  <select
                    value={newCategory}
                    onChange={(e) => setNewCategory(e.target.value)}
                    className="w-full px-3 py-2 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 bg-white"
                  >
                    <option value="Route disruption">Route disruption</option>
                    <option value="Medical concern">Medical concern</option>
                    <option value="Unresolved student">Unresolved student</option>
                    <option value="Vehicle breakdown">Vehicle breakdown</option>
                    <option value="Severe Weather">Severe Weather</option>
                  </select>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold text-slate-700 mb-1">
                    Trip Reference
                  </label>
                  <input
                    type="text"
                    required
                    value={newTrip}
                    onChange={(e) => setNewTrip(e.target.value)}
                    className="w-full px-3 py-2 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
                  />
                </div>
                <div>
                  <label className="block font-semibold text-slate-700 mb-1">
                    Owner / Assignee
                  </label>
                  <input
                    type="text"
                    required
                    value={newOwner}
                    onChange={(e) => setNewOwner(e.target.value)}
                    className="w-full px-3 py-2 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold text-slate-700 mb-1">
                    Initial Status
                  </label>
                  <select
                    value={newStatus}
                    onChange={(e) =>
                      setNewStatus(
                        e.target.value as 'Investigating' | 'Resolved' | 'Escalated' | 'Closed'
                      )
                    }
                    className="w-full px-3 py-2 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 bg-white"
                  >
                    <option value="Investigating">Investigating</option>
                    <option value="Escalated">Escalated</option>
                    <option value="Resolved">Resolved</option>
                    <option value="Closed">Closed</option>
                  </select>
                </div>
                <div>
                  <label className="block font-semibold text-slate-700 mb-1">
                    Severity Level
                  </label>
                  <select
                    value={newSeverity}
                    onChange={(e) =>
                      setNewSeverity(
                        e.target.value as 'Critical' | 'High' | 'Medium' | 'Low'
                      )
                    }
                    className="w-full px-3 py-2 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 bg-white"
                  >
                    <option value="Critical">Critical</option>
                    <option value="High">High</option>
                    <option value="Medium">Medium</option>
                    <option value="Low">Low</option>
                  </select>
                </div>
              </div>

              <div>
                <label className="block font-semibold text-slate-700 mb-1">
                  Incident Description & Action Taken
                </label>
                <textarea
                  rows={3}
                  value={newNotes}
                  onChange={(e) => setNewNotes(e.target.value)}
                  placeholder="Detail what happened, parent contacts initiated, and emergency services status..."
                  className="w-full px-3 py-2 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 resize-none"
                />
              </div>

              <div className="flex items-center justify-end gap-2 pt-3 border-t border-slate-100">
                <button
                  type="button"
                  onClick={() => setIsCreateModalOpen(false)}
                  className="px-4 py-2 border border-slate-200 rounded-xl text-slate-600 hover:bg-slate-50 font-semibold"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 bg-[#3B5DF0] hover:bg-[#2F4DCB] text-white rounded-xl font-semibold shadow-xs"
                >
                  Save Incident
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* MODAL 2: Safety Reconciliation Review */}
      {isReconciliationModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/40 backdrop-blur-xs p-4">
          <div className="bg-white rounded-2xl max-w-xl w-full p-6 shadow-xl border border-slate-100 space-y-4 animate-in fade-in-50 zoom-in-95 duration-150">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div className="flex items-center gap-2">
                <div className="w-8 h-8 rounded-lg bg-[#F04438] text-white flex items-center justify-center font-bold">
                  !
                </div>
                <div>
                  <h3 className="font-bold text-slate-900 text-base">
                    Safety Reconciliation (4 Unresolved)
                  </h3>
                  <p className="text-[11px] text-slate-500">
                    Mandatory audit trail before clearing student records
                  </p>
                </div>
              </div>
              <button
                type="button"
                onClick={() => setIsReconciliationModalOpen(false)}
                className="text-slate-400 hover:text-slate-600 p-1 rounded-lg hover:bg-slate-100 transition-colors"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <div className="space-y-3 max-h-72 overflow-y-auto pr-1">
              {[
                {
                  id: 's1',
                  name: 'Dulani M.',
                  ref: 'ST-2042',
                  trip: 'TR-1042',
                  stop: 'Oak Junction',
                  status: 'No event reported',
                },
                {
                  id: 's2',
                  name: 'Kavindu P.',
                  ref: 'ST-2071',
                  trip: 'TR-1041',
                  stop: 'Lake Road',
                  status: 'Parent absent notification pending confirmation',
                },
                {
                  id: 's3',
                  name: 'Tanya Perera',
                  ref: 'ST-2089',
                  trip: 'TR-1042',
                  stop: 'Pine Ave',
                  status: 'Boarding missed - contacted mother',
                },
                {
                  id: 's4',
                  name: 'Rohan Silva',
                  ref: 'ST-2095',
                  trip: 'TR-1032',
                  stop: 'Hillside Point',
                  status: 'Left early with parent car verified by attendant',
                },
              ].map((student) => (
                <div
                  key={student.id}
                  className="p-3 bg-slate-50 border border-slate-200/80 rounded-xl flex items-center justify-between text-xs"
                >
                  <div>
                    <div className="flex items-center gap-2">
                      <span className="font-bold text-slate-900">{student.name}</span>
                      <span className="text-[10px] bg-slate-200 text-slate-700 px-1.5 py-0.5 rounded font-mono">
                        {student.ref}
                      </span>
                    </div>
                    <div className="text-slate-500 text-[11px] mt-0.5">
                      Trip {student.trip} • Stop: {student.stop}
                    </div>
                    <div className="text-rose-600 text-[10px] font-semibold mt-1">
                      {student.status}
                    </div>
                  </div>
                  <button
                    type="button"
                    onClick={() => {
                      alert(`Student ${student.name} reconciled with signed audit log by Transport Manager Dinuka Silva.`);
                    }}
                    className="px-3 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-lg font-semibold text-[11px] shadow-2xs"
                  >
                    Confirm Safe
                  </button>
                </div>
              ))}
            </div>

            <div className="flex items-center justify-end gap-2 pt-3 border-t border-slate-100 text-xs">
              <button
                type="button"
                onClick={() => setIsReconciliationModalOpen(false)}
                className="px-4 py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 font-semibold rounded-xl"
              >
                Close
              </button>
            </div>
          </div>
        </div>
      )}

      {/* MODAL 3: Incident Details View */}
      {activeIncidentDetails && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/40 backdrop-blur-xs p-4">
          <div className="bg-white rounded-2xl max-w-md w-full p-6 shadow-xl border border-slate-100 space-y-4 animate-in fade-in-50 zoom-in-95 duration-150 text-xs">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div>
                <span className="text-[10px] font-bold uppercase text-slate-400">
                  INCIDENT DETAILS
                </span>
                <h3 className="font-bold text-slate-900 text-base">
                  {activeIncidentDetails.reference}
                </h3>
              </div>
              <button
                type="button"
                onClick={() => setActiveIncidentDetails(null)}
                className="text-slate-400 hover:text-slate-600 p-1 rounded-lg hover:bg-slate-100 transition-colors"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <div className="space-y-2.5">
              <div className="flex justify-between py-1 border-b border-slate-50">
                <span className="text-slate-400">Category:</span>
                <span className="font-bold text-slate-800">{activeIncidentDetails.category}</span>
              </div>
              <div className="flex justify-between py-1 border-b border-slate-50">
                <span className="text-slate-400">Trip:</span>
                <span className="font-bold text-[#3B5DF0]">{activeIncidentDetails.trip}</span>
              </div>
              <div className="flex justify-between py-1 border-b border-slate-50">
                <span className="text-slate-400">Reported:</span>
                <span className="font-medium text-slate-700">{activeIncidentDetails.reported}</span>
              </div>
              <div className="flex justify-between py-1 border-b border-slate-50">
                <span className="text-slate-400">Owner:</span>
                <span className="font-medium text-slate-700">{activeIncidentDetails.owner}</span>
              </div>
              <div className="flex justify-between py-1 border-b border-slate-50">
                <span className="text-slate-400">Status:</span>
                <span className="font-bold text-slate-800">{activeIncidentDetails.status}</span>
              </div>
              <div className="pt-2">
                <span className="text-slate-400 block mb-1">Notes & Audit:</span>
                <p className="p-3 bg-slate-50 rounded-xl text-slate-700 border border-slate-100 text-[11px] leading-relaxed">
                  {activeIncidentDetails.notes || 'No extra notes recorded for this event.'}
                </p>
              </div>
            </div>

            <div className="flex items-center justify-between pt-3 border-t border-slate-100">
              <button
                type="button"
                onClick={() => {
                  setIncidentsList((prev) =>
                    prev.map((i) =>
                      i.id === activeIncidentDetails.id
                        ? { ...i, status: 'Resolved' }
                        : i
                    )
                  );
                  setActiveIncidentDetails(null);
                }}
                className="px-3 py-1.5 bg-emerald-50 text-emerald-700 border border-emerald-200 rounded-xl font-semibold hover:bg-emerald-100 transition-colors"
              >
                Mark as Resolved
              </button>
              <button
                type="button"
                onClick={() => setActiveIncidentDetails(null)}
                className="px-4 py-1.5 bg-slate-900 text-white rounded-xl font-semibold hover:bg-slate-800 transition-colors"
              >
                Done
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
