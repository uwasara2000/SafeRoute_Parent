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

interface TripRecord {
  id: string;
  tripCode: string;
  route: string;
  vehicle: string;
  driver: string;
  startTime: string;
  status: 'In Progress' | 'Delayed' | 'Completed' | 'Scheduled' | 'Cancelled';
}

const initialTrips: TripRecord[] = [
  {
    id: 't1',
    tripCode: 'TR-1042',
    route: 'North Ridge AM',
    vehicle: 'NB-2341',
    driver: 'M. Perera',
    startTime: '07:10',
    status: 'In Progress',
  },
  {
    id: 't2',
    tripCode: 'TR-1041',
    route: 'Lakeside AM',
    vehicle: 'NC-8872',
    driver: 'R. Silva',
    startTime: '06:55',
    status: 'Delayed',
  },
  {
    id: 't3',
    tripCode: 'TR-1040',
    route: 'Hillview AM',
    vehicle: 'ND-4105',
    driver: 'A. Fernando',
    startTime: '06:45',
    status: 'Completed',
  },
  {
    id: 't4',
    tripCode: 'TR-1052',
    route: 'North Ridge PM',
    vehicle: 'NB-2341',
    driver: 'M. Perera',
    startTime: '13:30',
    status: 'Scheduled',
  },
];

type TabType = 'All trips' | 'Active' | 'Scheduled' | 'Completed' | 'Cancelled';

export default function JourneysPage() {
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = useState<TabType>('All trips');
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedTrips, setSelectedTrips] = useState<string[]>([]);
  const [isScheduleModalOpen, setIsScheduleModalOpen] = useState(false);

  // Form State for new trip modal
  const [newTripCode, setNewTripCode] = useState('TR-1055');
  const [newRoute, setNewRoute] = useState('North Ridge PM');
  const [newVehicle, setNewVehicle] = useState('NB-2341');
  const [newDriver, setNewDriver] = useState('M. Perera');
  const [newStartTime, setNewStartTime] = useState('14:15');

  const [tripsList, setTripsList] = useState<TripRecord[]>(initialTrips);

  // Filter tabs and search
  const filteredTrips = tripsList.filter((trip) => {
    // Tab filtering
    if (activeTab === 'Active' && !(trip.status === 'In Progress' || trip.status === 'Delayed')) {
      return false;
    }
    if (activeTab === 'Scheduled' && trip.status !== 'Scheduled') return false;
    if (activeTab === 'Completed' && trip.status !== 'Completed') return false;
    if (activeTab === 'Cancelled' && trip.status !== 'Cancelled') return false;

    // Search query
    const q = searchQuery.toLowerCase();
    return (
      trip.tripCode.toLowerCase().includes(q) ||
      trip.route.toLowerCase().includes(q) ||
      trip.vehicle.toLowerCase().includes(q) ||
      trip.driver.toLowerCase().includes(q)
    );
  });

  const handleSelectAll = (checked: boolean) => {
    if (checked) {
      setSelectedTrips(filteredTrips.map((t) => t.id));
    } else {
      setSelectedTrips([]);
    }
  };

  const handleToggleSelect = (id: string) => {
    setSelectedTrips((prev) =>
      prev.includes(id) ? prev.filter((item) => item !== id) : [...prev, id]
    );
  };

  const handleCreateTrip = (e: React.FormEvent) => {
    e.preventDefault();
    const newRecord: TripRecord = {
      id: `t_${Date.now()}`,
      tripCode: newTripCode,
      route: newRoute,
      vehicle: newVehicle,
      driver: newDriver,
      startTime: newStartTime,
      status: 'Scheduled',
    };
    setTripsList((prev) => [newRecord, ...prev]);
    setIsScheduleModalOpen(false);
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
            Trips
          </h1>
          <p className="text-slate-500 text-xs md:text-sm mt-1">
            Schedule, assign and monitor every school transport journey.
          </p>
        </div>

        {/* Right CTA Button */}
        <button
          type="button"
          onClick={() => setIsScheduleModalOpen(true)}
          className="inline-flex items-center gap-2 bg-[#3B5DF0] hover:bg-[#2F4DCB] text-white text-xs font-semibold px-4 py-2.5 rounded-xl shadow-sm shadow-[#3B5DF0]/30 transition-all self-start md:self-auto cursor-pointer"
        >
          <Plus className="w-4 h-4" />
          <span>Schedule trip</span>
        </button>
      </div>

      {/* 2. Main White Card Container */}
      <div className="bg-white border border-slate-200/80 rounded-2xl p-6 shadow-xs space-y-6">
        {/* Navigation Tabs */}
        <div className="flex items-center gap-8 border-b border-slate-100 text-xs font-semibold text-slate-500 pb-0">
          {(['All trips', 'Active', 'Scheduled', 'Completed', 'Cancelled'] as TabType[]).map(
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
              placeholder="Search trips..."
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
                      filteredTrips.length > 0 &&
                      selectedTrips.length === filteredTrips.length
                    }
                    onChange={(e) => handleSelectAll(e.target.checked)}
                    className="w-4 h-4 rounded border-slate-300 text-[#3B5DF0] focus:ring-blue-500 cursor-pointer"
                  />
                </th>
                <th className="py-3 px-4 font-bold">TRIP</th>
                <th className="py-3 px-4 font-bold">ROUTE</th>
                <th className="py-3 px-4 font-bold">VEHICLE</th>
                <th className="py-3 px-4 font-bold">DRIVER</th>
                <th className="py-3 px-4 font-bold">START</th>
                <th className="py-3 px-4 font-bold">STATUS</th>
                <th className="py-3 px-4 w-12 text-right"></th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {filteredTrips.map((trip) => {
                const isSelected = selectedTrips.includes(trip.id);
                return (
                  <tr
                    key={trip.id}
                    className={cn(
                      'hover:bg-slate-50/70 transition-colors group',
                      isSelected && 'bg-blue-50/30'
                    )}
                  >
                    <td className="py-3.5 px-3">
                      <input
                        type="checkbox"
                        checked={isSelected}
                        onChange={() => handleToggleSelect(trip.id)}
                        className="w-4 h-4 rounded border-slate-300 text-[#3B5DF0] focus:ring-blue-500 cursor-pointer"
                      />
                    </td>
                    <td className="py-3.5 px-4 font-bold text-slate-900">
                      <button
                        type="button"
                        onClick={() => navigate('/monitoring')}
                        className="hover:text-[#3B5DF0] hover:underline transition-colors text-left font-bold"
                        title="View on Live Fleet Tracking"
                      >
                        {trip.tripCode}
                      </button>
                    </td>
                    <td className="py-3.5 px-4 text-slate-600 font-medium">
                      {trip.route}
                    </td>
                    <td className="py-3.5 px-4 text-slate-600 font-medium">
                      {trip.vehicle}
                    </td>
                    <td className="py-3.5 px-4 text-slate-600 font-medium">
                      {trip.driver}
                    </td>
                    <td className="py-3.5 px-4 text-slate-600 font-medium">
                      {trip.startTime}
                    </td>
                    <td className="py-3.5 px-4">
                      {trip.status === 'In Progress' && (
                        <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-semibold bg-slate-100 text-slate-700 border border-slate-200">
                          <span className="w-1.5 h-1.5 rounded-full bg-emerald-500" />
                          In Progress
                        </span>
                      )}
                      {trip.status === 'Delayed' && (
                        <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-semibold bg-amber-50 text-amber-700 border border-amber-200">
                          <span className="w-1.5 h-1.5 rounded-full bg-amber-500" />
                          Delayed
                        </span>
                      )}
                      {trip.status === 'Completed' && (
                        <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-semibold bg-emerald-50 text-emerald-700 border border-emerald-200">
                          <span className="w-1.5 h-1.5 rounded-full bg-emerald-500" />
                          Completed
                        </span>
                      )}
                      {trip.status === 'Scheduled' && (
                        <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-semibold bg-slate-100 text-slate-600 border border-slate-200">
                          <span className="w-1.5 h-1.5 rounded-full bg-slate-400" />
                          Scheduled
                        </span>
                      )}
                      {trip.status === 'Cancelled' && (
                        <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-semibold bg-rose-50 text-rose-700 border border-rose-200">
                          <span className="w-1.5 h-1.5 rounded-full bg-rose-500" />
                          Cancelled
                        </span>
                      )}
                    </td>
                    <td className="py-3.5 px-4 text-right">
                      <button
                        type="button"
                        onClick={() => navigate('/monitoring')}
                        className="p-1 rounded-lg text-slate-400 hover:text-slate-600 hover:bg-slate-100 transition-colors cursor-pointer"
                        title="Actions"
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
          <span>Showing {filteredTrips.length} records</span>

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

      {/* 5. Schedule Trip Modal */}
      {isScheduleModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-xs p-4">
          <div className="bg-white rounded-2xl shadow-xl border border-slate-200 w-full max-w-lg p-6 space-y-5 animate-in fade-in zoom-in-95 duration-150">
            <div className="flex items-center justify-between pb-3 border-b border-slate-100">
              <div>
                <h3 className="text-base font-extrabold text-slate-900">Schedule New Trip</h3>
                <p className="text-xs text-slate-500 mt-0.5">
                  Assign route, vehicle, and driver for a school transport run.
                </p>
              </div>
              <button
                type="button"
                onClick={() => setIsScheduleModalOpen(false)}
                className="p-1 rounded-lg text-slate-400 hover:text-slate-600 hover:bg-slate-100 transition-colors cursor-pointer"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleCreateTrip} className="space-y-4 text-xs">
              <div>
                <label className="block font-bold text-slate-700 mb-1">Trip Code</label>
                <input
                  type="text"
                  value={newTripCode}
                  onChange={(e) => setNewTripCode(e.target.value)}
                  required
                  className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-bold text-slate-700 mb-1">Route</label>
                  <select
                    value={newRoute}
                    onChange={(e) => setNewRoute(e.target.value)}
                    className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
                  >
                    <option value="North Ridge AM">North Ridge AM</option>
                    <option value="North Ridge PM">North Ridge PM</option>
                    <option value="Lakeside AM">Lakeside AM</option>
                    <option value="Lakeside PM">Lakeside PM</option>
                    <option value="Hillview AM">Hillview AM</option>
                    <option value="Hillview PM">Hillview PM</option>
                  </select>
                </div>

                <div>
                  <label className="block font-bold text-slate-700 mb-1">Vehicle</label>
                  <select
                    value={newVehicle}
                    onChange={(e) => setNewVehicle(e.target.value)}
                    className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
                  >
                    <option value="NB-2341">NB-2341</option>
                    <option value="NC-8872">NC-8872</option>
                    <option value="ND-4105">ND-4105</option>
                    <option value="NE-0218">NE-0218</option>
                  </select>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-bold text-slate-700 mb-1">Driver</label>
                  <select
                    value={newDriver}
                    onChange={(e) => setNewDriver(e.target.value)}
                    className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
                  >
                    <option value="M. Perera">M. Perera</option>
                    <option value="R. Silva">R. Silva</option>
                    <option value="A. Fernando">A. Fernando</option>
                  </select>
                </div>

                <div>
                  <label className="block font-bold text-slate-700 mb-1">Start Time</label>
                  <input
                    type="time"
                    value={newStartTime}
                    onChange={(e) => setNewStartTime(e.target.value)}
                    required
                    className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
                  />
                </div>
              </div>

              <div className="pt-3 border-t border-slate-100 flex items-center justify-end gap-2.5">
                <button
                  type="button"
                  onClick={() => setIsScheduleModalOpen(false)}
                  className="px-4 py-2 rounded-xl border border-slate-200 text-slate-700 font-semibold hover:bg-slate-50 transition-colors cursor-pointer"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="inline-flex items-center gap-1.5 px-4 py-2 rounded-xl bg-[#3B5DF0] hover:bg-[#2F4DCB] text-white font-semibold shadow-xs transition-colors cursor-pointer"
                >
                  <Check className="w-4 h-4" />
                  <span>Save Trip</span>
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
