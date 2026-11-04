import { Search, ChevronDown } from 'lucide-react';
import { useLocation, Link } from 'react-router-dom';

const routeTitleMap: Record<string, string> = {
  '/': 'Overview',
  '/monitoring': 'Live Fleet Tracking',
  '/journeys': 'Trips',
  '/routes': 'Routes & Stops',
  '/buses': 'Vehicles',
  '/drivers': 'Drivers & Attendants',
  '/students': 'Students',
  '/parents': 'Parents & Guardians',
  '/assignments': 'Attendance & Absences',
  '/notifications': 'Notifications',
  '/emergencies': 'Incidents & Safety',
  '/payments': 'Payments & Fees',
  '/reports': 'Reports & Analytics',
  '/support': 'Support Requests',
  '/staff': 'Staff & Permissions',
  '/settings': 'Settings',
  '/audit': 'Audit Logs',
  '/blueprint': 'Platform Blueprint',
};

export default function Navbar() {
  const location = useLocation();
  const currentTitle = routeTitleMap[location.pathname] || 'Overview';

  return (
    <header className="h-16 bg-white border-b border-slate-200/80 px-8 flex items-center justify-between shrink-0 z-10">
      {/* Left breadcrumb with link */}
      <div className="flex items-center gap-2 text-sm select-none">
        <Link to="/" className="text-slate-400 hover:text-slate-600 font-medium transition-colors">
          RideSafe
        </Link>
        <span className="text-slate-300">/</span>
        <span className="text-slate-900 font-bold">{currentTitle}</span>
      </div>

      {/* Right controls */}
      <div className="flex items-center gap-4">
        {/* Search input */}
        <div className="relative w-72">
          <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
          <input
            type="text"
            placeholder="Search students, trips, vehicles..."
            className="w-full pl-9 pr-4 py-2 text-xs bg-slate-50 border border-slate-200/80 rounded-full focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 placeholder:text-slate-400 text-slate-700 transition-all"
          />
        </div>

        {/* Notification badge */}
        <button
          type="button"
          aria-label="Notifications"
          className="relative w-9 h-9 rounded-full border border-slate-200 flex items-center justify-center text-xs font-semibold text-slate-600 hover:bg-slate-50 cursor-pointer transition-colors"
        >
          <span>N</span>
          <span className="absolute top-1.5 right-1.5 w-2 h-2 rounded-full bg-rose-500 ring-2 ring-white" />
        </button>

        {/* User profile dropdown */}
        <div className="flex items-center gap-2.5 pl-2 cursor-pointer group select-none">
          <div className="w-9 h-9 rounded-full bg-blue-100 text-[#3B5DF0] font-bold text-xs flex items-center justify-center">
            DS
          </div>
          <div className="text-left">
            <p className="text-xs font-bold text-slate-800 leading-tight">Dinuka Silva</p>
            <p className="text-[11px] text-slate-400 leading-tight">Manager</p>
          </div>
          <ChevronDown className="w-3.5 h-3.5 text-slate-400 group-hover:text-slate-600 transition-colors" />
        </div>
      </div>
    </header>
  );
}
