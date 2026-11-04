import { useState } from 'react';
import {
  Plus,
  Search,
  Calendar,
  SlidersHorizontal,
  Download,
  MoreHorizontal,
  X,
  MessageSquare,
  LifeBuoy,
} from 'lucide-react';
import { cn } from '@/utils/cn';

interface TicketRecord {
  id: string;
  ticket: string;
  category: string;
  requestedBy: 'Parent' | 'Driver' | 'Attendant' | 'Staff';
  requesterName?: string;
  updated: string;
  assignedTo: string;
  status: 'Open' | 'In Progress' | 'Waiting' | 'Resolved';
  priority?: 'High' | 'Medium' | 'Low';
  description?: string;
}

const initialTickets: TicketRecord[] = [
  {
    id: 't-1',
    ticket: 'SUP-184',
    category: 'Missing notification',
    requestedBy: 'Parent',
    requesterName: 'S. Senanayake',
    updated: '8 min ago',
    assignedTo: 'D. Silva',
    status: 'Open',
    priority: 'Medium',
    description: 'Parent reported not receiving push notification when student Aanya boarded bus NB-2341.',
  },
  {
    id: 't-2',
    ticket: 'SUP-183',
    category: 'GPS issue',
    requestedBy: 'Driver',
    requesterName: 'Malith Perera (NB-2341)',
    updated: '22 min ago',
    assignedTo: 'Dispatch team',
    status: 'In Progress',
    priority: 'High',
    description: 'Vehicle GPS tracker intermittent connectivity near Baseline Road underpass.',
  },
  {
    id: 't-3',
    ticket: 'SUP-181',
    category: 'Payment question',
    requestedBy: 'Parent',
    requesterName: 'R. Fernando',
    updated: '1 hr ago',
    assignedTo: 'Finance team',
    status: 'Waiting',
    priority: 'Low',
    description: 'Inquiry regarding Term 2 transport fee discount for sibling enrollment.',
  },
  {
    id: 't-4',
    ticket: 'SUP-176',
    category: 'Application issue',
    requestedBy: 'Attendant',
    requesterName: 'Nimali Jayasekara',
    updated: 'Yesterday',
    assignedTo: 'N. Perera',
    status: 'Resolved',
    priority: 'Medium',
    description: 'Student list QR scanner camera permission error resolved following app cache clear.',
  },
];

type TabType = 'All tickets' | 'Open' | 'In progress' | 'Waiting' | 'Resolved';

export default function SupportRequestsPage() {
  const [activeTab, setActiveTab] = useState<TabType>('All tickets');
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedTickets, setSelectedTickets] = useState<string[]>([]);
  const [ticketsList, setTicketsList] = useState<TicketRecord[]>(initialTickets);

  // Modals state
  const [isCreateModalOpen, setIsCreateModalOpen] = useState(false);
  const [activeTicketDetails, setActiveTicketDetails] = useState<TicketRecord | null>(null);

  // Form state
  const [newCategory, setNewCategory] = useState('Missing notification');
  const [newRequestedBy, setNewRequestedBy] = useState<'Parent' | 'Driver' | 'Attendant' | 'Staff'>('Parent');
  const [newRequesterName, setNewRequesterName] = useState('K. Menaka');
  const [newAssignedTo, setNewAssignedTo] = useState('D. Silva');
  const [newPriority, setNewPriority] = useState<'High' | 'Medium' | 'Low'>('Medium');
  const [newDescription, setNewDescription] = useState('');

  // Filtering
  const filteredTickets = ticketsList.filter((item) => {
    // Tab filter
    if (activeTab === 'Open' && item.status !== 'Open') return false;
    if (activeTab === 'In progress' && item.status !== 'In Progress') return false;
    if (activeTab === 'Waiting' && item.status !== 'Waiting') return false;
    if (activeTab === 'Resolved' && item.status !== 'Resolved') return false;

    // Search filter
    const q = searchQuery.toLowerCase();
    return (
      item.ticket.toLowerCase().includes(q) ||
      item.category.toLowerCase().includes(q) ||
      item.requestedBy.toLowerCase().includes(q) ||
      item.assignedTo.toLowerCase().includes(q) ||
      item.status.toLowerCase().includes(q)
    );
  });

  const handleSelectAll = (checked: boolean) => {
    if (checked) {
      setSelectedTickets(filteredTickets.map((t) => t.id));
    } else {
      setSelectedTickets([]);
    }
  };

  const handleToggleSelect = (id: string) => {
    setSelectedTickets((prev) =>
      prev.includes(id) ? prev.filter((t) => t !== id) : [...prev, id]
    );
  };

  const handleCreateTicket = (e: React.FormEvent) => {
    e.preventDefault();
    const nextTicketNum = ticketsList.length + 185;
    const newRecord: TicketRecord = {
      id: `t-${Date.now()}`,
      ticket: `SUP-${nextTicketNum}`,
      category: newCategory,
      requestedBy: newRequestedBy,
      requesterName: newRequesterName,
      updated: 'Just now',
      assignedTo: newAssignedTo,
      status: 'Open',
      priority: newPriority,
      description: newDescription || 'No detailed description provided.',
    };
    setTicketsList((prev) => [newRecord, ...prev]);
    setIsCreateModalOpen(false);
    setNewDescription('');
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
            Support Requests
          </h1>
          <p className="text-slate-500 text-xs md:text-sm mt-1">
            Respond to parent and driver issues in one queue.
          </p>
        </div>

        {/* Right CTA Button */}
        <button
          type="button"
          onClick={() => setIsCreateModalOpen(true)}
          className="inline-flex items-center gap-2 bg-[#3B5DF0] hover:bg-[#2F4DCB] text-white text-xs font-semibold px-4 py-2.5 rounded-xl shadow-sm shadow-[#3B5DF0]/30 transition-all self-start md:self-auto cursor-pointer"
        >
          <Plus className="w-4 h-4" />
          <span>Create ticket</span>
        </button>
      </div>

      {/* 2. Main White Card Container */}
      <div className="bg-white border border-slate-200/80 rounded-2xl p-6 shadow-xs space-y-6">
        {/* Navigation Tabs */}
        <div className="flex items-center gap-8 border-b border-slate-100 text-xs font-semibold text-slate-500 pb-0 overflow-x-auto">
          {(['All tickets', 'Open', 'In progress', 'Waiting', 'Resolved'] as TabType[]).map(
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
              placeholder="Search support requests..."
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
                      filteredTickets.length > 0 &&
                      selectedTickets.length === filteredTickets.length
                    }
                    onChange={(e) => handleSelectAll(e.target.checked)}
                    className="w-4 h-4 rounded border-slate-300 text-[#3B5DF0] focus:ring-blue-500 cursor-pointer"
                  />
                </th>
                <th className="py-3 px-4 font-bold">TICKET</th>
                <th className="py-3 px-4 font-bold">CATEGORY</th>
                <th className="py-3 px-4 font-bold">REQUESTED BY</th>
                <th className="py-3 px-4 font-bold">UPDATED</th>
                <th className="py-3 px-4 font-bold">ASSIGNED TO</th>
                <th className="py-3 px-4 font-bold">STATUS</th>
                <th className="py-3 px-4 w-12 text-right"></th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 text-slate-700">
              {filteredTickets.map((item) => (
                <tr
                  key={item.id}
                  className="hover:bg-slate-50/70 transition-colors group cursor-pointer"
                  onClick={() => setActiveTicketDetails(item)}
                >
                  <td className="py-3 px-3" onClick={(e) => e.stopPropagation()}>
                    <input
                      type="checkbox"
                      checked={selectedTickets.includes(item.id)}
                      onChange={() => handleToggleSelect(item.id)}
                      className="w-4 h-4 rounded border-slate-300 text-[#3B5DF0] focus:ring-blue-500 cursor-pointer"
                    />
                  </td>
                  <td className="py-3 px-4 font-bold text-slate-900">
                    {item.ticket}
                  </td>
                  <td className="py-3 px-4 font-medium text-slate-800">
                    {item.category}
                  </td>
                  <td className="py-3 px-4 text-slate-600 font-medium">
                    {item.requestedBy}
                  </td>
                  <td className="py-3 px-4 text-slate-500 font-medium">
                    {item.updated}
                  </td>
                  <td className="py-3 px-4 text-slate-700 font-medium">
                    {item.assignedTo}
                  </td>
                  <td className="py-3 px-4">
                    {item.status === 'Open' && (
                      <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-semibold bg-slate-100 text-slate-700 border border-slate-200/60">
                        <span className="w-1.5 h-1.5 rounded-full bg-slate-500" />
                        Open
                      </span>
                    )}
                    {item.status === 'In Progress' && (
                      <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-semibold bg-blue-50 text-blue-700 border border-blue-200/60">
                        <span className="w-1.5 h-1.5 rounded-full bg-[#3B5DF0]" />
                        In Progress
                      </span>
                    )}
                    {item.status === 'Waiting' && (
                      <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-semibold bg-amber-50 text-amber-700 border border-amber-200/60">
                        <span className="w-1.5 h-1.5 rounded-full bg-amber-500" />
                        Waiting
                      </span>
                    )}
                    {item.status === 'Resolved' && (
                      <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-semibold bg-emerald-50 text-emerald-700 border border-emerald-200/60">
                        <span className="w-1.5 h-1.5 rounded-full bg-emerald-500" />
                        Resolved
                      </span>
                    )}
                  </td>
                  <td className="py-3 px-4 text-right" onClick={(e) => e.stopPropagation()}>
                    <button
                      type="button"
                      onClick={() => setActiveTicketDetails(item)}
                      className="p-1 rounded-lg text-slate-400 hover:text-slate-600 hover:bg-slate-100 transition-colors cursor-pointer"
                    >
                      <MoreHorizontal className="w-4 h-4" />
                    </button>
                  </td>
                </tr>
              ))}

              {filteredTickets.length === 0 && (
                <tr>
                  <td colSpan={8} className="py-12 text-center text-slate-400">
                    No support tickets match the current filter.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>

        {/* 4. Pagination Footer */}
        <div className="flex flex-col sm:flex-row items-center justify-between gap-4 pt-4 border-t border-slate-100 text-xs text-slate-500 font-medium">
          <span>Showing {filteredTickets.length} sample records</span>

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

      {/* MODAL 1: Create Ticket */}
      {isCreateModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/40 backdrop-blur-xs p-4">
          <div className="bg-white rounded-2xl max-w-lg w-full p-6 shadow-xl border border-slate-100 space-y-4 animate-in fade-in-50 zoom-in-95 duration-150">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div className="flex items-center gap-2">
                <div className="w-8 h-8 rounded-lg bg-blue-50 text-[#3B5DF0] flex items-center justify-center font-bold">
                  <LifeBuoy className="w-4 h-4" />
                </div>
                <h3 className="font-bold text-slate-900 text-base">New Support Ticket</h3>
              </div>
              <button
                type="button"
                onClick={() => setIsCreateModalOpen(false)}
                className="text-slate-400 hover:text-slate-600 p-1 rounded-lg hover:bg-slate-100 transition-colors"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <form onSubmit={handleCreateTicket} className="space-y-4 text-xs">
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold text-slate-700 mb-1">
                    Category
                  </label>
                  <select
                    value={newCategory}
                    onChange={(e) => setNewCategory(e.target.value)}
                    className="w-full px-3 py-2 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 bg-white"
                  >
                    <option value="Missing notification">Missing notification</option>
                    <option value="GPS issue">GPS issue</option>
                    <option value="Payment question">Payment question</option>
                    <option value="Application issue">Application issue</option>
                    <option value="Route change request">Route change request</option>
                  </select>
                </div>
                <div>
                  <label className="block font-semibold text-slate-700 mb-1">
                    Requested By
                  </label>
                  <select
                    value={newRequestedBy}
                    onChange={(e) =>
                      setNewRequestedBy(e.target.value as 'Parent' | 'Driver' | 'Attendant' | 'Staff')
                    }
                    className="w-full px-3 py-2 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 bg-white"
                  >
                    <option value="Parent">Parent</option>
                    <option value="Driver">Driver</option>
                    <option value="Attendant">Attendant</option>
                    <option value="Staff">Staff</option>
                  </select>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold text-slate-700 mb-1">
                    Contact / Requester Name
                  </label>
                  <input
                    type="text"
                    required
                    value={newRequesterName}
                    onChange={(e) => setNewRequesterName(e.target.value)}
                    className="w-full px-3 py-2 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
                  />
                </div>
                <div>
                  <label className="block font-semibold text-slate-700 mb-1">
                    Assign To
                  </label>
                  <select
                    value={newAssignedTo}
                    onChange={(e) => setNewAssignedTo(e.target.value)}
                    className="w-full px-3 py-2 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 bg-white"
                  >
                    <option value="D. Silva">D. Silva</option>
                    <option value="Dispatch team">Dispatch team</option>
                    <option value="Finance team">Finance team</option>
                    <option value="N. Perera">N. Perera</option>
                  </select>
                </div>
              </div>

              <div>
                <label className="block font-semibold text-slate-700 mb-1">
                  Priority
                </label>
                <div className="grid grid-cols-3 gap-2">
                  {(['Low', 'Medium', 'High'] as const).map((p) => (
                    <button
                      key={p}
                      type="button"
                      onClick={() => setNewPriority(p)}
                      className={cn(
                        'py-1.5 rounded-xl text-center font-semibold border transition-all text-xs cursor-pointer',
                        newPriority === p
                          ? 'bg-[#3B5DF0] text-white border-[#3B5DF0]'
                          : 'bg-white text-slate-700 border-slate-200 hover:bg-slate-50'
                      )}
                    >
                      {p}
                    </button>
                  ))}
                </div>
              </div>

              <div>
                <label className="block font-semibold text-slate-700 mb-1">
                  Issue Details
                </label>
                <textarea
                  rows={3}
                  required
                  value={newDescription}
                  onChange={(e) => setNewDescription(e.target.value)}
                  placeholder="Describe the issue reported by the user..."
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
                  Create Ticket
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* MODAL 2: Ticket Details View */}
      {activeTicketDetails && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/40 backdrop-blur-xs p-4">
          <div className="bg-white rounded-2xl max-w-md w-full p-6 shadow-xl border border-slate-100 space-y-4 animate-in fade-in-50 zoom-in-95 duration-150 text-xs">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div className="flex items-center gap-2">
                <div className="w-8 h-8 rounded-lg bg-blue-50 text-[#3B5DF0] flex items-center justify-center font-bold">
                  <MessageSquare className="w-4 h-4" />
                </div>
                <div>
                  <h3 className="font-bold text-slate-900 text-base">
                    {activeTicketDetails.ticket}
                  </h3>
                  <span className="text-[10px] text-slate-400">
                    Category: {activeTicketDetails.category}
                  </span>
                </div>
              </div>
              <button
                type="button"
                onClick={() => setActiveTicketDetails(null)}
                className="text-slate-400 hover:text-slate-600 p-1 rounded-lg hover:bg-slate-100 transition-colors"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <div className="space-y-2.5">
              <div className="flex justify-between py-1 border-b border-slate-50">
                <span className="text-slate-400">Requester:</span>
                <span className="font-bold text-slate-800">
                  {activeTicketDetails.requesterName || activeTicketDetails.requestedBy} ({activeTicketDetails.requestedBy})
                </span>
              </div>
              <div className="flex justify-between py-1 border-b border-slate-50">
                <span className="text-slate-400">Assigned To:</span>
                <span className="font-bold text-slate-800">{activeTicketDetails.assignedTo}</span>
              </div>
              <div className="flex justify-between py-1 border-b border-slate-50">
                <span className="text-slate-400">Last Updated:</span>
                <span className="font-medium text-slate-700">{activeTicketDetails.updated}</span>
              </div>
              <div className="flex justify-between py-1 border-b border-slate-50">
                <span className="text-slate-400">Status:</span>
                <span className="font-bold text-slate-800">{activeTicketDetails.status}</span>
              </div>
              <div className="pt-2">
                <span className="text-slate-400 block mb-1">Issue Description:</span>
                <p className="p-3 bg-slate-50 rounded-xl text-slate-700 border border-slate-100 text-[11px] leading-relaxed">
                  {activeTicketDetails.description}
                </p>
              </div>
            </div>

            <div className="flex items-center justify-between pt-3 border-t border-slate-100">
              <button
                type="button"
                onClick={() => {
                  setTicketsList((prev) =>
                    prev.map((t) =>
                      t.id === activeTicketDetails.id
                        ? { ...t, status: 'Resolved' }
                        : t
                    )
                  );
                  setActiveTicketDetails(null);
                }}
                className="px-3 py-1.5 bg-emerald-50 text-emerald-700 border border-emerald-200 rounded-xl font-semibold hover:bg-emerald-100 transition-colors"
              >
                Mark as Resolved
              </button>
              <button
                type="button"
                onClick={() => setActiveTicketDetails(null)}
                className="px-4 py-1.5 bg-slate-900 text-white rounded-xl font-semibold hover:bg-slate-800 transition-colors"
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
