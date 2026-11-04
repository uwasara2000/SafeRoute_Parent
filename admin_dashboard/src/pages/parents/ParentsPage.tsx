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
  ShieldCheck,
} from 'lucide-react';
import { cn } from '@/utils/cn';

interface ParentRecord {
  id: string;
  name: string;
  contact: string;
  linkedChildren: string;
  verification: 'Verified' | 'Pending';
  access: 'Parent' | 'Guardian' | '—';
  status: 'Active' | 'Review' | 'Revoked';
}

const initialParents: ParentRecord[] = [
  {
    id: 'p1',
    name: 'S. Senanayake',
    contact: 's***@gmail.com',
    linkedChildren: '2 children',
    verification: 'Verified',
    access: 'Parent',
    status: 'Active',
  },
  {
    id: 'p2',
    name: 'P. Perera',
    contact: '+94 77 *** 229',
    linkedChildren: '1 child',
    verification: 'Verified',
    access: 'Guardian',
    status: 'Active',
  },
  {
    id: 'p3',
    name: 'R. Fernando',
    contact: 'r***@gmail.com',
    linkedChildren: '1 requested',
    verification: 'Pending',
    access: '—',
    status: 'Review',
  },
  {
    id: 'p4',
    name: 'M. Ramanathan',
    contact: '+94 71 *** 301',
    linkedChildren: '2 children',
    verification: 'Verified',
    access: 'Parent',
    status: 'Active',
  },
];

type TabType = 'All accounts' | 'Verified' | 'Pending review' | 'Access revoked';

export default function ParentsPage() {
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = useState<TabType>('All accounts');
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedParents, setSelectedParents] = useState<string[]>([]);
  const [isReviewModalOpen, setIsReviewModalOpen] = useState(false);

  // Review requests modal state
  const [pendingRequests, setPendingRequests] = useState([
    {
      id: 'req1',
      parentName: 'R. Fernando',
      email: 'rashmi.fernando@gmail.com',
      childName: 'Dulani M.',
      school: 'Lakeland College',
      requestedAt: '2 hours ago',
    },
    {
      id: 'req2',
      parentName: 'D. Gunawardena',
      email: 'dilan.g@gmail.com',
      childName: 'Kavindu P.',
      school: 'Central Academy',
      requestedAt: '5 hours ago',
    },
  ]);

  const [parentsList, setParentsList] = useState<ParentRecord[]>(initialParents);

  // Filtering
  const filteredParents = parentsList.filter((parent) => {
    // Tab filter
    if (activeTab === 'Verified' && parent.verification !== 'Verified') return false;
    if (activeTab === 'Pending review' && parent.status !== 'Review') return false;
    if (activeTab === 'Access revoked' && parent.status !== 'Revoked') return false;

    // Search filter
    const q = searchQuery.toLowerCase();
    return (
      parent.name.toLowerCase().includes(q) ||
      parent.contact.toLowerCase().includes(q) ||
      parent.linkedChildren.toLowerCase().includes(q) ||
      parent.access.toLowerCase().includes(q)
    );
  });

  const handleSelectAll = (checked: boolean) => {
    if (checked) {
      setSelectedParents(filteredParents.map((p) => p.id));
    } else {
      setSelectedParents([]);
    }
  };

  const handleToggleSelect = (id: string) => {
    setSelectedParents((prev) =>
      prev.includes(id) ? prev.filter((item) => item !== id) : [...prev, id]
    );
  };

  const handleApproveRequest = (id: string, parentName: string) => {
    setPendingRequests((prev) => prev.filter((r) => r.id !== id));
    setParentsList((prev) =>
      prev.map((p) =>
        p.name === parentName
          ? { ...p, verification: 'Verified', access: 'Parent', status: 'Active', linkedChildren: '1 child' }
          : p
      )
    );
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
            Parents & Guardians
          </h1>
          <p className="text-slate-500 text-xs md:text-sm mt-1">
            Verify contacts and control authorized child access.
          </p>
        </div>

        {/* Right CTA Button */}
        <button
          type="button"
          onClick={() => setIsReviewModalOpen(true)}
          className="inline-flex items-center gap-2 bg-[#3B5DF0] hover:bg-[#2F4DCB] text-white text-xs font-semibold px-4 py-2.5 rounded-xl shadow-sm shadow-[#3B5DF0]/30 transition-all self-start md:self-auto cursor-pointer"
        >
          <Plus className="w-4 h-4" />
          <span>Review requests</span>
        </button>
      </div>

      {/* 2. Main White Card Container */}
      <div className="bg-white border border-slate-200/80 rounded-2xl p-6 shadow-xs space-y-6">
        {/* Navigation Tabs */}
        <div className="flex items-center gap-8 border-b border-slate-100 text-xs font-semibold text-slate-500 pb-0">
          {(['All accounts', 'Verified', 'Pending review', 'Access revoked'] as TabType[]).map(
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
              placeholder="Search parents & guardians..."
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
                      filteredParents.length > 0 &&
                      selectedParents.length === filteredParents.length
                    }
                    onChange={(e) => handleSelectAll(e.target.checked)}
                    className="w-4 h-4 rounded border-slate-300 text-[#3B5DF0] focus:ring-blue-500 cursor-pointer"
                  />
                </th>
                <th className="py-3 px-4 font-bold">PARENT / GUARDIAN</th>
                <th className="py-3 px-4 font-bold">CONTACT</th>
                <th className="py-3 px-4 font-bold">LINKED CHILDREN</th>
                <th className="py-3 px-4 font-bold">VERIFICATION</th>
                <th className="py-3 px-4 font-bold">ACCESS</th>
                <th className="py-3 px-4 font-bold">STATUS</th>
                <th className="py-3 px-4 w-12 text-right"></th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {filteredParents.map((parent) => {
                const isSelected = selectedParents.includes(parent.id);
                return (
                  <tr
                    key={parent.id}
                    className={cn(
                      'hover:bg-slate-50/70 transition-colors group',
                      isSelected && 'bg-blue-50/30'
                    )}
                  >
                    <td className="py-3.5 px-3">
                      <input
                        type="checkbox"
                        checked={isSelected}
                        onChange={() => handleToggleSelect(parent.id)}
                        className="w-4 h-4 rounded border-slate-300 text-[#3B5DF0] focus:ring-blue-500 cursor-pointer"
                      />
                    </td>
                    <td className="py-3.5 px-4 font-bold text-slate-900">
                      {parent.name}
                    </td>
                    <td className="py-3.5 px-4 text-slate-600 font-medium font-mono text-[11px]">
                      {parent.contact}
                    </td>
                    <td className="py-3.5 px-4 text-slate-600 font-medium">
                      <button
                        type="button"
                        onClick={() => navigate('/students')}
                        className="hover:text-[#3B5DF0] hover:underline transition-colors text-left"
                        title="View linked students"
                      >
                        {parent.linkedChildren}
                      </button>
                    </td>
                    <td className="py-3.5 px-4 text-slate-600 font-medium">
                      <span className="inline-flex items-center gap-1">
                        <ShieldCheck className={cn('w-3.5 h-3.5', parent.verification === 'Verified' ? 'text-emerald-500' : 'text-amber-500')} />
                        {parent.verification}
                      </span>
                    </td>
                    <td className="py-3.5 px-4 text-slate-600 font-medium">
                      {parent.access}
                    </td>
                    <td className="py-3.5 px-4">
                      {parent.status === 'Active' && (
                        <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-semibold bg-emerald-50 text-emerald-700 border border-emerald-200">
                          <span className="w-1.5 h-1.5 rounded-full bg-emerald-500" />
                          Active
                        </span>
                      )}
                      {parent.status === 'Review' && (
                        <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-semibold bg-amber-50 text-amber-700 border border-amber-200">
                          <span className="w-1.5 h-1.5 rounded-full bg-amber-500" />
                          Review
                        </span>
                      )}
                      {parent.status === 'Revoked' && (
                        <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-semibold bg-rose-50 text-rose-700 border border-rose-200">
                          <span className="w-1.5 h-1.5 rounded-full bg-rose-500" />
                          Revoked
                        </span>
                      )}
                    </td>
                    <td className="py-3.5 px-4 text-right">
                      <button
                        type="button"
                        onClick={() => setIsReviewModalOpen(true)}
                        className="p-1 rounded-lg text-slate-400 hover:text-slate-600 hover:bg-slate-100 transition-colors cursor-pointer"
                        title="Manage Parent Access"
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
          <span>Showing {filteredParents.length} records</span>

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

      {/* 5. Review Requests Modal */}
      {isReviewModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-xs p-4">
          <div className="bg-white rounded-2xl shadow-xl border border-slate-200 w-full max-w-lg p-6 space-y-5 animate-in fade-in zoom-in-95 duration-150">
            <div className="flex items-center justify-between pb-3 border-b border-slate-100">
              <div>
                <h3 className="text-base font-extrabold text-slate-900">Parent Access Requests</h3>
                <p className="text-xs text-slate-500 mt-0.5">
                  Approve or reject parent verification and student linkage requests.
                </p>
              </div>
              <button
                type="button"
                onClick={() => setIsReviewModalOpen(false)}
                className="p-1 rounded-lg text-slate-400 hover:text-slate-600 hover:bg-slate-100 transition-colors cursor-pointer"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <div className="space-y-3 text-xs">
              {pendingRequests.length === 0 ? (
                <p className="text-center py-6 text-slate-400 font-medium">
                  No pending parent requests right now.
                </p>
              ) : (
                pendingRequests.map((req) => (
                  <div
                    key={req.id}
                    className="p-3.5 rounded-xl border border-slate-200/90 bg-slate-50/50 flex items-center justify-between gap-3"
                  >
                    <div>
                      <p className="font-bold text-slate-900">{req.parentName}</p>
                      <p className="text-[11px] text-slate-500 mt-0.5">{req.email}</p>
                      <p className="text-[11px] text-[#3B5DF0] font-semibold mt-1">
                        Linking to: {req.childName} ({req.school})
                      </p>
                      <p className="text-[10px] text-slate-400 mt-0.5">{req.requestedAt}</p>
                    </div>

                    <div className="flex items-center gap-1.5 shrink-0">
                      <button
                        type="button"
                        onClick={() => handleApproveRequest(req.id, req.parentName)}
                        className="px-3 py-1.5 rounded-lg bg-[#3B5DF0] hover:bg-[#2F4DCB] text-white font-semibold text-xs flex items-center gap-1 shadow-2xs transition-colors cursor-pointer"
                      >
                        <Check className="w-3.5 h-3.5" />
                        <span>Approve</span>
                      </button>
                    </div>
                  </div>
                ))
              )}
            </div>

            <div className="pt-3 border-t border-slate-100 flex items-center justify-end">
              <button
                type="button"
                onClick={() => setIsReviewModalOpen(false)}
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
