'use strict';
'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { supabase } from '@/app/lib/supabaseClient';
import { BookOpen, UserCheck, CheckCircle2, ChevronRight, GraduationCap, Loader2 } from 'lucide-react';
import toast from 'react-hot-toast';
import Link from 'next/link';

interface Stats {
  totalCourses: number;
  totalLearners: number;
  totalStaff: number;
  publishedCourses: number;
}

export default function OverviewPage() {
  const router = useRouter();
  const [stats, setStats] = useState<Stats>({
    totalCourses: 0,
    totalLearners: 0,
    totalStaff: 0,
    publishedCourses: 0,
  });
  const [isLoading, setIsLoading] = useState(true);
  const [isAuthorized, setIsAuthorized] = useState(false);

  useEffect(() => {
    async function checkAccess() {
      const { data: { session } } = await supabase.auth.getSession();
      if (!session) { router.push('/login'); return; }

      const { data: profile } = await supabase
        .from('profiles')
        .select('role')
        .eq('id', session.user.id)
        .single();

      if (!profile || !['admin', 'superadmin'].includes(profile.role)) {
        toast.error('Access denied.');
        router.push('/dashboard/courses');
        return;
      }
      setIsAuthorized(true);
    }
    checkAccess();
  }, [router]);

  useEffect(() => {
    if (!isAuthorized) return;
    async function fetchStats() {
      try {
        // Get the current session token to authenticate the API route
        const { data: { session } } = await supabase.auth.getSession();
        const token = session?.access_token;

        if (!token) {
          toast.error('Session expired. Please log in again.');
          setIsLoading(false);
          return;
        }

        const response = await fetch('/api/admin/stats', {
          headers: { Authorization: `Bearer ${token}` },
        });

        if (!response.ok) {
          const err = await response.json();
          throw new Error(err.error || 'Failed to load stats.');
        }

        const data = await response.json();
        setStats({
          totalCourses: data.totalCourses,
          totalLearners: data.totalLearners,
          totalStaff: data.totalStaff,
          publishedCourses: data.publishedCourses,
        });
      } catch {
        toast.error('Error fetching dashboard statistics.');
      } finally {
        setIsLoading(false);
      }
    }

    fetchStats();
  }, [isAuthorized]);


  const statCards = [
    {
      name: 'Total Courses',
      value: stats.totalCourses,
      desc: `${stats.publishedCourses} Published courses`,
      icon: BookOpen,
      color: 'from-teal-500 to-emerald-400',
    },
    {
      name: 'Active Learners',
      value: stats.totalLearners,
      desc: 'Registered student profiles',
      icon: GraduationCap,
      color: 'from-blue-500 to-indigo-500',
    },
    {
      name: 'Administrators & Staff',
      value: stats.totalStaff,
      desc: 'Admins, Superadmins & Instructors',
      icon: UserCheck,
      color: 'from-purple-500 to-pink-500',
    },
  ];

  if (isLoading) {
    return (
      <div className="flex h-64 items-center justify-center">
        <span className="text-sm font-medium text-zinc-400">Loading metrics...</span>
      </div>
    );
  }

  return (
    <div className="space-y-8 animate-in fade-in duration-300">
      {/* Title */}
      <div>
        <h1 className="text-3xl font-extrabold text-white tracking-tight">Overview Dashboard</h1>
        <p className="text-zinc-400 text-sm mt-1">Platform summaries and performance metrics.</p>
      </div>

      {/* Grid Stats */}
      <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
        {statCards.map((card) => {
          const Icon = card.icon;
          return (
            <div
              key={card.name}
              className="relative overflow-hidden rounded-2xl border border-zinc-800 bg-zinc-900/40 p-6 backdrop-blur-sm"
            >
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-xs font-semibold uppercase tracking-wider text-zinc-400">
                    {card.name}
                  </p>
                  <p className="text-4xl font-extrabold text-white mt-2 leading-none">
                    {card.value}
                  </p>
                </div>
                <div className={`rounded-xl bg-gradient-to-tr ${card.color} p-3 text-zinc-950 shadow-lg shadow-teal-500/5`}>
                  <Icon className="h-6 w-6" />
                </div>
              </div>
              <p className="text-xs text-zinc-500 mt-4 flex items-center gap-1 font-medium">
                <CheckCircle2 className="h-3.5 w-3.5 text-teal-500" />
                {card.desc}
              </p>
            </div>
          );
        })}
      </div>

      {/* Quick Actions Panel */}
      <div className="rounded-2xl border border-zinc-800 bg-zinc-900/20 p-6">
        <h2 className="text-lg font-bold text-white mb-4">Quick Management Actions</h2>
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          <Link
            href="/dashboard/courses/new"
            className="flex items-center justify-between p-4 rounded-xl border border-zinc-800 hover:border-teal-500/40 hover:bg-teal-500/5 transition-all duration-200 group"
          >
            <div className="space-y-1">
              <span className="text-sm font-semibold text-white group-hover:text-teal-400 transition-colors">Create New Course</span>
              <p className="text-xs text-zinc-500">Add course modules and detail structures</p>
            </div>
            <ChevronRight className="h-4 w-4 text-zinc-500 group-hover:text-teal-400 group-hover:translate-x-0.5 transition-all" />
          </Link>

          <Link
            href="/dashboard/admins"
            className="flex items-center justify-between p-4 rounded-xl border border-zinc-800 hover:border-teal-500/40 hover:bg-teal-500/5 transition-all duration-200 group"
          >
            <div className="space-y-1">
              <span className="text-sm font-semibold text-white group-hover:text-teal-400 transition-colors">Manage Administrators</span>
              <p className="text-xs text-zinc-500">Promote user roles and invite staff</p>
            </div>
            <ChevronRight className="h-4 w-4 text-zinc-500 group-hover:text-teal-400 group-hover:translate-x-0.5 transition-all" />
          </Link>

          <Link
            href="/dashboard/change-password"
            className="flex items-center justify-between p-4 rounded-xl border border-zinc-800 hover:border-teal-500/40 hover:bg-teal-500/5 transition-all duration-200 group"
          >
            <div className="space-y-1">
              <span className="text-sm font-semibold text-white group-hover:text-teal-400 transition-colors">Update Password</span>
              <p className="text-xs text-zinc-500">Change your active login credentials</p>
            </div>
            <ChevronRight className="h-4 w-4 text-zinc-500 group-hover:text-teal-400 group-hover:translate-x-0.5 transition-all" />
          </Link>
        </div>
      </div>
    </div>
  );
}
