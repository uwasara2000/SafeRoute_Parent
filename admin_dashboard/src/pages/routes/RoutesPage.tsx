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

interface RouteRecord {
  id: string;
  name: string;
  school: string;
  stopsCount: number;
  vehicle: string;
  staffAssigned: number;
  status: 'Active' | 'Draft' | 'Needs review';
}

const initialRoutes: RouteRecord[] = [
  {
    id: 'r1',
    name: 'North Ridge AM',
    school: 'Lakeland College',
    stopsCount: 12,
    vehicle: 'NB-2341',
    staffAssigned: 2,
    status: 'Active',
  },
  {
    id: 'r2',
    name: 'Lakeside AM',
    school: 'Central Academy',
    stopsCount: 8,
    vehicle: 'NC-8872',
    staffAssigned: 2,
    status: 'Active',
  },
  {
    id: 'r3',
    name: 'Hillview AM',
    school: 'Lakeland College',
    stopsCount: 14,
    vehicle: 'ND-4105',
    staffAssigned: 2,
    status: 'Needs review',
  },
  {
    id: 'r4',
    name: 'East Gate PM',
    school: 'Central Academy',
    stopsCount: 11,
    vehicle: 'Unassigned',
    staffAssigned: 1,
    status: 'Draft',
  },
];

type TabType = 'All routes' | 'Active' | 'Drafts' | 'Needs review';

export default function RoutesPage() {
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = useState<TabType>('All routes');
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedRoutes, setSelectedRoutes] = useState<string[]>([]);
  const [isCreateModalOpen, setIsCreateModalOpen] = useState(false);

  // Form State
  const [newRouteName, setNewRouteName] = useState('West End PM');
  const [newSchool, setNewSchool] = useState('Lakeland College');
  const [newStopsCount, setNewStopsCount] = useState(10);
  const [newVehicle, setNewVehicle] = useState('NB-2341');
  const [newStaffAssigned, setNewStaffAssigned] = useState(2);
  const [newStatus, setNewStatus] = useState<'Active' | 'Draft' | 'Needs review'>('Active');

  const [routesList, setRoutesList] = useState<RouteRecord[]>(initialRoutes);

  // Filtering
  const filteredRoutes = routesList.filter((route) => {
    // Tab filter
    if (activeTab === 'Active' && route.status !== 'Active') return false;
    if (activeTab === 'Drafts' && route.status !== 'Draft') return false;
    if (activeTab === 'Needs review' && route.status !== 'Needs review') return false;

    // Search filter
    const q = searchQuery.toLowerCase();
    return (
      route.name.toLowerCase().includes(q) ||
      route.school.toLowerCase().includes(q) ||
      route.vehicle.toLowerCase().includes(q)
    );
  });

  const handleSelectAll = (checked: boolean) => {
    if (checked) {
      setSelectedRoutes(filteredRoutes.map((r) => r.id));
    } else {
      setSelectedRoutes([]);
    }
  };

  const handleToggleSelect = (id: string) => {
    setSelectedRoutes((prev) =>
      prev.includes(id) ? prev.filter((item) => item !== id) : [...prev, id]
    );
  };

  const handleCreateRoute = (e: React.FormEvent) => {
    e.preventDefault();
    const newRecord: RouteRecord = {
      id: `r_${Date.now()}`,
      name: newRouteName,
      school: newSchool,
      stopsCount: Number(newStopsCount),
      vehicle: newVehicle,
      staffAssigned: Number(newStaffAssigned),
      status: newStatus,
    };
    setRoutesList((prev) => [newRecord, ...prev]);
    setIsCreateModalOpen(false);
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
            Routes & Stops
          </h1>
          <p className="text-slate-500 text-xs md:text-sm mt-1">
            Manage approved routes, ordered stops and staff assignments.
          </p>
        </div>

        {/* Right CTA Button */}
        <button
          type="button"
          onClick={() => setIsCreateModalOpen(true)}
          className="inline-flex items-center gap-2 bg-[#3B5DF0] hover:bg-[#2F4DCB] text-white text-xs font-semibold px-4 py-2.5 rounded-xl shadow-sm shadow-[#3B5DF0]/30 transition-all self-start md:self-auto cursor-pointer"
        >
          <Plus className="w-4 h-4" />
          <span>Create route</span>
        </button>
      </div>

      {/* 2. Main White Card Container */}
      <div className="bg-white border border-slate-200/80 rounded-2xl p-6 shadow-xs space-y-6">
        {/* Navigation Tabs */}
        <div className="flex items-center gap-8 border-b border-slate-100 text-xs font-semibold text-slate-500 pb-0">
          {(['All routes', 'Active', 'Drafts', 'Needs review'] as TabType[]).map((tab) => {
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
              placeholder="Search routes & stops..."
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
                      filteredRoutes.length > 0 &&
                      selectedRoutes.length === filteredRoutes.length
                    }
                    onChange={(e) => handleSelectAll(e.target.checked)}
                    className="w-4 h-4 rounded border-slate-300 text-[#3B5DF0] focus:ring-blue-500 cursor-pointer"
                  />
                </th>
                <th className="py-3 px-4 font-bold">ROUTE</th>
                <th className="py-3 px-4 font-bold">SCHOOL</th>
                <th className="py-3 px-4 font-bold">STOPS</th>
                <th className="py-3 px-4 font-bold">VEHICLE</th>
                <th className="py-3 px-4 font-bold">STAFF</th>
                <th className="py-3 px-4 font-bold">STATUS</th>
                <th className="py-3 px-4 w-12 text-right"></th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {filteredRoutes.map((route) => {
                const isSelected = selectedRoutes.includes(route.id);
                return (
                  <tr
                    key={route.id}
                    className={cn(
                      'hover:bg-slate-50/70 transition-colors group',
                      isSelected && 'bg-blue-50/30'
                    )}
                  >
                    <td className="py-3.5 px-3">
                      <input
                        type="checkbox"
                        checked={isSelected}
                        onChange={() => handleToggleSelect(route.id)}
                        className="w-4 h-4 rounded border-slate-300 text-[#3B5DF0] focus:ring-blue-500 cursor-pointer"
                      />
                    </td>
                    <td className="py-3.5 px-4 font-bold text-slate-900">
                      <button
                        type="button"
                        onClick={() => navigate('/monitoring')}
                        className="hover:text-[#3B5DF0] hover:underline transition-colors text-left font-bold"
                        title="View route corridor on Live Map"
                      >
                        {route.name}
                      </button>
                    </td>
                    <td className="py-3.5 px-4 text-slate-600 font-medium">
                      {route.school}
                    </td>
                    <td className="py-3.5 px-4 text-slate-600 font-medium">
                      {route.stopsCount} stops
                    </td>
                    <td className="py-3.5 px-4 text-slate-600 font-medium">
                      {route.vehicle}
                    </td>
                    <td className="py-3.5 px-4 text-slate-600 font-medium">
                      {route.staffAssigned} assigned
                    </td>
                    <td className="py-3.5 px-4">
                      {route.status === 'Active' && (
                        <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-semibold bg-emerald-50 text-emerald-700 border border-emerald-200">
                          <span className="w-1.5 h-1.5 rounded-full bg-emerald-500" />
                          Active
                        </span>
                      )}
                      {route.status === 'Needs review' && (
                        <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-semibold bg-amber-50 text-amber-700 border border-amber-200">
                          <span className="w-1.5 h-1.5 rounded-full bg-amber-500" />
                          Review
                        </span>
                      )}
                      {route.status === 'Draft' && (
                        <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-semibold bg-slate-100 text-slate-600 border border-slate-200">
                          <span className="w-1.5 h-1.5 rounded-full bg-slate-400" />
                          Draft
                        </span>
                      )}
                    </td>
                    <td className="py-3.5 px-4 text-right">
                      <button
                        type="button"
                        onClick={() => navigate('/monitoring')}
                        className="p-1 rounded-lg text-slate-400 hover:text-slate-600 hover:bg-slate-100 transition-colors cursor-pointer"
                        title="Route Options"
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
          <span>Showing {filteredRoutes.length} records</span>

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

      {/* 5. Create Route Modal */}
      {isCreateModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-xs p-4">
          <div className="bg-white rounded-2xl shadow-xl border border-slate-200 w-full max-w-lg p-6 space-y-5 animate-in fade-in zoom-in-95 duration-150">
            <div className="flex items-center justify-between pb-3 border-b border-slate-100">
              <div>
                <h3 className="text-base font-extrabold text-slate-900">Create New Route</h3>
                <p className="text-xs text-slate-500 mt-0.5">
                  Define route path, serving school, and assigned fleet.
                </p>
              </div>
              <button
                type="button"
                onClick={() => setIsCreateModalOpen(false)}
                className="p-1 rounded-lg text-slate-400 hover:text-slate-600 hover:bg-slate-100 transition-colors cursor-pointer"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleCreateRoute} className="space-y-4 text-xs">
              <div>
                <label className="block font-bold text-slate-700 mb-1">Route Name</label>
                <input
                  type="text"
                  value={newRouteName}
                  onChange={(e) => setNewRouteName(e.target.value)}
                  required
                  placeholder="e.g. West End PM"
                  className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
                />
              </div>

              <div className="grid grid-cols-3 gap-3">
                <div>
                  <label className="block font-bold text-slate-700 mb-1">Serving School</label>
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
                  <label className="block font-bold text-slate-700 mb-1">Stops Count</label>
                  <input
                    type="number"
                    min="1"
                    max="50"
                    value={newStopsCount}
                    onChange={(e) => setNewStopsCount(Number(e.target.value))}
                    required
                    className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
                  />
                </div>

                <div>
                  <label className="block font-bold text-slate-700 mb-1">Staff Assigned</label>
                  <input
                    type="number"
                    min="1"
                    max="5"
                    value={newStaffAssigned}
                    onChange={(e) => setNewStaffAssigned(Number(e.target.value))}
                    required
                    className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
                  />
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
                  <label className="block font-bold text-slate-700 mb-1">Status</label>
                  <select
                    value={newStatus}
                    onChange={(e) =>
                      setNewStatus(e.target.value as 'Active' | 'Draft' | 'Needs review')
                    }
                    className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
                  >
                    <option value="Active">Active</option>
                    <option value="Draft">Draft</option>
                    <option value="Needs review">Needs review</option>
                  </select>
                </div>
              </div>

              <div className="pt-3 border-t border-slate-100 flex items-center justify-end gap-2.5">
                <button
                  type="button"
                  onClick={() => setIsCreateModalOpen(false)}
                  className="px-4 py-2 rounded-xl border border-slate-200 text-slate-700 font-semibold hover:bg-slate-50 transition-colors cursor-pointer"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="inline-flex items-center gap-1.5 px-4 py-2 rounded-xl bg-[#3B5DF0] hover:bg-[#2F4DCB] text-white font-semibold shadow-xs transition-colors cursor-pointer"
                >
                  <Check className="w-4 h-4" />
                  <span>Create Route</span>
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
