import { useNavigate } from 'react-router-dom';
import { Plus, ChevronRight, ArrowRight } from 'lucide-react';

export default function DashboardPage() {
  const navigate = useNavigate();

  return (
    <div className="w-full p-8 space-y-6 max-w-[1600px] mx-auto overflow-x-hidden">
      {/* 1. Page Header & Greeting */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <span className="text-[11px] font-bold tracking-wider text-[#3B5DF0] uppercase">
            TRANSPORT OPERATIONS
          </span>
          <h1 className="text-2xl md:text-3xl font-extrabold text-slate-900 mt-1 tracking-tight">
            Good morning, Dinuka
          </h1>
          <p className="text-slate-500 text-xs md:text-sm mt-1">
            Here is the sample operational picture for Tuesday, 17 June.
          </p>
          <div className="flex items-center gap-2 mt-2">
            <span className="bg-[#EEF2FF] text-[#3B5DF0] text-[10px] font-bold px-2 py-0.5 rounded">
              DEMO DATA
            </span>
            <span className="text-[11px] text-slate-400">
              Updated in prototype 2 minutes ago — not a live service
            </span>
          </div>
        </div>

        {/* Right CTA Button: Navigates to Live Fleet Tracking */}
        <button
          type="button"
          onClick={() => navigate('/monitoring')}
          className="inline-flex items-center gap-2 bg-[#3B5DF0] hover:bg-[#2F4DCB] text-white text-xs font-semibold px-4 py-2.5 rounded-xl shadow-sm shadow-[#3B5DF0]/30 transition-all self-start md:self-auto cursor-pointer"
        >
          <Plus className="w-4 h-4" />
          <span>Open live fleet</span>
        </button>
      </div>

      {/* 2. Six Key Metrics Cards */}
      <div className="grid grid-cols-2 md:grid-cols-3 xl:grid-cols-6 gap-3.5">
        {/* Metric 1: Total vehicles */}
        <div
          onClick={() => navigate('/buses')}
          className="bg-white border border-slate-200/80 rounded-2xl p-4 shadow-xs hover:shadow-sm hover:border-slate-300 transition-all cursor-pointer"
        >
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <span className="w-7 h-7 rounded-lg bg-indigo-50 text-indigo-600 font-bold text-xs flex items-center justify-center shrink-0">
                V
              </span>
              <span className="text-xs font-medium text-slate-600 truncate">Total vehicles</span>
            </div>
            <ChevronRight className="w-3.5 h-3.5 text-slate-300 shrink-0" />
          </div>
          <p className="text-2xl font-extrabold text-slate-900 mt-3">24</p>
          <p className="text-[11px] text-slate-400 mt-1">3 require attention</p>
        </div>

        {/* Metric 2: Active trips */}
        <div
          onClick={() => navigate('/journeys')}
          className="bg-white border border-slate-200/80 rounded-2xl p-4 shadow-xs hover:shadow-sm hover:border-slate-300 transition-all cursor-pointer"
        >
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <span className="w-7 h-7 rounded-lg bg-purple-50 text-purple-600 font-bold text-xs flex items-center justify-center shrink-0">
                T
              </span>
              <span className="text-xs font-medium text-slate-600 truncate">Active trips</span>
            </div>
            <ChevronRight className="w-3.5 h-3.5 text-slate-300 shrink-0" />
          </div>
          <p className="text-2xl font-extrabold text-slate-900 mt-3">8</p>
          <p className="text-[11px] text-slate-400 mt-1">6 on time</p>
        </div>

        {/* Metric 3: Students on board */}
        <div
          onClick={() => navigate('/students')}
          className="bg-white border border-slate-200/80 rounded-2xl p-4 shadow-xs hover:shadow-sm hover:border-slate-300 transition-all cursor-pointer"
        >
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <span className="w-7 h-7 rounded-lg bg-emerald-50 text-emerald-600 font-bold text-xs flex items-center justify-center shrink-0">
                S
              </span>
              <span className="text-xs font-medium text-slate-600 truncate">Students on board</span>
            </div>
            <ChevronRight className="w-3.5 h-3.5 text-slate-300 shrink-0" />
          </div>
          <p className="text-2xl font-extrabold text-slate-900 mt-3">143</p>
          <p className="text-[11px] text-slate-400 mt-1">Across 8 active trips</p>
        </div>

        {/* Metric 4: Reported absences */}
        <div
          onClick={() => navigate('/assignments')}
          className="bg-white border border-slate-200/80 rounded-2xl p-4 shadow-xs hover:shadow-sm hover:border-slate-300 transition-all cursor-pointer"
        >
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <span className="w-7 h-7 rounded-lg bg-violet-50 text-violet-600 font-bold text-xs flex items-center justify-center shrink-0">
                A
              </span>
              <span className="text-xs font-medium text-slate-600 truncate">Reported absences</span>
            </div>
            <ChevronRight className="w-3.5 h-3.5 text-slate-300 shrink-0" />
          </div>
          <p className="text-2xl font-extrabold text-slate-900 mt-3">12</p>
          <p className="text-[11px] text-slate-400 mt-1">Today</p>
        </div>

        {/* Metric 5: Delayed trips */}
        <div
          onClick={() => navigate('/monitoring')}
          className="bg-white border border-slate-200/80 rounded-2xl p-4 shadow-xs hover:shadow-sm hover:border-slate-300 transition-all cursor-pointer"
        >
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <span className="w-7 h-7 rounded-lg bg-amber-50 text-amber-600 font-bold text-xs flex items-center justify-center shrink-0">
                D
              </span>
              <span className="text-xs font-medium text-slate-600 truncate">Delayed trips</span>
            </div>
            <ChevronRight className="w-3.5 h-3.5 text-slate-300 shrink-0" />
          </div>
          <p className="text-2xl font-extrabold text-slate-900 mt-3">2</p>
          <p className="text-[11px] text-slate-400 mt-1">Action recommended</p>
        </div>

        {/* Metric 6: Safety alerts */}
        <div
          onClick={() => navigate('/emergencies')}
          className="bg-white border border-slate-200/80 rounded-2xl p-4 shadow-xs hover:shadow-sm hover:border-slate-300 transition-all cursor-pointer"
        >
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <span className="w-7 h-7 rounded-lg bg-rose-50 text-rose-600 font-bold text-xs flex items-center justify-center shrink-0">
                !
              </span>
              <span className="text-xs font-medium text-slate-600 truncate">Safety alerts</span>
            </div>
            <ChevronRight className="w-3.5 h-3.5 text-slate-300 shrink-0" />
          </div>
          <p className="text-2xl font-extrabold text-slate-900 mt-3">2</p>
          <p className="text-[11px] text-slate-400 mt-1">1 unresolved</p>
        </div>
      </div>

      {/* 3. Middle Section: Live Fleet Overview Map & Upcoming Departures */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
        {/* Left: Live fleet overview (8 cols) */}
        <div className="lg:col-span-8 bg-white border border-slate-200/80 rounded-2xl p-5 shadow-xs flex flex-col">
          <div className="flex items-center justify-between mb-4">
            <div>
              <h2 className="text-sm font-bold text-slate-900">Live fleet overview</h2>
              <p className="text-xs text-slate-400">Latest successfully received sample locations</p>
            </div>
            <button
              type="button"
              onClick={() => navigate('/monitoring')}
              className="text-xs font-semibold text-[#3B5DF0] hover:text-[#2F4DCB] flex items-center gap-1 transition-colors cursor-pointer"
            >
              <span>View fleet</span>
              <ArrowRight className="w-3.5 h-3.5" />
            </button>
          </div>

          {/* Interactive Vector Map Preview */}
          <div
            onClick={() => navigate('/monitoring')}
            className="relative w-full h-[320px] rounded-xl overflow-hidden bg-[#EFF4EE] border border-slate-200/70 select-none cursor-pointer group"
          >
            <svg
              className="w-full h-full object-cover"
              viewBox="0 0 800 400"
              preserveAspectRatio="xMidYMid slice"
            >
              <defs>
                <pattern
                  id="map-grid-pattern"
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
              <rect width="100%" height="100%" fill="url(#map-grid-pattern)" />

              {/* Major Highway Roads */}
              <line
                x1="-50"
                y1="340"
                x2="850"
                y2="90"
                stroke="#FFFFFF"
                strokeWidth="26"
                strokeLinecap="round"
              />
              <line
                x1="330"
                y1="-20"
                x2="395"
                y2="420"
                stroke="#FFFFFF"
                strokeWidth="22"
                strokeLinecap="round"
              />
              <line
                x1="160"
                y1="-20"
                x2="720"
                y2="420"
                stroke="#FFFFFF"
                strokeWidth="18"
                strokeLinecap="round"
              />
              <line
                x1="-20"
                y1="150"
                x2="820"
                y2="310"
                stroke="#FFFFFF"
                strokeWidth="15"
                strokeLinecap="round"
              />

              {/* Subtle Road Edge Borders */}
              <line
                x1="-50"
                y1="340"
                x2="850"
                y2="90"
                stroke="#E2E7DF"
                strokeWidth="2"
              />
              <line
                x1="330"
                y1="-20"
                x2="395"
                y2="420"
                stroke="#E2E7DF"
                strokeWidth="2"
              />

              {/* Landmark Labels matching design */}
              <text
                x="170"
                y="110"
                fill="#525B6A"
                fontSize="11"
                fontWeight="700"
                fontFamily="sans-serif"
              >
                North Ridge
              </text>
              <text
                x="330"
                y="225"
                fill="#525B6A"
                fontSize="11"
                fontWeight="700"
                fontFamily="sans-serif"
              >
                Lakeland College
              </text>
              <text
                x="570"
                y="295"
                fill="#525B6A"
                fontSize="11"
                fontWeight="700"
                fontFamily="sans-serif"
              >
                Lakeside
              </text>
            </svg>

            {/* Vehicle Pin Marker 24 (Active / Green) */}
            <div
              className="absolute left-[37%] top-[38%] -translate-x-1/2 -translate-y-1/2 cursor-pointer"
              title="Bus 24 - Active"
            >
              <div className="w-8 h-8 rounded-lg bg-[#0D8B75] rotate-45 flex items-center justify-center shadow-md border-2 border-white transition-transform group-hover:scale-110">
                <span className="-rotate-45 text-white font-bold text-[11px]">24</span>
              </div>
            </div>

            {/* Vehicle Pin Marker 31 (Active / Green) */}
            <div
              className="absolute left-[54%] top-[68%] -translate-x-1/2 -translate-y-1/2 cursor-pointer"
              title="Bus 31 - Active"
            >
              <div className="w-8 h-8 rounded-lg bg-[#0D8B75] rotate-45 flex items-center justify-center shadow-md border-2 border-white transition-transform group-hover:scale-110">
                <span className="-rotate-45 text-white font-bold text-[11px]">31</span>
              </div>
            </div>

            {/* Vehicle Pin Marker 18 (Delayed / Orange) */}
            <div
              className="absolute left-[62%] top-[55%] -translate-x-1/2 -translate-y-1/2 cursor-pointer"
              title="Bus 18 - Delayed"
            >
              <div className="w-8 h-8 rounded-lg bg-[#EA8A24] rotate-45 flex items-center justify-center shadow-md border-2 border-white transition-transform group-hover:scale-110">
                <span className="-rotate-45 text-white font-bold text-[11px]">18</span>
              </div>
            </div>

            {/* Bottom Left Status Legend Pill */}
            <div className="absolute left-4 bottom-4 bg-white/95 backdrop-blur-sm border border-slate-200/80 rounded-full px-3.5 py-1.5 shadow-sm flex items-center gap-3.5 text-[11px] font-semibold text-slate-600">
              <span className="flex items-center gap-1.5">
                <span className="w-2 h-2 rounded-full bg-[#0D8B75]" />
                <span>6 active</span>
              </span>
              <span className="flex items-center gap-1.5">
                <span className="w-2 h-2 rounded-full bg-[#EA8A24]" />
                <span>2 delayed</span>
              </span>
              <span className="flex items-center gap-1.5">
                <span className="w-2 h-2 rounded-full bg-slate-400" />
                <span>4 idle</span>
              </span>
            </div>
          </div>
        </div>

        {/* Right: Upcoming Departures (4 cols) */}
        <div className="lg:col-span-4 bg-white border border-slate-200/80 rounded-2xl p-5 shadow-xs flex flex-col justify-between">
          <div>
            <div className="flex items-center justify-between mb-4">
              <div>
                <h2 className="text-sm font-bold text-slate-900">Upcoming departures</h2>
                <p className="text-xs text-slate-400">Next 90 minutes</p>
              </div>
              <button
                type="button"
                onClick={() => navigate('/journeys')}
                className="text-xs font-semibold text-[#3B5DF0] hover:text-[#2F4DCB] transition-colors cursor-pointer"
              >
                View all
              </button>
            </div>

            {/* Departures List */}
            <div className="divide-y divide-slate-100">
              {/* Item 1 */}
              <div
                onClick={() => navigate('/monitoring')}
                className="py-4 flex items-center justify-between hover:bg-slate-50/70 -mx-2 px-2 rounded-xl transition-colors cursor-pointer group"
              >
                <div className="flex items-center gap-4">
                  <span className="text-sm font-extrabold text-slate-900">13:30</span>
                  <div>
                    <p className="text-xs font-bold text-slate-800 leading-tight">North Ridge PM</p>
                    <p className="text-[11px] text-slate-400 mt-0.5">NB-2341</p>
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-semibold bg-emerald-50 text-emerald-700 border border-emerald-200/80">
                    <span className="w-1.5 h-1.5 rounded-full bg-emerald-500" />
                    Ready
                  </span>
                  <ChevronRight className="w-4 h-4 text-slate-300 group-hover:text-slate-500 transition-colors" />
                </div>
              </div>

              {/* Item 2 */}
              <div
                onClick={() => navigate('/monitoring')}
                className="py-4 flex items-center justify-between hover:bg-slate-50/70 -mx-2 px-2 rounded-xl transition-colors cursor-pointer group"
              >
                <div className="flex items-center gap-4">
                  <span className="text-sm font-extrabold text-slate-900">13:45</span>
                  <div>
                    <p className="text-xs font-bold text-slate-800 leading-tight">Lakeside PM</p>
                    <p className="text-[11px] text-slate-400 mt-0.5">NC-8872</p>
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-semibold bg-amber-50 text-amber-800 border border-amber-200/80">
                    <span className="w-1.5 h-1.5 rounded-full bg-amber-500" />
                    Staff pending
                  </span>
                  <ChevronRight className="w-4 h-4 text-slate-300 group-hover:text-slate-500 transition-colors" />
                </div>
              </div>

              {/* Item 3 */}
              <div
                onClick={() => navigate('/monitoring')}
                className="py-4 flex items-center justify-between hover:bg-slate-50/70 -mx-2 px-2 rounded-xl transition-colors cursor-pointer group"
              >
                <div className="flex items-center gap-4">
                  <span className="text-sm font-extrabold text-slate-900">14:00</span>
                  <div>
                    <p className="text-xs font-bold text-slate-800 leading-tight">Hillview PM</p>
                    <p className="text-[11px] text-slate-400 mt-0.5">ND-4105</p>
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-semibold bg-slate-100 text-slate-600 border border-slate-200">
                    <span className="w-1.5 h-1.5 rounded-full bg-slate-400" />
                    Scheduled
                  </span>
                  <ChevronRight className="w-4 h-4 text-slate-300 group-hover:text-slate-500 transition-colors" />
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* 4. Lower Section: Attendance Today, Recent Activity, and Quick Actions */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {/* Column 1: Attendance today */}
        <div className="bg-white border border-slate-200/80 rounded-2xl p-5 shadow-xs flex flex-col justify-between">
          <div>
            <div className="flex items-center justify-between mb-4">
              <div>
                <h2 className="text-sm font-bold text-slate-900">Attendance today</h2>
                <p className="text-xs text-slate-400">Sample morning trip summary</p>
              </div>
              <button
                type="button"
                onClick={() => navigate('/assignments')}
                className="text-xs font-semibold text-[#3B5DF0] hover:text-[#2F4DCB] transition-colors cursor-pointer"
              >
                View details
              </button>
            </div>

            {/* Circular Ring Chart & Breakdown Row */}
            <div className="flex items-center justify-between pt-2 pb-1 gap-4">
              {/* Donut Progress Ring */}
              <div className="relative w-28 h-28 shrink-0 flex items-center justify-center">
                <svg className="w-full h-full -rotate-90" viewBox="0 0 100 100">
                  <circle
                    cx="50"
                    cy="50"
                    r="40"
                    stroke="#F1F5F9"
                    strokeWidth="9"
                    fill="none"
                  />
                  <circle
                    cx="50"
                    cy="50"
                    r="40"
                    stroke="#0D8B75"
                    strokeWidth="9"
                    fill="none"
                    strokeDasharray="251.2"
                    strokeDashoffset="20"
                    strokeLinecap="round"
                  />
                  <circle
                    cx="50"
                    cy="50"
                    r="40"
                    stroke="#F59E0B"
                    strokeWidth="9"
                    fill="none"
                    strokeDasharray="251.2"
                    strokeDashoffset="242"
                    strokeLinecap="round"
                  />
                </svg>
                <div className="absolute text-center flex flex-col items-center justify-center">
                  <span className="text-xl font-extrabold text-slate-900 leading-tight">94%</span>
                  <span className="text-[10px] text-slate-400 leading-tight">accounted</span>
                </div>
              </div>

              {/* Legend & Breakdown values */}
              <div className="flex-1 space-y-3 text-xs">
                <div className="flex items-center justify-between">
                  <span className="flex items-center gap-2 text-slate-600 text-[11px]">
                    <span className="w-2 h-2 rounded-full bg-[#0D8B75]" />
                    <span>Boarded or dropped off</span>
                  </span>
                  <span className="font-bold text-slate-900 text-xs">205</span>
                </div>

                <div className="flex items-center justify-between">
                  <span className="flex items-center gap-2 text-slate-600 text-[11px]">
                    <span className="w-2 h-2 rounded-full bg-[#F59E0B]" />
                    <span>Reported absent</span>
                  </span>
                  <span className="font-bold text-slate-900 text-xs">13</span>
                </div>

                <div className="flex items-center justify-between">
                  <span className="flex items-center gap-2 text-slate-600 text-[11px]">
                    <span className="w-2 h-2 rounded-full bg-[#EF4444]" />
                    <span>Unresolved</span>
                  </span>
                  <span className="font-bold text-slate-900 text-xs">4</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Column 2: Recent activity */}
        <div className="bg-white border border-slate-200/80 rounded-2xl p-5 shadow-xs flex flex-col justify-between">
          <div>
            <div className="flex items-center justify-between mb-4">
              <div>
                <h2 className="text-sm font-bold text-slate-900">Recent activity</h2>
                <p className="text-xs text-slate-400">Across connected applications</p>
              </div>
              <button
                type="button"
                onClick={() => navigate('/audit')}
                className="text-xs font-semibold text-[#3B5DF0] hover:text-[#2F4DCB] transition-colors cursor-pointer"
              >
                Audit log
              </button>
            </div>

            {/* Activity Stream */}
            <div className="space-y-3.5">
              {/* Event 1 */}
              <div className="flex items-start gap-3">
                <div className="w-7 h-7 rounded-lg bg-indigo-50 text-indigo-600 font-bold text-xs flex items-center justify-center shrink-0 mt-0.5">
                  S
                </div>
                <div>
                  <p className="text-xs font-bold text-slate-800 leading-tight">
                    Aanya S. boarded
                  </p>
                  <p className="text-[11px] text-slate-400 mt-0.5">
                    Driver app · TR-1042 · 4 min ago
                  </p>
                </div>
              </div>

              {/* Event 2 */}
              <div className="flex items-start gap-3">
                <div className="w-7 h-7 rounded-lg bg-blue-50 text-blue-600 font-bold text-xs flex items-center justify-center shrink-0 mt-0.5">
                  D
                </div>
                <div>
                  <p className="text-xs font-bold text-slate-800 leading-tight">
                    Delay reported on Lakeside
                  </p>
                  <p className="text-[11px] text-slate-400 mt-0.5">
                    Driver app · 11 min ago
                  </p>
                </div>
              </div>

              {/* Event 3 */}
              <div className="flex items-start gap-3">
                <div className="w-7 h-7 rounded-lg bg-purple-50 text-purple-600 font-bold text-xs flex items-center justify-center shrink-0 mt-0.5">
                  A
                </div>
                <div>
                  <p className="text-xs font-bold text-slate-800 leading-tight">
                    Absence submitted for Kavindu P.
                  </p>
                  <p className="text-[11px] text-slate-400 mt-0.5">
                    Parent app · 18 min ago
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Column 3: Quick actions */}
        <div className="bg-white border border-slate-200/80 rounded-2xl p-5 shadow-xs flex flex-col justify-between">
          <div>
            <div className="mb-4">
              <h2 className="text-sm font-bold text-slate-900">Quick actions</h2>
              <p className="text-xs text-slate-400">Common management tasks</p>
            </div>

            {/* 2-Column Grid of 6 Action Buttons */}
            <div className="grid grid-cols-2 gap-2.5 pt-1">
              <button
                type="button"
                onClick={() => navigate('/buses')}
                className="flex items-center gap-1.5 px-3 py-2.5 rounded-lg border border-slate-200 bg-white hover:bg-slate-50 text-[11px] font-semibold text-slate-700 transition-all shadow-xs cursor-pointer group text-left"
              >
                <Plus className="w-3.5 h-3.5 text-slate-400 group-hover:text-slate-600 shrink-0" />
                <span className="truncate">Add vehicle</span>
              </button>

              <button
                type="button"
                onClick={() => navigate('/drivers')}
                className="flex items-center gap-1.5 px-3 py-2.5 rounded-lg border border-slate-200 bg-white hover:bg-slate-50 text-[11px] font-semibold text-slate-700 transition-all shadow-xs cursor-pointer group text-left"
              >
                <Plus className="w-3.5 h-3.5 text-slate-400 group-hover:text-slate-600 shrink-0" />
                <span className="truncate">Add driver</span>
              </button>

              <button
                type="button"
                onClick={() => navigate('/students')}
                className="flex items-center gap-1.5 px-3 py-2.5 rounded-lg border border-slate-200 bg-white hover:bg-slate-50 text-[11px] font-semibold text-slate-700 transition-all shadow-xs cursor-pointer group text-left"
              >
                <Plus className="w-3.5 h-3.5 text-slate-400 group-hover:text-slate-600 shrink-0" />
                <span className="truncate">Add student</span>
              </button>

              <button
                type="button"
                onClick={() => navigate('/routes')}
                className="flex items-center gap-1.5 px-3 py-2.5 rounded-lg border border-slate-200 bg-white hover:bg-slate-50 text-[11px] font-semibold text-slate-700 transition-all shadow-xs cursor-pointer group text-left"
              >
                <Plus className="w-3.5 h-3.5 text-slate-400 group-hover:text-slate-600 shrink-0" />
                <span className="truncate">Create route</span>
              </button>

              <button
                type="button"
                onClick={() => navigate('/assignments')}
                className="flex items-center gap-1.5 px-3 py-2.5 rounded-lg border border-slate-200 bg-white hover:bg-slate-50 text-[11px] font-semibold text-slate-700 transition-all shadow-xs cursor-pointer group text-left"
              >
                <Plus className="w-3.5 h-3.5 text-slate-400 group-hover:text-slate-600 shrink-0" />
                <span className="truncate">Assign trip</span>
              </button>

              <button
                type="button"
                onClick={() => navigate('/notifications')}
                className="flex items-center gap-1.5 px-3 py-2.5 rounded-lg border border-slate-200 bg-white hover:bg-slate-50 text-[11px] font-semibold text-slate-700 transition-all shadow-xs cursor-pointer group text-left"
              >
                <Plus className="w-3.5 h-3.5 text-slate-400 group-hover:text-slate-600 shrink-0" />
                <span className="truncate">Send announcement</span>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
