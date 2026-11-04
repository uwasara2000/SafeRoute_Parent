import { useState } from 'react';
import { ArrowRight, Database, GitFork, CheckCircle2 } from 'lucide-react';
import { cn } from '@/utils/cn';

interface DataEntityGroup {
  category: string;
  items: string[];
}

const entityGroups: DataEntityGroup[] = [
  {
    category: 'Identity & Access',
    items: ['Users', 'Roles', 'Permissions', 'Parents', 'Drivers', 'Attendants', 'Students', 'Guardians', 'Schools'],
  },
  {
    category: 'Transport & Operations',
    items: ['Vehicles', 'Routes', 'Stops', 'Trips', 'Assignments', 'Boarding Events', 'Drop-off Events', 'Absences'],
  },
  {
    category: 'Communication & Audit',
    items: ['GPS Updates', 'Notifications', 'Incidents', 'Support Tickets', 'Payments', 'Audit Logs'],
  },
];

interface WorkflowItem {
  id: string;
  title: string;
  flow: string[];
}

const integrationWorkflows: WorkflowItem[] = [
  {
    id: 'w-1',
    title: 'Student assignment',
    flow: ['Admin', 'shared record', 'Parent child profile + Driver roster'],
  },
  {
    id: 'w-2',
    title: 'Trip start',
    flow: ['Driver', 'trip in progress', 'Admin monitor + Parent journey'],
  },
  {
    id: 'w-3',
    title: 'Boarding / drop-off',
    flow: ['Attendant', 'verified event', 'Attendance + Parent timeline'],
  },
  {
    id: 'w-4',
    title: 'Absence report',
    flow: ['Parent', 'absence record', 'Admin queue + Driver roster'],
  },
  {
    id: 'w-5',
    title: 'Trip delay',
    flow: ['Driver', 'delay event', 'Admin alert + Parent status'],
  },
  {
    id: 'w-6',
    title: 'Safety incident',
    flow: ['Driver / attendant', 'incident', 'Admin escalation + verified communication'],
  },
  {
    id: 'w-7',
    title: 'Payment update',
    flow: ['Admin verified record', 'Parent billing history'],
  },
  {
    id: 'w-8',
    title: 'Route change',
    flow: ['Admin approved route', 'Driver route + affected parents'],
  },
];

export default function PlatformBlueprintPage() {
  const [selectedEntity, setSelectedEntity] = useState<string | null>(null);

  return (
    <div className="w-full p-8 space-y-6 max-w-[1600px] mx-auto overflow-x-hidden">
      {/* 1. Page Header */}
      <div>
        <span className="text-[11px] font-bold tracking-wider text-[#3B5DF0] uppercase">
          TRANSPORT OPERATIONS
        </span>
        <h1 className="text-2xl md:text-3xl font-extrabold text-slate-900 mt-1 tracking-tight">
          Platform Blueprint
        </h1>
        <p className="text-slate-500 text-xs md:text-sm mt-1">
          Implementation handoff for the shared Parent, Driver and Admin platform.
        </p>
      </div>

      {/* 2. Main 2-Column Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-stretch">
        {/* Left Card: Shared data model (5 cols) */}
        <div className="lg:col-span-5 bg-white border border-slate-200/80 rounded-2xl p-6 md:p-7 shadow-xs flex flex-col justify-between">
          <div className="space-y-6">
            {/* Header */}
            <div className="border-b border-slate-100 pb-4 flex items-center justify-between">
              <div>
                <h2 className="text-base font-bold text-slate-900 flex items-center gap-2">
                  <Database className="w-4 h-4 text-[#3B5DF0]" />
                  <span>Shared data model</span>
                </h2>
                <p className="text-xs text-slate-500 mt-0.5">
                  One backend, not separate application databases.
                </p>
              </div>
            </div>

            {/* Pill Groups */}
            <div className="space-y-5">
              {entityGroups.map((group) => (
                <div key={group.category} className="space-y-2">
                  <span className="text-[10px] font-bold tracking-wider text-slate-400 uppercase">
                    {group.category}
                  </span>
                  <div className="flex flex-wrap gap-2">
                    {group.items.map((entity) => {
                      const isSelected = selectedEntity === entity;
                      return (
                        <button
                          key={entity}
                          type="button"
                          onClick={() => setSelectedEntity(isSelected ? null : entity)}
                          className={cn(
                            'px-3 py-1.5 rounded-full text-xs font-semibold transition-all cursor-pointer border',
                            isSelected
                              ? 'bg-[#3B5DF0] text-white border-[#3B5DF0] shadow-2xs'
                              : 'bg-blue-50/70 hover:bg-blue-100/70 text-[#2F4DCB] border-blue-100/80'
                          )}
                        >
                          {entity}
                        </button>
                      );
                    })}
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Bottom Info Note */}
          <div className="mt-6 pt-4 border-t border-slate-100 text-[11px] text-slate-500 flex items-center gap-2">
            <CheckCircle2 className="w-4 h-4 text-emerald-500 shrink-0" />
            <span>Shared Firebase Cloud Firestore schema unified across all 3 client apps.</span>
          </div>
        </div>

        {/* Right Card: Application integration map (7 cols) */}
        <div className="lg:col-span-7 bg-white border border-slate-200/80 rounded-2xl p-6 md:p-7 shadow-xs space-y-5">
          {/* Header */}
          <div className="border-b border-slate-100 pb-4">
            <h2 className="text-base font-bold text-slate-900 flex items-center gap-2">
              <GitFork className="w-4 h-4 text-[#3B5DF0]" />
              <span>Application integration map</span>
            </h2>
            <p className="text-xs text-slate-500 mt-0.5">
              Event-driven shared workflows.
            </p>
          </div>

          {/* Workflow List */}
          <div className="divide-y divide-slate-100 text-xs">
            {integrationWorkflows.map((item) => (
              <div key={item.id} className="py-3 first:pt-0 last:pb-0 group">
                <h3 className="font-bold text-slate-900 group-hover:text-[#3B5DF0] transition-colors text-xs">
                  {item.title}
                </h3>
                <div className="flex items-center flex-wrap gap-1.5 text-[11px] text-slate-500 font-medium mt-1">
                  {item.flow.map((step, idx) => (
                    <span key={step} className="flex items-center gap-1.5">
                      <span className={idx === 0 ? 'text-slate-800 font-semibold' : ''}>
                        {step}
                      </span>
                      {idx < item.flow.length - 1 && (
                        <ArrowRight className="w-3 h-3 text-slate-300 shrink-0" />
                      )}
                    </span>
                  ))}
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

