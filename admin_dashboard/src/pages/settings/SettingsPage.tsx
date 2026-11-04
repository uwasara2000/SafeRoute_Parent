import { useState } from 'react';
import {
  ChevronRight,
  CheckCircle2,
} from 'lucide-react';
import { cn } from '@/utils/cn';

interface SettingsSection {
  id: string;
  code: string;
  title: string;
  description: string;
}

const settingsSections: SettingsSection[] = [
  { id: 'general', code: 'GE', title: 'General', description: 'Organization information, branding, contacts and hours' },
  { id: 'transport', code: 'TR', title: 'Transport', description: 'Schools, routes and attendance policies' },
  { id: 'security', code: 'SE', title: 'Security', description: 'Roles, two-factor authentication and sessions' },
  { id: 'notifications', code: 'NO', title: 'Notifications', description: 'Templates, alert rules and recipients' },
  { id: 'language', code: 'LA', title: 'Language', description: 'English, Sinhala and Tamil' },
  { id: 'appearance', code: 'AP', title: 'Appearance', description: 'Light, dark and system default' },
  { id: 'finance', code: 'FI', title: 'Finance', description: 'Billing, fee and receipt settings' },
  { id: 'privacy', code: 'PR', title: 'Privacy', description: 'Retention, policy and data access rules' },
  { id: 'system', code: 'SY', title: 'System status', description: 'Connections, GPS sync and background jobs' },
];

export default function SettingsPage() {
  const [activeSection, setActiveSection] = useState<string>('general');
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  // General Form State
  const [orgName, setOrgName] = useState('RideSafe Transport Services');
  const operatorRef = 'OP-00142';
  const [supportEmail, setSupportEmail] = useState('support@example.com');
  const [supportPhone, setSupportPhone] = useState('+94 11 234 0678');
  const [registeredAddress, setRegisteredAddress] = useState('42 Lake Road, Colombo');

  // Secondary Form states
  const [attendanceWindow, setAttendanceWindow] = useState('15 mins prior to departure');
  const [twoFactorRequired, setTwoFactorRequired] = useState(true);
  const [defaultLanguage, setDefaultLanguage] = useState('English');
  const [themeMode, setThemeMode] = useState('Light');

  const handleSave = (e: React.FormEvent) => {
    e.preventDefault();
    setToastMessage('Settings successfully updated and applied.');
    setTimeout(() => setToastMessage(null), 3000);
  };

  const handleDiscard = () => {
    setOrgName('RideSafe Transport Services');
    setSupportEmail('support@example.com');
    setSupportPhone('+94 11 234 0678');
    setRegisteredAddress('42 Lake Road, Colombo');
    setToastMessage('Changes discarded.');
    setTimeout(() => setToastMessage(null), 2500);
  };

  return (
    <div className="w-full p-8 space-y-6 max-w-[1600px] mx-auto overflow-x-hidden">
      {/* Toast Notification */}
      {toastMessage && (
        <div className="fixed top-20 right-8 z-50 bg-slate-900 text-white text-xs px-4 py-3 rounded-xl shadow-xl flex items-center gap-2.5 animate-in slide-in-from-top-4 duration-200">
          <CheckCircle2 className="w-4 h-4 text-emerald-400" />
          <span>{toastMessage}</span>
        </div>
      )}

      {/* 1. Page Header */}
      <div>
        <span className="text-[11px] font-bold tracking-wider text-[#3B5DF0] uppercase">
          TRANSPORT OPERATIONS
        </span>
        <h1 className="text-2xl md:text-3xl font-extrabold text-slate-900 mt-1 tracking-tight">
          Settings
        </h1>
        <p className="text-slate-500 text-xs md:text-sm mt-1">
          Organization-wide configuration. Sensitive areas require elevated access.
        </p>
      </div>

      {/* 2. Settings 2-Column Layout */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
        {/* Left Navigation Card (4 cols) */}
        <div className="lg:col-span-4 bg-white border border-slate-200/80 rounded-2xl p-2.5 shadow-xs space-y-1">
          {settingsSections.map((section) => {
            const isActive = activeSection === section.id;
            return (
              <button
                key={section.id}
                type="button"
                onClick={() => setActiveSection(section.id)}
                className={cn(
                  'w-full p-3 rounded-xl text-left transition-all flex items-center justify-between group cursor-pointer',
                  isActive
                    ? 'bg-[#EEF2FF] text-[#3B5DF0]'
                    : 'hover:bg-slate-50 text-slate-700'
                )}
              >
                <div className="flex items-center gap-3 min-w-0 pr-2">
                  <div
                    className={cn(
                      'w-8 h-8 rounded-lg flex items-center justify-center text-[11px] font-bold shrink-0 transition-colors',
                      isActive
                        ? 'bg-[#3B5DF0] text-white shadow-xs'
                        : 'bg-slate-100 text-slate-600 group-hover:bg-slate-200'
                    )}
                  >
                    {section.code}
                  </div>
                  <div className="min-w-0">
                    <h3
                      className={cn(
                        'text-xs font-bold leading-tight truncate',
                        isActive ? 'text-[#3B5DF0]' : 'text-slate-900'
                      )}
                    >
                      {section.title}
                    </h3>
                    <p className="text-[11px] text-slate-400 truncate mt-0.5 font-normal">
                      {section.description}
                    </p>
                  </div>
                </div>

                <ChevronRight
                  className={cn(
                    'w-4 h-4 shrink-0 transition-transform',
                    isActive ? 'text-[#3B5DF0]' : 'text-slate-300 group-hover:text-slate-500'
                  )}
                />
              </button>
            );
          })}
        </div>

        {/* Right Content Pane (8 cols) */}
        <div className="lg:col-span-8 bg-white border border-slate-200/80 rounded-2xl p-6 md:p-8 shadow-xs">
          {activeSection === 'general' && (
            <form onSubmit={handleSave} className="space-y-6">
              {/* Card Title */}
              <div className="border-b border-slate-100 pb-4">
                <h2 className="text-base font-bold text-slate-900">Organization information</h2>
                <p className="text-xs text-slate-500 mt-0.5">
                  Shown to authorized parents and staff.
                </p>
              </div>

              {/* Form Grid */}
              <div className="space-y-4 text-xs">
                {/* Row 1: Org name & Operator ref */}
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <div>
                    <label className="block font-semibold text-slate-700 mb-1.5">
                      Organization name
                    </label>
                    <input
                      type="text"
                      value={orgName}
                      onChange={(e) => setOrgName(e.target.value)}
                      className="w-full px-3.5 py-2.5 bg-white border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 text-slate-800 font-medium"
                    />
                  </div>
                  <div>
                    <label className="block font-semibold text-slate-700 mb-1.5">
                      Operator reference
                    </label>
                    <input
                      type="text"
                      disabled
                      value={operatorRef}
                      className="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-slate-500 font-medium cursor-not-allowed select-none"
                    />
                  </div>
                </div>

                {/* Row 2: Support email & phone */}
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <div>
                    <label className="block font-semibold text-slate-700 mb-1.5">
                      Support email
                    </label>
                    <input
                      type="email"
                      value={supportEmail}
                      onChange={(e) => setSupportEmail(e.target.value)}
                      className="w-full px-3.5 py-2.5 bg-white border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 text-slate-800 font-medium"
                    />
                  </div>
                  <div>
                    <label className="block font-semibold text-slate-700 mb-1.5">
                      Support phone
                    </label>
                    <input
                      type="text"
                      value={supportPhone}
                      onChange={(e) => setSupportPhone(e.target.value)}
                      className="w-full px-3.5 py-2.5 bg-white border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 text-slate-800 font-medium"
                    />
                  </div>
                </div>

                {/* Row 3: Registered address */}
                <div>
                  <label className="block font-semibold text-slate-700 mb-1.5">
                    Registered address
                  </label>
                  <textarea
                    rows={4}
                    value={registeredAddress}
                    onChange={(e) => setRegisteredAddress(e.target.value)}
                    className="w-full px-3.5 py-2.5 bg-white border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 text-slate-800 font-medium resize-none leading-relaxed"
                  />
                </div>
              </div>

              {/* Action Buttons */}
              <div className="flex items-center justify-end gap-3 pt-6 border-t border-slate-100">
                <button
                  type="button"
                  onClick={handleDiscard}
                  className="px-4 py-2 border border-slate-200 hover:bg-slate-50 text-slate-700 text-xs font-semibold rounded-xl transition-colors cursor-pointer"
                >
                  Discard
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 bg-[#3B5DF0] hover:bg-[#2F4DCB] text-white text-xs font-semibold rounded-xl shadow-xs transition-colors cursor-pointer"
                >
                  Save changes
                </button>
              </div>
            </form>
          )}

          {activeSection === 'transport' && (
            <div className="space-y-6 text-xs">
              <div className="border-b border-slate-100 pb-4">
                <h2 className="text-base font-bold text-slate-900">Transport & Attendance Policies</h2>
                <p className="text-xs text-slate-500 mt-0.5">Define automated check-in and cutoff timings.</p>
              </div>
              <div className="space-y-4">
                <div>
                  <label className="block font-semibold text-slate-700 mb-1.5">Attendance Check-in Window</label>
                  <select
                    value={attendanceWindow}
                    onChange={(e) => setAttendanceWindow(e.target.value)}
                    className="w-full sm:w-80 px-3.5 py-2.5 bg-white border border-slate-200 rounded-xl"
                  >
                    <option value="10 mins prior to departure">10 mins prior to departure</option>
                    <option value="15 mins prior to departure">15 mins prior to departure</option>
                    <option value="20 mins prior to departure">20 mins prior to departure</option>
                  </select>
                </div>
                <div className="p-4 bg-slate-50 rounded-xl border border-slate-100 text-slate-600">
                  <p className="font-semibold text-slate-800">Unresolved Boarding Escalation</p>
                  <p className="mt-1">Students not confirmed on board after 10 minutes from route departure trigger an automatic dispatch team alert.</p>
                </div>
              </div>
              <div className="flex justify-end pt-4 border-t border-slate-100">
                <button
                  type="button"
                  onClick={handleSave}
                  className="px-4 py-2 bg-[#3B5DF0] text-white font-semibold rounded-xl shadow-xs"
                >
                  Save changes
                </button>
              </div>
            </div>
          )}

          {activeSection === 'security' && (
            <div className="space-y-6 text-xs">
              <div className="border-b border-slate-100 pb-4">
                <h2 className="text-base font-bold text-slate-900">Security & Session Management</h2>
                <p className="text-xs text-slate-500 mt-0.5">Enforce two-factor authentication and token lifespans.</p>
              </div>
              <div className="space-y-4">
                <div className="flex items-center justify-between p-4 bg-slate-50 rounded-xl border border-slate-100">
                  <div>
                    <h4 className="font-bold text-slate-800">Enforce 2FA for all administrative roles</h4>
                    <p className="text-slate-500 mt-0.5">Requires SMS OTP or Authenticator app for Manager and Dispatcher logins.</p>
                  </div>
                  <input
                    type="checkbox"
                    checked={twoFactorRequired}
                    onChange={(e) => setTwoFactorRequired(e.target.checked)}
                    className="w-4 h-4 rounded text-[#3B5DF0]"
                  />
                </div>
              </div>
              <div className="flex justify-end pt-4 border-t border-slate-100">
                <button
                  type="button"
                  onClick={handleSave}
                  className="px-4 py-2 bg-[#3B5DF0] text-white font-semibold rounded-xl shadow-xs"
                >
                  Save changes
                </button>
              </div>
            </div>
          )}

          {activeSection === 'language' && (
            <div className="space-y-6 text-xs">
              <div className="border-b border-slate-100 pb-4">
                <h2 className="text-base font-bold text-slate-900">Language Preferences</h2>
                <p className="text-xs text-slate-500 mt-0.5">Select default application and alert localization.</p>
              </div>
              <div className="grid grid-cols-3 gap-3">
                {['English', 'Sinhala (සිංහල)', 'Tamil (தமிழ்)'].map((lang) => (
                  <button
                    key={lang}
                    type="button"
                    onClick={() => setDefaultLanguage(lang)}
                    className={cn(
                      'p-4 rounded-xl border text-center font-bold transition-all',
                      defaultLanguage === lang
                        ? 'border-[#3B5DF0] bg-blue-50 text-[#3B5DF0]'
                        : 'border-slate-200 bg-white text-slate-700 hover:bg-slate-50'
                    )}
                  >
                    {lang}
                  </button>
                ))}
              </div>
            </div>
          )}

          {activeSection === 'appearance' && (
            <div className="space-y-6 text-xs">
              <div className="border-b border-slate-100 pb-4">
                <h2 className="text-base font-bold text-slate-900">Dashboard Appearance</h2>
                <p className="text-xs text-slate-500 mt-0.5">Visual theme preference for transport manager console.</p>
              </div>
              <div className="grid grid-cols-3 gap-3">
                {['Light', 'Dark', 'System default'].map((theme) => (
                  <button
                    key={theme}
                    type="button"
                    onClick={() => setThemeMode(theme)}
                    className={cn(
                      'p-4 rounded-xl border text-center font-bold transition-all',
                      themeMode === theme
                        ? 'border-[#3B5DF0] bg-blue-50 text-[#3B5DF0]'
                        : 'border-slate-200 bg-white text-slate-700 hover:bg-slate-50'
                    )}
                  >
                    {theme}
                  </button>
                ))}
              </div>
            </div>
          )}

          {(activeSection === 'notifications' || activeSection === 'finance' || activeSection === 'privacy' || activeSection === 'system') && (
            <div className="space-y-6 text-xs">
              <div className="border-b border-slate-100 pb-4">
                <h2 className="text-base font-bold text-slate-900 capitalize">{activeSection} Configuration</h2>
                <p className="text-xs text-slate-500 mt-0.5">Configuration active and synced across all transport fleet nodes.</p>
              </div>
              <div className="p-4 bg-slate-50 rounded-xl border border-slate-100 text-slate-600 space-y-2">
                <p className="font-semibold text-slate-800">Operational Policy Sync</p>
                <p>All rules and parameters in this section are currently active with real-time Firebase backend connection.</p>
              </div>
              <div className="flex justify-end pt-4 border-t border-slate-100">
                <button
                  type="button"
                  onClick={handleSave}
                  className="px-4 py-2 bg-[#3B5DF0] text-white font-semibold rounded-xl shadow-xs"
                >
                  Save changes
                </button>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
