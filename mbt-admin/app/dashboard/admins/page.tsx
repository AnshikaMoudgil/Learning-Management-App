'use strict';
'use client';

import { useEffect, useState, useDeferredValue } from 'react';
import { useRouter } from 'next/navigation';
import { supabase } from '@/app/lib/supabaseClient';
import toast from 'react-hot-toast';
import { Search, Plus, Trash2, ShieldAlert, Shield, HelpCircle, X, Loader2 } from 'lucide-react';
import Select from '@/components/Select';
import Pagination from '@/components/Pagination';
import ConfirmDialog from '@/components/ConfirmDialog';
import { PAGE_SIZE } from '@/app/lib/constants';
import { csrfHeaders } from '@/lib/csrf';

interface Profile {
  id: string;
  full_name: string;
  email: string | null;
  role: string;
  status: string;
  allowed_sections?: string[];
  allowed_actions?: string[];
}

export default function ManageAdminsPage() {
  const router = useRouter();
  const [currentUserId, setCurrentUserId] = useState<string>('');
  const [currentUserRole, setCurrentUserRole] = useState<string>('');
  const [users, setUsers] = useState<Profile[]>([]);
  const [searchTerm, setSearchTerm] = useState('');
  const deferredSearchTerm = useDeferredValue(searchTerm);
  const [isLoading, setIsLoading] = useState(true);
  const [isAuthorized, setIsAuthorized] = useState(false);
  const [currentPage, setCurrentPage] = useState(1);

  // Invite form states
  const [isInviteOpen, setIsInviteOpen] = useState(false);
  const [inviteEmail, setInviteEmail] = useState('');
  const [inviteFullName, setInviteFullName] = useState('');
  const [invitePassword, setInvitePassword] = useState('');
  const [inviteRole, setInviteRole] = useState('admin');
  const [isInviting, setIsInviting] = useState(false);
  const [inviteErrors, setInviteErrors] = useState<Record<string, string>>({});

  // Delete confirmation states
  const [isDeleteOpen, setIsDeleteOpen] = useState(false);
  const [userToDelete, setUserToDelete] = useState<{ id: string; name: string } | null>(null);

  // Permissions modal states
  const [isPermissionsOpen, setIsPermissionsOpen] = useState(false);
  const [selectedUser, setSelectedUser] = useState<Profile | null>(null);
  const [tempSections, setTempSections] = useState<string[]>([]);
  const [tempActions, setTempActions] = useState<string[]>([]);
  const [isUpdatingPermissions, setIsUpdatingPermissions] = useState(false);

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
        .select('role, allowed_sections')
        .eq('id', session.user.id)
        .single();

      const hasAccess = profile && (
        profile.role === 'superadmin' ||
        profile.role === 'admin' ||
        (profile.allowed_sections || []).includes('Staff Directory')
      );

      if (!hasAccess) {
        toast.error('Access denied.');
        router.push('/dashboard');
        return;
      }

      setCurrentUserId(session.user.id);
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
          ...csrfHeaders(),
        },
        body: JSON.stringify({
          email: inviteEmail,
          password: invitePassword,
          role: inviteRole,
          full_name: inviteFullName.trim() || null,
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
      setInviteFullName('');
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
          ...csrfHeaders(),
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
          ...csrfHeaders(),
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

  const handleDeleteUser = async () => {
    if (!userToDelete) return;
    const { id: targetUserId } = userToDelete;

    const loadingToast = toast.loading('Deleting user account...');
    try {
      const { data: { session } } = await supabase.auth.getSession();
      const token = session?.access_token;

      const response = await fetch(`/api/users/${targetUserId}`, {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${token}`,
          ...csrfHeaders(),
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

  const handleOpenPermissions = (user: Profile) => {
    setSelectedUser(user);
    setTempSections(user.allowed_sections || []);
    setTempActions(user.allowed_actions || []);
    setIsPermissionsOpen(true);
  };

  const handleSavePermissions = async () => {
    if (!selectedUser) return;
    setIsUpdatingPermissions(true);
    const loadingToast = toast.loading('Saving permissions...');
    try {
      const { data: { session } } = await supabase.auth.getSession();
      const token = session?.access_token;

      const response = await fetch('/api/users', {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`,
          ...csrfHeaders(),
        },
        body: JSON.stringify({
          targetUserId: selectedUser.id,
          allowed_sections: tempSections,
          allowed_actions: tempActions,
        }),
      });

      const resData = await response.json();
      if (!response.ok) {
        throw new Error(resData.error || 'Failed to update permissions.');
      }

      toast.dismiss(loadingToast);
      toast.success('Permissions updated successfully.');
      setUsers(users.map(u => u.id === selectedUser.id ? { ...u, allowed_sections: tempSections, allowed_actions: tempActions } : u));
      setIsPermissionsOpen(false);
    } catch (err: unknown) {
      toast.dismiss(loadingToast);
      toast.error(err instanceof Error ? err.message : 'Failed to update permissions.');
    } finally {
      setIsUpdatingPermissions(false);
    }
  };

  useEffect(() => { setCurrentPage(1); }, [searchTerm]);

  const isSuperAdmin = currentUserRole === 'superadmin';

  const filteredUsers = users.filter((u) => {
    const matchSearch =
      (u.full_name && u.full_name.toLowerCase().includes(deferredSearchTerm.toLowerCase())) ||
      (u.email && u.email.toLowerCase().includes(deferredSearchTerm.toLowerCase()));

    return matchSearch && u.role !== 'learner';
  });

  const totalPages = Math.max(1, Math.ceil(filteredUsers.length / PAGE_SIZE));
  const safePage = Math.min(currentPage, totalPages);
  const paginatedUsers = filteredUsers.slice((safePage - 1) * PAGE_SIZE, safePage * PAGE_SIZE);

  return (
    <div className="space-y-8 animate-in fade-in duration-300">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-3xl font-extrabold text-gray-900 tracking-tight">Staff Directory</h1>
          <p className="text-gray-500 text-sm mt-1">Manage administrators, instructors, and staff accounts.</p>
        </div>
        {isSuperAdmin && (
          <button
            onClick={() => setIsInviteOpen(true)}
            className="inline-flex items-center gap-2 rounded-xl bg-gradient-to-r from-blue-600 to-blue-500 px-5 py-3 text-sm font-semibold text-white transition hover:from-blue-500 hover:to-blue-400 cursor-pointer shadow-lg shadow-blue-500/10 active:scale-[0.98]"
          >
            <Plus className="h-4 w-4" />
            Invite Admin
          </button>
        )}
      </div>

      {/* Search Bar */}
      <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div className="relative w-full md:max-w-xs">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" />
          <input
            type="text"
            placeholder="Search directory..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full rounded-xl border border-gray-200 bg-gray-50 py-2.5 pl-9 pr-4 text-xs text-gray-900 placeholder-gray-400 outline-none transition focus:border-blue-500 focus:bg-white"
          />
        </div>
      </div>

      {/* Users Table */}
      {isLoading ? (
        <div className="flex h-48 items-center justify-center">
          <span className="text-sm text-gray-400">Loading user directory...</span>
        </div>
      ) : filteredUsers.length === 0 ? (
        <div className="flex flex-col items-center justify-center text-center p-12 rounded-2xl border border-dashed border-gray-200 bg-gray-50">
          <HelpCircle className="h-10 w-10 text-gray-400 mb-3" />
          <h3 className="text-lg font-bold text-gray-900">No staff found</h3>
          <p className="text-gray-400 text-sm mt-1">No matching staff members found.</p>
        </div>
      ) : (
        <div className="overflow-x-auto rounded-2xl border border-gray-200 bg-white shadow-sm">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="border-b border-gray-200 bg-gray-50 text-xs font-semibold uppercase tracking-wider text-gray-500">
                <th className="p-4 sm:p-5">Name / Email</th>
                <th className="p-4 sm:p-5">Current Role</th>
                <th className="p-4 sm:p-5">Status</th>
                <th className="p-4 sm:p-5 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {paginatedUsers.map((user) => (
                <tr key={user.id} className="text-sm text-gray-700 hover:bg-gray-50 transition duration-150">
                  {/* Name and Email */}
                  <td className="p-4 sm:p-5">
                    <div className="font-semibold text-gray-900">{user.full_name || 'No Name'}</div>
                    <div className="text-xs text-gray-400 mt-0.5">{user.email || 'No email registered'}</div>
                  </td>

                  {/* Role and Role Selector */}
                  <td className="p-4 sm:p-5">
                    {user.id === currentUserId ? (
                      <span className="inline-flex items-center rounded-lg bg-gray-100 px-3 py-2 text-xs font-semibold text-gray-500">{user.role}</span>
                    ) : (
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
                    )}
                  </td>

                  {/* Status Badge */}
                  <td className="p-4 sm:p-5">
                    <span className={`inline-flex rounded-full px-2.5 py-0.5 text-xs font-semibold leading-5 ${
                      user.status === 'ACTIVE'
                        ? 'bg-blue-600/10 text-blue-400 border border-blue-500/25'
                        : 'bg-rose-500/10 text-rose-400 border border-rose-500/20'
                    }`}>
                      {user.status}
                    </span>
                  </td>

                  {/* Actions Column */}
                  <td className="p-4 sm:p-5 text-right space-x-2">
                    {user.id === currentUserId ? (
                      <span className="text-xs text-gray-400 italic">Your Account</span>
                    ) : isSuperAdmin ? (
                      <>
                        {user.role !== 'superadmin' && (
                          <button
                            onClick={() => handleOpenPermissions(user)}
                            className="inline-flex items-center gap-1 rounded-lg border border-gray-200 hover:border-blue-300 hover:bg-blue-50 px-2.5 py-1.5 text-xs font-semibold text-blue-600 transition cursor-pointer"
                          >
                            <Shield className="h-3.5 w-3.5" />
                            Permissions
                          </button>
                        )}
                        <button
                          onClick={() => handleToggleStatus(user.id, user.status)}
                          className="inline-flex items-center gap-1 rounded-lg border border-gray-200 hover:border-gray-300 hover:bg-gray-100 px-2.5 py-1.5 text-xs font-semibold text-gray-700 transition cursor-pointer"
                        >
                          <ShieldAlert className="h-3.5 w-3.5" />
                          {user.status === 'ACTIVE' ? 'Suspend' : 'Activate'}
                        </button>
                        <button
                          onClick={() => { setUserToDelete({ id: user.id, name: user.full_name }); setIsDeleteOpen(true); }}
                          className="inline-flex items-center gap-1 rounded-lg border border-gray-200 hover:border-rose-900/30 hover:bg-rose-950/20 px-2.5 py-1.5 text-xs font-semibold text-rose-400 transition cursor-pointer"
                        >
                          <Trash2 className="h-3.5 w-3.5" />
                          Delete
                        </button>
                      </>
                    ) : (
                      <span className="text-xs text-gray-400 italic">SuperAdmin Actions Locked</span>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      <Pagination currentPage={safePage} totalPages={totalPages} onPageChange={setCurrentPage} />

      {/* Delete Confirmation Dialog */}
      <ConfirmDialog
        isOpen={isDeleteOpen}
        title="Delete Staff Member"
        message={`Are you sure you want to delete "${userToDelete?.name || 'this staff member'}"? This action is permanent and cannot be undone.`}
        confirmLabel="Delete"
        variant="danger"
        onConfirm={handleDeleteUser}
        onCancel={() => { setIsDeleteOpen(false); setUserToDelete(null); }}
      />

      {/* Invite Admin Modal */}
      {isInviteOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4 animate-in fade-in duration-200">
          <div className="w-full max-w-md overflow-hidden rounded-2xl border border-gray-200 bg-white p-6 shadow-2xl space-y-6">
            <div className="flex items-center justify-between">
              <h2 className="text-xl font-bold text-gray-900 flex items-center gap-2">
                <Shield className="h-5 w-5 text-blue-600" />
                Invite Staff Member
              </h2>
              <button
                onClick={() => setIsInviteOpen(false)}
                className="rounded-lg p-1 text-gray-500 hover:bg-gray-100 hover:text-gray-900 transition"
              >
                <X className="h-5 w-5" />
              </button>
            </div>

            <form onSubmit={handleInvite} className="space-y-4">
              {/* Email */}
              <div className="space-y-1.5">
                <label className="text-xs font-semibold uppercase tracking-wider text-gray-500 block">Email Address <span className="text-rose-400">*</span></label>
                <input
                  type="email"
                  placeholder="name@example.com"
                  value={inviteEmail}
                  onChange={(e) => { setInviteEmail(e.target.value); setInviteErrors((prev) => ({ ...prev, email: '' })); }}
                  className={`w-full rounded-lg border ${inviteErrors.email ? 'border-rose-500' : 'border-gray-200'} bg-white py-3 px-4 text-sm text-gray-900 placeholder-gray-400 outline-none focus:border-blue-500 transition`}
                />
                {inviteErrors.email && <p className="text-xs text-rose-400">{inviteErrors.email}</p>}
              </div>

              {/* Full Name */}
              <div className="space-y-1.5">
                <label className="text-xs font-semibold uppercase tracking-wider text-gray-500 block">User Name <span className="text-gray-400">(optional)</span></label>
                <input
                  type="text"
                  placeholder="e.g. John Doe"
                  value={inviteFullName}
                  onChange={(e) => { setInviteFullName(e.target.value); setInviteErrors((prev) => ({ ...prev, full_name: '' })); }}
                  className={`w-full rounded-lg border ${inviteErrors.full_name ? 'border-rose-500' : 'border-gray-200'} bg-white py-3 px-4 text-sm text-gray-900 placeholder-gray-400 outline-none focus:border-blue-500 transition`}
                />
                {inviteErrors.full_name && <p className="text-xs text-rose-400">{inviteErrors.full_name}</p>}
              </div>

              {/* Password */}
              <div className="space-y-1.5">
                <label className="text-xs font-semibold uppercase tracking-wider text-gray-500 block">Temporary Password <span className="text-rose-400">*</span></label>
                <input
                  type="password"
                  placeholder="Minimum 6 characters"
                  value={invitePassword}
                  onChange={(e) => { setInvitePassword(e.target.value); setInviteErrors((prev) => ({ ...prev, password: '' })); }}
                  className={`w-full rounded-lg border ${inviteErrors.password ? 'border-rose-500' : 'border-gray-200'} bg-white py-3 px-4 text-sm text-gray-900 placeholder-gray-400 outline-none focus:border-blue-500 transition`}
                />
                {inviteErrors.password && <p className="text-xs text-rose-400">{inviteErrors.password}</p>}
              </div>

              {/* Role */}
              <div className="space-y-1.5">
                <label className="text-xs font-semibold uppercase tracking-wider text-gray-500 block">Assigned Role <span className="text-rose-400">*</span></label>
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
              <div className="pt-4 border-t border-gray-200 flex justify-end gap-3">
                <button
                  type="button"
                onClick={() => { setIsInviteOpen(false); setInviteErrors({}); }}
                  className="rounded-lg border border-gray-200 px-4 py-2.5 text-xs font-semibold text-gray-500 hover:text-gray-700 transition"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={isInviting}
                  className="flex items-center gap-1.5 rounded-lg bg-gradient-to-r from-blue-600 to-blue-500 px-4 py-2.5 text-xs font-semibold text-white transition hover:from-blue-500 hover:to-blue-400 cursor-pointer shadow-lg shadow-blue-500/10 active:scale-[0.98] disabled:opacity-50"
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
      {isPermissionsOpen && selectedUser && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4 animate-in fade-in duration-200">
          <div className="w-full max-w-lg overflow-hidden rounded-2xl border border-gray-200 bg-white p-6 shadow-2xl space-y-6">
            <div className="flex items-center justify-between">
              <h2 className="text-xl font-bold text-gray-900 flex items-center gap-2">
                <Shield className="h-5 w-5 text-blue-600" />
                Manage Permissions for {selectedUser.full_name || 'Staff Member'}
              </h2>
              <button
                onClick={() => setIsPermissionsOpen(false)}
                className="rounded-lg p-1 text-gray-500 hover:bg-gray-100 hover:text-gray-900 transition"
              >
                <X className="h-5 w-5" />
              </button>
            </div>

            <div className="max-h-[60vh] overflow-y-auto space-y-1 pr-1 divide-y divide-gray-100">
              {[
                { name: 'Overview', hasWrite: false, desc: 'View analytics dashboard and statistics' },
                { name: 'Courses', hasWrite: true, writeAction: 'Courses: Write', desc: 'Manage courses, modules, and lessons' },
                { name: 'Live Classes', hasWrite: true, writeAction: 'Live Classes: Write', desc: 'Schedule and manage live video sessions' },
                { name: 'Manage Coupons', hasWrite: true, writeAction: 'Manage Coupons: Write', desc: 'Create and edit promotional codes' },
                { name: 'Payments & Orders', hasWrite: true, writeAction: 'Payments & Orders: Write', desc: 'Review transactions and refunds' },
                { name: 'Staff Directory', hasWrite: true, writeAction: 'Staff Directory: Write', desc: 'Manage administrators and instructors' },
                { name: 'User Directory', hasWrite: true, writeAction: 'User Directory: Write', desc: 'View learners and suspend accounts' },
                { name: 'Device Requests', hasWrite: true, writeAction: 'Accept / Reject Device Requests', desc: 'Review user device change queries' },
                { name: 'Integrations', hasWrite: true, writeAction: 'Integrations: Write', desc: 'Configure provider credentials' },
              ].map((section, idx) => {
                const hasSection = tempSections.includes(section.name);
                const hasWrite = section.hasWrite && tempActions.includes(section.writeAction || '');
                
                let currentVal = 'none';
                if (hasSection) {
                  currentVal = hasWrite ? 'write' : 'read';
                }

                const handleAccessChange = (val: string) => {
                  let newSections = [...tempSections];
                  let newActions = [...tempActions];

                  // Reset this section settings first
                  newSections = newSections.filter(s => s !== section.name);
                  if (section.writeAction) {
                    newActions = newActions.filter(a => a !== section.writeAction);
                  }

                  if (val === 'read') {
                    newSections.push(section.name);
                  } else if (val === 'write') {
                    newSections.push(section.name);
                    if (section.writeAction) {
                      newActions.push(section.writeAction);
                    }
                  }

                  setTempSections(newSections);
                  setTempActions(newActions);
                };

                return (
                  <div key={section.name} className={`flex flex-col sm:flex-row sm:items-center sm:justify-between py-3.5 ${idx === 0 ? '' : 'border-t border-gray-100'}`}>
                    <div className="space-y-0.5">
                      <span className="text-sm font-semibold text-gray-900">{section.name}</span>
                      {section.desc && <p className="text-xs text-gray-400">{section.desc}</p>}
                    </div>
                    <div className="mt-2 sm:mt-0 shrink-0">
                      <Select
                        value={currentVal}
                        onChange={handleAccessChange}
                        options={[
                          { value: 'none', label: 'No Access' },
                          { value: 'read', label: 'Read Only' },
                          ...(section.hasWrite ? [{ value: 'write', label: 'Read & Write' }] : []),
                        ]}
                        size="sm"
                        className="w-36 font-semibold"
                      />
                    </div>
                  </div>
                );
              })}
            </div>

            {/* Buttons */}
            <div className="pt-4 border-t border-gray-200 flex justify-end gap-3">
              <button
                type="button"
                onClick={() => setIsPermissionsOpen(false)}
                className="rounded-lg border border-gray-200 px-4 py-2.5 text-xs font-semibold text-gray-500 hover:text-gray-700 transition"
              >
                Cancel
              </button>
              <button
                type="button"
                onClick={handleSavePermissions}
                disabled={isUpdatingPermissions}
                className="flex items-center gap-1.5 rounded-lg bg-gradient-to-r from-blue-600 to-blue-500 px-4 py-2.5 text-xs font-semibold text-white transition hover:from-blue-500 hover:to-blue-400 cursor-pointer shadow-lg shadow-blue-500/10 active:scale-[0.98] disabled:opacity-50"
              >
                {isUpdatingPermissions ? (
                  <>
                    <Loader2 className="h-3 w-3 animate-spin" />
                    Saving...
                  </>
                ) : (
                  'Save Permissions'
                )}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
