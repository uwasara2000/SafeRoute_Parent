import { useState } from 'react';
import {
  Plus,
  Search,
  Calendar,
  SlidersHorizontal,
  Download,
  MoreHorizontal,
  X,
  Send,
} from 'lucide-react';
import { cn } from '@/utils/cn';

interface NotificationRecord {
  id: string;
  title: string;
  audience: string;
  channel: string;
  created: string;
  delivery: string;
  status: 'Partial' | 'Delivered' | 'Failed: 3';
}

const initialNotifications: NotificationRecord[] = [
  {
    id: 'n1',
    title: 'Trip delay: Lakeside',
    audience: '18 parents',
    channel: 'Push + SMS',
    created: '07:18',
    delivery: '16 delivered',
    status: 'Partial',
  },
  {
    id: 'n2',
    title: 'Student boarded',
    audience: 'S. Senanayake',
    channel: 'Push',
    created: '07:21',
    delivery: 'Delivered',
    status: 'Delivered',
  },
  {
    id: 'n3',
    title: 'Route update',
    audience: 'North Ridge',
    channel: 'Push + email',
    created: 'Yesterday',
    delivery: '31 delivered',
    status: 'Delivered',
  },
  {
    id: 'n4',
    title: 'Payment reminder',
    audience: '12 parents',
    channel: 'Email',
    created: 'Yesterday',
    delivery: '0 delivered',
    status: 'Failed: 3',
  },
];

type TabType = 'Delivery history' | 'Automated events' | 'Templates' | 'Failed';

export default function NotificationsPage() {
  const [activeTab, setActiveTab] = useState<TabType>('Delivery history');
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedNotifications, setSelectedNotifications] = useState<string[]>([]);
  const [isSendModalOpen, setIsSendModalOpen] = useState(false);

  // Form State
  const [newTitle, setNewTitle] = useState('Severe Traffic Alert: North Ridge Route');
  const [newAudience, setNewAudience] = useState('All parents on North Ridge');
  const [newChannel, setNewChannel] = useState('Push + SMS');
  const [newMessage, setNewMessage] = useState(
    'Bus NB-2341 is experiencing a 10-minute traffic delay near Horton Place. All students are safe on board.'
  );

  const [notificationsList, setNotificationsList] = useState<NotificationRecord[]>(initialNotifications);

  // Filtering
  const filteredNotifications = notificationsList.filter((item) => {
    // Tab filter
    if (activeTab === 'Automated events' && item.title !== 'Student boarded') return false;
    if (activeTab === 'Failed' && !item.status.includes('Failed')) return false;

    // Search filter
    const q = searchQuery.toLowerCase();
    return (
      item.title.toLowerCase().includes(q) ||
      item.audience.toLowerCase().includes(q) ||
      item.channel.toLowerCase().includes(q) ||
      item.delivery.toLowerCase().includes(q)
    );
  });

  const handleSelectAll = (checked: boolean) => {
    if (checked) {
      setSelectedNotifications(filteredNotifications.map((n) => n.id));
    } else {
      setSelectedNotifications([]);
    }
  };

  const handleToggleSelect = (id: string) => {
    setSelectedNotifications((prev) =>
      prev.includes(id) ? prev.filter((item) => item !== id) : [...prev, id]
    );
  };

  const handleSendAnnouncement = (e: React.FormEvent) => {
    e.preventDefault();
    const newRecord: NotificationRecord = {
      id: `n_${Date.now()}`,
      title: newTitle,
      audience: newAudience,
      channel: newChannel,
      created: 'Just now',
      delivery: 'Broadcasting...',
      status: 'Delivered',
    };
    setNotificationsList((prev) => [newRecord, ...prev]);
    setIsSendModalOpen(false);
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
            Notifications
          </h1>
          <p className="text-slate-500 text-xs md:text-sm mt-1">
            Manage event messages, announcements and delivery history.
          </p>
        </div>

        {/* Right CTA Button */}
        <button
          type="button"
          onClick={() => setIsSendModalOpen(true)}
          className="inline-flex items-center gap-2 bg-[#3B5DF0] hover:bg-[#2F4DCB] text-white text-xs font-semibold px-4 py-2.5 rounded-xl shadow-sm shadow-[#3B5DF0]/30 transition-all self-start md:self-auto cursor-pointer"
        >
          <Plus className="w-4 h-4" />
          <span>Send announcement</span>
        </button>
      </div>

      {/* 2. Main White Card Container */}
      <div className="bg-white border border-slate-200/80 rounded-2xl p-6 shadow-xs space-y-6">
        {/* Navigation Tabs */}
        <div className="flex items-center gap-8 border-b border-slate-100 text-xs font-semibold text-slate-500 pb-0">
          {(['Delivery history', 'Automated events', 'Templates', 'Failed'] as TabType[]).map(
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
              placeholder="Search notifications..."
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
                      filteredNotifications.length > 0 &&
                      selectedNotifications.length === filteredNotifications.length
                    }
                    onChange={(e) => handleSelectAll(e.target.checked)}
                    className="w-4 h-4 rounded border-slate-300 text-[#3B5DF0] focus:ring-blue-500 cursor-pointer"
                  />
                </th>
                <th className="py-3 px-4 font-bold">NOTIFICATION</th>
                <th className="py-3 px-4 font-bold">AUDIENCE</th>
                <th className="py-3 px-4 font-bold">CHANNEL</th>
                <th className="py-3 px-4 font-bold">CREATED</th>
                <th className="py-3 px-4 font-bold">DELIVERY</th>
                <th className="py-3 px-4 font-bold">STATUS</th>
                <th className="py-3 px-4 w-12 text-right"></th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {filteredNotifications.map((item) => {
                const isSelected = selectedNotifications.includes(item.id);
                return (
                  <tr
                    key={item.id}
                    className={cn(
                      'hover:bg-slate-50/70 transition-colors group',
                      isSelected && 'bg-blue-50/30'
                    )}
                  >
                    <td className="py-3.5 px-3">
                      <input
                        type="checkbox"
                        checked={isSelected}
                        onChange={() => handleToggleSelect(item.id)}
                        className="w-4 h-4 rounded border-slate-300 text-[#3B5DF0] focus:ring-blue-500 cursor-pointer"
                      />
                    </td>
                    <td className="py-3.5 px-4 font-bold text-slate-900">
                      {item.title}
                    </td>
                    <td className="py-3.5 px-4 text-slate-600 font-medium">
                      {item.audience}
                    </td>
                    <td className="py-3.5 px-4 text-slate-600 font-medium">
                      {item.channel}
                    </td>
                    <td className="py-3.5 px-4 text-slate-600 font-medium">
                      {item.created}
                    </td>
                    <td className="py-3.5 px-4 text-slate-600 font-medium">
                      {item.delivery}
                    </td>
                    <td className="py-3.5 px-4">
                      {item.status === 'Delivered' && (
                        <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-semibold bg-emerald-50 text-emerald-700 border border-emerald-200">
                          <span className="w-1.5 h-1.5 rounded-full bg-emerald-500" />
                          Delivered
                        </span>
                      )}
                      {item.status === 'Partial' && (
                        <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-semibold bg-amber-50 text-amber-700 border border-amber-200">
                          <span className="w-1.5 h-1.5 rounded-full bg-amber-500" />
                          Partial
                        </span>
                      )}
                      {item.status.includes('Failed') && (
                        <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-semibold bg-rose-50 text-rose-700 border border-rose-200">
                          <span className="w-1.5 h-1.5 rounded-full bg-rose-500" />
                          {item.status}
                        </span>
                      )}
                    </td>
                    <td className="py-3.5 px-4 text-right">
                      <button
                        type="button"
                        className="p-1 rounded-lg text-slate-400 hover:text-slate-600 hover:bg-slate-100 transition-colors cursor-pointer"
                        title="Notification Actions"
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
          <span>Showing {filteredNotifications.length} records</span>

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

      {/* 5. Send Announcement Modal */}
      {isSendModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-xs p-4">
          <div className="bg-white rounded-2xl shadow-xl border border-slate-200 w-full max-w-lg p-6 space-y-5 animate-in fade-in zoom-in-95 duration-150">
            <div className="flex items-center justify-between pb-3 border-b border-slate-100">
              <div>
                <h3 className="text-base font-extrabold text-slate-900">Send Fleet Announcement</h3>
                <p className="text-xs text-slate-500 mt-0.5">
                  Broadcast instant alerts and SMS/Push notifications to parents or staff.
                </p>
              </div>
              <button
                type="button"
                onClick={() => setIsSendModalOpen(false)}
                className="p-1 rounded-lg text-slate-400 hover:text-slate-600 hover:bg-slate-100 transition-colors cursor-pointer"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleSendAnnouncement} className="space-y-4 text-xs">
              <div>
                <label className="block font-bold text-slate-700 mb-1">Announcement Title</label>
                <input
                  type="text"
                  value={newTitle}
                  onChange={(e) => setNewTitle(e.target.value)}
                  required
                  placeholder="e.g. Route Delay Alert"
                  className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 font-bold"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-bold text-slate-700 mb-1">Target Audience</label>
                  <select
                    value={newAudience}
                    onChange={(e) => setNewAudience(e.target.value)}
                    className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
                  >
                    <option value="All parents on North Ridge">All parents on North Ridge</option>
                    <option value="All parents on Lakeside">All parents on Lakeside</option>
                    <option value="All active drivers">All active drivers</option>
                    <option value="All parents & guardians">All parents & guardians</option>
                  </select>
                </div>

                <div>
                  <label className="block font-bold text-slate-700 mb-1">Channels</label>
                  <select
                    value={newChannel}
                    onChange={(e) => setNewChannel(e.target.value)}
                    className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
                  >
                    <option value="Push + SMS">Push + SMS</option>
                    <option value="Push Notification">Push Notification</option>
                    <option value="Email Alert">Email Alert</option>
                    <option value="All Channels">All Channels (Push, SMS, Email)</option>
                  </select>
                </div>
              </div>

              <div>
                <label className="block font-bold text-slate-700 mb-1">Message Content</label>
                <textarea
                  rows={3}
                  value={newMessage}
                  onChange={(e) => setNewMessage(e.target.value)}
                  required
                  placeholder="Write message to send..."
                  className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 text-xs"
                />
              </div>

              <div className="pt-3 border-t border-slate-100 flex items-center justify-end gap-2.5">
                <button
                  type="button"
                  onClick={() => setIsSendModalOpen(false)}
                  className="px-4 py-2 rounded-xl border border-slate-200 text-slate-700 font-semibold hover:bg-slate-50 transition-colors cursor-pointer"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="inline-flex items-center gap-1.5 px-4 py-2 rounded-xl bg-[#3B5DF0] hover:bg-[#2F4DCB] text-white font-semibold shadow-xs transition-colors cursor-pointer"
                >
                  <Send className="w-4 h-4" />
                  <span>Broadcast Now</span>
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}

