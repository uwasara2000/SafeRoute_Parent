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

interface VehicleRecord {
  id: string;
  registration: string;
  type: string;
  capacity: string;
  driver: string;
  route: string;
  status: 'In Trip' | 'Delayed' | 'Idle' | 'Offline' | 'Maintenance';
}

const initialVehicles: VehicleRecord[] = [
  {
    id: 'v1',
    registration: 'NB-2341',
    type: 'School bus',
    capacity: '32 seats',
    driver: 'M. Perera',
    route: 'North Ridge',
    status: 'In Trip',
  },
  {
    id: 'v2',
    registration: 'NC-8872',
    type: 'Mini bus',
    capacity: '18 seats',
    driver: 'R. Silva',
    route: 'Lakeside',
    status: 'Delayed',
  },
  {
    id: 'v3',
    registration: 'ND-4105',
    type: 'School bus',
    capacity: '40 seats',
    driver: 'A. Fernando',
    route: 'Hillview',
    status: 'Idle',
  },
  {
    id: 'v4',
    registration: 'NE-0218',
    type: 'Van',
    capacity: '12 seats',
    driver: 'Unassigned',
    route: '—',
    status: 'Offline',
  },
];

type TabType = 'All vehicles' | 'Active' | 'In trip' | 'Maintenance' | 'Inactive';

export default function BusesPage() {
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = useState<TabType>('All vehicles');
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedVehicles, setSelectedVehicles] = useState<string[]>([]);
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);

  // Form State
  const [newReg, setNewReg] = useState('NF-5520');
  const [newType, setNewType] = useState('School bus');
  const [newCapacity, setNewCapacity] = useState('36 seats');
  const [newDriver, setNewDriver] = useState('M. Perera');
  const [newRoute, setNewRoute] = useState('North Ridge');
  const [newStatus, setNewStatus] = useState<'In Trip' | 'Delayed' | 'Idle' | 'Offline' | 'Maintenance'>('Idle');

  const [vehiclesList, setVehiclesList] = useState<VehicleRecord[]>(initialVehicles);

  // Filtering
  const filteredVehicles = vehiclesList.filter((vehicle) => {
    // Tab filter
    if (activeTab === 'Active' && (vehicle.status === 'Offline' || vehicle.status === 'Maintenance')) {
      return false;
    }
    if (activeTab === 'In trip' && vehicle.status !== 'In Trip') return false;
    if (activeTab === 'Maintenance' && vehicle.status !== 'Maintenance') return false;
    if (activeTab === 'Inactive' && vehicle.status !== 'Offline') return false;

    // Search filter
    const q = searchQuery.toLowerCase();
    return (
      vehicle.registration.toLowerCase().includes(q) ||
      vehicle.type.toLowerCase().includes(q) ||
      vehicle.driver.toLowerCase().includes(q) ||
      vehicle.route.toLowerCase().includes(q)
    );
  });

  const handleSelectAll = (checked: boolean) => {
    if (checked) {
      setSelectedVehicles(filteredVehicles.map((v) => v.id));
    } else {
      setSelectedVehicles([]);
    }
  };

  const handleToggleSelect = (id: string) => {
    setSelectedVehicles((prev) =>
      prev.includes(id) ? prev.filter((item) => item !== id) : [...prev, id]
    );
  };

  const handleAddVehicle = (e: React.FormEvent) => {
    e.preventDefault();
    const newRecord: VehicleRecord = {
      id: `v_${Date.now()}`,
      registration: newReg,
      type: newType,
      capacity: newCapacity,
      driver: newDriver,
      route: newRoute,
      status: newStatus,
    };
    setVehiclesList((prev) => [newRecord, ...prev]);
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
            Vehicles
          </h1>
          <p className="text-slate-500 text-xs md:text-sm mt-1">
            Maintain fleet records, capacity and operational assignments.
          </p>
        </div>

        {/* Right CTA Button */}
        <button
          type="button"
          onClick={() => setIsAddModalOpen(true)}
          className="inline-flex items-center gap-2 bg-[#3B5DF0] hover:bg-[#2F4DCB] text-white text-xs font-semibold px-4 py-2.5 rounded-xl shadow-sm shadow-[#3B5DF0]/30 transition-all self-start md:self-auto cursor-pointer"
        >
          <Plus className="w-4 h-4" />
          <span>Add vehicle</span>
        </button>
      </div>

      {/* 2. Main White Card Container */}
      <div className="bg-white border border-slate-200/80 rounded-2xl p-6 shadow-xs space-y-6">
        {/* Navigation Tabs */}
        <div className="flex items-center gap-8 border-b border-slate-100 text-xs font-semibold text-slate-500 pb-0">
          {(['All vehicles', 'Active', 'In trip', 'Maintenance', 'Inactive'] as TabType[]).map(
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
              placeholder="Search vehicles..."
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
                      filteredVehicles.length > 0 &&
                      selectedVehicles.length === filteredVehicles.length
                    }
                    onChange={(e) => handleSelectAll(e.target.checked)}
                    className="w-4 h-4 rounded border-slate-300 text-[#3B5DF0] focus:ring-blue-500 cursor-pointer"
                  />
                </th>
                <th className="py-3 px-4 font-bold">REGISTRATION</th>
                <th className="py-3 px-4 font-bold">TYPE</th>
                <th className="py-3 px-4 font-bold">CAPACITY</th>
                <th className="py-3 px-4 font-bold">DRIVER</th>
                <th className="py-3 px-4 font-bold">ROUTE</th>
                <th className="py-3 px-4 font-bold">STATUS</th>
                <th className="py-3 px-4 w-12 text-right"></th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {filteredVehicles.map((vehicle) => {
                const isSelected = selectedVehicles.includes(vehicle.id);
                return (
                  <tr
                    key={vehicle.id}
                    className={cn(
                      'hover:bg-slate-50/70 transition-colors group',
                      isSelected && 'bg-blue-50/30'
                    )}
                  >
                    <td className="py-3.5 px-3">
                      <input
                        type="checkbox"
                        checked={isSelected}
                        onChange={() => handleToggleSelect(vehicle.id)}
                        className="w-4 h-4 rounded border-slate-300 text-[#3B5DF0] focus:ring-blue-500 cursor-pointer"
                      />
                    </td>
                    <td className="py-3.5 px-4 font-bold text-slate-900">
                      <button
                        type="button"
                        onClick={() => navigate('/monitoring')}
                        className="hover:text-[#3B5DF0] hover:underline transition-colors text-left font-bold"
                        title="Locate vehicle on Live Fleet Tracking"
                      >
                        {vehicle.registration}
                      </button>
                    </td>
                    <td className="py-3.5 px-4 text-slate-600 font-medium">
                      {vehicle.type}
                    </td>
                    <td className="py-3.5 px-4 text-slate-600 font-medium">
                      {vehicle.capacity}
                    </td>
                    <td className="py-3.5 px-4 text-slate-600 font-medium">
                      {vehicle.driver}
                    </td>
                    <td className="py-3.5 px-4 text-slate-600 font-medium">
                      {vehicle.route}
                    </td>
                    <td className="py-3.5 px-4">
                      {vehicle.status === 'In Trip' && (
                        <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-semibold bg-slate-100 text-slate-700 border border-slate-200">
                          <span className="w-1.5 h-1.5 rounded-full bg-emerald-500" />
                          In Trip
                        </span>
                      )}
                      {vehicle.status === 'Delayed' && (
                        <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-semibold bg-amber-50 text-amber-700 border border-amber-200">
                          <span className="w-1.5 h-1.5 rounded-full bg-amber-500" />
                          Delayed
                        </span>
                      )}
                      {vehicle.status === 'Idle' && (
                        <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-semibold bg-slate-100 text-slate-600 border border-slate-200">
                          <span className="w-1.5 h-1.5 rounded-full bg-slate-400" />
                          Idle
                        </span>
                      )}
                      {vehicle.status === 'Offline' && (
                        <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-semibold bg-slate-50 text-slate-500 border border-slate-200">
                          <span className="w-1.5 h-1.5 rounded-full bg-slate-400" />
                          Offline
                        </span>
                      )}
                      {vehicle.status === 'Maintenance' && (
                        <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-semibold bg-rose-50 text-rose-700 border border-rose-200">
                          <span className="w-1.5 h-1.5 rounded-full bg-rose-500" />
                          Maintenance
                        </span>
                      )}
                    </td>
                    <td className="py-3.5 px-4 text-right">
                      <button
                        type="button"
                        onClick={() => navigate('/monitoring')}
                        className="p-1 rounded-lg text-slate-400 hover:text-slate-600 hover:bg-slate-100 transition-colors cursor-pointer"
                        title="Vehicle Actions"
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
          <span>Showing {filteredVehicles.length} records</span>

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

      {/* 5. Add Vehicle Modal */}
      {isAddModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-xs p-4">
          <div className="bg-white rounded-2xl shadow-xl border border-slate-200 w-full max-w-lg p-6 space-y-5 animate-in fade-in zoom-in-95 duration-150">
            <div className="flex items-center justify-between pb-3 border-b border-slate-100">
              <div>
                <h3 className="text-base font-extrabold text-slate-900">Add New Vehicle</h3>
                <p className="text-xs text-slate-500 mt-0.5">
                  Register a school bus, mini bus or van to the active fleet.
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

            <form onSubmit={handleAddVehicle} className="space-y-4 text-xs">
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-bold text-slate-700 mb-1">Registration No.</label>
                  <input
                    type="text"
                    value={newReg}
                    onChange={(e) => setNewReg(e.target.value)}
                    required
                    placeholder="e.g. NF-5520"
                    className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 font-bold"
                  />
                </div>

                <div>
                  <label className="block font-bold text-slate-700 mb-1">Vehicle Type</label>
                  <select
                    value={newType}
                    onChange={(e) => setNewType(e.target.value)}
                    className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
                  >
                    <option value="School bus">School bus</option>
                    <option value="Mini bus">Mini bus</option>
                    <option value="Van">Van</option>
                  </select>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-bold text-slate-700 mb-1">Seating Capacity</label>
                  <input
                    type="text"
                    value={newCapacity}
                    onChange={(e) => setNewCapacity(e.target.value)}
                    required
                    placeholder="e.g. 36 seats"
                    className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
                  />
                </div>

                <div>
                  <label className="block font-bold text-slate-700 mb-1">Status</label>
                  <select
                    value={newStatus}
                    onChange={(e) =>
                      setNewStatus(e.target.value as 'In Trip' | 'Delayed' | 'Idle' | 'Offline' | 'Maintenance')
                    }
                    className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
                  >
                    <option value="Idle">Idle</option>
                    <option value="In Trip">In Trip</option>
                    <option value="Delayed">Delayed</option>
                    <option value="Maintenance">Maintenance</option>
                    <option value="Offline">Offline</option>
                  </select>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-bold text-slate-700 mb-1">Assigned Driver</label>
                  <select
                    value={newDriver}
                    onChange={(e) => setNewDriver(e.target.value)}
                    className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
                  >
                    <option value="M. Perera">M. Perera</option>
                    <option value="R. Silva">R. Silva</option>
                    <option value="A. Fernando">A. Fernando</option>
                    <option value="Unassigned">Unassigned</option>
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
                    <option value="—">— (None)</option>
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
                  <span>Save Vehicle</span>
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
