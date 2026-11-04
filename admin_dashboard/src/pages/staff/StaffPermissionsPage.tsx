import { useState } from 'react';
import {
  Plus,
  Info,
  Check,
  X,
  UserPlus,
  Shield,
  CheckCircle2,
} from 'lucide-react';
import { cn } from '@/utils/cn';

interface RoleDefinition {
  id: string;
  name: string;
  code: string;
  staffCount: number;
  description: string;
}

const rolesList: RoleDefinition[] = [
  { id: 'owner', name: 'Owner', code: 'OW', staffCount: 2, description: 'Super administrator with unrestricted global platform privileges.' },
  { id: 'manager', name: 'Manager', code: 'TM', staffCount: 4, description: 'Full operational authority over transport fleet, schedules, and staff.' },
  { id: 'dispatcher', name: 'Dispatcher', code: 'DI', staffCount: 8, description: 'Live monitoring, trip dispatching, and real-time route adjustments.' },
  { id: 'finance', name: 'Finance', code: 'FI', staffCount: 3, description: 'Fee billing, payment reconciliations, and student subsidy waivers.' },
  { id: 'support', name: 'Support', code: 'SU', staffCount: 6, description: 'Customer tickets, parent inquiries, and notification delivery checks.' },
  { id: 'readonly', name: 'Read-only', code: 'RO', staffCount: 2, description: 'Auditor and observer view without modification or export permissions.' },
];

interface PermissionRow {
  group: string;
  view: boolean;
  create: boolean;
  edit: boolean;
  delete: boolean;
  approve: boolean;
  assign: boolean;
  export: boolean;
  disabledCreate?: boolean;
  disabledEdit?: boolean;
}

const defaultPermissions: PermissionRow[] = [
  { group: 'Students', view: true, create: true, edit: true, delete: false, approve: false, assign: true, export: false },
  { group: 'Parents', view: true, create: true, edit: true, delete: false, approve: false, assign: true, export: false },
  { group: 'Vehicles', view: true, create: true, edit: true, delete: false, approve: false, assign: true, export: false },
  { group: 'Drivers', view: true, create: true, edit: true, delete: false, approve: false, assign: true, export: false },
  { group: 'Routes', view: true, create: true, edit: true, delete: false, approve: false, assign: true, export: false },
  { group: 'Trips', view: true, create: true, edit: true, delete: false, approve: false, assign: true, export: false },
  { group: 'Attendance', view: true, create: true, edit: true, delete: false, approve: false, assign: true, export: false },
  { group: 'Incidents', view: true, create: true, edit: true, delete: false, approve: false, assign: true, export: false },
  { group: 'Payments', view: true, create: true, edit: true, delete: false, approve: false, assign: false, export: false },
  { group: 'Notifications', view: true, create: true, edit: true, delete: false, approve: false, assign: false, export: false },
  { group: 'Reports', view: true, create: true, edit: true, delete: false, approve: false, assign: false, export: false },
  { group: 'Settings', view: true, create: false, edit: false, delete: false, approve: false, assign: false, export: false, disabledCreate: true, disabledEdit: true },
];

export default function StaffPermissionsPage() {
  const [selectedRole, setSelectedRole] = useState<RoleDefinition>(rolesList[1]); // Default to Manager (index 1)
  const [permissions, setPermissions] = useState<PermissionRow[]>(defaultPermissions);
  const [isInviteModalOpen, setIsInviteModalOpen] = useState(false);
  const [savedToast, setSavedToast] = useState<string | null>(null);

  // Invite form state
  const [inviteName, setInviteName] = useState('');
  const [inviteEmail, setInviteEmail] = useState('');
  const [inviteRole, setInviteRole] = useState('Manager');
  const [inviteDept, setInviteDept] = useState('Operations');

  const togglePermission = (rowIndex: number, column: keyof Omit<PermissionRow, 'group' | 'disabledCreate' | 'disabledEdit'>) => {
    // If Settings create or edit is disabled, ignore
    if (permissions[rowIndex].group === 'Settings' && (column === 'create' || column === 'edit')) {
      return;
    }

    setPermissions((prev) => {
      const updated = [...prev];
      updated[rowIndex] = {
        ...updated[rowIndex],
        [column]: !updated[rowIndex][column],
      };
      return updated;
    });
  };

  const handleSaveChanges = () => {
    setSavedToast(`${selectedRole.name} permissions updated successfully and logged to audit trail.`);
    setTimeout(() => setSavedToast(null), 3500);
  };

  const handleSendInvite = (e: React.FormEvent) => {
    e.preventDefault();
    setSavedToast(`Invitation email sent to ${inviteEmail} for role ${inviteRole}.`);
    setIsInviteModalOpen(false);
    setInviteName('');
    setInviteEmail('');
    setTimeout(() => setSavedToast(null), 3500);
  };

  return (
    <div className="w-full p-8 space-y-6 max-w-[1600px] mx-auto overflow-x-hidden">
      {/* Toast Notification */}
      {savedToast && (
        <div className="fixed top-20 right-8 z-50 bg-slate-900 text-white text-xs px-4 py-3 rounded-xl shadow-xl flex items-center gap-2.5 animate-in slide-in-from-top-4 duration-200">
          <CheckCircle2 className="w-4 h-4 text-emerald-400" />
          <span>{savedToast}</span>
        </div>
      )}

      {/* 1. Page Header & Action Button */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 shrink-0">
        <div>
          <span className="text-[11px] font-bold tracking-wider text-[#3B5DF0] uppercase">
            TRANSPORT OPERATIONS
          </span>
          <h1 className="text-2xl md:text-3xl font-extrabold text-slate-900 mt-1 tracking-tight">
            Roles & Permissions
          </h1>
          <p className="text-slate-500 text-xs md:text-sm mt-1">
            Control access without allowing staff to elevate their own role.
          </p>
        </div>

        {/* Right CTA Button */}
        <button
          type="button"
          onClick={() => setIsInviteModalOpen(true)}
          className="inline-flex items-center gap-2 bg-[#3B5DF0] hover:bg-[#2F4DCB] text-white text-xs font-semibold px-4 py-2.5 rounded-xl shadow-sm shadow-[#3B5DF0]/30 transition-all self-start md:self-auto cursor-pointer"
        >
          <Plus className="w-4 h-4" />
          <span>Invite staff member</span>
        </button>
      </div>

      {/* 2. Role Cards Row */}
      <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-3.5">
        {rolesList.map((role) => {
          const isSelected = selectedRole.id === role.id;
          return (
            <button
              key={role.id}
              type="button"
              onClick={() => setSelectedRole(role)}
              className={cn(
                'p-4 rounded-2xl text-left transition-all relative border cursor-pointer flex flex-col justify-between min-h-[96px]',
                isSelected
                  ? 'bg-white border-[#3B5DF0] ring-2 ring-[#3B5DF0]/20 shadow-xs'
                  : 'bg-white border-slate-200/80 hover:border-slate-300 hover:bg-slate-50/50 shadow-2xs'
              )}
            >
              <div className="w-8 h-8 rounded-xl bg-slate-100 flex items-center justify-center text-[11px] font-bold text-slate-600 mb-2">
                {role.code}
              </div>
              <div>
                <h3 className="font-bold text-slate-900 text-sm leading-tight">
                  {role.name}
                </h3>
                <span className="text-[11px] text-slate-400 font-medium mt-0.5 block">
                  {role.staffCount} staff
                </span>
              </div>
            </button>
          );
        })}
      </div>

      {/* 3. Main Permissions Matrix Card */}
      <div className="bg-white border border-slate-200/80 rounded-2xl p-6 shadow-xs space-y-6">
        {/* Card Header */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 border-b border-slate-100 pb-4">
          <div>
            <h2 className="text-base font-bold text-slate-900">
              {selectedRole.name === 'Manager' ? 'Transport Manager' : selectedRole.name} permissions
            </h2>
            <p className="text-xs text-slate-500 mt-0.5">
              Inherited system permissions are locked. Changes are audited.
            </p>
          </div>

          <button
            type="button"
            onClick={handleSaveChanges}
            className="px-4 py-2 border border-slate-200 hover:bg-slate-50 text-slate-700 text-xs font-semibold rounded-xl shadow-2xs transition-colors self-start sm:self-auto cursor-pointer"
          >
            Save changes
          </button>
        </div>

        {/* Matrix Table */}
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs border-collapse">
            <thead>
              <tr className="border-b border-slate-100 text-[11px] font-bold text-slate-400 uppercase tracking-wider">
                <th className="py-3 px-4 font-bold min-w-[140px]">PERMISSION GROUP</th>
                <th className="py-3 px-4 font-bold text-center">VIEW</th>
                <th className="py-3 px-4 font-bold text-center">CREATE</th>
                <th className="py-3 px-4 font-bold text-center">EDIT</th>
                <th className="py-3 px-4 font-bold text-center">DELETE</th>
                <th className="py-3 px-4 font-bold text-center">APPROVE</th>
                <th className="py-3 px-4 font-bold text-center">ASSIGN</th>
                <th className="py-3 px-4 font-bold text-center">EXPORT</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 text-slate-700">
              {permissions.map((row, idx) => (
                <tr key={row.group} className="hover:bg-slate-50/60 transition-colors">
                  <td className="py-3.5 px-4 font-bold text-slate-900">
                    {row.group}
                  </td>

                  {/* VIEW */}
                  <td className="py-3.5 px-4 text-center">
                    <button
                      type="button"
                      onClick={() => togglePermission(idx, 'view')}
                      className={cn(
                        'w-4 h-4 rounded border flex items-center justify-center mx-auto transition-colors cursor-pointer',
                        row.view
                          ? 'bg-[#3B5DF0] border-[#3B5DF0] text-white'
                          : 'border-slate-300 hover:border-slate-400'
                      )}
                    >
                      {row.view && <Check className="w-3 h-3 stroke-[3]" />}
                    </button>
                  </td>

                  {/* CREATE */}
                  <td className="py-3.5 px-4 text-center">
                    {row.disabledCreate ? (
                      <div className="w-4 h-4 rounded bg-slate-200 border border-slate-300 mx-auto opacity-50 cursor-not-allowed" />
                    ) : (
                      <button
                        type="button"
                        onClick={() => togglePermission(idx, 'create')}
                        className={cn(
                          'w-4 h-4 rounded border flex items-center justify-center mx-auto transition-colors cursor-pointer',
                          row.create
                            ? 'bg-[#3B5DF0] border-[#3B5DF0] text-white'
                            : 'border-slate-300 hover:border-slate-400'
                        )}
                      >
                        {row.create && <Check className="w-3 h-3 stroke-[3]" />}
                      </button>
                    )}
                  </td>

                  {/* EDIT */}
                  <td className="py-3.5 px-4 text-center">
                    {row.disabledEdit ? (
                      <div className="w-4 h-4 rounded bg-slate-200 border border-slate-300 mx-auto opacity-50 cursor-not-allowed" />
                    ) : (
                      <button
                        type="button"
                        onClick={() => togglePermission(idx, 'edit')}
                        className={cn(
                          'w-4 h-4 rounded border flex items-center justify-center mx-auto transition-colors cursor-pointer',
                          row.edit
                            ? 'bg-[#3B5DF0] border-[#3B5DF0] text-white'
                            : 'border-slate-300 hover:border-slate-400'
                        )}
                      >
                        {row.edit && <Check className="w-3 h-3 stroke-[3]" />}
                      </button>
                    )}
                  </td>

                  {/* DELETE */}
                  <td className="py-3.5 px-4 text-center">
                    <button
                      type="button"
                      onClick={() => togglePermission(idx, 'delete')}
                      className={cn(
                        'w-4 h-4 rounded border flex items-center justify-center mx-auto transition-colors cursor-pointer',
                        row.delete
                          ? 'bg-[#3B5DF0] border-[#3B5DF0] text-white'
                          : 'border-slate-300 hover:border-slate-400'
                      )}
                    >
                      {row.delete && <Check className="w-3 h-3 stroke-[3]" />}
                    </button>
                  </td>

                  {/* APPROVE */}
                  <td className="py-3.5 px-4 text-center">
                    <button
                      type="button"
                      onClick={() => togglePermission(idx, 'approve')}
                      className={cn(
                        'w-4 h-4 rounded border flex items-center justify-center mx-auto transition-colors cursor-pointer',
                        row.approve
                          ? 'bg-[#3B5DF0] border-[#3B5DF0] text-white'
                          : 'border-slate-300 hover:border-slate-400'
                      )}
                    >
                      {row.approve && <Check className="w-3 h-3 stroke-[3]" />}
                    </button>
                  </td>

                  {/* ASSIGN */}
                  <td className="py-3.5 px-4 text-center">
                    <button
                      type="button"
                      onClick={() => togglePermission(idx, 'assign')}
                      className={cn(
                        'w-4 h-4 rounded border flex items-center justify-center mx-auto transition-colors cursor-pointer',
                        row.assign
                          ? 'bg-[#3B5DF0] border-[#3B5DF0] text-white'
                          : 'border-slate-300 hover:border-slate-400'
                      )}
                    >
                      {row.assign && <Check className="w-3 h-3 stroke-[3]" />}
                    </button>
                  </td>

                  {/* EXPORT */}
                  <td className="py-3.5 px-4 text-center">
                    <button
                      type="button"
                      onClick={() => togglePermission(idx, 'export')}
                      className={cn(
                        'w-4 h-4 rounded border flex items-center justify-center mx-auto transition-colors cursor-pointer',
                        row.export
                          ? 'bg-[#3B5DF0] border-[#3B5DF0] text-white'
                          : 'border-slate-300 hover:border-slate-400'
                      )}
                    >
                      {row.export && <Check className="w-3 h-3 stroke-[3]" />}
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* 4. Privilege Protection Info Notice */}
        <div className="bg-[#EFF6FF] border border-[#DBEAFE] rounded-2xl p-4 flex items-center gap-3.5 text-xs shadow-2xs">
          <div className="w-8 h-8 rounded-xl bg-blue-100 text-[#3B5DF0] flex items-center justify-center shrink-0 font-bold">
            <Info className="w-4 h-4" />
          </div>
          <div>
            <h4 className="font-bold text-slate-900 text-xs">Privilege protection</h4>
            <p className="text-slate-500 text-[11px] mt-0.5">
              Role changes require an owner-level administrator. Staff cannot alter their own permissions.
            </p>
          </div>
        </div>
      </div>

      {/* MODAL: Invite Staff Member */}
      {isInviteModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/40 backdrop-blur-xs p-4">
          <div className="bg-white rounded-2xl max-w-lg w-full p-6 shadow-xl border border-slate-100 space-y-4 animate-in fade-in-50 zoom-in-95 duration-150">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div className="flex items-center gap-2">
                <div className="w-8 h-8 rounded-lg bg-blue-50 text-[#3B5DF0] flex items-center justify-center font-bold">
                  <UserPlus className="w-4 h-4" />
                </div>
                <h3 className="font-bold text-slate-900 text-base">Invite Staff Member</h3>
              </div>
              <button
                type="button"
                onClick={() => setIsInviteModalOpen(false)}
                className="text-slate-400 hover:text-slate-600 p-1 rounded-lg hover:bg-slate-100 transition-colors"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <form onSubmit={handleSendInvite} className="space-y-4 text-xs">
              <div>
                <label className="block font-semibold text-slate-700 mb-1">
                  Full Name
                </label>
                <input
                  type="text"
                  required
                  value={inviteName}
                  onChange={(e) => setInviteName(e.target.value)}
                  placeholder="e.g. Priyantha Jayawardena"
                  className="w-full px-3 py-2 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
                />
              </div>

              <div>
                <label className="block font-semibold text-slate-700 mb-1">
                  Email Address (Official School/Transport Domain)
                </label>
                <input
                  type="email"
                  required
                  value={inviteEmail}
                  onChange={(e) => setInviteEmail(e.target.value)}
                  placeholder="name@ridesafe.lk"
                  className="w-full px-3 py-2 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold text-slate-700 mb-1">
                    Assigned Role
                  </label>
                  <select
                    value={inviteRole}
                    onChange={(e) => setInviteRole(e.target.value)}
                    className="w-full px-3 py-2 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 bg-white"
                  >
                    <option value="Manager">Manager</option>
                    <option value="Dispatcher">Dispatcher</option>
                    <option value="Finance">Finance</option>
                    <option value="Support">Support</option>
                    <option value="Read-only">Read-only</option>
                    <option value="Owner">Owner</option>
                  </select>
                </div>

                <div>
                  <label className="block font-semibold text-slate-700 mb-1">
                    Department
                  </label>
                  <select
                    value={inviteDept}
                    onChange={(e) => setInviteDept(e.target.value)}
                    className="w-full px-3 py-2 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 bg-white"
                  >
                    <option value="Operations">Operations</option>
                    <option value="Safety & Audit">Safety & Audit</option>
                    <option value="Customer Care">Customer Care</option>
                    <option value="Finance & Accounts">Finance & Accounts</option>
                  </select>
                </div>
              </div>

              <div className="p-3 bg-slate-50 border border-slate-100 rounded-xl text-slate-600 text-[11px] flex items-center gap-2">
                <Shield className="w-4 h-4 text-blue-500 shrink-0" />
                <span>Invited staff member will receive a secure 2FA setup link valid for 48 hours.</span>
              </div>

              <div className="flex items-center justify-end gap-2 pt-3 border-t border-slate-100">
                <button
                  type="button"
                  onClick={() => setIsInviteModalOpen(false)}
                  className="px-4 py-2 border border-slate-200 rounded-xl text-slate-600 hover:bg-slate-50 font-semibold"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 bg-[#3B5DF0] hover:bg-[#2F4DCB] text-white rounded-xl font-semibold shadow-xs"
                >
                  Send Invitation
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}

