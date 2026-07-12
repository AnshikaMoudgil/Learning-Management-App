'use strict';
'use client';

import { useEffect, useState } from 'react';
import { useRouter, usePathname } from 'next/navigation';
import { supabase } from '@/app/lib/supabaseClient';
import Link from 'next/link';
import toast from 'react-hot-toast';
import {
  LayoutDashboard,
  BookOpen,
  Users,
  KeyRound,
  LogOut,
  Loader2,
  Menu,
  X,
  UserCheck
} from 'lucide-react';

interface Profile {
  full_name: string;
  email: string;
  role: string;
  avatar_url: string | null;
}

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const router = useRouter();
  const pathname = usePathname();
  const [profile, setProfile] = useState<Profile | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  useEffect(() => {
    async function checkAuth() {
      try {
        // 1. Get current session
        const { data: { session }, error: sessionError } = await supabase.auth.getSession();
        
        if (sessionError || !session) {
          router.push('/login');
          return;
        }

        // 2. Fetch profile and role details
        const { data: profileData, error: profileError } = await supabase
          .from('profiles')
          .select('full_name, email, role, avatar_url, status')
          .eq('id', session.user.id)
          .maybeSingle();

        if (profileError || !profileData) {
          await supabase.auth.signOut();
          toast.error('Session invalid or profile not found.');
          router.push('/login');
          return;
        }

        // Check if suspended
        if (profileData.status !== 'ACTIVE') {
          await supabase.auth.signOut();
          toast.error('Your account is inactive or suspended.');
          router.push('/login');
          return;
        }

        // Check if role is allowed
        const allowedRoles = ['admin', 'superadmin', 'instructor'];
        if (!allowedRoles.includes(profileData.role)) {
          await supabase.auth.signOut();
          toast.error('Access Denied: Learners are not permitted.');
          router.push('/login');
          return;
        }

        setProfile({
          full_name: profileData.full_name || 'Admin User',
          email: profileData.email || session.user.email || '',
          role: profileData.role,
          avatar_url: profileData.avatar_url,
        });
      } catch (err) {
        console.error('Auth verification error:', err);
        router.push('/login');
      } finally {
        setIsLoading(false);
      }
    }

    checkAuth();
  }, [router]);

  const handleLogout = async () => {
    const loadingToast = toast.loading('Signing out...');
    try {
      await supabase.auth.signOut();
      toast.dismiss(loadingToast);
      toast.success('Signed out successfully.');
      router.push('/login');
    } catch (err: any) {
      toast.dismiss(loadingToast);
      toast.error(err.message || 'Logout failed.');
    }
  };

  const navItems = [
    { name: 'Overview', href: '/dashboard', icon: LayoutDashboard },
    { name: 'Courses', href: '/dashboard/courses', icon: BookOpen },
    { name: 'Manage Admins', href: '/dashboard/admins', icon: Users },
    { name: 'Change Password', href: '/dashboard/change-password', icon: KeyRound },
  ];

  if (isLoading) {
    return (
      <div className="flex h-screen w-screen items-center justify-center bg-zinc-950 text-zinc-100">
        <div className="flex flex-col items-center gap-4">
          <Loader2 className="h-10 w-10 animate-spin text-teal-500" />
          <p className="text-sm font-medium text-zinc-400">Loading your admin console...</p>
        </div>
      </div>
    );
  }

  const roleLabels: Record<string, string> = {
    superadmin: 'Super Admin',
    admin: 'Administrator',
    instructor: 'Instructor',
  };

  const sidebarContent = (
    <div className="flex h-full flex-col justify-between p-6">
      <div className="space-y-8">
        {/* Brand Logo */}
        <div className="flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-gradient-to-tr from-teal-500 to-emerald-400 text-zinc-950 font-bold text-lg shadow-md shadow-teal-500/10">
            M
          </div>
          <div>
            <h1 className="font-bold leading-none text-white tracking-wide">MBT Dashboard</h1>
            <span className="text-[10px] uppercase font-semibold tracking-widest text-teal-500">Admin Control</span>
          </div>
        </div>

        {/* Nav Links */}
        <nav className="space-y-1">
          {navItems.map((item) => {
            const Icon = item.icon;
            const isActive = pathname === item.href || (item.href !== '/dashboard' && pathname.startsWith(item.href));
            return (
              <Link
                key={item.name}
                href={item.href}
                onClick={() => setIsMobileMenuOpen(false)}
                className={`flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-medium transition-all duration-200 ${
                  isActive
                    ? 'bg-teal-500/10 text-teal-400 border border-teal-500/20 shadow-inner'
                    : 'text-zinc-400 hover:bg-zinc-900 hover:text-zinc-200'
                }`}
              >
                <Icon className="h-5 w-5" />
                {item.name}
              </Link>
            );
          })}
        </nav>
      </div>

      {/* Footer Profile & Logout */}
      <div className="pt-6 border-t border-zinc-800 space-y-4">
        {profile && (
          <div className="flex items-center gap-3">
            <div className="flex h-10 w-10 items-center justify-center rounded-full bg-zinc-800 text-zinc-300 font-bold border border-zinc-700">
              {profile.avatar_url ? (
                <img src={profile.avatar_url} alt={profile.full_name} className="h-full w-full rounded-full object-cover" />
              ) : (
                profile.full_name.charAt(0).toUpperCase()
              )}
            </div>
            <div className="flex-1 min-w-0">
              <p className="text-sm font-semibold text-white truncate leading-tight">{profile.full_name}</p>
              <span className="inline-flex items-center gap-1 text-[10px] font-medium text-teal-400 mt-1 uppercase tracking-wider">
                <UserCheck className="h-3 w-3" />
                {roleLabels[profile.role] || profile.role}
              </span>
            </div>
          </div>
        )}
        <button
          onClick={handleLogout}
          className="flex w-full items-center justify-center gap-2 rounded-xl border border-zinc-800 bg-zinc-950 py-3 text-sm font-semibold text-rose-400 transition-all duration-200 hover:bg-rose-950/20 hover:border-rose-900/30 cursor-pointer"
        >
          <LogOut className="h-4 w-4" />
          Log Out
        </button>
      </div>
    </div>
  );

  return (
    <div className="flex h-screen bg-zinc-950 text-zinc-100 overflow-hidden font-sans">
      {/* Desktop Sidebar */}
      <aside className="hidden md:block w-64 border-r border-zinc-900 bg-zinc-950/50 backdrop-blur-xl">
        {sidebarContent}
      </aside>

      {/* Mobile Nav Header */}
      <div className="flex flex-col flex-1 overflow-hidden">
        <header className="md:hidden flex h-16 items-center justify-between border-b border-zinc-900 bg-zinc-950 px-6">
          <div className="flex items-center gap-2">
            <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-teal-500 text-zinc-950 font-bold">
              M
            </div>
            <span className="font-bold text-sm tracking-wide">MBT Admin</span>
          </div>
          <button
            onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
            className="rounded-lg border border-zinc-800 p-2 text-zinc-400 hover:bg-zinc-900 hover:text-zinc-200"
          >
            {isMobileMenuOpen ? <X className="h-5 w-5" /> : <Menu className="h-5 w-5" />}
          </button>
        </header>

        {/* Mobile Menu Drawer */}
        {isMobileMenuOpen && (
          <div className="md:hidden absolute inset-x-0 top-16 z-50 h-[calc(100vh-64px)] border-b border-zinc-900 bg-zinc-950/95 backdrop-blur-xl shadow-2xl animate-in slide-in-from-top duration-200">
            {sidebarContent}
          </div>
        )}

        {/* Main Content Area */}
        <main className="flex-1 overflow-y-auto bg-zinc-950 p-6 md:p-8 relative">
          {/* Subtle decoration */}
          <div className="absolute top-0 right-0 h-[300px] w-[300px] rounded-full bg-teal-500/5 blur-[80px] pointer-events-none" />
          <div className="absolute bottom-0 left-0 h-[300px] w-[300px] rounded-full bg-indigo-500/5 blur-[80px] pointer-events-none" />
          <div className="relative max-w-7xl mx-auto space-y-6">
            {children}
          </div>
        </main>
      </div>
    </div>
  );
}
