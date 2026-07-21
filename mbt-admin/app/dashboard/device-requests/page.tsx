'use strict';
'use client';

import { useEffect, useState } from 'react';
import { supabase } from '@/app/lib/supabaseClient';
import { useAuth } from '@/app/lib/AuthContext';
import toast from 'react-hot-toast';
import { Loader2, CheckCircle, XCircle, Clock, Smartphone, User } from 'lucide-react';
import Pagination from '@/components/Pagination';
import { PAGE_SIZE } from '@/app/lib/constants';

interface DeviceRequest {
  id: string;
  user_id: string;
  old_fingerprint: string | null;
  new_fingerprint: string;
  reason: string | null;
  status: string;
  reviewed_by: string | null;
  reviewed_at: string | null;
  created_at: string;
  user: {
    id: string;
    full_name: string | null;
    email: string | null;
  } | null;
  reviewer: {
    id: string;
    full_name: string | null;
  } | null;
}

export default function DeviceRequestsPage() {
  const { accessToken, role, profile } = useAuth();
  const [requests, setRequests] = useState<DeviceRequest[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [actionLoading, setActionLoading] = useState<string | null>(null);
  const [filter, setFilter] = useState<string>('all');
  const [currentPage, setCurrentPage] = useState(1);

  const hasAccess = role === 'superadmin' || role === 'admin' || (profile?.allowed_sections || []).includes('Device Requests');
  const canReview = role === 'superadmin' || role === 'admin' || (profile?.allowed_actions || []).includes('Accept / Reject Device Requests');

  const fetchRequests = async () => {
    try {
      setIsLoading(true);
      if (!accessToken) {
        toast.error('Session expired. Please log in again.');
        return;
      }

      const res = await fetch('/api/admin/device-requests', {
        headers: { Authorization: `Bearer ${accessToken}` },
      });

      if (!res.ok) {
        const err = await res.json();
        toast.error(err.error || 'Failed to fetch requests');
        return;
      }

      const data = await res.json();
      setRequests(data.requests || []);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to fetch');
    } finally {
      setIsLoading(false);
    }
  };

  const handleReview = async (requestId: string, status: 'approved' | 'rejected') => {
    try {
      setActionLoading(requestId);
      if (!accessToken) {
        toast.error('Session expired.');
        return;
      }

      const res = await fetch('/api/admin/device-requests', {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${accessToken}`,
        },
        body: JSON.stringify({ requestId, status }),
      });

      if (!res.ok) {
        const err = await res.json();
        toast.error(err.error || 'Failed to update request');
        return;
      }

      toast.success(status === 'approved' ? 'Device change approved' : 'Device change rejected');
      fetchRequests();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to update');
    } finally {
      setActionLoading(null);
    }
  };

  useEffect(() => {
    fetchRequests();
  }, []);

  useEffect(() => { setCurrentPage(1); }, [filter]);

  const filteredRequests = filter === 'all'
    ? requests
    : requests.filter(r => r.status === filter);

  const totalPages = Math.max(1, Math.ceil(filteredRequests.length / PAGE_SIZE));
  const safePage = Math.min(currentPage, totalPages);
  const paginatedRequests = filteredRequests.slice((safePage - 1) * PAGE_SIZE, safePage * PAGE_SIZE);

  const getStatusBadge = (status: string) => {
    switch (status) {
      case 'pending':
        return (
          <span className="inline-flex items-center gap-1 rounded-full bg-amber-500/10 px-3 py-1 text-xs font-medium text-amber-400 border border-amber-500/20">
            <Clock className="h-3 w-3" /> Pending
          </span>
        );
      case 'approved':
        return (
          <span className="inline-flex items-center gap-1 rounded-full bg-emerald-500/10 px-3 py-1 text-xs font-medium text-emerald-400 border border-emerald-500/20">
            <CheckCircle className="h-3 w-3" /> Approved
          </span>
        );
      case 'rejected':
        return (
          <span className="inline-flex items-center gap-1 rounded-full bg-rose-500/10 px-3 py-1 text-xs font-medium text-rose-400 border border-rose-500/20">
            <XCircle className="h-3 w-3" /> Rejected
          </span>
        );
      default:
        return null;
    }
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <Loader2 className="h-8 w-8 animate-spin text-blue-500" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Device Change Requests</h1>
        <p className="text-sm text-gray-500 mt-1">
          Review and manage user device change requests
        </p>
      </div>

      {/* Filter Tabs */}
      <div className="flex gap-2">
        {['all', 'pending', 'approved', 'rejected'].map((f) => (
          <button
            key={f}
            onClick={() => setFilter(f)}
            className={`px-4 py-2 rounded-lg text-sm font-medium transition-all duration-200 cursor-pointer ${
              filter === f
                ? 'bg-blue-600/10 text-blue-400 border border-blue-500/25'
                : 'text-gray-500 hover:text-gray-700 border border-transparent hover:border-gray-200'
            }`}
          >
            {f.charAt(0).toUpperCase() + f.slice(1)}
          </button>
        ))}
      </div>

      {/* Requests List */}
      {filteredRequests.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-16 text-gray-400">
          <Smartphone className="h-12 w-12 mb-4 opacity-50" />
          <p className="text-sm font-medium">No device change requests found</p>
          <p className="text-xs mt-1">Requests will appear here when users submit them</p>
        </div>
      ) : (
        <div className="space-y-4">
          {paginatedRequests.map((req) => (
            <div
              key={req.id}
              className="rounded-xl border border-gray-200 bg-white p-5 space-y-4 shadow-sm"
            >
              <div className="flex items-start justify-between">
                <div className="flex items-center gap-3">
                  <div className="flex h-10 w-10 items-center justify-center rounded-full bg-gray-100 text-gray-700 font-bold border border-gray-300">
                    <User className="h-5 w-5" />
                  </div>
                  <div>
                    <p className="text-sm font-semibold text-gray-900">
                      {req.user?.full_name || 'Unknown User'}
                    </p>
                    <p className="text-xs text-gray-400">{req.user?.email || 'No email'}</p>
                  </div>
                </div>
                {getStatusBadge(req.status)}
              </div>

              <div className="grid grid-cols-2 gap-4 text-sm">
                <div>
                  <p className="text-xs text-gray-400 mb-1">New Device Fingerprint</p>
                  <p className="text-gray-700 font-mono text-xs truncate">{req.new_fingerprint}</p>
                </div>
                {req.old_fingerprint && (
                  <div>
                    <p className="text-xs text-gray-400 mb-1">Old Device Fingerprint</p>
                    <p className="text-gray-700 font-mono text-xs truncate">{req.old_fingerprint}</p>
                  </div>
                )}
              </div>

              {req.reason && (
                <div>
                  <p className="text-xs text-gray-400 mb-1">Reason</p>
                  <p className="text-sm text-gray-700 bg-gray-50 rounded-lg p-3">{req.reason}</p>
                </div>
              )}

              <div className="flex items-center justify-between text-xs text-gray-400">
                <span>Submitted: {new Date(req.created_at).toLocaleString()}</span>
                {req.reviewer && (
                  <span>Reviewed by: {req.reviewer.full_name || 'Admin'}</span>
                )}
              </div>

              {req.status === 'pending' && (
                <div className="flex gap-3 pt-2 border-t border-gray-200">
                  <button
                    onClick={() => handleReview(req.id, 'approved')}
                    disabled={actionLoading === req.id || !canReview}
                    title={!canReview ? "You do not have permission to approve device change requests" : undefined}
                    className="flex items-center gap-2 px-4 py-2 rounded-lg bg-emerald-500/10 text-emerald-400 hover:bg-emerald-500/20 border border-emerald-500/20 text-sm font-medium transition-all duration-200 disabled:opacity-50 cursor-pointer"
                  >
                    {actionLoading === req.id ? (
                      <Loader2 className="h-4 w-4 animate-spin" />
                    ) : (
                      <CheckCircle className="h-4 w-4" />
                    )}
                    Approve
                  </button>
                  <button
                    onClick={() => handleReview(req.id, 'rejected')}
                    disabled={actionLoading === req.id || !canReview}
                    title={!canReview ? "You do not have permission to reject device change requests" : undefined}
                    className="flex items-center gap-2 px-4 py-2 rounded-lg bg-rose-500/10 text-rose-400 hover:bg-rose-500/20 border border-rose-500/20 text-sm font-medium transition-all duration-200 disabled:opacity-50 cursor-pointer"
                  >
                    {actionLoading === req.id ? (
                      <Loader2 className="h-4 w-4 animate-spin" />
                    ) : (
                      <XCircle className="h-4 w-4" />
                    )}
                    Reject
                  </button>
                </div>
              )}
            </div>
          ))}
        </div>
      )}

      <Pagination currentPage={safePage} totalPages={totalPages} onPageChange={setCurrentPage} />
    </div>
  );
}
