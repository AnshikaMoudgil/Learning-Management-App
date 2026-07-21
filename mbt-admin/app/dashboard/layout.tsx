'use client';

import { useState } from 'react';
import { usePathname } from 'next/navigation';
import { supabase } from '@/app/lib/supabaseClient';
import { AuthProvider, useAuth } from '@/app/lib/AuthContext';
import Link from 'next/link';
import toast from 'react-hot-toast';
import {
  LayoutDashboard,
  BookOpen,
  Users,
  KeyRound,
  LogOut,
  Menu,
  X,
  UserCheck,
  Smartphone,
  Tag,
  CreditCard,
  Video,
  Settings,
  User,
  ChevronLeft,
  ChevronRight,
} from 'lucide-react';

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <AuthProvider>
      <DashboardShell>{children}</DashboardShell>
    </AuthProvider>
  );
}

function DashboardShell({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const { role, profile } = useAuth();
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const [isCollapsed, setIsCollapsed] = useState(false);

  const handleLogout = async () => {
    const loadingToast = toast.loading('Signing out...');
    try {
      await supabase.auth.signOut();
      toast.dismiss(loadingToast);
      toast.success('Signed out successfully.');
    } catch (err: unknown) {
      toast.dismiss(loadingToast);
      toast.error(err instanceof Error ? err.message : 'Logout failed.');
    }
  };

  const allNavItems = [
    { name: 'Overview',          href: '/dashboard',                        icon: LayoutDashboard, roles: ['admin', 'superadmin'] },
    { name: 'My Profile',        href: '/dashboard/instructor-profile',      icon: UserCheck,       roles: ['instructor'] },
    { name: 'Courses',           href: '/dashboard/courses',                 icon: BookOpen,        roles: ['admin', 'superadmin'] },
    { name: 'Live Classes',      href: '/dashboard/live-classes',            icon: Video,           roles: ['admin', 'superadmin'] },
    { name: 'Manage Coupons',    href: '/dashboard/coupons',                 icon: Tag,             roles: ['admin', 'superadmin'] },
    { name: 'Payments & Orders', href: '/dashboard/payments',                icon: CreditCard,      roles: ['admin', 'superadmin'] },
    { name: 'Staff Directory',   href: '/dashboard/admins',                  icon: Users,           roles: ['admin', 'superadmin'] },
    { name: 'User Directory',    href: '/dashboard/users',                   icon: User,            roles: ['admin', 'superadmin'] },
    { name: 'Device Requests',   href: '/dashboard/device-requests',         icon: Smartphone,      roles: ['admin', 'superadmin'] },
    { name: 'Integrations',      href: '/dashboard/integrations',            icon: Settings,        roles: ['superadmin'] },
    { name: 'Change Password',   href: '/dashboard/change-password',         icon: KeyRound,        roles: ['admin', 'superadmin'] },
  ];

  const navItems = allNavItems.filter(item => {
    // 1. Hide My Profile from superadmin and admin
    if (item.name === 'My Profile' && (role === 'superadmin' || role === 'admin')) {
      return false;
    }
    // 2. Superadmin has access to all remaining sections
    if (role === 'superadmin') return true;

    // 3. Others check default roles or dynamic permissions
    const hasRoleAccess = item.roles.includes(role || '');
    const hasDynamicAccess = profile?.allowed_sections?.includes(item.name);
    return hasRoleAccess || hasDynamicAccess;
  });

  const roleLabels: Record<string, string> = {
    superadmin: 'Super Admin',
    admin:      'Administrator',
    instructor: 'Instructor',
  };

  const sidebarContent = (collapsed: boolean) => (
    <div className="flex h-full flex-col p-3">
      {/* Brand Logo & Title */}
      <div className={`flex items-center ${collapsed ? 'justify-center' : 'gap-3'} shrink-0 px-1`}>
        <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-blue-600 text-white font-bold text-lg shrink-0">
          M
        </div>
        {!collapsed && (
          <div className="min-w-0">
            <h1 className="font-bold leading-none text-gray-900 text-sm tracking-wide truncate">
              MBT Dashboard
            </h1>
            <span className="text-[10px] uppercase font-semibold tracking-widest text-gray-400 mt-1 block">
              Admin Control
            </span>
          </div>
        )}
      </div>

      {/* Nav Links — scrollable */}
      <nav className={`flex-1 overflow-y-auto space-y-1 min-h-0 ${collapsed ? 'mt-2' : 'mt-4'}`}>
        {navItems.map((item) => {
          const Icon = item.icon;
          const isActive =
            pathname === item.href ||
            (item.href !== '/dashboard' && pathname.startsWith(item.href));
          return (
            <Link
              key={item.name}
              href={item.href}
              onClick={() => setIsMobileMenuOpen(false)}
              className={`flex items-center ${collapsed ? 'justify-center' : 'gap-3'} px-4 py-3 rounded-lg text-sm font-medium transition-all duration-150 border ${
                isActive
                  ? 'bg-blue-50 text-blue-600 border-blue-200'
                  : 'text-gray-500 border-transparent hover:bg-gray-100 hover:text-gray-700'
              }`}
              title={collapsed ? item.name : undefined}
            >
              <Icon className="h-4.5 w-4.5 shrink-0" />
              {!collapsed && item.name}
            </Link>
          );
        })}
      </nav>

      {/* Footer Profile & Logout — always visible */}
      <div className={`pt-4 mt-4 border-t border-gray-200 space-y-3 shrink-0 ${collapsed ? 'px-0' : ''}`}>
        {profile && (
          <div className={`flex items-center ${collapsed ? 'justify-center' : 'gap-3'} px-1`}>
            <div className="flex h-9 w-9 items-center justify-center rounded-full bg-gray-200 text-gray-500 font-bold border border-gray-300 overflow-hidden shrink-0">
              {profile.avatar_url ? (
                <img src={profile.avatar_url} alt={profile.full_name} className="h-full w-full object-cover" />
              ) : (
                profile.full_name.charAt(0).toUpperCase()
              )}
            </div>
            {!collapsed && (
              <div className="flex-1 min-w-0">
                <p className="text-sm font-semibold text-gray-900 truncate leading-tight">{profile.full_name}</p>
                <span className="text-[10px] font-medium text-blue-600 mt-1 block uppercase tracking-wider">
                  {roleLabels[role || ''] || role}
                </span>
              </div>
            )}
          </div>
        )}
        <button
          onClick={handleLogout}
          className={`flex w-full items-center ${collapsed ? 'justify-center' : 'justify-center gap-2'} rounded-lg border border-gray-200 bg-transparent py-3 text-sm font-semibold text-blue-600 transition-all duration-150 hover:bg-blue-50 hover:border-blue-200 cursor-pointer`}
          title={collapsed ? 'Log Out' : undefined}
        >
          <LogOut className="h-4 w-4 shrink-0" />
          {!collapsed && <span>Log Out</span>}
        </button>

        {/* Toggle Collapse Button */}
        <button
          onClick={() => setIsCollapsed(!collapsed)}
          className={`flex w-full items-center ${collapsed ? 'justify-center' : 'justify-center gap-2'} rounded-lg border border-gray-200 bg-transparent py-2.5 text-sm font-semibold text-gray-400 hover:text-gray-600 hover:bg-gray-100 transition cursor-pointer`}
          title={collapsed ? 'Expand sidebar' : 'Collapse sidebar'}
        >
          {collapsed ? <ChevronRight className="h-4 w-4" /> : <ChevronLeft className="h-4 w-4" />}
          {!collapsed && <span>Collapse</span>}
        </button>
      </div>
    </div>
  );

  return (
    <div className="flex h-screen bg-gray-50 text-gray-900 overflow-hidden font-sans">
      
      {/* Desktop Sidebar */}
      <aside className={`hidden md:block ${isCollapsed ? 'w-16' : 'w-64'} border-r border-gray-200 bg-white shrink-0 transition-all duration-200`}>
        {sidebarContent(isCollapsed)}
      </aside>

      {/* Mobile Nav Header */}
      <div className="flex flex-col flex-1 overflow-hidden">
        <header className="md:hidden flex h-16 items-center justify-between border-b border-gray-200 bg-white px-6">
          <div className="flex items-center gap-2">
            <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-blue-600 text-white font-bold">
              M
            </div>
            <span className="font-bold text-sm tracking-wide text-gray-900">MBT Admin</span>
          </div>
          <button
            onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
            className="rounded-lg border border-gray-200 p-2 text-gray-400 hover:bg-gray-100 hover:text-gray-600"
          >
            {isMobileMenuOpen ? <X className="h-5 w-5" /> : <Menu className="h-5 w-5" />}
          </button>
        </header>

        {/* Mobile Menu Drawer */}
        {isMobileMenuOpen && (
          <div className="md:hidden absolute inset-x-0 top-16 z-50 h-[calc(100vh-64px)] border-b border-gray-200 bg-white/95 backdrop-blur-xl shadow-2xl">
            {sidebarContent(false)}
          </div>
        )}

        {/* Main Content Area */}
        <main className="flex-1 overflow-y-auto bg-gray-50 p-6 md:p-8 relative">
          <div className="relative max-w-7xl mx-auto">
            {children}
          </div>
        </main>
      </div>
    </div>
  );
}
