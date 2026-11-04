import { useState } from 'react';
import { Search, ChevronDown, Plus, Minus, X } from 'lucide-react';
import { cn } from '@/utils/cn';

interface VehicleItem {
  id: string;
  regNumber: string;
  route: string;
  gpsTime: string;
  status: 'In Trip' | 'Delayed' | 'Idle' | 'GPS Unavailable';
  driver: string;
  attendant: string;
  tripId: string;
  eta: string;
  students: string;
  mapPinNumber?: number;
  mapX?: string;
  mapY?: string;
  pinColor?: 'green' | 'orange' | 'gray';
}

const vehiclesData: VehicleItem[] = [
  {
    id: 'v1',
    regNumber: 'NB-2341',
    route: 'North Ridge AM',
    gpsTime: 'GPS 1 min ago',
    status: 'In Trip',
    driver: 'Malith Perera',
    attendant: 'Nimali Jayasekara',
    tripId: 'TR-1042',
    eta: '07:52 - estimate only',
    students: '24 / 32 seats',
    mapPinNumber: 24,
    mapX: '48%',
    mapY: '44%',
    pinColor: 'green',
  },
  {
    id: 'v2',
    regNumber: 'NC-8872',
    route: 'Lakeside AM',
    gpsTime: 'GPS 3 min ago',
    status: 'Delayed',
    driver: 'Saman Kumara',
    attendant: 'Kamal Bandara',
    tripId: 'TR-1048',
    eta: '08:05 - estimate only',
    students: '28 / 32 seats',
    mapPinNumber: 18,
    mapX: '65%',
    mapY: '60%',
    pinColor: 'orange',
  },
  {
    id: 'v3',
    regNumber: 'ND-4105',
    route: 'Hillview AM',
    gpsTime: 'GPS 8 min ago',
    status: 'Idle',
    driver: 'Nuwan Pradeep',
    attendant: 'Anoma Wickrama',
    tripId: 'TR-1051',
    eta: 'Standby at Depot',
    students: '0 / 28 seats',
    mapPinNumber: 31,
    mapX: '60%',
    mapY: '78%',
    pinColor: 'green',
  },
  {
    id: 'v4',
    regNumber: 'NE-0218',
    route: 'Unassigned',
    gpsTime: 'No successful update',
    status: 'GPS Unavailable',
    driver: 'Not Assigned',
    attendant: 'Not Assigned',
    tripId: 'None',
    eta: 'Offline',
    students: '0 / 30 seats',
    pinColor: 'gray',
  },
];

export default function MonitoringPage() {
  const [selectedVehicle, setSelectedVehicle] = useState<VehicleItem>(vehiclesData[0]);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedStatus, setSelectedStatus] = useState<string>('All statuses');
  const [zoomLevel, setZoomLevel] = useState(1);
  const [isDetailOpen, setIsDetailOpen] = useState(true);

  // Filter vehicles
  const filteredVehicles = vehiclesData.filter((v) => {
    const matchesSearch =
      v.regNumber.toLowerCase().includes(searchQuery.toLowerCase()) ||
      v.driver.toLowerCase().includes(searchQuery.toLowerCase()) ||
      v.route.toLowerCase().includes(searchQuery.toLowerCase());

    const matchesStatus =
      selectedStatus === 'All statuses' || v.status === selectedStatus;

    return matchesSearch && matchesStatus;
  });

  return (
    <div className="w-full h-full p-8 flex flex-col space-y-6 max-w-[1600px] mx-auto overflow-x-hidden">
      {/* 1. Header Section */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 shrink-0">
        <div>
          <span className="text-[11px] font-bold tracking-wider text-[#3B5DF0] uppercase">
            TRANSPORT OPERATIONS
          </span>
          <h1 className="text-2xl md:text-3xl font-extrabold text-slate-900 mt-1 tracking-tight">
            Live Fleet Tracking
          </h1>
          <p className="text-slate-500 text-xs md:text-sm mt-1">
            Monitor only locations successfully received from assigned vehicles.
          </p>
        </div>

        {/* Right CTA Button */}
        <button
          type="button"
          className="inline-flex items-center gap-2 bg-[#3B5DF0] hover:bg-[#2F4DCB] text-white text-xs font-semibold px-4 py-2.5 rounded-xl shadow-sm shadow-[#3B5DF0]/30 transition-all self-start md:self-auto cursor-pointer"
        >
          <Plus className="w-4 h-4" />
          <span>Report fleet issue</span>
        </button>
      </div>

      {/* 2. Search & Filter Bar */}
      <div className="flex flex-col sm:flex-row items-center justify-between gap-4 shrink-0">
        <div className="flex items-center gap-3 w-full sm:w-auto">
          {/* Search box */}
          <div className="relative w-full sm:w-80">
            <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search registration, driver or route"
              className="w-full pl-9 pr-4 py-2 text-xs bg-white border border-slate-200/90 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 placeholder:text-slate-400 text-slate-700 shadow-2xs transition-all"
            />
          </div>

          {/* Status Filter Dropdown */}
          <div className="relative">
            <select
              value={selectedStatus}
              onChange={(e) => setSelectedStatus(e.target.value)}
              className="appearance-none bg-white border border-slate-200/90 rounded-xl pl-4 pr-9 py-2 text-xs font-semibold text-slate-700 focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 shadow-2xs cursor-pointer"
            >
              <option value="All statuses">All statuses</option>
              <option value="In Trip">In Trip</option>
              <option value="Delayed">Delayed</option>
              <option value="Idle">Idle</option>
              <option value="GPS Unavailable">GPS Unavailable</option>
            </select>
            <ChevronDown className="absolute right-3 top-1/2 -translate-y-1/2 w-3.5 h-3.5 text-slate-400 pointer-events-none" />
          </div>
        </div>

        {/* Prototype indicator tag */}
        <div className="flex items-center gap-2 self-end sm:self-auto">
          <span className="w-2 h-2 rounded-full bg-[#F59E0B]" />
          <span className="text-[11px] font-medium text-slate-400">
            Prototype sample - not live
          </span>
        </div>
      </div>

      {/* 3. Main 3-Column Monitoring Workspace */}
      <div className="flex-1 grid grid-cols-1 lg:grid-cols-12 gap-5 min-h-[560px]">
        {/* Column 1: Vehicles List (3 of 12 cols) */}
        <div className="lg:col-span-3 bg-white border border-slate-200/80 rounded-2xl p-4 shadow-xs flex flex-col">
          <div className="flex items-center justify-between pb-3 mb-2 border-b border-slate-100">
            <h2 className="text-xs font-bold text-slate-800 uppercase tracking-wider">
              Vehicles
            </h2>
            <span className="text-xs text-slate-400 font-medium">24 total</span>
          </div>

          {/* List */}
          <div className="flex-1 overflow-y-auto space-y-2 pr-1 scrollbar-thin">
            {filteredVehicles.map((vehicle) => {
              const isSelected = selectedVehicle.id === vehicle.id;
              return (
                <div
                  key={vehicle.id}
                  onClick={() => {
                    setSelectedVehicle(vehicle);
                    setIsDetailOpen(true);
                  }}
                  className={cn(
                    'p-3 rounded-xl border transition-all cursor-pointer relative',
                    isSelected
                      ? 'bg-blue-50/40 border-blue-400 shadow-xs ring-1 ring-blue-400/40'
                      : 'bg-white border-slate-100 hover:border-slate-200 hover:bg-slate-50/60'
                  )}
                >
                  {isSelected && (
                    <div className="absolute left-0 top-2 bottom-2 w-1 bg-[#3B5DF0] rounded-r" />
                  )}
                  <div className="flex items-start justify-between gap-2">
                    <div className="flex items-start gap-2.5">
                      <div className="w-7 h-7 rounded-lg bg-blue-50 text-[#3B5DF0] font-bold text-xs flex items-center justify-center shrink-0 mt-0.5">
                        B
                      </div>
                      <div>
                        <p className="text-xs font-bold text-slate-900 leading-tight">
                          {vehicle.regNumber}
                        </p>
                        <p className="text-[11px] text-slate-500 mt-0.5">{vehicle.route}</p>
                        <p className="text-[10px] text-slate-400 mt-1">{vehicle.gpsTime}</p>
                      </div>
                    </div>

                    {/* Status Pill */}
                    <div className="shrink-0">
                      {vehicle.status === 'In Trip' && (
                        <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[10px] font-semibold bg-slate-100 text-slate-700 border border-slate-200">
                          <span className="w-1.5 h-1.5 rounded-full bg-emerald-500" />
                          In Trip
                        </span>
                      )}
                      {vehicle.status === 'Delayed' && (
                        <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[10px] font-semibold bg-amber-50 text-amber-700 border border-amber-200">
                          <span className="w-1.5 h-1.5 rounded-full bg-amber-500" />
                          Delayed
                        </span>
                      )}
                      {vehicle.status === 'Idle' && (
                        <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[10px] font-semibold bg-slate-50 text-slate-600 border border-slate-200">
                          <span className="w-1.5 h-1.5 rounded-full bg-slate-400" />
                          Idle
                        </span>
                      )}
                      {vehicle.status === 'GPS Unavailable' && (
                        <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[10px] font-semibold bg-slate-50 text-slate-500 border border-slate-200">
                          <span className="w-1.5 h-1.5 rounded-full bg-slate-400" />
                          GPS Unavailable
                        </span>
                      )}
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* Column 2: Interactive Vector Map View (6 or 9 of 12 cols depending on detail panel) */}
        <div
          className={cn(
            'bg-white border border-slate-200/80 rounded-2xl overflow-hidden shadow-xs relative flex flex-col transition-all',
            isDetailOpen ? 'lg:col-span-6' : 'lg:col-span-9'
          )}
        >
          {/* Map canvas */}
          <div className="relative w-full h-full min-h-[500px] bg-[#EFF4EE] select-none overflow-hidden">
            <svg
              className="w-full h-full object-cover transition-transform duration-300"
              style={{ transform: `scale(${zoomLevel})` }}
              viewBox="0 0 800 600"
              preserveAspectRatio="xMidYMid slice"
            >
              <defs>
                <pattern
                  id="fleet-map-grid"
                  width="36"
                  height="36"
                  patternUnits="userSpaceOnUse"
                >
                  <path
                    d="M 36 0 L 0 0 0 36"
                    fill="none"
                    stroke="#E3EAE1"
                    strokeWidth="1"
                  />
                </pattern>
              </defs>
              <rect width="100%" height="100%" fill="#EEF4EC" />
              <rect width="100%" height="100%" fill="url(#fleet-map-grid)" />

              {/* Major Roads */}
              <line
                x1="-50"
                y1="480"
                x2="850"
                y2="120"
                stroke="#FFFFFF"
                strokeWidth="28"
                strokeLinecap="round"
              />
              <line
                x1="360"
                y1="-20"
                x2="480"
                y2="620"
                stroke="#FFFFFF"
                strokeWidth="22"
                strokeLinecap="round"
              />
              <line
                x1="120"
                y1="-20"
                x2="780"
                y2="620"
                stroke="#FFFFFF"
                strokeWidth="20"
                strokeLinecap="round"
              />
              <line
                x1="-20"
                y1="220"
                x2="820"
                y2="420"
                stroke="#FFFFFF"
                strokeWidth="16"
                strokeLinecap="round"
              />

              {/* Road Casing Borders */}
              <line
                x1="-50"
                y1="480"
                x2="850"
                y2="120"
                stroke="#E2E7DF"
                strokeWidth="2"
              />
              <line
                x1="360"
                y1="-20"
                x2="480"
                y2="620"
                stroke="#E2E7DF"
                strokeWidth="2"
              />

              {/* ACTIVE BLUE ROUTE LINE matching Figma */}
              <line
                x1="260"
                y1="270"
                x2="620"
                y2="385"
                stroke="#4F6EF7"
                strokeWidth="5"
                strokeLinecap="round"
              />

              {/* Landmark Labels */}
              <text
                x="340"
                y="190"
                fill="#525B6A"
                fontSize="12"
                fontWeight="700"
                fontFamily="sans-serif"
              >
                North Ridge
              </text>
              <text
                x="430"
                y="350"
                fill="#525B6A"
                fontSize="12"
                fontWeight="700"
                fontFamily="sans-serif"
              >
                Lakeland College
              </text>
            </svg>

            {/* Vehicle Pin 24 on Map */}
            <div
              onClick={() => {
                const target = vehiclesData.find((v) => v.regNumber === 'NB-2341');
                if (target) {
                  setSelectedVehicle(target);
                  setIsDetailOpen(true);
                }
              }}
              className="absolute left-[48%] top-[44%] -translate-x-1/2 -translate-y-1/2 cursor-pointer group"
              title="NB-2341 (Bus 24)"
            >
              <div
                className={cn(
                  'w-8 h-8 rounded-lg bg-[#0D8B75] rotate-45 flex items-center justify-center shadow-lg border-2 border-white transition-all group-hover:scale-125',
                  selectedVehicle.regNumber === 'NB-2341' && 'ring-4 ring-blue-500/50 scale-110'
                )}
              >
                <span className="-rotate-45 text-white font-bold text-[11px]">24</span>
              </div>
            </div>

            {/* Vehicle Pin 18 on Map */}
            <div
              onClick={() => {
                const target = vehiclesData.find((v) => v.regNumber === 'NC-8872');
                if (target) {
                  setSelectedVehicle(target);
                  setIsDetailOpen(true);
                }
              }}
              className="absolute left-[65%] top-[60%] -translate-x-1/2 -translate-y-1/2 cursor-pointer group"
              title="NC-8872 (Bus 18)"
            >
              <div
                className={cn(
                  'w-8 h-8 rounded-lg bg-[#EA8A24] rotate-45 flex items-center justify-center shadow-lg border-2 border-white transition-all group-hover:scale-125',
                  selectedVehicle.regNumber === 'NC-8872' && 'ring-4 ring-orange-500/50 scale-110'
                )}
              >
                <span className="-rotate-45 text-white font-bold text-[11px]">18</span>
              </div>
            </div>

            {/* Vehicle Pin 31 on Map */}
            <div
              onClick={() => {
                const target = vehiclesData.find((v) => v.regNumber === 'ND-4105');
                if (target) {
                  setSelectedVehicle(target);
                  setIsDetailOpen(true);
                }
              }}
              className="absolute left-[60%] top-[78%] -translate-x-1/2 -translate-y-1/2 cursor-pointer group"
              title="ND-4105 (Bus 31)"
            >
              <div
                className={cn(
                  'w-8 h-8 rounded-lg bg-[#0D8B75] rotate-45 flex items-center justify-center shadow-lg border-2 border-white transition-all group-hover:scale-125',
                  selectedVehicle.regNumber === 'ND-4105' && 'ring-4 ring-blue-500/50 scale-110'
                )}
              >
                <span className="-rotate-45 text-white font-bold text-[11px]">31</span>
              </div>
            </div>

            {/* Floating Zoom Controls (+ / -) */}
            <div className="absolute top-4 right-4 bg-white rounded-xl shadow-md border border-slate-200/90 flex flex-col divide-y divide-slate-100 overflow-hidden z-10">
              <button
                type="button"
                onClick={() => setZoomLevel((z) => Math.min(z + 0.2, 1.8))}
                className="w-9 h-9 flex items-center justify-center text-slate-700 hover:bg-slate-50 transition-colors cursor-pointer"
                title="Zoom in"
              >
                <Plus className="w-4 h-4" />
              </button>
              <button
                type="button"
                onClick={() => setZoomLevel((z) => Math.max(z - 0.2, 0.8))}
                className="w-9 h-9 flex items-center justify-center text-slate-700 hover:bg-slate-50 transition-colors cursor-pointer"
                title="Zoom out"
              >
                <Minus className="w-4 h-4" />
              </button>
            </div>
          </div>
        </div>

        {/* Column 3: Selected Vehicle Details Card (3 of 12 cols) */}
        {isDetailOpen && (
          <div className="lg:col-span-3 bg-white border border-slate-200/80 rounded-2xl p-5 shadow-xs flex flex-col justify-between">
            <div className="space-y-4">
              {/* Header with Title & Close button */}
              <div className="flex items-start justify-between">
                <div className="flex items-center gap-3">
                  <div className="w-8 h-8 rounded-lg bg-blue-50 text-[#3B5DF0] font-bold text-xs flex items-center justify-center shrink-0">
                    B
                  </div>
                  <div>
                    <h3 className="text-base font-extrabold text-slate-900 leading-tight">
                      {selectedVehicle.regNumber}
                    </h3>
                    <div className="mt-1">
                      {selectedVehicle.status === 'In Trip' && (
                        <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[10px] font-semibold bg-slate-100 text-slate-700 border border-slate-200">
                          <span className="w-1.5 h-1.5 rounded-full bg-emerald-500" />
                          In Trip
                        </span>
                      )}
                      {selectedVehicle.status === 'Delayed' && (
                        <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[10px] font-semibold bg-amber-50 text-amber-700 border border-amber-200">
                          <span className="w-1.5 h-1.5 rounded-full bg-amber-500" />
                          Delayed
                        </span>
                      )}
                      {selectedVehicle.status === 'Idle' && (
                        <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[10px] font-semibold bg-slate-50 text-slate-600 border border-slate-200">
                          <span className="w-1.5 h-1.5 rounded-full bg-slate-400" />
                          Idle
                        </span>
                      )}
                      {selectedVehicle.status === 'GPS Unavailable' && (
                        <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[10px] font-semibold bg-slate-50 text-slate-500 border border-slate-200">
                          <span className="w-1.5 h-1.5 rounded-full bg-slate-400" />
                          GPS Unavailable
                        </span>
                      )}
                    </div>
                  </div>
                </div>

                <button
                  type="button"
                  onClick={() => setIsDetailOpen(false)}
                  className="p-1 rounded-lg text-slate-400 hover:text-slate-600 hover:bg-slate-100 transition-colors cursor-pointer"
                  title="Close panel"
                >
                  <X className="w-4 h-4" />
                </button>
              </div>

              {/* GPS Alert / Timestamp Card */}
              <div className="bg-[#FFFBEB] border border-[#FDE68A] rounded-xl p-3 text-left">
                <p className="text-xs font-bold text-amber-900 leading-tight">
                  {selectedVehicle.gpsTime}
                </p>
                <p className="text-[11px] text-amber-800/80 mt-1">
                  Last known location is clearly timestamped.
                </p>
              </div>

              {/* Metadata rows */}
              <div className="divide-y divide-slate-100 text-xs">
                <div className="py-2.5 flex items-center justify-between">
                  <span className="text-slate-400 font-medium">Assigned driver</span>
                  <span className="font-bold text-slate-800">{selectedVehicle.driver}</span>
                </div>
                <div className="py-2.5 flex items-center justify-between">
                  <span className="text-slate-400 font-medium">Attendant</span>
                  <span className="font-bold text-slate-800">{selectedVehicle.attendant}</span>
                </div>
                <div className="py-2.5 flex items-center justify-between">
                  <span className="text-slate-400 font-medium">Active route</span>
                  <span className="font-bold text-slate-800">{selectedVehicle.route}</span>
                </div>
                <div className="py-2.5 flex items-center justify-between">
                  <span className="text-slate-400 font-medium">Current trip</span>
                  <span className="font-bold text-slate-800">{selectedVehicle.tripId}</span>
                </div>
                <div className="py-2.5 flex items-center justify-between">
                  <span className="text-slate-400 font-medium">Estimated arrival</span>
                  <span className="font-bold text-slate-800 text-[11px]">
                    {selectedVehicle.eta}
                  </span>
                </div>
                <div className="py-2.5 flex items-center justify-between">
                  <span className="text-slate-400 font-medium">Students</span>
                  <span className="font-bold text-slate-800">{selectedVehicle.students}</span>
                </div>
              </div>
            </div>

            {/* Action Buttons (2x2 Grid) */}
            <div className="grid grid-cols-2 gap-2.5 pt-4 mt-2 border-t border-slate-100">
              <button
                type="button"
                className="w-full py-2.5 px-3 rounded-xl bg-[#3B5DF0] hover:bg-[#2F4DCB] text-white text-xs font-semibold shadow-xs transition-colors cursor-pointer text-center"
              >
                View trip
              </button>

              <button
                type="button"
                className="w-full py-2.5 px-3 rounded-xl border border-slate-200 bg-white hover:bg-slate-50 text-slate-700 text-xs font-semibold shadow-2xs transition-colors cursor-pointer text-center"
              >
                View route
              </button>

              <button
                type="button"
                className="w-full py-2.5 px-3 rounded-xl border border-slate-200 bg-white hover:bg-slate-50 text-slate-700 text-xs font-semibold shadow-2xs transition-colors cursor-pointer text-center"
              >
                Contact driver
              </button>

              <button
                type="button"
                className="w-full py-2.5 px-3 rounded-xl border border-rose-200 bg-rose-50/50 hover:bg-rose-50 text-rose-600 text-xs font-semibold shadow-2xs transition-colors cursor-pointer text-center"
              >
                Report issue
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
