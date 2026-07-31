'use client';

import { useEffect, useState } from 'react';
import { useParams } from 'next/navigation';
import { Plus, Trash2, Edit2, Check, X, Loader2 } from 'lucide-react';
import { supabase } from '@/app/lib/supabaseClient';
import { csrfHeaders } from '@/lib/csrf';

interface RenewalPlan {
  id: string;
  course_id: string;
  label: string;
  duration_value: number;
  duration_unit: 'days' | 'months' | 'years';
  price: number;
  sort_order: number;
  is_active: boolean;
}

export default function RenewalPlansPage() {
  const params = useParams();
  const courseId = params?.id as string;

  const [plans, setPlans] = useState<RenewalPlan[]>([]);
  const [loading, setLoading] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Form State
  const [isEditing, setIsEditing] = useState<string | null>(null); // Plan ID or 'new'
  const [label, setLabel] = useState('');
  const [durationValue, setDurationValue] = useState<number>(3);
  const [durationUnit, setDurationUnit] = useState<'days' | 'months' | 'years'>('months');
  const [price, setPrice] = useState<number>(0);
  const [sortOrder, setSortOrder] = useState<number>(0);
  const [isActive, setIsActive] = useState<boolean>(true);

  const fetchPlans = async () => {
    try {
      setLoading(true);
      setError(null);
      const session = await supabase.auth.getSession();
      const token = session.data.session?.access_token;
      if (!token) throw new Error('No admin session');

      const res = await fetch(`/api/admin/renewal-plans?courseId=${courseId}`, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });

      if (!res.ok) {
        const errData = await res.json().catch(() => ({}));
        throw new Error(errData.error || 'Failed to fetch plans');
      }

      const data = await res.json();
      setPlans(data.plans || []);
    } catch (err: any) {
      setError(err.message || 'An error occurred');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (courseId) {
      fetchPlans();
    }
  }, [courseId]);

  const resetForm = () => {
    setIsEditing(null);
    setLabel('');
    setDurationValue(3);
    setDurationUnit('months');
    setPrice(0);
    setSortOrder(0);
    setIsActive(true);
  };

  const handleEditClick = (plan: RenewalPlan) => {
    setIsEditing(plan.id);
    setLabel(plan.label);
    setDurationValue(plan.duration_value);
    setDurationUnit(plan.duration_unit);
    setPrice(plan.price);
    setSortOrder(plan.sort_order);
    setIsActive(plan.is_active);
  };

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      setIsSubmitting(true);
      setError(null);
      const session = await supabase.auth.getSession();
      const token = session.data.session?.access_token;
      if (!token) throw new Error('No admin session');

      const isNew = isEditing === 'new';
      const url = isNew ? '/api/admin/renewal-plans' : `/api/admin/renewal-plans/${isEditing}`;
      const method = isNew ? 'POST' : 'PATCH';

      const res = await fetch(url, {
        method,
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${token}`,
          ...csrfHeaders(),
        },
        body: JSON.stringify({
          course_id: courseId,
          label: label || `${durationValue} ${durationUnit.charAt(0).toUpperCase() + durationUnit.slice(1)}`,
          duration_value: durationValue,
          duration_unit: durationUnit,
          price,
          sort_order: sortOrder,
          is_active: isActive,
        }),
      });

      if (!res.ok) {
        const errData = await res.json().catch(() => ({}));
        throw new Error(errData.error || 'Failed to save renewal plan');
      }

      await fetchPlans();
      resetForm();
    } catch (err: any) {
      setError(err.message || 'Failed to save');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleDelete = async (planId: string) => {
    if (!confirm('Are you sure you want to delete this renewal plan?')) return;
    try {
      setLoading(true);
      setError(null);
      const session = await supabase.auth.getSession();
      const token = session.data.session?.access_token;
      if (!token) throw new Error('No admin session');

      const res = await fetch(`/api/admin/renewal-plans/${planId}`, {
        method: 'DELETE',
        headers: {
          Authorization: `Bearer ${token}`,
          ...csrfHeaders(),
        },
      });

      if (!res.ok) {
        const errData = await res.json().catch(() => ({}));
        throw new Error(errData.error || 'Failed to delete plan');
      }

      await fetchPlans();
    } catch (err: any) {
      setError(err.message || 'Failed to delete');
    } finally {
      setLoading(false);
    }
  };

  const toggleActiveStatus = async (plan: RenewalPlan) => {
    try {
      const session = await supabase.auth.getSession();
      const token = session.data.session?.access_token;
      if (!token) throw new Error('No admin session');

      const res = await fetch(`/api/admin/renewal-plans/${plan.id}`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${token}`,
          ...csrfHeaders(),
        },
        body: JSON.stringify({
          is_active: !plan.is_active,
        }),
      });

      if (!res.ok) throw new Error('Failed to update status');
      await fetchPlans();
    } catch (err: any) {
      setError(err.message || 'Failed to toggle status');
    }
  };

  if (loading && plans.length === 0) {
    return (
      <div className="flex items-center justify-center p-12 bg-white border border-gray-200 rounded-xl shadow-sm">
        <Loader2 className="h-8 w-8 animate-spin text-blue-600" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center bg-white p-6 border border-gray-200 rounded-xl shadow-sm">
        <div>
          <h2 className="text-lg font-bold text-gray-900">Renewal Plans</h2>
          <p className="text-xs text-gray-500">Configure renewal durations and pricing for this course.</p>
        </div>
        {!isEditing && (
          <button
            onClick={() => {
              resetForm();
              setIsEditing('new');
            }}
            className="flex items-center gap-2 rounded-lg bg-blue-600 px-4 py-2.5 text-sm font-semibold text-white hover:bg-blue-700 transition-colors shadow-sm"
          >
            <Plus className="h-4 w-4" /> Add Renewal Plan
          </button>
        )}
      </div>

      {error && (
        <div className="rounded-lg bg-red-50 border border-red-200 p-4 text-sm text-red-700 flex justify-between items-center">
          <span>{error}</span>
          <button onClick={() => setError(null)} className="text-red-950 font-bold">Dismiss</button>
        </div>
      )}

      {/* Add / Edit Form Panel */}
      {isEditing && (
        <form onSubmit={handleSave} className="bg-white p-6 border border-gray-200 rounded-xl shadow-sm space-y-4 animate-in slide-in-from-top duration-200">
          <h3 className="text-sm font-bold text-gray-900">
            {isEditing === 'new' ? 'Create New Renewal Plan' : 'Edit Renewal Plan'}
          </h3>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div>
              <label className="block text-xs font-semibold text-gray-700 mb-1">Duration Value</label>
              <input
                type="number"
                min="1"
                required
                value={durationValue}
                onChange={(e) => setDurationValue(Number(e.target.value))}
                className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none"
              />
            </div>
            <div>
              <label className="block text-xs font-semibold text-gray-700 mb-1">Duration Unit</label>
              <select
                value={durationUnit}
                onChange={(e) => setDurationUnit(e.target.value as any)}
                className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none"
              >
                <option value="days">Days</option>
                <option value="months">Months</option>
                <option value="years">Years</option>
              </select>
            </div>
            <div>
              <label className="block text-xs font-semibold text-gray-700 mb-1">Price (INR)</label>
              <input
                type="number"
                min="0"
                required
                value={price}
                onChange={(e) => setPrice(Number(e.target.value))}
                className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none"
              />
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-semibold text-gray-700 mb-1">Display Label (e.g. "3 Months")</label>
              <input
                type="text"
                placeholder={`Auto: ${durationValue} ${durationUnit}`}
                value={label}
                onChange={(e) => setLabel(e.target.value)}
                className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none"
              />
            </div>
            <div>
              <label className="block text-xs font-semibold text-gray-700 mb-1">Sort Order</label>
              <input
                type="number"
                value={sortOrder}
                onChange={(e) => setSortOrder(Number(e.target.value))}
                className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none"
              />
            </div>
          </div>

          <div className="flex items-center gap-2">
            <input
              type="checkbox"
              id="isActive"
              checked={isActive}
              onChange={(e) => setIsActive(e.target.checked)}
              className="h-4 w-4 rounded border-gray-300 text-blue-600 focus:ring-blue-500"
            />
            <label htmlFor="isActive" className="text-xs font-semibold text-gray-700">Active (Visible to users)</label>
          </div>

          <div className="flex justify-end gap-2 pt-2">
            <button
              type="button"
              onClick={resetForm}
              className="rounded-lg border border-gray-300 px-4 py-2 text-sm font-semibold text-gray-700 hover:bg-gray-50 transition-colors"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={isSubmitting}
              className="flex items-center gap-2 rounded-lg bg-blue-600 px-4 py-2 text-sm font-semibold text-white hover:bg-blue-700 transition-colors shadow-sm disabled:opacity-50"
            >
              {isSubmitting ? <Loader2 className="h-4 w-4 animate-spin" /> : <Check className="h-4 w-4" />}
              Save Plan
            </button>
          </div>
        </form>
      )}

      {/* Plans List Table */}
      <div className="bg-white border border-gray-200 rounded-xl shadow-sm overflow-hidden">
        {plans.length === 0 ? (
          <div className="p-12 text-center">
            <p className="text-sm text-gray-500">No renewal plans configured for this course yet.</p>
          </div>
        ) : (
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Label</th>
                <th className="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Duration</th>
                <th className="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Price</th>
                <th className="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Sort Order</th>
                <th className="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Status</th>
                <th className="px-6 py-3 text-right text-xs font-bold text-gray-500 uppercase tracking-wider">Actions</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200 text-sm">
              {plans.map((plan) => (
                <tr key={plan.id} className="hover:bg-gray-50 transition-colors">
                  <td className="px-6 py-4 whitespace-nowrap font-semibold text-gray-900">{plan.label}</td>
                  <td className="px-6 py-4 whitespace-nowrap text-gray-500">
                    {plan.duration_value} {plan.duration_unit}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap font-bold text-blue-600">₹{plan.price}</td>
                  <td className="px-6 py-4 whitespace-nowrap text-gray-500">{plan.sort_order}</td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <button
                      onClick={() => toggleActiveStatus(plan)}
                      className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold transition-colors ${
                        plan.is_active
                          ? 'bg-green-50 text-green-700 hover:bg-green-100'
                          : 'bg-gray-100 text-gray-800 hover:bg-gray-200'
                      }`}
                    >
                      {plan.is_active ? 'Active' : 'Inactive'}
                    </button>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-right text-xs font-medium space-x-2">
                    <button
                      onClick={() => handleEditClick(plan)}
                      className="inline-flex items-center gap-1 text-blue-600 hover:text-blue-900"
                    >
                      <Edit2 className="h-3.5 w-3.5" /> Edit
                    </button>
                    <button
                      onClick={() => handleDelete(plan.id)}
                      className="inline-flex items-center gap-1 text-red-600 hover:text-red-900"
                    >
                      <Trash2 className="h-3.5 w-3.5" /> Delete
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}
