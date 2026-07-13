'use strict';
'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { supabase } from '@/app/lib/supabaseClient';
import toast from 'react-hot-toast';
import { Search, Plus, Trash2, ShieldAlert, Shield, HelpCircle, X, Loader2 } from 'lucide-react';
import Select from '@/components/Select';

interface Profile {
  id: string;
  full_name: string;
  email: string | null;
  role: string;
  status: string;
}

export default function ManageAdminsPage() {
  const router = useRouter();
  const [currentUserRole, setCurrentUserRole] = useState<string>('');
  const [users, setUsers] = useState<Profile[]>([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [activeTab, setActiveTab] = useState<'staff' | 'learners'>('staff');
  const [isLoading, setIsLoading] = useState(true);
  const [isAuthorized, setIsAuthorized] = useState(false);

  // Invite form states
  const [isInviteOpen, setIsInviteOpen] = useState(false);
  const [inviteEmail, setInviteEmail] = useState('');
  const [invitePassword, setInvitePassword] = useState('');
  const [inviteRole, setInviteRole] = useState('admin');
  const [isInviting, setIsInviting] = useState(false);
  const [inviteErrors, setInviteErrors] = useState<Record<string, string>>({});

  const fetchUsers = async () => {
    try {
      setIsLoading(true);

      // Get session token to authenticate the server-side API route
      const { data: { session } } = await supabase.auth.getSession();
      const token = session?.access_token;

      if (!token) {
        toast.error('Session expired. Please log in again.');
        setIsLoading(false);
        return;
      }

      // Call secure server-side API (uses service role to bypass RLS)
      const response = await fetch('/api/admin/users', {
        headers: { Authorization: `Bearer ${token}` },
      });

      if (!response.ok) {
        const err = await response.json();
        throw new Error(err.error || 'Failed to load users.');
      }

      const data = await response.json();
      setUsers(data.profiles || []);
    } catch {
      toast.error('Failed to load user directories.');
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
        .select('role')
        .eq('id', session.user.id)
        .single();

      if (!profile || !['admin', 'superadmin'].includes(profile.role)) {
        toast.error('Access denied.');
        router.push('/dashboard');
        return;
      }

      setCurrentUserRole(profile.role);
      setIsAuthorized(true);
      fetchUsers();
    }
    init();
  }, [router]);

  const handleInvite = async (e: React.FormEvent) => {
    e.preventDefault();
    setInviteErrors({});

    if (!inviteEmail.trim()) {
      setInviteErrors((prev) => ({ ...prev, email: 'Email address is required.' }));
      toast.error('Email address is required.');
      return;
    }
    if (!invitePassword || invitePassword.length < 6) {
      setInviteErrors((prev) => ({ ...prev, password: 'Password must be at least 6 characters.' }));
      toast.error('Password must be at least 6 characters.');
      return;
    }

    setIsInviting(true);
    const loadingToast = toast.loading('Sending invite...');

    try {
      const { data: { session } } = await supabase.auth.getSession();
      const token = session?.access_token;

      const response = await fetch('/api/users', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`,
        },
        body: JSON.stringify({
          email: inviteEmail,
          password: invitePassword,
          role: inviteRole,
        }),
      });

      const resData = await response.json();
      if (!response.ok) {
        throw new Error(resData.error || 'Failed to invite user.');
      }

      toast.dismiss(loadingToast);
      toast.success('User invited successfully!');
      setIsInviteOpen(false);
      setInviteErrors({});
      
      // Clear forms
      setInviteEmail('');
      setInvitePassword('');
      setInviteRole('admin');
      
      fetchUsers();
    } catch (err: unknown) {
      toast.dismiss(loadingToast);
      toast.error(err instanceof Error ? err.message : 'Invitation failed.');
    } finally {
      setIsInviting(false);
    }
  };

  const handleUpdateRole = async (targetUserId: string, newRole: string) => {
    const loadingToast = toast.loading('Updating user role...');
    try {
      const { data: { session } } = await supabase.auth.getSession();
      const token = session?.access_token;

      const response = await fetch('/api/users', {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`,
        },
        body: JSON.stringify({
          targetUserId,
          role: newRole,
        }),
      });

      const resData = await response.json();
      if (!response.ok) {
        throw new Error(resData.error || 'Failed to update role.');
      }

      toast.dismiss(loadingToast);
      toast.success('Role updated successfully.');
      setUsers(users.map(u => u.id === targetUserId ? { ...u, role: newRole } : u));
    } catch (err: unknown) {
      toast.dismiss(loadingToast);
      toast.error(err instanceof Error ? err.message : 'Failed to update role.');
    }
  };

  const handleToggleStatus = async (targetUserId: string, currentStatus: string) => {
    const newStatus = currentStatus === 'ACTIVE' ? 'SUSPENDED' : 'ACTIVE';
    const loadingToast = toast.loading(`Updating user status to ${newStatus}...`);

    try {
      const { data: { session } } = await supabase.auth.getSession();
      const token = session?.access_token;

      const response = await fetch('/api/users', {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`,
        },
        body: JSON.stringify({
          targetUserId,
          status: newStatus,
        }),
      });

      const resData = await response.json();
      if (!response.ok) {
        throw new Error(resData.error || 'Failed to update status.');
      }

      toast.dismiss(loadingToast);
      toast.success(`User status updated to ${newStatus}.`);
      setUsers(users.map(u => u.id === targetUserId ? { ...u, status: newStatus } : u));
    } catch (err: unknown) {
      toast.dismiss(loadingToast);
      toast.error(err instanceof Error ? err.message : 'Failed to change status.');
    }
  };

  const handleDeleteUser = async (targetUserId: string, name: string) => {
    if (!confirm(`Are you absolutely sure you want to delete user "${name}"? This action is permanent and cannot be undone.`)) {
      return;
    }

    const loadingToast = toast.loading('Deleting user account...');
    try {
      const { data: { session } } = await supabase.auth.getSession();
      const token = session?.access_token;

      const response = await fetch(`/api/users/${targetUserId}`, {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${token}`,
        },
      });

      const resData = await response.json();
      if (!response.ok) {
        throw new Error(resData.error || 'Failed to delete user.');
      }

      toast.dismiss(loadingToast);
      toast.success('User deleted successfully.');
      setUsers(users.filter(u => u.id !== targetUserId));
    } catch (err: unknown) {
      toast.dismiss(loadingToast);
      toast.error(err instanceof Error ? err.message : 'Failed to delete user.');
    }
  };

  const isSuperAdmin = currentUserRole === 'superadmin';

  const filteredUsers = users.filter((u) => {
    const matchSearch =
      (u.full_name && u.full_name.toLowerCase().includes(searchTerm.toLowerCase())) ||
      (u.email && u.email.toLowerCase().includes(searchTerm.toLowerCase()));
    
    if (!matchSearch) return false;

    if (activeTab === 'staff') {
      return u.role !== 'learner';
    } else {
      return u.role === 'learner';
    }
  });

  return (
    <div className="space-y-8 animate-in fade-in duration-300">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-3xl font-extrabold text-white tracking-tight">Manage Staff & Users</h1>
          <p className="text-zinc-400 text-sm mt-1">Promote user roles, suspend access, and invite administrators.</p>
        </div>
        {isSuperAdmin && (
          <button
            onClick={() => setIsInviteOpen(true)}
            className="inline-flex items-center gap-2 rounded-xl bg-gradient-to-r from-teal-500 to-emerald-500 px-5 py-3 text-sm font-semibold text-zinc-950 transition hover:from-teal-400 hover:to-emerald-400 cursor-pointer shadow-lg shadow-teal-500/10 active:scale-[0.98]"
          >
            <Plus className="h-4 w-4" />
            Invite Admin
          </button>
        )}
      </div>

      {/* Tabs and Search Bar */}
      <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div className="flex items-center gap-2 p-1 rounded-xl bg-zinc-900/60 border border-zinc-800 self-start">
          <button
            onClick={() => setActiveTab('staff')}
            className={`px-4 py-2 text-xs font-semibold rounded-lg transition-all cursor-pointer ${
              activeTab === 'staff'
                ? 'bg-teal-500 text-zinc-950 shadow-md shadow-teal-500/10'
                : 'text-zinc-400 hover:text-white'
            }`}
          >
            Staff Directory ({users.filter(u => u.role !== 'learner').length})
          </button>
          <button
            onClick={() => setActiveTab('learners')}
            className={`px-4 py-2 text-xs font-semibold rounded-lg transition-all cursor-pointer ${
              activeTab === 'learners'
                ? 'bg-teal-500 text-zinc-950 shadow-md shadow-teal-500/10'
                : 'text-zinc-400 hover:text-white'
            }`}
          >
            User Directory ({users.filter(u => u.role === 'learner').length})
          </button>
        </div>

        <div className="relative w-full md:max-w-xs">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-zinc-500" />
          <input
            type="text"
            placeholder="Search directory..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full rounded-xl border border-zinc-800 bg-zinc-900/40 py-2.5 pl-9 pr-4 text-xs text-zinc-100 placeholder-zinc-500 outline-none transition focus:border-teal-500 focus:bg-zinc-900/50"
          />
        </div>
      </div>

      {/* Users Table */}
      {isLoading ? (
        <div className="flex h-48 items-center justify-center">
          <span className="text-sm text-zinc-500">Loading user directory...</span>
        </div>
      ) : filteredUsers.length === 0 ? (
        <div className="flex flex-col items-center justify-center text-center p-12 rounded-2xl border border-dashed border-zinc-800 bg-zinc-900/10">
          <HelpCircle className="h-10 w-10 text-zinc-650 mb-3" />
          <h3 className="text-lg font-bold text-white">No users found</h3>
          <p className="text-zinc-500 text-sm mt-1">No matching emails or names discovered.</p>
        </div>
      ) : (
        <div className="overflow-x-auto rounded-2xl border border-zinc-800 bg-zinc-900/20">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="border-b border-zinc-850 bg-zinc-900/40 text-xs font-semibold uppercase tracking-wider text-zinc-400">
                <th className="p-4 sm:p-5">Name / Email</th>
                <th className="p-4 sm:p-5">Current Role</th>
                <th className="p-4 sm:p-5">Status</th>
                <th className="p-4 sm:p-5 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-zinc-850">
              {filteredUsers.map((user) => (
                <tr key={user.id} className="text-sm text-zinc-300 hover:bg-zinc-900/10 transition duration-150">
                  {/* Name and Email */}
                  <td className="p-4 sm:p-5">
                    <div className="font-semibold text-white">{user.full_name || 'No Name'}</div>
                    <div className="text-xs text-zinc-500 mt-0.5">{user.email || 'No email registered'}</div>
                  </td>

                  {/* Role and Role Selector */}
                  <td className="p-4 sm:p-5">
                    <Select
                      value={user.role}
                      onChange={(value) => handleUpdateRole(user.id, value)}
                      options={[
                        { value: 'learner', label: 'Learner' },
                        { value: 'instructor', label: 'Instructor' },
                        { value: 'admin', label: 'Admin' },
                        { value: 'superadmin', label: 'Super Admin' },
                      ]}
                    />
                  </td>

                  {/* Status Badge */}
                  <td className="p-4 sm:p-5">
                    <span className={`inline-flex rounded-full px-2.5 py-0.5 text-xs font-semibold leading-5 ${
                      user.status === 'ACTIVE'
                        ? 'bg-teal-500/10 text-teal-400 border border-teal-500/20'
                        : 'bg-rose-500/10 text-rose-400 border border-rose-500/20'
                    }`}>
                      {user.status}
                    </span>
                  </td>

                  {/* Actions Column */}
                  <td className="p-4 sm:p-5 text-right space-x-2">
                    {isSuperAdmin ? (
                      <>
                        <button
                          onClick={() => handleToggleStatus(user.id, user.status)}
                          className="inline-flex items-center gap-1 rounded-lg border border-zinc-800 hover:border-zinc-700 hover:bg-zinc-800 px-2.5 py-1.5 text-xs font-semibold text-zinc-300 transition cursor-pointer"
                        >
                          <ShieldAlert className="h-3.5 w-3.5" />
                          {user.status === 'ACTIVE' ? 'Suspend' : 'Activate'}
                        </button>
                        <button
                          onClick={() => handleDeleteUser(user.id, user.full_name)}
                          className="inline-flex items-center gap-1 rounded-lg border border-zinc-800 hover:border-rose-900/30 hover:bg-rose-950/20 px-2.5 py-1.5 text-xs font-semibold text-rose-400 transition cursor-pointer"
                        >
                          <Trash2 className="h-3.5 w-3.5" />
                          Delete
                        </button>
                      </>
                    ) : (
                      <span className="text-xs text-zinc-650 italic">SuperAdmin Actions Locked</span>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* Invite Admin Modal */}
      {isInviteOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4 animate-in fade-in duration-200">
          <div className="w-full max-w-md overflow-hidden rounded-2xl border border-zinc-800 bg-zinc-900 p-6 shadow-2xl space-y-6">
            <div className="flex items-center justify-between">
              <h2 className="text-xl font-bold text-white flex items-center gap-2">
                <Shield className="h-5 w-5 text-teal-400" />
                Invite Staff Member
              </h2>
              <button
                onClick={() => setIsInviteOpen(false)}
                className="rounded-lg p-1 text-zinc-400 hover:bg-zinc-850 hover:text-white transition"
              >
                <X className="h-5 w-5" />
              </button>
            </div>

            <form onSubmit={handleInvite} className="space-y-4">
              {/* Email */}
              <div className="space-y-1.5">
                <label className="text-xs font-semibold uppercase tracking-wider text-zinc-400 block">Email Address <span className="text-rose-400">*</span></label>
                <input
                  type="email"
                  placeholder="name@example.com"
                  value={inviteEmail}
                  onChange={(e) => { setInviteEmail(e.target.value); setInviteErrors((prev) => ({ ...prev, email: '' })); }}
                  className={`w-full rounded-lg border ${inviteErrors.email ? 'border-rose-500' : 'border-zinc-800'} bg-zinc-950 py-3 px-4 text-sm text-zinc-100 placeholder-zinc-600 outline-none focus:border-teal-500 transition`}
                />
                {inviteErrors.email && <p className="text-xs text-rose-400">{inviteErrors.email}</p>}
              </div>

              {/* Password */}
              <div className="space-y-1.5">
                <label className="text-xs font-semibold uppercase tracking-wider text-zinc-400 block">Temporary Password <span className="text-rose-400">*</span></label>
                <input
                  type="password"
                  placeholder="Minimum 6 characters"
                  value={invitePassword}
                  onChange={(e) => { setInvitePassword(e.target.value); setInviteErrors((prev) => ({ ...prev, password: '' })); }}
                  className={`w-full rounded-lg border ${inviteErrors.password ? 'border-rose-500' : 'border-zinc-800'} bg-zinc-950 py-3 px-4 text-sm text-zinc-100 placeholder-zinc-600 outline-none focus:border-teal-500 transition`}
                />
                {inviteErrors.password && <p className="text-xs text-rose-400">{inviteErrors.password}</p>}
              </div>

              {/* Role */}
              <div className="space-y-1.5">
                <label className="text-xs font-semibold uppercase tracking-wider text-zinc-400 block">Assigned Role <span className="text-rose-400">*</span></label>
                <Select
                  value={inviteRole}
                  onChange={setInviteRole}
                  options={[
                    { value: 'admin', label: 'Admin' },
                    { value: 'superadmin', label: 'Super Admin' },
                    { value: 'instructor', label: 'Instructor' },
                  ]}
                  error={inviteErrors.role}
                />
                {inviteErrors.role && <p className="text-xs text-rose-400">{inviteErrors.role}</p>}
              </div>

              {/* Buttons */}
              <div className="pt-4 border-t border-zinc-800 flex justify-end gap-3">
                <button
                  type="button"
                onClick={() => { setIsInviteOpen(false); setInviteErrors({}); }}
                  className="rounded-lg border border-zinc-800 px-4 py-2.5 text-xs font-semibold text-zinc-400 hover:text-zinc-200 transition"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={isInviting}
                  className="flex items-center gap-1.5 rounded-lg bg-gradient-to-r from-teal-500 to-emerald-500 px-4 py-2.5 text-xs font-semibold text-zinc-950 transition hover:from-teal-400 hover:to-emerald-400 cursor-pointer shadow-lg shadow-teal-500/10 active:scale-[0.98] disabled:opacity-50"
                >
                  {isInviting ? (
                    <>
                      <Loader2 className="h-3 w-3 animate-spin" />
                      Creating Account...
                    </>
                  ) : (
                    'Invite Member'
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
