'use strict';
'use client';

import { useEffect, useState, useCallback, startTransition } from 'react';
import { useAuth } from '@/app/lib/AuthContext';
import toast from 'react-hot-toast';
import {
  Search, Plus, Tag, Percent, X, Loader2,
  CheckCircle, XCircle, Clock, Calendar, MoreHorizontal, Trash2,
} from 'lucide-react';
import Select from '@/components/Select';
import Pagination from '@/components/Pagination';
import ConfirmDialog from '@/components/ConfirmDialog';
import { PAGE_SIZE } from '@/app/lib/constants';
import { csrfHeaders } from '@/lib/csrf';

interface Coupon {
  id: string;
  code: string;
  discount_type: 'percentage' | 'fixed';
  discount_value: number;
  max_uses: number | null;
  uses_count: number;
  min_purchase_amount: number;
  starts_at: string | null;
  expires_at: string | null;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

const emptyForm = {
  code: '',
  discount_type: 'percentage' as 'percentage' | 'fixed',
  discount_value: '',
  max_uses: '',
  min_purchase_amount: '0',
  starts_at: '',
  expires_at: '',
  is_active: true,
};

export default function CouponsPage() {
  const { role, profile, accessToken } = useAuth();
  const [coupons, setCoupons] = useState<Coupon[]>([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [isLoading, setIsLoading] = useState(true);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [form, setForm] = useState(emptyForm);
  const [formErrors, setFormErrors] = useState<Record<string, string>>({});
  const [currentPage, setCurrentPage] = useState(1);
  const [dropdownOpen, setDropdownOpen] = useState<{ coupon: Coupon; x: number; y: number } | null>(null);
  const [couponToDelete, setCouponToDelete] = useState<Coupon | null>(null);

  const hasAccess = role === 'superadmin' || role === 'admin' || (profile?.allowed_sections || []).includes('Manage Coupons');
  const canWrite = role === 'superadmin' || role === 'admin' || (profile?.allowed_actions || []).includes('Manage Coupons: Write');

  const fetchCoupons = useCallback(async () => {
    try {
      setIsLoading(true);
      if (!accessToken) { toast.error('Session expired.'); return; }

      const res = await fetch('/api/admin/coupons', {
        headers: { Authorization: `Bearer ${accessToken}` },
      });
      if (!res.ok) { const err = await res.json(); throw new Error(err.error || 'Failed to load coupons.'); }
      const data = await res.json();
      setCoupons(data.coupons || []);
    } catch (err: unknown) {
      toast.error(err instanceof Error ? err.message : 'Failed to load coupons.');
    } finally {
      setIsLoading(false);
    }
  }, [accessToken]);

  useEffect(() => {
    if (accessToken && hasAccess) {
      startTransition(() => { fetchCoupons(); });
    } else if (accessToken && !hasAccess) {
      startTransition(() => { setIsLoading(false); });
    }
  }, [fetchCoupons, hasAccess, accessToken]);

  useEffect(() => { startTransition(() => { setCurrentPage(1); }); }, [searchTerm]);

  useEffect(() => {
    if (!dropdownOpen) return;
    const handleClick = () => setDropdownOpen(null);
    document.addEventListener('click', handleClick);
    return () => document.removeEventListener('click', handleClick);
  }, [dropdownOpen]);

  if (isLoading) {
    return (
      <div className="flex h-64 items-center justify-center">
        <div className="flex items-center gap-3">
          <Loader2 className="h-5 w-5 animate-spin text-blue-500" />
          <span className="text-sm font-medium text-gray-500">Loading coupons...</span>
        </div>
      </div>
    );
  }

  if (!hasAccess) {
    return (
      <div className="flex flex-col items-center justify-center text-center p-12 rounded-2xl border border-dashed border-gray-200 bg-gray-50">
        <h3 className="text-lg font-bold text-gray-900">Access Denied</h3>
        <p className="text-gray-400 text-sm mt-1">You do not have permission to access the Manage Coupons section.</p>
      </div>
    );
  }

  const openCreate = () => {
    setEditingId(null);
    setForm(emptyForm);
    setFormErrors({});
    setIsModalOpen(true);
  };

  const openEdit = (coupon: Coupon) => {
    setEditingId(coupon.id);
    setForm({
      code: coupon.code,
      discount_type: coupon.discount_type,
      discount_value: String(coupon.discount_value),
      max_uses: coupon.max_uses !== null ? String(coupon.max_uses) : '',
      min_purchase_amount: String(coupon.min_purchase_amount),
      starts_at: coupon.starts_at ? coupon.starts_at.slice(0, 16) : '',
      expires_at: coupon.expires_at ? coupon.expires_at.slice(0, 16) : '',
      is_active: coupon.is_active,
    });
    setFormErrors({});
    setIsModalOpen(true);
  };

  const validate = () => {
    const errors: Record<string, string> = {};
    if (!form.code.trim()) errors.code = 'Code is required';
    if (!form.discount_value || Number(form.discount_value) <= 0) errors.discount_value = 'Must be greater than 0';
    if (form.max_uses && Number(form.max_uses) < 0) errors.max_uses = 'Must be 0 or empty';
    if (form.starts_at && form.expires_at && new Date(form.expires_at) <= new Date(form.starts_at)) {
      errors.expires_at = 'Expiry date must be after start date';
    }
    setFormErrors(errors);
    return Object.keys(errors).length === 0;
  };

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!validate()) return;

    setIsSaving(true);
    const loadingToast = toast.loading(editingId ? 'Updating coupon...' : 'Creating coupon...');

    try {
      const payload = {
        ...(editingId ? { id: editingId } : {}),
        code: form.code,
        discount_type: form.discount_type,
        discount_value: Number(form.discount_value),
        max_uses: form.max_uses ? Number(form.max_uses) : null,
        min_purchase_amount: Number(form.min_purchase_amount) || 0,
        starts_at: form.starts_at ? new Date(form.starts_at).toISOString() : null,
        expires_at: form.expires_at ? new Date(form.expires_at).toISOString() : null,
        is_active: form.is_active,
      };

      const res = await fetch('/api/admin/coupons', {
        method: editingId ? 'PATCH' : 'POST',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${accessToken}`, ...csrfHeaders() },
        body: JSON.stringify(payload),
      });

      const data = await res.json();
      if (!res.ok) throw new Error(data.error || 'Failed to save coupon.');

      toast.dismiss(loadingToast);
      toast.success(editingId ? 'Coupon updated!' : 'Coupon created!');
      setIsModalOpen(false);
      fetchCoupons();
    } catch (err: unknown) {
      toast.dismiss(loadingToast);
      toast.error(err instanceof Error ? err.message : 'Failed to save coupon.');
    } finally {
      setIsSaving(false);
    }
  };

  const toggleActive = async (coupon: Coupon) => {
    const loadingToast = toast.loading('Toggling coupon status...');
    try {
      const res = await fetch('/api/admin/coupons', {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${accessToken}`, ...csrfHeaders() },
        body: JSON.stringify({ id: coupon.id, is_active: !coupon.is_active }),
      });

      const data = await res.json();
      if (!res.ok) throw new Error(data.error || 'Failed to update coupon.');

      toast.dismiss(loadingToast);
      toast.success(`Coupon ${coupon.is_active ? 'deactivated' : 'activated'}`);
      setCoupons(coupons.map(c => c.id === coupon.id ? { ...c, is_active: !c.is_active } : c));
    } catch (err: unknown) {
      toast.dismiss(loadingToast);
      toast.error(err instanceof Error ? err.message : 'Failed to update.');
    }
  };

  const handleDeleteCoupon = async () => {
    if (!couponToDelete) return;

    const loadingToast = toast.loading('Deleting coupon...');
    try {
      const res = await fetch('/api/admin/coupons', {
        method: 'DELETE',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${accessToken}`, ...csrfHeaders() },
        body: JSON.stringify({ id: couponToDelete.id }),
      });

      const data = await res.json();
      if (!res.ok) throw new Error(data.error || 'Failed to delete coupon.');

      toast.dismiss(loadingToast);
      toast.success('Coupon deleted.');
      setCouponToDelete(null);
      fetchCoupons();
    } catch (err: unknown) {
      toast.dismiss(loadingToast);
      toast.error(err instanceof Error ? err.message : 'Failed to delete coupon.');
    }
  };

  const isExpired = (coupon: Coupon) => {
    if (!coupon.expires_at) return false;
    return new Date(coupon.expires_at) <= new Date();
  };

  const isUpcoming = (coupon: Coupon) => {
    if (!coupon.starts_at) return false;
    return new Date(coupon.starts_at) > new Date();
  };

  const getStatusBadge = (coupon: Coupon) => {
    if (!coupon.is_active) {
      return <span className="inline-flex items-center gap-1 rounded-full bg-zinc-500/10 px-3 py-1 text-xs font-medium text-zinc-400 border border-zinc-500/20"><XCircle className="h-3 w-3" /> Inactive</span>;
    }
    if (isExpired(coupon)) {
      return <span className="inline-flex items-center gap-1 rounded-full bg-rose-500/10 px-3 py-1 text-xs font-medium text-rose-400 border border-rose-500/20"><Clock className="h-3 w-3" /> Expired</span>;
    }
    if (isUpcoming(coupon)) {
      return <span className="inline-flex items-center gap-1 rounded-full bg-amber-500/10 px-3 py-1 text-xs font-medium text-amber-400 border border-amber-500/20"><Calendar className="h-3 w-3" /> Scheduled</span>;
    }
    if (coupon.max_uses !== null && coupon.uses_count >= coupon.max_uses) {
      return <span className="inline-flex items-center gap-1 rounded-full bg-rose-500/10 px-3 py-1 text-xs font-medium text-rose-400 border border-rose-500/20"><XCircle className="h-3 w-3" /> Exhausted</span>;
    }
    return <span className="inline-flex items-center gap-1 rounded-full bg-emerald-500/10 px-3 py-1 text-xs font-medium text-emerald-400 border border-emerald-500/20"><CheckCircle className="h-3 w-3" /> Active</span>;
  };

  const filteredCoupons = coupons.filter(c =>
    c.code.toLowerCase().includes(searchTerm.toLowerCase())
  );
  const totalPages = Math.max(1, Math.ceil(filteredCoupons.length / PAGE_SIZE));
  const safePage = Math.min(currentPage, totalPages);
  const paginatedCoupons = filteredCoupons.slice((safePage - 1) * PAGE_SIZE, safePage * PAGE_SIZE);

  return (
    <div className="space-y-8 animate-in fade-in duration-300">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-3xl font-extrabold text-gray-900 tracking-tight">Manage Coupons</h1>
          <p className="text-gray-500 text-sm mt-1">Create and manage promotional coupon codes for courses.</p>
        </div>
        {canWrite && (
          <button
            onClick={openCreate}
            className="inline-flex items-center gap-2 rounded-xl bg-gradient-to-r from-blue-600 to-blue-500 px-5 py-3 text-sm font-semibold text-white transition hover:from-blue-500 hover:to-blue-400 cursor-pointer shadow-lg shadow-blue-500/10 active:scale-[0.98]"
          >
            <Plus className="h-4 w-4" />
            Create Coupon
          </button>
        )}
      </div>

      <div className="relative w-full md:max-w-xs shadow-sm">
        <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" />
        <input
          type="text"
          placeholder="Search coupons by code..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          className="w-full rounded-xl border border-gray-200 bg-gray-50 py-2.5 pl-9 pr-4 text-xs text-gray-900 placeholder-gray-400 outline-none transition focus:border-blue-500 focus:bg-white"
        />
      </div>

      {isLoading ? (
        <div className="flex h-48 items-center justify-center">
          <span className="text-sm text-gray-400">Loading coupons...</span>
        </div>
      ) : filteredCoupons.length === 0 ? (
        <div className="flex flex-col items-center justify-center text-center p-12 rounded-2xl border border-dashed border-gray-200 bg-gray-50">
          <Tag className="h-10 w-10 text-gray-400 mb-3" />
          <h3 className="text-lg font-bold text-gray-900">No coupons found</h3>
          <p className="text-gray-400 text-sm mt-1">{searchTerm ? 'No matching coupon codes.' : 'Create your first coupon to start offering discounts.'}</p>
        </div>
      ) : (
        <div className="overflow-x-auto rounded-2xl border border-gray-200 bg-white shadow-sm">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="border-b border-gray-200 bg-gray-50 text-xs font-semibold uppercase tracking-wider text-gray-500">
                <th className="p-4 sm:p-5">Code</th>
                <th className="p-4 sm:p-5">Discount</th>
                <th className="p-4 sm:p-5">Usage</th>
                <th className="p-4 sm:p-5">Min Purchase</th>
                <th className="p-4 sm:p-5">Valid Period</th>
                <th className="p-4 sm:p-5">Status</th>
                <th className="p-4 sm:p-5 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {paginatedCoupons.map((coupon) => (
                <tr key={coupon.id} className="text-sm text-gray-700 hover:bg-gray-50 transition duration-150">
                  <td className="p-4 sm:p-5">
                    <span className="font-mono font-bold text-gray-900 tracking-wide">{coupon.code}</span>
                  </td>
                  <td className="p-4 sm:p-5">
                    <span className="inline-flex items-center gap-1">
                      {coupon.discount_type === 'percentage' ? (
                        <Percent className="h-3.5 w-3.5 text-blue-600" />
                      ) : (
                        <Tag className="h-3.5 w-3.5 text-blue-600" />
                      )}
                      {coupon.discount_type === 'percentage'
                        ? `${coupon.discount_value}%`
                        : `₹${coupon.discount_value}`}
                    </span>
                  </td>
                  <td className="p-4 sm:p-5">
                    <div className="flex items-center gap-2">
                      <div className="flex-1 h-2 rounded-full bg-gray-100 overflow-hidden max-w-[100px]">
                        <div
                          className="h-full rounded-full bg-blue-600 transition-all"
                          style={{
                            width: coupon.max_uses
                              ? `${Math.min(100, (coupon.uses_count / coupon.max_uses) * 100)}%`
                              : `${Math.min(100, coupon.uses_count * 5)}%`,
                          }}
                        />
                      </div>
                      <span className="text-xs text-gray-500">
                        {coupon.uses_count}{coupon.max_uses !== null ? ` / ${coupon.max_uses}` : ''}
                      </span>
                    </div>
                  </td>
                  <td className="p-4 sm:p-5">
                    {coupon.min_purchase_amount > 0 ? `${coupon.min_purchase_amount}` : 'None'}
                  </td>
                  <td className="p-4 sm:p-5">
                    <div className="text-xs text-gray-500">
                      {coupon.starts_at ? new Date(coupon.starts_at).toLocaleDateString() : 'Any'} —
                      {coupon.expires_at ? new Date(coupon.expires_at).toLocaleDateString() : 'Forever'}
                    </div>
                  </td>
                  <td className="p-4 sm:p-5">{getStatusBadge(coupon)}</td>
                  <td className="p-4 sm:p-5 text-right">
                    {canWrite ? (
                      <button
                        onClick={(e) => {
                          e.stopPropagation();
                          if (dropdownOpen?.coupon.id === coupon.id) {
                            setDropdownOpen(null);
                          } else {
                            const rect = (e.currentTarget as HTMLElement).getBoundingClientRect();
                            setDropdownOpen({ coupon, x: rect.right, y: rect.bottom + 4 });
                          }
                        }}
                        className="inline-flex items-center justify-center rounded-lg border border-gray-200 hover:border-gray-300 hover:bg-gray-100 w-8 h-8 text-gray-500 transition cursor-pointer"
                      >
                        <MoreHorizontal className="h-4 w-4" />
                      </button>
                    ) : (
                      <span className="text-xs text-gray-400 italic font-medium bg-gray-50 border border-gray-100 px-2 py-1.5 rounded-lg">Read Only</span>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          <Pagination currentPage={safePage} totalPages={totalPages} onPageChange={setCurrentPage} />
        </div>
      )}

      {dropdownOpen && (
        <div
          className="fixed z-50 w-44 rounded-xl border border-gray-200 bg-white shadow-xl py-1.5 animate-in fade-in zoom-in-95 duration-150 origin-top-right"
          style={{ left: dropdownOpen.x - 176, top: dropdownOpen.y }}
        >
          <button
            onClick={() => { openEdit(dropdownOpen.coupon); setDropdownOpen(null); }}
            className="flex w-full items-center gap-2 px-4 py-2 text-xs font-semibold text-gray-700 hover:bg-gray-50 transition cursor-pointer"
          >
            <Tag className="h-3.5 w-3.5 text-blue-500" />
            Edit
          </button>
          <button
            onClick={() => { toggleActive(dropdownOpen.coupon); setDropdownOpen(null); }}
            className="flex w-full items-center gap-2 px-4 py-2 text-xs font-semibold text-gray-700 hover:bg-gray-50 transition cursor-pointer"
          >
            {dropdownOpen.coupon.is_active ? (
              <><XCircle className="h-3.5 w-3.5 text-amber-500" /> Deactivate</>
            ) : (
              <><CheckCircle className="h-3.5 w-3.5 text-emerald-500" /> Activate</>
            )}
          </button>
          <div className="my-1 border-t border-gray-100" />
          <button
            onClick={() => { setCouponToDelete(dropdownOpen.coupon); setDropdownOpen(null); }}
            className="flex w-full items-center gap-2 px-4 py-2 text-xs font-semibold text-rose-500 hover:bg-rose-50 transition cursor-pointer"
          >
            <Trash2 className="h-3.5 w-3.5" />
            Delete
          </button>
        </div>
      )}

      <ConfirmDialog
        isOpen={!!couponToDelete}
        title="Delete Coupon"
        message={`Are you sure you want to delete coupon "${couponToDelete?.code}"? This action is permanent and cannot be undone.`}
        confirmLabel="Delete"
        variant="danger"
        onConfirm={handleDeleteCoupon}
        onCancel={() => setCouponToDelete(null)}
      />

      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4 animate-in fade-in duration-200">
          <div className="w-full max-w-lg overflow-hidden rounded-2xl border border-gray-200 bg-white p-6 shadow-2xl space-y-6">
            <div className="flex items-center justify-between">
              <h2 className="text-xl font-bold text-gray-900 flex items-center gap-2">
                <Tag className="h-5 w-5 text-blue-600" />
                {editingId ? 'Edit Coupon' : 'Create Coupon'}
              </h2>
              <button
                onClick={() => setIsModalOpen(false)}
                className="rounded-lg p-1 text-gray-500 hover:bg-gray-100 hover:text-gray-900 transition"
              >
                <X className="h-5 w-5" />
              </button>
            </div>

            <form onSubmit={handleSave} className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-1.5">
                  <label className="text-xs font-semibold uppercase tracking-wider text-gray-500 block">Code <span className="text-rose-400">*</span></label>
                  <input
                    type="text"
                    placeholder="SAVE20"
                    value={form.code}
                    onChange={(e) => { setForm({ ...form, code: e.target.value }); setFormErrors({ ...formErrors, code: '' }); }}
                    className={`w-full rounded-lg border ${formErrors.code ? 'border-rose-500' : 'border-gray-200'} bg-white py-3 px-4 text-sm text-gray-900 placeholder-gray-400 outline-none focus:border-blue-500 transition uppercase`}
                  />
                  {formErrors.code && <p className="text-xs text-rose-400">{formErrors.code}</p>}
                </div>

                <div className="space-y-1.5">
                  <label className="text-xs font-semibold uppercase tracking-wider text-gray-500 block">Discount Type <span className="text-rose-400">*</span></label>
                  <Select
                    value={form.discount_type}
                    onChange={(v) => setForm({ ...form, discount_type: v as 'percentage' | 'fixed' })}
                    options={[
                      { value: 'percentage', label: 'Percentage (%)' },
                      { value: 'fixed', label: 'Fixed' },
                    ]}
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-1.5">
                  <label className="text-xs font-semibold uppercase tracking-wider text-gray-500 block">Discount Value <span className="text-rose-400">*</span></label>
                  <input
                    type="number"
                    step="0.01"
                    min="0.01"
                    placeholder="20"
                    value={form.discount_value}
                    onChange={(e) => { setForm({ ...form, discount_value: e.target.value }); setFormErrors({ ...formErrors, discount_value: '' }); }}
                    className={`w-full rounded-lg border ${formErrors.discount_value ? 'border-rose-500' : 'border-gray-200'} bg-white py-3 px-4 text-sm text-gray-900 placeholder-gray-400 outline-none focus:border-blue-500 transition`}
                  />
                  {formErrors.discount_value && <p className="text-xs text-rose-400">{formErrors.discount_value}</p>}
                </div>

                <div className="space-y-1.5">
                  <label className="text-xs font-semibold uppercase tracking-wider text-gray-500 block">Max Uses</label>
                  <input
                    type="number"
                    min="0"
                    placeholder="Unlimited"
                    value={form.max_uses}
                    onChange={(e) => setForm({ ...form, max_uses: e.target.value })}
                    className="w-full rounded-lg border border-gray-200 bg-white py-3 px-4 text-sm text-gray-900 placeholder-gray-400 outline-none focus:border-blue-500 transition"
                  />
                </div>
              </div>

              <div className="space-y-1.5">
                <label className="text-xs font-semibold uppercase tracking-wider text-gray-500 block">Min Purchase Amount</label>
                <input
                  type="number"
                  step="0.01"
                  min="0"
                  placeholder="0"
                  value={form.min_purchase_amount}
                  onChange={(e) => setForm({ ...form, min_purchase_amount: e.target.value })}
                  className="w-full rounded-lg border border-gray-200 bg-white py-3 px-4 text-sm text-gray-900 placeholder-gray-400 outline-none focus:border-blue-500 transition"
                />
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-1.5">
                  <label className="text-xs font-semibold uppercase tracking-wider text-gray-500 block">Start Date</label>
                  <input
                    type="datetime-local"
                    value={form.starts_at}
                    onChange={(e) => setForm({ ...form, starts_at: e.target.value })}
                    className="w-full rounded-lg border border-gray-200 bg-white py-3 px-4 text-sm text-gray-900 outline-none focus:border-blue-500 transition [color-scheme:light]"
                  />
                </div>

                <div className="space-y-1.5">
                  <label className="text-xs font-semibold uppercase tracking-wider text-gray-500 block">Expiry Date</label>
                  <input
                    type="datetime-local"
                    value={form.expires_at}
                    onChange={(e) => { setForm({ ...form, expires_at: e.target.value }); setFormErrors({ ...formErrors, expires_at: '' }); }}
                    className={`w-full rounded-lg border ${formErrors.expires_at ? 'border-rose-500' : 'border-gray-200'} bg-white py-3 px-4 text-sm text-gray-900 outline-none focus:border-blue-500 transition [color-scheme:light]`}
                  />
                  {formErrors.expires_at && <p className="text-xs text-rose-400">{formErrors.expires_at}</p>}
                </div>
              </div>

              <div className="pt-4 border-t border-gray-200 flex justify-end gap-3">
                <button
                  type="button"
                  onClick={() => setIsModalOpen(false)}
                  className="rounded-lg border border-gray-200 px-4 py-2.5 text-xs font-semibold text-gray-500 hover:text-gray-700 transition"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={isSaving}
                  className="flex items-center gap-1.5 rounded-lg bg-gradient-to-r from-blue-600 to-blue-500 px-4 py-2.5 text-xs font-semibold text-white transition hover:from-blue-500 hover:to-blue-400 cursor-pointer shadow-lg shadow-blue-500/10 active:scale-[0.98] disabled:opacity-50"
                >
                  {isSaving ? (
                    <><Loader2 className="h-3 w-3 animate-spin" /> {editingId ? 'Updating...' : 'Creating...'}</>
                  ) : (
                    editingId ? 'Update Coupon' : 'Create Coupon'
                  )}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
