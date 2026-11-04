import { useState } from 'react';
import {
  Plus,
  Search,
  Calendar,
  SlidersHorizontal,
  Download,
  MoreHorizontal,
  X,
  CreditCard,
  Receipt,
  CheckCircle2,
  BellRing,
} from 'lucide-react';
import { Link } from 'react-router-dom';
import { cn } from '@/utils/cn';

interface PaymentRecord {
  id: string;
  student: string;
  studentRef?: string;
  parent: string;
  billingPeriod: string;
  amount: string;
  amountValue: number;
  dueDate: string;
  status: 'Paid' | 'Pending' | 'Overdue' | 'Waived';
  receiptNo?: string;
  paymentMethod?: string;
  paidAt?: string;
}

const initialPayments: PaymentRecord[] = [
  {
    id: 'pay-1',
    student: 'Aanya S.',
    studentRef: 'ST-2084',
    parent: 'S. Senanayake',
    billingPeriod: 'June 2025',
    amount: 'LKR 8,500',
    amountValue: 8500,
    dueDate: '20 Jun',
    status: 'Paid',
    receiptNo: 'REC-2025-0641',
    paymentMethod: 'Bank Transfer (Commercial Bank)',
    paidAt: '18 Jun 2025, 09:14 AM',
  },
  {
    id: 'pay-2',
    student: 'Kavindu P.',
    studentRef: 'ST-2071',
    parent: 'P. Perera',
    billingPeriod: 'June 2025',
    amount: 'LKR 7,200',
    amountValue: 7200,
    dueDate: '20 Jun',
    status: 'Pending',
    receiptNo: 'INV-2025-0688',
    paymentMethod: 'Awaiting Parent Confirmation',
  },
  {
    id: 'pay-3',
    student: 'Yasara F.',
    studentRef: 'ST-2085',
    parent: 'R. Fernando',
    billingPeriod: 'May 2025',
    amount: 'LKR 8,500',
    amountValue: 8500,
    dueDate: '20 May',
    status: 'Overdue',
    receiptNo: 'INV-2025-0512',
    paymentMethod: 'Overdue - Notice Sent',
  },
  {
    id: 'pay-4',
    student: 'Nethum R.',
    studentRef: 'ST-2042',
    parent: 'M. Ramanathan',
    billingPeriod: 'June 2025',
    amount: 'LKR 8,900',
    amountValue: 8900,
    dueDate: '20 Jun',
    status: 'Waived',
    receiptNo: 'WAV-2025-0019',
    paymentMethod: 'School Scholarship Subsidized',
    paidAt: 'Approved by Principal',
  },
];

type TabType = 'All records' | 'Outstanding' | 'Paid' | 'Receipts' | 'Reminders';

export default function PaymentsPage() {
  const [activeTab, setActiveTab] = useState<TabType>('All records');
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedPayments, setSelectedPayments] = useState<string[]>([]);
  const [paymentsList, setPaymentsList] = useState<PaymentRecord[]>(initialPayments);

  // Modals state
  const [isRecordModalOpen, setIsRecordModalOpen] = useState(false);
  const [selectedPaymentDetail, setSelectedPaymentDetail] = useState<PaymentRecord | null>(null);
  const [reminderToast, setReminderToast] = useState<string | null>(null);

  // Form state
  const [newStudent, setNewStudent] = useState('Dulani M.');
  const [newParent, setNewParent] = useState('K. Menaka');
  const [newBillingPeriod, setNewBillingPeriod] = useState('June 2025');
  const [newAmount, setNewAmount] = useState('8500');
  const [newDueDate, setNewDueDate] = useState('20 Jun');
  const [newStatus, setNewStatus] = useState<'Paid' | 'Pending' | 'Overdue' | 'Waived'>('Paid');
  const [newMethod, setNewMethod] = useState('Card Gateway');

  // Filtering
  const filteredPayments = paymentsList.filter((item) => {
    // Tab filter
    if (activeTab === 'Outstanding' && item.status !== 'Pending' && item.status !== 'Overdue') return false;
    if (activeTab === 'Paid' && item.status !== 'Paid') return false;
    if (activeTab === 'Receipts' && item.status !== 'Paid' && item.status !== 'Waived') return false;
    if (activeTab === 'Reminders' && item.status !== 'Pending' && item.status !== 'Overdue') return false;

    // Search filter
    const q = searchQuery.toLowerCase();
    return (
      item.student.toLowerCase().includes(q) ||
      item.parent.toLowerCase().includes(q) ||
      item.billingPeriod.toLowerCase().includes(q) ||
      item.amount.toLowerCase().includes(q) ||
      item.dueDate.toLowerCase().includes(q) ||
      item.status.toLowerCase().includes(q)
    );
  });

  const handleSelectAll = (checked: boolean) => {
    if (checked) {
      setSelectedPayments(filteredPayments.map((p) => p.id));
    } else {
      setSelectedPayments([]);
    }
  };

  const handleToggleSelect = (id: string) => {
    setSelectedPayments((prev) =>
      prev.includes(id) ? prev.filter((p) => p !== id) : [...prev, id]
    );
  };

  const handleRecordPayment = (e: React.FormEvent) => {
    e.preventDefault();
    const formattedAmount = `LKR ${Number(newAmount).toLocaleString()}`;
    const newRecord: PaymentRecord = {
      id: `pay-${Date.now()}`,
      student: newStudent,
      studentRef: `ST-${Math.floor(2000 + Math.random() * 900)}`,
      parent: newParent,
      billingPeriod: newBillingPeriod,
      amount: formattedAmount,
      amountValue: Number(newAmount),
      dueDate: newDueDate,
      status: newStatus,
      receiptNo: `REC-2025-${Math.floor(1000 + Math.random() * 9000)}`,
      paymentMethod: newMethod,
      paidAt: 'Just now',
    };
    setPaymentsList((prev) => [newRecord, ...prev]);
    setIsRecordModalOpen(false);
  };

  const triggerReminder = (payment: PaymentRecord) => {
    setReminderToast(`SMS & Push Payment Reminder dispatched to ${payment.parent} for ${payment.student} (${payment.amount})`);
    setTimeout(() => setReminderToast(null), 4000);
  };

  return (
    <div className="w-full p-8 space-y-6 max-w-[1600px] mx-auto overflow-x-hidden">
      {/* Toast Notification */}
      {reminderToast && (
        <div className="fixed top-20 right-8 z-50 bg-slate-900 text-white text-xs px-4 py-3 rounded-xl shadow-xl flex items-center gap-2.5 animate-in slide-in-from-top-4 duration-200">
          <BellRing className="w-4 h-4 text-amber-400" />
          <span>{reminderToast}</span>
        </div>
      )}

      {/* 1. Page Header & Action Button */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 shrink-0">
        <div>
          <span className="text-[11px] font-bold tracking-wider text-[#3B5DF0] uppercase">
            TRANSPORT OPERATIONS
          </span>
          <h1 className="text-2xl md:text-3xl font-extrabold text-slate-900 mt-1 tracking-tight">
            Payments & Fees
          </h1>
          <p className="text-slate-500 text-xs md:text-sm mt-1">
            Track verified billing records, receipts and reminders.
          </p>
        </div>

        {/* Right CTA Button */}
        <button
          type="button"
          onClick={() => setIsRecordModalOpen(true)}
          className="inline-flex items-center gap-2 bg-[#3B5DF0] hover:bg-[#2F4DCB] text-white text-xs font-semibold px-4 py-2.5 rounded-xl shadow-sm shadow-[#3B5DF0]/30 transition-all self-start md:self-auto cursor-pointer"
        >
          <Plus className="w-4 h-4" />
          <span>Record payment</span>
        </button>
      </div>

      {/* 2. Main White Card Container */}
      <div className="bg-white border border-slate-200/80 rounded-2xl p-6 shadow-xs space-y-6">
        {/* Navigation Tabs */}
        <div className="flex items-center gap-8 border-b border-slate-100 text-xs font-semibold text-slate-500 pb-0 overflow-x-auto">
          {(['All records', 'Outstanding', 'Paid', 'Receipts', 'Reminders'] as TabType[]).map(
            (tab) => {
              const isActive = activeTab === tab;
              return (
                <button
                  key={tab}
                  type="button"
                  onClick={() => setActiveTab(tab)}
                  className={cn(
                    'pb-3.5 transition-all relative cursor-pointer whitespace-nowrap',
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
              placeholder="Search payments & fees..."
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
                      filteredPayments.length > 0 &&
                      selectedPayments.length === filteredPayments.length
                    }
                    onChange={(e) => handleSelectAll(e.target.checked)}
                    className="w-4 h-4 rounded border-slate-300 text-[#3B5DF0] focus:ring-blue-500 cursor-pointer"
                  />
                </th>
                <th className="py-3 px-4 font-bold">STUDENT</th>
                <th className="py-3 px-4 font-bold">PARENT</th>
                <th className="py-3 px-4 font-bold">BILLING PERIOD</th>
                <th className="py-3 px-4 font-bold">AMOUNT</th>
                <th className="py-3 px-4 font-bold">DUE DATE</th>
                <th className="py-3 px-4 font-bold">STATUS</th>
                <th className="py-3 px-4 w-12 text-right"></th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 text-slate-700">
              {filteredPayments.map((item) => (
                <tr
                  key={item.id}
                  className="hover:bg-slate-50/70 transition-colors group cursor-pointer"
                  onClick={() => setSelectedPaymentDetail(item)}
                >
                  <td className="py-3 px-3" onClick={(e) => e.stopPropagation()}>
                    <input
                      type="checkbox"
                      checked={selectedPayments.includes(item.id)}
                      onChange={() => handleToggleSelect(item.id)}
                      className="w-4 h-4 rounded border-slate-300 text-[#3B5DF0] focus:ring-blue-500 cursor-pointer"
                    />
                  </td>
                  <td className="py-3 px-4 font-bold text-slate-900">
                    <Link
                      to="/students"
                      onClick={(e) => e.stopPropagation()}
                      className="hover:text-[#3B5DF0] transition-colors"
                    >
                      {item.student}
                    </Link>
                  </td>
                  <td className="py-3 px-4 text-slate-600 font-medium">
                    <Link
                      to="/parents"
                      onClick={(e) => e.stopPropagation()}
                      className="hover:text-[#3B5DF0] transition-colors"
                    >
                      {item.parent}
                    </Link>
                  </td>
                  <td className="py-3 px-4 text-slate-600 font-medium">
                    {item.billingPeriod}
                  </td>
                  <td className="py-3 px-4 font-semibold text-slate-800">
                    {item.amount}
                  </td>
                  <td className="py-3 px-4 text-slate-500 font-medium">
                    {item.dueDate}
                  </td>
                  <td className="py-3 px-4">
                    {item.status === 'Paid' && (
                      <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-semibold bg-emerald-50 text-emerald-700 border border-emerald-200/60">
                        <span className="w-1.5 h-1.5 rounded-full bg-emerald-500" />
                        Paid
                      </span>
                    )}
                    {item.status === 'Pending' && (
                      <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-semibold bg-amber-50 text-amber-700 border border-amber-200/60">
                        <span className="w-1.5 h-1.5 rounded-full bg-amber-500" />
                        Pending
                      </span>
                    )}
                    {item.status === 'Overdue' && (
                      <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-semibold bg-rose-50 text-rose-700 border border-rose-200/60">
                        <span className="w-1.5 h-1.5 rounded-full bg-rose-500" />
                        Overdue
                      </span>
                    )}
                    {item.status === 'Waived' && (
                      <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-semibold bg-slate-100 text-slate-600 border border-slate-200/60">
                        <span className="w-1.5 h-1.5 rounded-full bg-slate-400" />
                        Waived
                      </span>
                    )}
                  </td>
                  <td className="py-3 px-4 text-right" onClick={(e) => e.stopPropagation()}>
                    <button
                      type="button"
                      onClick={() => setSelectedPaymentDetail(item)}
                      className="p-1 rounded-lg text-slate-400 hover:text-slate-600 hover:bg-slate-100 transition-colors cursor-pointer"
                    >
                      <MoreHorizontal className="w-4 h-4" />
                    </button>
                  </td>
                </tr>
              ))}

              {filteredPayments.length === 0 && (
                <tr>
                  <td colSpan={8} className="py-12 text-center text-slate-400">
                    No payment records match the filter or search query.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>

        {/* 4. Pagination Footer */}
        <div className="flex flex-col sm:flex-row items-center justify-between gap-4 pt-4 border-t border-slate-100 text-xs text-slate-500 font-medium">
          <span>Showing {filteredPayments.length} sample records</span>

          <div className="flex items-center gap-1">
            <button
              type="button"
              className="px-3 py-1.5 rounded-lg border border-slate-200 hover:bg-slate-50 disabled:opacity-50 text-slate-600 transition-colors cursor-pointer"
            >
              Previous
            </button>
            <button
              type="button"
              className="w-8 h-8 rounded-lg bg-[#3B5DF0] text-white font-bold flex items-center justify-center cursor-pointer shadow-xs"
            >
              1
            </button>
            <button
              type="button"
              className="px-3 py-1.5 rounded-lg border border-slate-200 hover:bg-slate-50 disabled:opacity-50 text-slate-600 transition-colors cursor-pointer"
            >
              Next
            </button>
          </div>
        </div>
      </div>

      {/* MODAL 1: Record Payment */}
      {isRecordModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/40 backdrop-blur-xs p-4">
          <div className="bg-white rounded-2xl max-w-lg w-full p-6 shadow-xl border border-slate-100 space-y-4 animate-in fade-in-50 zoom-in-95 duration-150">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div className="flex items-center gap-2">
                <div className="w-8 h-8 rounded-lg bg-blue-50 text-[#3B5DF0] flex items-center justify-center font-bold">
                  <CreditCard className="w-4 h-4" />
                </div>
                <h3 className="font-bold text-slate-900 text-base">Record Fee Payment</h3>
              </div>
              <button
                type="button"
                onClick={() => setIsRecordModalOpen(false)}
                className="text-slate-400 hover:text-slate-600 p-1 rounded-lg hover:bg-slate-100 transition-colors"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <form onSubmit={handleRecordPayment} className="space-y-4 text-xs">
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold text-slate-700 mb-1">
                    Student Name
                  </label>
                  <input
                    type="text"
                    required
                    value={newStudent}
                    onChange={(e) => setNewStudent(e.target.value)}
                    className="w-full px-3 py-2 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
                  />
                </div>
                <div>
                  <label className="block font-semibold text-slate-700 mb-1">
                    Parent / Guardian
                  </label>
                  <input
                    type="text"
                    required
                    value={newParent}
                    onChange={(e) => setNewParent(e.target.value)}
                    className="w-full px-3 py-2 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold text-slate-700 mb-1">
                    Billing Period
                  </label>
                  <select
                    value={newBillingPeriod}
                    onChange={(e) => setNewBillingPeriod(e.target.value)}
                    className="w-full px-3 py-2 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 bg-white"
                  >
                    <option value="June 2025">June 2025</option>
                    <option value="July 2025">July 2025</option>
                    <option value="August 2025">August 2025</option>
                    <option value="Term 2 (2025)">Term 2 (2025)</option>
                  </select>
                </div>
                <div>
                  <label className="block font-semibold text-slate-700 mb-1">
                    Amount (LKR)
                  </label>
                  <input
                    type="number"
                    required
                    value={newAmount}
                    onChange={(e) => setNewAmount(e.target.value)}
                    className="w-full px-3 py-2 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold text-slate-700 mb-1">
                    Due Date
                  </label>
                  <input
                    type="text"
                    required
                    value={newDueDate}
                    onChange={(e) => setNewDueDate(e.target.value)}
                    className="w-full px-3 py-2 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
                  />
                </div>
                <div>
                  <label className="block font-semibold text-slate-700 mb-1">
                    Payment Method
                  </label>
                  <select
                    value={newMethod}
                    onChange={(e) => setNewMethod(e.target.value)}
                    className="w-full px-3 py-2 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 bg-white"
                  >
                    <option value="Bank Transfer (Commercial Bank)">Bank Transfer</option>
                    <option value="Card Gateway">Card Gateway</option>
                    <option value="Cash at Transport Desk">Cash Desk</option>
                    <option value="Scholarship Subsidized">Scholarship</option>
                  </select>
                </div>
              </div>

              <div>
                <label className="block font-semibold text-slate-700 mb-1">
                  Payment Status
                </label>
                <div className="grid grid-cols-4 gap-2">
                  {(['Paid', 'Pending', 'Overdue', 'Waived'] as const).map((statusOption) => (
                    <button
                      key={statusOption}
                      type="button"
                      onClick={() => setNewStatus(statusOption)}
                      className={cn(
                        'py-2 rounded-xl text-center font-semibold border transition-all',
                        newStatus === statusOption
                          ? 'bg-[#3B5DF0] text-white border-[#3B5DF0]'
                          : 'bg-white text-slate-700 border-slate-200 hover:bg-slate-50'
                      )}
                    >
                      {statusOption}
                    </button>
                  ))}
                </div>
              </div>

              <div className="flex items-center justify-end gap-2 pt-3 border-t border-slate-100">
                <button
                  type="button"
                  onClick={() => setIsRecordModalOpen(false)}
                  className="px-4 py-2 border border-slate-200 rounded-xl text-slate-600 hover:bg-slate-50 font-semibold"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 bg-[#3B5DF0] hover:bg-[#2F4DCB] text-white rounded-xl font-semibold shadow-xs"
                >
                  Confirm & Save
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* MODAL 2: Receipt & Detailed View */}
      {selectedPaymentDetail && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/40 backdrop-blur-xs p-4">
          <div className="bg-white rounded-2xl max-w-md w-full p-6 shadow-xl border border-slate-100 space-y-4 animate-in fade-in-50 zoom-in-95 duration-150 text-xs">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div className="flex items-center gap-2">
                <div className="w-8 h-8 rounded-lg bg-emerald-50 text-emerald-600 flex items-center justify-center font-bold">
                  <Receipt className="w-4 h-4" />
                </div>
                <div>
                  <h3 className="font-bold text-slate-900 text-base">
                    {selectedPaymentDetail.receiptNo || 'Payment Record'}
                  </h3>
                  <span className="text-[10px] text-slate-400">
                    Official Transport Billing Ledger
                  </span>
                </div>
              </div>
              <button
                type="button"
                onClick={() => setSelectedPaymentDetail(null)}
                className="text-slate-400 hover:text-slate-600 p-1 rounded-lg hover:bg-slate-100 transition-colors"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <div className="space-y-2.5">
              <div className="flex justify-between py-1 border-b border-slate-50">
                <span className="text-slate-400">Student:</span>
                <span className="font-bold text-slate-800">{selectedPaymentDetail.student}</span>
              </div>
              <div className="flex justify-between py-1 border-b border-slate-50">
                <span className="text-slate-400">Parent / Guardian:</span>
                <span className="font-medium text-slate-700">{selectedPaymentDetail.parent}</span>
              </div>
              <div className="flex justify-between py-1 border-b border-slate-50">
                <span className="text-slate-400">Billing Period:</span>
                <span className="font-medium text-slate-700">{selectedPaymentDetail.billingPeriod}</span>
              </div>
              <div className="flex justify-between py-1 border-b border-slate-50">
                <span className="text-slate-400">Total Fee:</span>
                <span className="font-bold text-base text-[#3B5DF0]">{selectedPaymentDetail.amount}</span>
              </div>
              <div className="flex justify-between py-1 border-b border-slate-50">
                <span className="text-slate-400">Due Date:</span>
                <span className="font-medium text-slate-700">{selectedPaymentDetail.dueDate}</span>
              </div>
              <div className="flex justify-between py-1 border-b border-slate-50">
                <span className="text-slate-400">Payment Status:</span>
                <span className="font-bold text-slate-800">{selectedPaymentDetail.status}</span>
              </div>
              <div className="flex justify-between py-1 border-b border-slate-50">
                <span className="text-slate-400">Method / Channel:</span>
                <span className="font-medium text-slate-700">{selectedPaymentDetail.paymentMethod}</span>
              </div>
            </div>

            <div className="flex items-center justify-between pt-3 border-t border-slate-100">
              {(selectedPaymentDetail.status === 'Pending' || selectedPaymentDetail.status === 'Overdue') ? (
                <button
                  type="button"
                  onClick={() => {
                    triggerReminder(selectedPaymentDetail);
                    setSelectedPaymentDetail(null);
                  }}
                  className="px-3 py-1.5 bg-amber-50 text-amber-700 border border-amber-200 rounded-xl font-semibold hover:bg-amber-100 transition-colors flex items-center gap-1.5"
                >
                  <BellRing className="w-3.5 h-3.5" />
                  Send Reminder
                </button>
              ) : (
                <button
                  type="button"
                  onClick={() => {
                    alert(`Receipt ${selectedPaymentDetail.receiptNo} sent to registered parent email & phone.`);
                    setSelectedPaymentDetail(null);
                  }}
                  className="px-3 py-1.5 bg-emerald-50 text-emerald-700 border border-emerald-200 rounded-xl font-semibold hover:bg-emerald-100 transition-colors flex items-center gap-1.5"
                >
                  <CheckCircle2 className="w-3.5 h-3.5" />
                  Email Receipt
                </button>
              )}

              <button
                type="button"
                onClick={() => setSelectedPaymentDetail(null)}
                className="px-4 py-1.5 bg-slate-900 text-white rounded-xl font-semibold hover:bg-slate-800 transition-colors"
              >
                Close
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
