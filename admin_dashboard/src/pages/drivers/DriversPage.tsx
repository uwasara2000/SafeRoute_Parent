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

interface StaffRecord {
  id: string;
  name: string;
  role: 'Driver' | 'Attendant';
  contact: string;
  vehicle: string;
  routes: string;
  status: 'Active' | 'Invited' | 'Suspended';
}

const initialStaff: StaffRecord[] = [
  {
    id: 's1',
    name: 'Malith Perera',
    role: 'Driver',
    contact: '+94 77 *** 482',
    vehicle: 'NB-2341',
    routes: '2 routes',
    status: 'Active',
  },
  {
    id: 's2',
    name: 'Nimali Jayasekara',
    role: 'Attendant',
    contact: '+94 71 *** 728',
    vehicle: 'NB-2341',
    routes: '2 routes',
    status: 'Active',
  },
  {
    id: 's3',
    name: 'Ruwan Silva',
    role: 'Driver',
    contact: '+94 76 *** 144',
    vehicle: 'NC-8872',
    routes: '1 route',
    status: 'Active',
  },
  {
    id: 's4',
    name: 'Tharushi De Mel',
    role: 'Attendant',
    contact: '+94 72 *** 096',
    vehicle: 'Unassigned',
    routes: '—',
    status: 'Invited',
  },
];

type TabType = 'All staff' | 'Drivers' | 'Attendants' | 'Invited' | 'Suspended';

export default function DriversPage() {
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = useState<TabType>('All staff');
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedStaff, setSelectedStaff] = useState<string[]>([]);
  const [isInviteModalOpen, setIsInviteModalOpen] = useState(false);

  // Form State
  const [newName, setNewName] = useState('Kasun Kalhara');
  const [newRole, setNewRole] = useState<'Driver' | 'Attendant'>('Driver');
  const [newContact, setNewContact] = useState('+94 77 123 4567');
  const [newVehicle, setNewVehicle] = useState('ND-4105');
  const [newRoutes, setNewRoutes] = useState('1 route');
  const [newStatus, setNewStatus] = useState<'Active' | 'Invited' | 'Suspended'>('Active');

  const [staffList, setStaffList] = useState<StaffRecord[]>(initialStaff);

  // Filtering
  const filteredStaff = staffList.filter((staff) => {
    // Tab filter
    if (activeTab === 'Drivers' && staff.role !== 'Driver') return false;
    if (activeTab === 'Attendants' && staff.role !== 'Attendant') return false;
    if (activeTab === 'Invited' && staff.status !== 'Invited') return false;
    if (activeTab === 'Suspended' && staff.status !== 'Suspended') return false;

    // Search filter
    const q = searchQuery.toLowerCase();
    return (
      staff.name.toLowerCase().includes(q) ||
      staff.role.toLowerCase().includes(q) ||
      staff.contact.toLowerCase().includes(q) ||
      staff.vehicle.toLowerCase().includes(q)
    );
  });

  const handleSelectAll = (checked: boolean) => {
    if (checked) {
      setSelectedStaff(filteredStaff.map((s) => s.id));
    } else {
      setSelectedStaff([]);
    }
  };

  const handleToggleSelect = (id: string) => {
    setSelectedStaff((prev) =>
      prev.includes(id) ? prev.filter((item) => item !== id) : [...prev, id]
    );
  };

  const handleInviteStaff = (e: React.FormEvent) => {
    e.preventDefault();
    const newRecord: StaffRecord = {
      id: `s_${Date.now()}`,
      name: newName,
      role: newRole,
      contact: newContact,
      vehicle: newVehicle,
      routes: newRoutes,
      status: newStatus,
    };
    setStaffList((prev) => [newRecord, ...prev]);
    setIsInviteModalOpen(false);
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
            Drivers & Attendants
          </h1>
          <p className="text-slate-500 text-xs md:text-sm mt-1">
            Manage staff access, employment status and assignments.
          </p>
        </div>

        {/* Right CTA Button */}
        <button
          type="button"
          onClick={() => setIsInviteModalOpen(true)}
          className="inline-flex items-center gap-2 bg-[#3B5DF0] hover:bg-[#2F4DCB] text-white text-xs font-semibold px-4 py-2.5 rounded-xl shadow-sm shadow-[#3B5DF0]/30 transition-all self-start md:self-auto cursor-pointer"
        >
          <Plus className="w-4 h-4" />
          <span>Invite staff</span>
        </button>
      </div>

      {/* 2. Main White Card Container */}
      <div className="bg-white border border-slate-200/80 rounded-2xl p-6 shadow-xs space-y-6">
        {/* Navigation Tabs */}
        <div className="flex items-center gap-8 border-b border-slate-100 text-xs font-semibold text-slate-500 pb-0">
          {(['All staff', 'Drivers', 'Attendants', 'Invited', 'Suspended'] as TabType[]).map(
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
              placeholder="Search drivers & attendants..."
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
                      filteredStaff.length > 0 &&
                      selectedStaff.length === filteredStaff.length
                    }
                    onChange={(e) => handleSelectAll(e.target.checked)}
                    className="w-4 h-4 rounded border-slate-300 text-[#3B5DF0] focus:ring-blue-500 cursor-pointer"
                  />
                </th>
                <th className="py-3 px-4 font-bold">STAFF MEMBER</th>
                <th className="py-3 px-4 font-bold">ROLE</th>
                <th className="py-3 px-4 font-bold">CONTACT</th>
                <th className="py-3 px-4 font-bold">VEHICLE</th>
                <th className="py-3 px-4 font-bold">ROUTES</th>
                <th className="py-3 px-4 font-bold">STATUS</th>
                <th className="py-3 px-4 w-12 text-right"></th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {filteredStaff.map((staff) => {
                const isSelected = selectedStaff.includes(staff.id);
                return (
                  <tr
                    key={staff.id}
                    className={cn(
                      'hover:bg-slate-50/70 transition-colors group',
                      isSelected && 'bg-blue-50/30'
                    )}
                  >
                    <td className="py-3.5 px-3">
                      <input
                        type="checkbox"
                        checked={isSelected}
                        onChange={() => handleToggleSelect(staff.id)}
                        className="w-4 h-4 rounded border-slate-300 text-[#3B5DF0] focus:ring-blue-500 cursor-pointer"
                      />
                    </td>
                    <td className="py-3.5 px-4 font-bold text-slate-900">
                      {staff.name}
                    </td>
                    <td className="py-3.5 px-4 text-slate-600 font-medium">
                      {staff.role}
                    </td>
                    <td className="py-3.5 px-4 text-slate-600 font-medium font-mono text-[11px]">
                      {staff.contact}
                    </td>
                    <td className="py-3.5 px-4 text-slate-600 font-medium">
                      {staff.vehicle !== 'Unassigned' ? (
                        <button
                          type="button"
                          onClick={() => navigate('/monitoring')}
                          className="hover:text-[#3B5DF0] hover:underline transition-colors font-medium text-left"
                          title="View vehicle on Live Map"
                        >
                          {staff.vehicle}
                        </button>
                      ) : (
                        <span className="text-slate-400">Unassigned</span>
                      )}
                    </td>
                    <td className="py-3.5 px-4 text-slate-600 font-medium">
                      {staff.routes}
                    </td>
                    <td className="py-3.5 px-4">
                      {staff.status === 'Active' && (
                        <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-semibold bg-emerald-50 text-emerald-700 border border-emerald-200">
                          <span className="w-1.5 h-1.5 rounded-full bg-emerald-500" />
                          Active
                        </span>
                      )}
                      {staff.status === 'Invited' && (
                        <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-semibold bg-slate-100 text-slate-600 border border-slate-200">
                          <span className="w-1.5 h-1.5 rounded-full bg-slate-400" />
                          Invited
                        </span>
                      )}
                      {staff.status === 'Suspended' && (
                        <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-semibold bg-rose-50 text-rose-700 border border-rose-200">
                          <span className="w-1.5 h-1.5 rounded-full bg-rose-500" />
                          Suspended
                        </span>
                      )}
                    </td>
                    <td className="py-3.5 px-4 text-right">
                      <button
                        type="button"
                        onClick={() => navigate('/monitoring')}
                        className="p-1 rounded-lg text-slate-400 hover:text-slate-600 hover:bg-slate-100 transition-colors cursor-pointer"
                        title="Staff Options"
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
          <span>Showing {filteredStaff.length} records</span>

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

      {/* 5. Invite Staff Modal */}
      {isInviteModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-xs p-4">
          <div className="bg-white rounded-2xl shadow-xl border border-slate-200 w-full max-w-lg p-6 space-y-5 animate-in fade-in zoom-in-95 duration-150">
            <div className="flex items-center justify-between pb-3 border-b border-slate-100">
              <div>
                <h3 className="text-base font-extrabold text-slate-900">Invite Staff Member</h3>
                <p className="text-xs text-slate-500 mt-0.5">
                  Add a new driver or bus attendant to the transport operations team.
                </p>
              </div>
              <button
                type="button"
                onClick={() => setIsInviteModalOpen(false)}
                className="p-1 rounded-lg text-slate-400 hover:text-slate-600 hover:bg-slate-100 transition-colors cursor-pointer"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleInviteStaff} className="space-y-4 text-xs">
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-bold text-slate-700 mb-1">Full Name</label>
                  <input
                    type="text"
                    value={newName}
                    onChange={(e) => setNewName(e.target.value)}
                    required
                    placeholder="e.g. Kasun Kalhara"
                    className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
                  />
                </div>

                <div>
                  <label className="block font-bold text-slate-700 mb-1">Role</label>
                  <select
                    value={newRole}
                    onChange={(e) => setNewRole(e.target.value as 'Driver' | 'Attendant')}
                    className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
                  >
                    <option value="Driver">Driver</option>
                    <option value="Attendant">Attendant</option>
                  </select>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-bold text-slate-700 mb-1">Phone Contact</label>
                  <input
                    type="text"
                    value={newContact}
                    onChange={(e) => setNewContact(e.target.value)}
                    required
                    placeholder="+94 77 123 4567"
                    className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
                  />
                </div>

                <div>
                  <label className="block font-bold text-slate-700 mb-1">Status</label>
                  <select
                    value={newStatus}
                    onChange={(e) =>
                      setNewStatus(e.target.value as 'Active' | 'Invited' | 'Suspended')
                    }
                    className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
                  >
                    <option value="Active">Active</option>
                    <option value="Invited">Invited</option>
                    <option value="Suspended">Suspended</option>
                  </select>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-bold text-slate-700 mb-1">Assigned Vehicle</label>
                  <select
                    value={newVehicle}
                    onChange={(e) => setNewVehicle(e.target.value)}
                    className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
                  >
                    <option value="NB-2341">NB-2341</option>
                    <option value="NC-8872">NC-8872</option>
                    <option value="ND-4105">ND-4105</option>
                    <option value="Unassigned">Unassigned</option>
                  </select>
                </div>

                <div>
                  <label className="block font-bold text-slate-700 mb-1">Assigned Routes</label>
                  <input
                    type="text"
                    value={newRoutes}
                    onChange={(e) => setNewRoutes(e.target.value)}
                    placeholder="e.g. 2 routes"
                    className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
                  />
                </div>
              </div>

              <div className="pt-3 border-t border-slate-100 flex items-center justify-end gap-2.5">
                <button
                  type="button"
                  onClick={() => setIsInviteModalOpen(false)}
                  className="px-4 py-2 rounded-xl border border-slate-200 text-slate-700 font-semibold hover:bg-slate-50 transition-colors cursor-pointer"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="inline-flex items-center gap-1.5 px-4 py-2 rounded-xl bg-[#3B5DF0] hover:bg-[#2F4DCB] text-white font-semibold shadow-xs transition-colors cursor-pointer"
                >
                  <Check className="w-4 h-4" />
                  <span>Send Invitation</span>
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
