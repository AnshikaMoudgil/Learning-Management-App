'use strict';
'use client';

import { useEffect, useState, useCallback } from 'react';
import { supabase } from '@/app/lib/supabaseClient';
import { useAuth } from '@/app/lib/AuthContext';
import toast from 'react-hot-toast';
import {
  CreditCard, Search, HelpCircle, Loader2, CheckCircle, XCircle,
  Clock, RefreshCw, User, Tag, Shield,
  AlertTriangle,
} from 'lucide-react';
import Pagination from '@/components/Pagination';
import { PAGE_SIZE } from '@/app/lib/constants';

interface PaymentUser {
  full_name: string | null;
  email: string | null;
}

interface PaymentCoupon {
  code: string;
  discount_type: string;
  discount_value: number;
}

interface Payment {
  id: string;
  user_id: string;
  course_id: string;
  coupon_id: string | null;
  base_amount: number;
  discount_amount: number;
  amount_paid: number;
  amount_subunits: number;
  currency: string;
  razorpay_order_id: string;
  razorpay_payment_id: string | null;
  razorpay_signature: string | null;
  status: string;
  expires_at: string;
  created_at: string;
  updated_at: string;
  user: PaymentUser | null;
  coupon: PaymentCoupon | null;
}

interface WebhookLog {
  id: string;
  razorpay_event_id: string | null;
  razorpay_order_id: string | null;
  razorpay_payment_id: string | null;
  event_type: string;
  payload: unknown;
  signature_verified: boolean;
  processed_at: string | null;
  created_at: string;
}

const statusConfig: Record<string, { label: string; color: string; icon: React.ComponentType<any> }> = {
  completed: { label: 'Completed', color: 'text-emerald-400 bg-emerald-500/10 border-emerald-500/20', icon: CheckCircle },
  pending: { label: 'Pending', color: 'text-amber-400 bg-amber-500/10 border-amber-500/20', icon: Clock },
  failed: { label: 'Failed', color: 'text-rose-400 bg-rose-500/10 border-rose-500/20', icon: XCircle },
  expired: { label: 'Expired', color: 'text-zinc-400 bg-zinc-500/10 border-zinc-500/20', icon: Clock },
  refunded: { label: 'Refunded', color: 'text-purple-400 bg-purple-500/10 border-purple-500/20', icon: RefreshCw },
};

const statuses = ['all', 'completed', 'pending', 'failed', 'expired', 'refunded'];

export default function PaymentsPage() {
  const { accessToken } = useAuth();
  const [payments, setPayments] = useState<Payment[]>([]);
  const [webhookLogs, setWebhookLogs] = useState<WebhookLog[]>([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [isLoading, setIsLoading] = useState(true);
  const [activeTab, setActiveTab] = useState<'payments' | 'webhooks'>('payments');
  const [currentPage, setCurrentPage] = useState(1);

  const fetchPayments = useCallback(async () => {
    try {
      setIsLoading(true);
      if (!accessToken) { toast.error('Session expired.'); return; }

      const params = new URLSearchParams();
      if (statusFilter !== 'all') params.set('status', statusFilter);

      const res = await fetch(`/api/admin/payments?${params.toString()}`, {
        headers: { Authorization: `Bearer ${accessToken}` },
      });
      if (!res.ok) { const err = await res.json(); throw new Error(err.error || 'Failed to load payments.'); }
      const data = await res.json();
      setPayments(data.payments || []);
    } catch (err: unknown) {
      toast.error(err instanceof Error ? err.message : 'Failed to load payments.');
    } finally {
      setIsLoading(false);
    }
  }, [statusFilter, accessToken]);

  const fetchWebhookLogs = useCallback(async () => {
    try {
      setIsLoading(true);

      const { data, error } = await supabase
        .from('webhook_logs')
        .select('*')
        .order('created_at', { ascending: false })
        .limit(100);

      if (error) throw new Error(error.message);
      setWebhookLogs(data || []);
    } catch (err: unknown) {
      toast.error(err instanceof Error ? err.message : 'Failed to load webhook logs.');
    } finally {
      setIsLoading(false);
    }
  }, []);

  useEffect(() => {
    if (activeTab === 'payments') fetchPayments();
  }, [fetchPayments, activeTab]);

  useEffect(() => {
    if (activeTab === 'webhooks') fetchWebhookLogs();
  }, [fetchWebhookLogs, activeTab]);

  useEffect(() => { setCurrentPage(1); }, [searchTerm, statusFilter]);

  const formatAmount = (amount: number) => `₹${amount.toLocaleString('en-IN', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;

  const getStatusBadge = (status: string) => {
    const cfg = statusConfig[status] || { label: status, color: 'text-zinc-400 bg-zinc-500/10 border-zinc-500/20', icon: HelpCircle };
    const Icon = cfg.icon;
    return (
      <span className={`inline-flex items-center gap-1 rounded-full px-3 py-1 text-xs font-medium border ${cfg.color}`}>
        <Icon className="h-3 w-3" /> {cfg.label}
      </span>
    );
  };

  const filteredPayments = payments.filter(p => {
    if (searchTerm) {
      const term = searchTerm.toLowerCase();
      if (p.razorpay_order_id?.toLowerCase().includes(term)) return true;
      if (p.razorpay_payment_id?.toLowerCase().includes(term)) return true;
      if (p.user?.full_name?.toLowerCase().includes(term)) return true;
      if (p.user?.email?.toLowerCase().includes(term)) return true;
      if (p.coupon?.code?.toLowerCase().includes(term)) return true;
      return false;
    }
    return true;
  });
  const totalPages = Math.max(1, Math.ceil(filteredPayments.length / PAGE_SIZE));
  const safePage = Math.min(currentPage, totalPages);
  const paginatedPayments = filteredPayments.slice((safePage - 1) * PAGE_SIZE, safePage * PAGE_SIZE);

  return (
    <div className="space-y-8 animate-in fade-in duration-300">
      <div>
        <h1 className="text-3xl font-extrabold text-gray-900 tracking-tight">Payments & Orders</h1>
        <p className="text-gray-500 text-sm mt-1">View payment transactions, order details, and Razorpay webhook audit logs.</p>
      </div>

      <div className="flex items-center gap-2 p-1 rounded-xl bg-white shadow-sm border border-gray-200 self-start">
        <button
          onClick={() => setActiveTab('payments')}
          className={`px-4 py-2 text-xs font-semibold rounded-lg transition-all cursor-pointer ${
            activeTab === 'payments'
          ? 'bg-blue-600 text-white shadow-md shadow-blue-500/10'
          : 'text-gray-500 hover:text-gray-900'
        }`}
        >
          <span className="inline-flex items-center gap-1.5">
            <CreditCard className="h-3.5 w-3.5" /> Orders & Payments
          </span>
        </button>
        <button
          onClick={() => setActiveTab('webhooks')}
          className={`px-4 py-2 text-xs font-semibold rounded-lg transition-all cursor-pointer ${
            activeTab === 'webhooks'
              ? 'bg-blue-600 text-white shadow-md shadow-blue-500/10'
              : 'text-gray-500 hover:text-gray-900'
          }`}
        >
          <span className="inline-flex items-center gap-1.5">
            <Shield className="h-3.5 w-3.5" /> Webhook Audit Logs
          </span>
        </button>
      </div>

      {activeTab === 'payments' && (
        <>
          <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
            <div className="flex gap-2 flex-wrap">
              {statuses.map((s) => (
                <button
                  key={s}
                  onClick={() => setStatusFilter(s)}
                  className={`px-3 py-1.5 rounded-lg text-xs font-medium transition-all cursor-pointer ${
                    statusFilter === s
                      ? 'bg-blue-600/10 text-blue-600 border border-blue-500/25'
                      : 'text-gray-500 hover:text-gray-700 border border-transparent hover:border-gray-300'
                  }`}
                >
                  {s.charAt(0).toUpperCase() + s.slice(1)}
                </button>
              ))}
            </div>

            <div className="relative w-full md:max-w-xs">
              <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" />
              <input
                type="text"
                placeholder="Search order ID, user, coupon..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full rounded-xl border border-gray-200 bg-gray-50 py-2.5 pl-9 pr-4 text-xs text-gray-900 placeholder-gray-400 outline-none transition focus:border-blue-500 focus:bg-white"
              />
            </div>
          </div>

          {isLoading ? (
            <div className="flex h-48 items-center justify-center">
              <span className="text-sm text-gray-400">Loading payments...</span>
            </div>
          ) : filteredPayments.length === 0 ? (
            <div className="flex flex-col items-center justify-center text-center p-12 rounded-2xl border border-dashed border-gray-200 bg-gray-50 shadow-sm">
              <CreditCard className="h-10 w-10 text-gray-400 mb-3" />
              <h3 className="text-lg font-bold text-gray-900">No payments found</h3>
              <p className="text-gray-400 text-sm mt-1">No transactions match your current filters.</p>
            </div>
          ) : (
            <div className="space-y-4">
              {paginatedPayments.map((p) => (
                <div key={p.id} className="rounded-xl border border-gray-200 bg-white shadow-sm p-5 space-y-4">
                  <div className="flex items-start justify-between flex-wrap gap-4">
                    <div className="flex items-center gap-3">
                      <div className="flex h-10 w-10 items-center justify-center rounded-full bg-gray-100 text-gray-700 border border-gray-300">
                        <User className="h-5 w-5" />
                      </div>
                      <div>
                        <p className="text-sm font-semibold text-gray-900">{p.user?.full_name || 'Unknown User'}</p>
                        <p className="text-xs text-gray-400">{p.user?.email || 'No email'}</p>
                      </div>
                    </div>
                    {getStatusBadge(p.status)}
                  </div>

                  <div className="grid grid-cols-2 md:grid-cols-4 gap-4 text-sm">
                    <div>
                      <p className="text-xs text-gray-400 mb-1">Order ID</p>
                      <p className="text-gray-700 font-mono text-xs break-all">{p.razorpay_order_id}</p>
                    </div>
                    <div>
                      <p className="text-xs text-gray-400 mb-1">Payment ID</p>
                      <p className="text-gray-700 font-mono text-xs break-all">{p.razorpay_payment_id || '—'}</p>
                    </div>
                    <div>
                      <p className="text-xs text-gray-400 mb-1">Base Amount</p>
                      <p className="text-gray-700">{formatAmount(p.base_amount)}</p>
                    </div>
                    <div>
                      <p className="text-xs text-gray-400 mb-1">Amount Paid</p>
                      <p className="text-gray-900 font-bold">{formatAmount(p.amount_paid)}</p>
                    </div>
                  </div>

                  {p.discount_amount > 0 && p.coupon && (
                    <div className="flex items-center gap-2 text-xs">
                      <Tag className="h-3.5 w-3.5 text-blue-600" />
                      <span className="text-gray-500">Coupon <span className="font-mono font-bold text-blue-600">{p.coupon.code}</span> applied — discount: {formatAmount(p.discount_amount)}</span>
                    </div>
                  )}

                  <div className="flex items-center justify-between text-xs text-gray-400 pt-2 border-t border-gray-200">
                    <span>Created: {new Date(p.created_at).toLocaleString()}</span>
                    {p.expires_at && <span>Expires: {new Date(p.expires_at).toLocaleString()}</span>}
                  </div>
                </div>
              ))}
            </div>
          )}
          {filteredPayments.length > 0 && (
            <Pagination currentPage={safePage} totalPages={totalPages} onPageChange={setCurrentPage} />
          )}
        </>
      )}

      {activeTab === 'webhooks' && (
        <>
          <p className="text-xs text-gray-400">Razorpay webhook events received and processed by the backend. Each event is logged before processing for audit trail integrity.</p>

          {isLoading ? (
            <div className="flex h-48 items-center justify-center">
              <span className="text-sm text-gray-400">Loading webhook logs...</span>
            </div>
          ) : webhookLogs.length === 0 ? (
            <div className="flex flex-col items-center justify-center text-center p-12 rounded-2xl border border-dashed border-gray-200 bg-gray-50 shadow-sm">
              <Shield className="h-10 w-10 text-gray-400 mb-3" />
              <h3 className="text-lg font-bold text-gray-900">No webhook events</h3>
              <p className="text-gray-400 text-sm mt-1">Razorpay webhook events will appear here when payments are processed.</p>
            </div>
          ) : (
            <div className="space-y-3">
              {webhookLogs.map((log) => (
                <div key={log.id} className="rounded-xl border border-gray-200 bg-gray-50 shadow-sm p-4 space-y-3">
                  <div className="flex items-start justify-between flex-wrap gap-2">
                    <div className="flex items-center gap-2">
                      {log.signature_verified ? (
                        <Shield className="h-4 w-4 text-emerald-400" />
                      ) : (
                        <AlertTriangle className="h-4 w-4 text-rose-400" />
                      )}
                      <span className="text-sm font-mono font-semibold text-gray-900">{log.event_type}</span>
                    </div>
                    <div className="flex items-center gap-2">
                      <span className={`inline-flex items-center gap-1 rounded-full px-2.5 py-0.5 text-xs font-medium border ${
                        log.signature_verified
                          ? 'text-emerald-400 bg-emerald-500/10 border-emerald-500/20'
                          : 'text-rose-400 bg-rose-500/10 border-rose-500/20'
                      }`}>
                        {log.signature_verified ? 'Verified' : 'Invalid Sig'}
                      </span>
                      {log.processed_at && (
                        <span className="inline-flex items-center gap-1 rounded-full px-2.5 py-0.5 text-xs font-medium text-blue-600 bg-blue-600/10 border border-blue-500/25">
                          <CheckCircle className="h-3 w-3" /> Processed
                        </span>
                      )}
                    </div>
                  </div>

                  <div className="grid grid-cols-2 md:grid-cols-3 gap-3 text-xs">
                    {log.razorpay_event_id && (
                      <div><span className="text-gray-400">Event ID:</span> <span className="text-gray-700 font-mono">{log.razorpay_event_id}</span></div>
                    )}
                    {log.razorpay_order_id && (
                      <div><span className="text-gray-400">Order ID:</span> <span className="text-gray-700 font-mono">{log.razorpay_order_id}</span></div>
                    )}
                    {log.razorpay_payment_id && (
                      <div><span className="text-gray-400">Payment ID:</span> <span className="text-gray-700 font-mono">{log.razorpay_payment_id}</span></div>
                    )}
                  </div>

                  <div className="flex items-center justify-between text-xs text-gray-400">
                    <span>Received: {new Date(log.created_at).toLocaleString()}</span>
                    {log.processed_at && <span>Processed: {new Date(log.processed_at).toLocaleString()}</span>}
                  </div>
                </div>
              ))}
            </div>
          )}
        </>
      )}
    </div>
  );
}
