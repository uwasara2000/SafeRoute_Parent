import { NavLink } from 'react-router-dom';
import { ChevronRight } from 'lucide-react';
import { cn } from '@/utils/cn';

interface NavItem {
  name: string;
  to: string;
  badgeCode: string;
  badgeCount?: number;
}

interface NavSection {
  title: string;
  items: NavItem[];
}

const navSections: NavSection[] = [
  {
    title: 'OPERATIONS',
    items: [
      { name: 'Overview', to: '/', badgeCode: 'OV' },
      { name: 'Live Fleet Tracking', to: '/monitoring', badgeCode: 'LF' },
      { name: 'Trips', to: '/journeys', badgeCode: 'TR' },
      { name: 'Routes & Stops', to: '/routes', badgeCode: 'RS' },
      { name: 'Vehicles', to: '/buses', badgeCode: 'VC' },
    ],
  },
  {
    title: 'PEOPLE',
    items: [
      { name: 'Drivers & Attendants', to: '/drivers', badgeCode: 'DA' },
      { name: 'Students', to: '/students', badgeCode: 'ST' },
      { name: 'Parents & Guardians', to: '/parents', badgeCode: 'PG' },
      { name: 'Attendance & Absences', to: '/assignments', badgeCode: 'AA' },
    ],
  },
  {
    title: 'MANAGEMENT',
    items: [
      { name: 'Notifications', to: '/notifications', badgeCode: 'NT' },
      { name: 'Incidents & Safety', to: '/emergencies', badgeCode: 'IS', badgeCount: 2 },
      { name: 'Payments & Fees', to: '/payments', badgeCode: 'PF' },
      { name: 'Reports & Analytics', to: '/reports', badgeCode: 'RA' },
      { name: 'Support Requests', to: '/support', badgeCode: 'SR' },
    ],
  },
  {
    title: 'ADMINISTRATION',
    items: [
      { name: 'Staff & Permissions', to: '/staff', badgeCode: 'SP' },
      { name: 'Settings', to: '/settings', badgeCode: 'ST' },
      { name: 'Audit Logs', to: '/audit', badgeCode: 'AL' },
      { name: 'Platform Blueprint', to: '/blueprint', badgeCode: 'PB' },
    ],
  },
];

export default function Sidebar() {
  return (
    <aside className="w-64 bg-[#141829] text-slate-300 flex flex-col h-screen shrink-0 select-none z-20 border-r border-[#1C223A]">
      {/* Brand header */}
      <div className="h-16 flex items-center px-5 gap-3 border-b border-[#1C223A] shrink-0">
        <div className="w-9 h-9 rounded-xl bg-white flex items-center justify-center text-[#3B5DF0] shadow-sm font-bold">
          <svg className="w-5 h-5 text-[#3B5DF0]" viewBox="0 0 24 24" fill="currentColor">
            <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 14h-2v-2h2v2zm0-4h-2V7h2v5z" />
          </svg>
        </div>
        <div>
          <span className="font-bold text-white text-[15px] tracking-tight leading-none block">
            RideSafe
          </span>
          <span className="block text-[11px] text-slate-400 font-medium mt-1">
            Transport operations
          </span>
        </div>
      </div>

      {/* Navigation sections (Scrollable within sidebar) */}
      <nav className="flex-1 overflow-y-auto overflow-x-hidden py-3 px-3 space-y-4 text-xs scrollbar-thin">
        {navSections.map((section) => (
          <div key={section.title} className="space-y-1">
            <p className="px-3 text-[10px] font-bold tracking-wider text-slate-400/70 uppercase">
              {section.title}
            </p>
            <div className="space-y-0.5 pt-0.5">
              {section.items.map((item) => (
                <NavLink
                  key={item.name}
                  to={item.to}
                  className={({ isActive }) =>
                    cn(
                      'flex items-center justify-between px-3 py-2 rounded-xl text-[13px] font-medium transition-all group',
                      isActive
                        ? 'bg-[#3B5DF0] text-white shadow-md shadow-[#3B5DF0]/30 font-semibold'
                        : 'text-slate-400 hover:text-white hover:bg-[#1C223A]'
                    )
                  }
                >
                  <div className="flex items-center gap-3 min-w-0">
                    <span
                      className={cn(
                        'w-5 h-5 rounded flex items-center justify-center text-[10px] font-semibold transition-colors shrink-0',
                        'bg-white/10 text-slate-300 group-hover:bg-white/20 group-hover:text-white'
                      )}
                    >
                      {item.badgeCode}
                    </span>
                    <span className="truncate">{item.name}</span>
                  </div>
                  {item.badgeCount && (
                    <span className="w-4 h-4 rounded-full bg-rose-500 text-white text-[10px] font-bold flex items-center justify-center shrink-0">
                      {item.badgeCount}
                    </span>
                  )}
                </NavLink>
              ))}
            </div>
          </div>
        ))}
      </nav>

      {/* User profile card at bottom */}
      <div className="p-3 border-t border-[#1C223A] shrink-0 bg-[#141829]">
        <div className="flex items-center justify-between p-2 rounded-xl hover:bg-[#1C223A] transition-colors cursor-pointer group">
          <div className="flex items-center gap-2.5">
            <div className="w-8 h-8 rounded-full bg-[#3B5DF0] text-white font-bold text-xs flex items-center justify-center shadow-sm">
              DS
            </div>
            <div className="text-left">
              <p className="text-xs font-bold text-white leading-tight">Dinuka Silva</p>
              <p className="text-[11px] text-slate-400 leading-tight mt-0.5">Transport Manager</p>
            </div>
          </div>
          <ChevronRight className="w-4 h-4 text-slate-500 group-hover:text-slate-300 transition-colors" />
        </div>
      </div>
    </aside>
  );
}
