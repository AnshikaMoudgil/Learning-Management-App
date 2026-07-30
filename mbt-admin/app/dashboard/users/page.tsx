'use client';

import { useEffect, useState, useMemo, startTransition } from 'react';
import { useRouter } from 'next/navigation';
import { supabase } from '@/app/lib/supabaseClient';
import toast from 'react-hot-toast';
import { Search, HelpCircle, ShieldAlert, Users, UserPlus, Calendar, TrendingUp } from 'lucide-react';
import Pagination from '@/components/Pagination';

interface Profile {
  id: string;
  full_name: string;
  email: string | null;
  phone: string | null;
  role: string;
  status: string;
  created_at: string;
  provider: string;
  last_sign_in_at: string | null;
}

import { PAGE_SIZE } from '@/app/lib/constants';

export default function UsersPage() {
  const router = useRouter();
  const [users, setUsers] = useState<Profile[]>([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [isLoading, setIsLoading] = useState(true);
  const [currentPage, setCurrentPage] = useState(1);

  const fetchUsers = async () => {
    try {
      setIsLoading(true);
      const { data: { session } } = await supabase.auth.getSession();
      const token = session?.access_token;
      if (!token) { toast.error('Session expired.'); setIsLoading(false); return; }

      const response = await fetch('/api/admin/users', {
        headers: { Authorization: `Bearer ${token}` },
      });
      if (!response.ok) throw new Error('Failed to load users.');
      const data = await response.json();
      setUsers(data.profiles || []);
    } catch {
      toast.error('Failed to load user directory.');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    async function init() {
      const { data: { session } } = await supabase.auth.getSession();
      if (!session) { router.push('/login'); return; }

      const { data: profile } = await supabase
        .from('profiles')
        .select('role, allowed_sections')
        .eq('id', session.user.id)
        .single();

      const hasAccess = profile && (
        profile.role === 'superadmin' ||
        profile.role === 'admin' ||
        (profile.allowed_sections || []).includes('User Directory')
      );

      if (!hasAccess) {
        toast.error('Access denied.');
        router.push('/dashboard');
        return;
      }
      fetchUsers();
    }
    init();
  }, [router]);

  const handleToggleStatus = async (targetUserId: string, currentStatus: string) => {
    const newStatus = currentStatus === 'ACTIVE' ? 'SUSPENDED' : 'ACTIVE';
    const loadingToast = toast.loading(`Updating user status to ${newStatus}...`);
    try {
      const { data: { session } } = await supabase.auth.getSession();
      const token = session?.access_token;
      const response = await fetch('/api/users', {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
        body: JSON.stringify({ targetUserId, status: newStatus }),
      });
      const resData = await response.json();
      if (!response.ok) throw new Error(resData.error || 'Failed to update status.');
      toast.dismiss(loadingToast);
      toast.success(`User status updated to ${newStatus}.`);
      setUsers(users.map(u => u.id === targetUserId ? { ...u, status: newStatus } : u));
    } catch (err: unknown) {
      toast.dismiss(loadingToast);
      toast.error(err instanceof Error ? err.message : 'Failed to change status.');
    }
  };

  const startMarkers = useMemo(() => {
    const today = new Date();
    const startOfToday = new Date(today.getFullYear(), today.getMonth(), today.getDate());
    const startOfWeek = new Date(today);
    startOfWeek.setDate(today.getDate() - today.getDay());
    startOfWeek.setHours(0, 0, 0, 0);
    const startOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);
    return { startOfToday, startOfWeek, startOfMonth };
  }, []);

  const learners = useMemo(() => users.filter((u) => u.role === 'learner'), [users]);

  const statCards = useMemo(() => {
    const { startOfToday, startOfWeek, startOfMonth } = startMarkers;
    return [
      {
        name: 'Total Users',
        value: learners.length,
        desc: 'Registered learners',
        icon: Users,
        iconBg: 'linear-gradient(135deg, #6366f1, #8b5cf6)',
        iconGlow: '0 0 20px rgba(99,102,241,0.35)',
      },
      {
        name: 'New Today',
        value: learners.filter((u) => new Date(u.created_at) >= startOfToday).length,
        desc: 'Joined in the last 24 hours',
        icon: UserPlus,
        iconBg: 'linear-gradient(135deg, #10b981, #059669)',
        iconGlow: '0 0 20px rgba(16,185,129,0.35)',
      },
      {
        name: 'This Week',
        value: learners.filter((u) => new Date(u.created_at) >= startOfWeek).length,
        desc: 'Joined this week',
        icon: Calendar,
        iconBg: 'linear-gradient(135deg, #f59e0b, #d97706)',
        iconGlow: '0 0 20px rgba(245,158,11,0.35)',
      },
      {
        name: 'This Month',
        value: learners.filter((u) => new Date(u.created_at) >= startOfMonth).length,
        desc: 'Joined this month',
        icon: TrendingUp,
        iconBg: 'linear-gradient(135deg, #0ea5e9, #2563eb)',
        iconGlow: '0 0 20px rgba(14,165,233,0.35)',
      },
    ];
  }, [learners, startMarkers]);

  const filtered = useMemo(() => {
    const f = learners.filter((u) =>
      (u.full_name && u.full_name.toLowerCase().includes(searchTerm.toLowerCase())) ||
      (u.email && u.email.toLowerCase().includes(searchTerm.toLowerCase()))
    );
    return f;
  }, [learners, searchTerm]);

  const totalPages = Math.max(1, Math.ceil(filtered.length / PAGE_SIZE));
  const safePage = Math.min(currentPage, totalPages);
  const paginated = filtered.slice((safePage - 1) * PAGE_SIZE, safePage * PAGE_SIZE);

  useEffect(() => {
    startTransition(() => { setCurrentPage(1); });
  }, [searchTerm]);

  const formatDate = (dateStr: string | null) => {
    if (!dateStr) return '—';
    return new Date(dateStr).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric', hour: '2-digit', minute: '2-digit' });
  };

  const formatProvider = (provider: string) => {
    switch (provider) {
      case 'google': return 'Google';
      case 'phone': return 'Phone';
      default: return 'Email';
    }
  };

  return (
    <div className="space-y-8 animate-in fade-in duration-300">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-3xl font-extrabold text-gray-900 tracking-tight">User Directory</h1>
          <p className="text-gray-500 text-sm mt-1">View and manage registered learner accounts.</p>
        </div>
      </div>

      <div className="grid gap-5 sm:grid-cols-2 lg:grid-cols-4">
        {statCards.map((card) => {
          const Icon = card.icon;
          return (
            <div key={card.name} className="rounded-xl border border-gray-200 bg-white p-5 shadow-sm">
              <div className="flex items-start justify-between">
                <div>
                  <p className="text-xs font-semibold uppercase tracking-wider text-gray-500">{card.name}</p>
                  <p className="text-3xl font-extrabold mt-2 leading-none text-gray-900">{card.value}</p>
                </div>
                <div className="rounded-xl p-3 shrink-0" style={{ background: card.iconBg, boxShadow: card.iconGlow }}>
                  <Icon className="h-5 w-5 text-white" />
                </div>
              </div>
              <p className="text-xs mt-4 text-gray-400">{card.desc}</p>
            </div>
          );
        })}
      </div>

      <div className="relative w-full md:max-w-xs">
        <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" />
        <input
          type="text"
          placeholder="Search learners..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          className="w-full rounded-xl border border-gray-200 bg-gray-50 py-2.5 pl-9 pr-4 text-xs text-gray-900 placeholder-gray-400 outline-none transition focus:border-blue-500 focus:bg-white"
        />
      </div>

      {isLoading ? (
        <div className="flex h-48 items-center justify-center">
          <span className="text-sm text-gray-400">Loading user directory...</span>
        </div>
      ) : filtered.length === 0 ? (
        <div className="flex flex-col items-center justify-center text-center p-12 rounded-2xl border border-dashed border-gray-200 bg-gray-50">
          <HelpCircle className="h-10 w-10 text-gray-400 mb-3" />
          <h3 className="text-lg font-bold text-gray-900">No learners found</h3>
          <p className="text-gray-400 text-sm mt-1">No matching learner accounts found.</p>
        </div>
      ) : (
        <div className="overflow-x-auto rounded-2xl border border-gray-200 bg-white shadow-sm">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="border-b border-gray-200 bg-gray-50 text-xs font-semibold uppercase tracking-wider text-gray-500">
                <th className="p-4 sm:p-5">Name / Email</th>
                <th className="p-4 sm:p-5">Phone</th>
                <th className="p-4 sm:p-5">Provider</th>
                <th className="p-4 sm:p-5">Joined</th>
                <th className="p-4 sm:p-5">Last Sign In</th>
                <th className="p-4 sm:p-5">Status</th>
                <th className="p-4 sm:p-5 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {paginated.map((user) => (
                <tr key={user.id} className="text-sm text-gray-700 hover:bg-gray-50 transition duration-150">
                  <td className="p-4 sm:p-5">
                    <div className="font-semibold text-gray-900">{user.full_name || 'No Name'}</div>
                    <div className="text-xs text-gray-400 mt-0.5">{user.email || 'No email registered'}</div>
                  </td>
                  <td className="p-4 sm:p-5 text-sm text-gray-500">{user.phone || '—'}</td>
                  <td className="p-4 sm:p-5">
                    <span className="inline-flex items-center gap-1 rounded-full bg-gray-100 px-2.5 py-1 text-xs font-medium text-gray-700">
                      {formatProvider(user.provider)}
                    </span>
                  </td>
                  <td className="p-4 sm:p-5 text-sm text-gray-500">{formatDate(user.created_at)}</td>
                  <td className="p-4 sm:p-5 text-sm text-gray-500">{formatDate(user.last_sign_in_at)}</td>
                  <td className="p-4 sm:p-5">
                    <span className={`inline-flex rounded-full px-2.5 py-0.5 text-xs font-semibold leading-5 ${
                      user.status === 'ACTIVE'
                        ? 'bg-blue-600/10 text-blue-600 border border-blue-500/25'
                        : 'bg-rose-500/10 text-rose-400 border border-rose-500/20'
                    }`}>
                      {user.status}
                    </span>
                  </td>
                  <td className="p-4 sm:p-5 text-right">
                    <button
                      onClick={() => handleToggleStatus(user.id, user.status)}
                      className="inline-flex items-center gap-1 rounded-lg border border-gray-200 hover:border-gray-300 hover:bg-gray-100 px-2.5 py-1.5 text-xs font-semibold text-gray-700 transition cursor-pointer"
                    >
                      <ShieldAlert className="h-3.5 w-3.5" />
                      {user.status === 'ACTIVE' ? 'Suspend' : 'Activate'}
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {filtered.length > PAGE_SIZE && (
        <Pagination currentPage={safePage} totalPages={totalPages} onPageChange={setCurrentPage} />
      )}
    </div>
  );
}
