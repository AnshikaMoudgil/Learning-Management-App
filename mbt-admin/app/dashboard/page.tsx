'use client';

import { useEffect, useState, useCallback } from 'react';
import { useAuth } from '@/app/lib/AuthContext';
import {
  BookOpen, UserCheck, GraduationCap, Loader2, Video, Tag,
  CreditCard, Smartphone, TrendingUp, Minus,
  AlertTriangle, Clock, XCircle, CheckCircle2,
  ChevronRight, ArrowUpRight,
} from 'lucide-react';
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer } from 'recharts';
import toast from 'react-hot-toast';
import Link from 'next/link';

interface Stats {
  totalCourses: number;
  totalLearners: number;
  totalStaff: number;
  publishedCourses: number;
  totalSessions: number;
  totalCoupons: number;
  activeCoupons: number;
  totalPayments: number;
  totalDeviceRequests: number;
  monthlyDeltas: {
    newCourses: number;
    newLearners: number;
    newSessions: number;
    newPayments: number;
  };
  dailyPayments: { date: string; count: number; amount: number }[];
  recentActivity: { type: string; desc: string; time: string; id: string }[];
  alerts: {
    pendingDeviceRequests: number;
    failedPayments: number;
    expiredCoupons: number;
  };
  needsAttention: {
    failedPaymentsThisWeek: number;
    expiringCoupons: number;
    pendingDeviceRequests: number;
  };
  topCourses: { id: string; title: string; slug: string; price: number; rating: number; reviews: number; enrollments: number }[];
}

const topRowCards = [
  { name: 'Total Courses', deltaKey: 'newCourses' as const, descKey: 'publishedCourses' as const }, 
  { name: 'Active Learners', deltaKey: 'newLearners' as const, descKey: null },
  { name: 'Admins & Staff', deltaKey: null, descKey: null },
  { name: 'Live Sessions', deltaKey: 'newSessions' as const, descKey: null },
] as const;

const bottomRowCards = [
  { name: 'Coupons', deltaKey: null },
  { name: 'Payments', deltaKey: 'newPayments' as const },
  { name: 'Device Requests', deltaKey: null },
] as const;

const cardIcons: Record<string, React.ComponentType<{ className?: string }>> = {
  'Total Courses': BookOpen,
  'Active Learners': GraduationCap,
  'Admins & Staff': UserCheck,
  'Live Sessions': Video,
  Coupons: Tag,
  Payments: CreditCard,
  'Device Requests': Smartphone,
};

function StatCard({
  card,
  value,
  delta,
  desc,
}: {
  card: (typeof topRowCards | typeof bottomRowCards)[number];
  value: number;
  delta: number;
  desc: string;
}) {
  const Icon = cardIcons[card.name];
  const name = card.name;
  const showZero = (name === 'Total Courses' || name === 'Active Learners' || name === 'Live Sessions' || name === 'Payments');

  return (
    <div className="rounded-xl border border-gray-200 bg-white p-5 shadow-sm">
      <div className="flex items-start justify-between">
        <div className="min-w-0">
          <p className="text-xs font-semibold uppercase tracking-wider text-gray-500 truncate">{name}</p>
          <div className="flex items-baseline gap-2 mt-2">
            <p className="text-3xl font-extrabold leading-none text-gray-900">{value}</p>
            {showZero && delta > 0 && (
              <span className="inline-flex items-center gap-0.5 text-xs font-semibold text-emerald-600 bg-emerald-50 px-1.5 py-0.5 rounded-full">
                <TrendingUp className="h-3 w-3" />+{delta}
              </span>
            )}
            {showZero && delta === 0 && (
              <span className="inline-flex gap-0.5 text-xs font-medium text-gray-400 items-center">
                <Minus className="h-3 w-3" />0
              </span>
            )}
          </div>
        </div>
        <div className="rounded-xl bg-blue-500 p-3 shrink-0 ml-3 shadow-sm">
          <Icon className="h-5 w-5 text-white" />
        </div>
      </div>
      <p className="text-xs mt-4 text-gray-400">{desc}</p>
    </div>
  );
}

export default function OverviewPage() {
  const { role, isAuthorized, accessToken, profile } = useAuth();
  const [stats, setStats] = useState<Stats | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  const formatTime = useCallback((t: string) => {
    const d = new Date(t);
    return d.toLocaleDateString('en-US', { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' });
  }, []);

  const hasAccess = role === 'superadmin' || role === 'admin' || (profile?.allowed_sections || []).includes('Overview');

  useEffect(() => {
    if (!isAuthorized) return;
    if (!hasAccess) {
      setIsLoading(false);
      return;
    }
    async function fetchStats() {
      try {
        const response = await fetch('/api/admin/stats', {
          headers: { Authorization: `Bearer ${accessToken}` },
        });
        const data = await response.json();
        if (!response.ok) throw new Error(data.error || 'Failed to load stats.');
        setStats(data);
      } catch (err: unknown) {
        const msg = err instanceof Error ? err.message : 'Error fetching dashboard statistics.';
        console.error('[Dashboard]', msg);
        toast.error(msg);
      } finally {
        setIsLoading(false);
      }
    }
    fetchStats();
  }, [isAuthorized, role, accessToken, hasAccess]);

  if (isLoading) {
    return (
      <div className="flex h-64 items-center justify-center">
        <div className="flex items-center gap-3">
          <Loader2 className="h-5 w-5 animate-spin text-blue-500" />
          <span className="text-sm font-medium text-gray-500">Loading metrics...</span>
        </div>
      </div>
    );
  }

  if (!hasAccess) {
    return (
      <div className="flex flex-col items-center justify-center text-center p-12 rounded-2xl border border-dashed border-gray-200 bg-gray-50">
        <h3 className="text-lg font-bold text-gray-900">Access Denied</h3>
        <p className="text-gray-400 text-sm mt-1">You do not have permission to view the Overview dashboard.</p>
      </div>
    );
  }

  if (!stats) {
    return (
      <div className="flex h-64 items-center justify-center">
        <span className="text-sm text-gray-400">Failed to load statistics.</span>
      </div>
    );
  }

  const d = stats.monthlyDeltas;

  const a = stats.alerts;
  const totalAlerts = a.pendingDeviceRequests + a.failedPayments + a.expiredCoupons;

  return (
    <div className="space-y-6 animate-in fade-in duration-300">

      {/* Page Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-extrabold text-gray-900 tracking-tight">Dashboard</h1>
          <p className="text-gray-500 text-sm mt-1">Platform overview and performance metrics.</p>
        </div>
        {totalAlerts > 0 && (
          <div className="flex items-center gap-2 rounded-xl bg-rose-50 border border-rose-200 px-4 py-2.5">
            <AlertTriangle className="h-4 w-4 text-rose-500" />
            <span className="text-sm font-semibold text-rose-600">{totalAlerts} items need attention</span>
          </div>
        )}
      </div>

      {/* Stat Cards */}
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {topRowCards.map((card) => {
          const deltaKey = card.deltaKey;
          const delta = deltaKey ? d[deltaKey] : 0;
          const desc = card.descKey
            ? `${stats[card.descKey]} Published`
            : card.name === 'Active Learners'
              ? 'Registered student profiles'
              : card.name === 'Admins & Staff'
                ? 'Admins, Superadmins & Instructors'
                : 'Scheduled & completed classes';
          return <StatCard key={card.name} card={card} value={stats[card.name === 'Total Courses' ? 'totalCourses' : card.name === 'Active Learners' ? 'totalLearners' : card.name === 'Admins & Staff' ? 'totalStaff' : 'totalSessions']} delta={delta} desc={desc} />;
        })}
      </div>
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {bottomRowCards.map((card) => {
          const value = card.name === 'Coupons' ? stats.totalCoupons : card.name === 'Payments' ? stats.totalPayments : stats.totalDeviceRequests;
          const delta = card.deltaKey ? d[card.deltaKey] : 0;
          const desc = card.name === 'Coupons' ? `${stats.activeCoupons} Active` : card.name === 'Payments' ? 'All transactions' : 'Pending & resolved';
          return <StatCard key={card.name} card={card} value={value} delta={delta} desc={desc} />;
        })}
      </div>



      {/* Chart + Needs Attention */}
      <div className="grid gap-6 lg:grid-cols-3">
        <div className="lg:col-span-2 rounded-xl border border-gray-200 bg-white p-5 shadow-sm">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-base font-bold text-gray-900">Daily Payments (30 days)</h2>
            <span className="text-xs text-gray-400">Count</span>
          </div>
          <div className="h-64">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={stats.dailyPayments} margin={{ top: 4, right: 4, bottom: 0, left: -16 }}>
                <XAxis
                  dataKey="date"
                  tick={{ fontSize: 10, fill: '#94a3b8' }}
                  tickFormatter={(v: string) => v.slice(5)}
                  axisLine={false}
                  tickLine={false}
                />
                <YAxis tick={{ fontSize: 10, fill: '#94a3b8' }} axisLine={false} tickLine={false} allowDecimals={false} />
                <Tooltip
                  contentStyle={{ borderRadius: 8, border: '1px solid #e2e8f0', fontSize: 12 }}
                  labelFormatter={(v: any) => new Date(v).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}
                  formatter={(value: any) => [value, 'Payments']}
                />
                <Bar dataKey="count" fill="#3b82f6" radius={[3, 3, 0, 0]} maxBarSize={24} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Needs Attention */}
        <div className="rounded-xl border border-gray-200 bg-white p-5 shadow-sm">
          <div className="flex items-center gap-2 mb-4">
            <AlertTriangle className="h-4 w-4 text-gray-500" />
            <h2 className="text-base font-bold text-gray-900">Needs Attention</h2>
          </div>
          <div className="space-y-4">
            <div className="flex items-center gap-3">
              <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-rose-50 shrink-0">
                <XCircle className="h-4 w-4 text-rose-500" />
              </div>
              <div>
                <p className="text-sm font-semibold text-gray-900">{stats.needsAttention.failedPaymentsThisWeek} payment{stats.needsAttention.failedPaymentsThisWeek === 1 ? '' : 's'} failed this week</p>
                <p className="text-xs text-gray-400">Requires investigation</p>
              </div>
            </div>
            <div className="flex items-center gap-3">
              <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-amber-50 shrink-0">
                <Clock className="h-4 w-4 text-amber-500" />
              </div>
              <div>
                <p className="text-sm font-semibold text-gray-900">{stats.needsAttention.expiringCoupons} coupon{stats.needsAttention.expiringCoupons === 1 ? ' expires' : 's expire'} in 3 days</p>
                <p className="text-xs text-gray-400">About to expire</p>
              </div>
            </div>
            <div className="flex items-center gap-3">
              <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-blue-50 shrink-0">
                <Smartphone className="h-4 w-4 text-blue-500" />
              </div>
              <div>
                {stats.needsAttention.pendingDeviceRequests > 0 ? (
                  <>
                    <p className="text-sm font-semibold text-gray-900">{stats.needsAttention.pendingDeviceRequests} pending device request{stats.needsAttention.pendingDeviceRequests === 1 ? '' : 's'}</p>
                    <p className="text-xs text-gray-400">Requires your review</p>
                  </>
                ) : (
                  <>
                    <p className="text-sm font-semibold text-gray-900">No pending device requests</p>
                    <p className="text-xs text-gray-400">All clear</p>
                  </>
                )}
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Top Courses + Recent Activity */}
      <div className="grid gap-6 lg:grid-cols-2">
        <div className="rounded-xl border border-gray-200 bg-white p-5 shadow-sm">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-base font-bold text-gray-900">Top Courses</h2>
            <Link href="/dashboard/courses" className="text-xs font-semibold text-blue-600 hover:text-blue-700">View all</Link>
          </div>
          {stats.topCourses.length === 0 ? (
            <p className="text-sm text-gray-400">No courses published yet.</p>
          ) : (
            <div className="space-y-3">
              {stats.topCourses.map((course, i) => (
                <Link
                  key={course.id}
                  href={`/dashboard/courses/${course.id}/edit`}
                  className="flex items-center gap-3 group"
                >
                  <span className="flex h-7 w-7 items-center justify-center rounded-md bg-gray-100 text-xs font-bold text-gray-500 shrink-0">
                    {i + 1}
                  </span>
                  <div className="min-w-0 flex-1">
                    <p className="text-sm font-semibold text-gray-900 truncate group-hover:text-blue-600 transition">{course.title}</p>
                    <p className="text-xs text-gray-400 mt-0.5">{course.enrollments} enrolled</p>
                  </div>
                  <ArrowUpRight className="h-4 w-4 text-gray-300 group-hover:text-blue-500 shrink-0 transition" />
                </Link>
              ))}
            </div>
          )}
        </div>

        {/* Recent Activity */}
        <div className="rounded-xl border border-gray-200 bg-white p-5 shadow-sm">
          <h2 className="text-base font-bold text-gray-900 mb-4">Recent Activity</h2>
          {stats.recentActivity.length === 0 ? (
            <p className="text-sm text-gray-400">No recent activity.</p>
          ) : (
            <div className="space-y-1">
              {stats.recentActivity.map((item, i) => (
                <div key={`${item.type}-${item.id}-${i}`} className="flex items-center gap-3 rounded-lg px-3 py-2 hover:bg-gray-50 transition h-10">
                  <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-blue-50">
                    <div className="h-4 w-4 text-blue-500">
                      {item.type === 'signup' ? <UserCheck className="h-full w-full" /> :
                       item.type === 'payment' ? <span className="text-sm font-bold">₹</span> :
                       item.type === 'course' ? <BookOpen className="h-full w-full" /> :
                       <CheckCircle2 className="h-full w-full" />}
                    </div>
                  </div>
                  <div className="min-w-0 flex-1 flex items-center justify-between gap-2">
                    <p className="text-sm text-gray-700 truncate">{item.desc}</p>
                    <p className="text-xs text-gray-400 shrink-0">{formatTime(item.time)}</p>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>

      {/* Quick Actions */}
      <div className="rounded-xl border border-gray-200 bg-white p-5 shadow-sm">
        <h2 className="text-base font-bold text-gray-900 mb-4">Quick Actions</h2>
        <div className="grid gap-3 sm:grid-cols-3">
          {[
            { label: 'Create New Course', sub: 'Add course modules and structure', href: '/dashboard/courses/new', icon: BookOpen },
            { label: 'Staff Directory', sub: 'Manage roles and staff accounts', href: '/dashboard/admins', icon: UserCheck },
            { label: 'Manage Coupons', sub: 'Create discount codes', href: '/dashboard/coupons', icon: Tag },
            { label: 'Live Classes', sub: 'Schedule and manage sessions', href: '/dashboard/live-classes', icon: Video },
            { label: 'Payments & Orders', sub: 'View transactions', href: '/dashboard/payments', icon: CreditCard },
            { label: 'User Directory', sub: 'View learner accounts', href: '/dashboard/users', icon: GraduationCap },
          ].map((action) => {
            const Icon = action.icon;
            return (
              <Link
                key={action.label}
                href={action.href}
                className="group flex items-center gap-4 rounded-lg border border-gray-200 px-4 py-3 hover:border-blue-200 hover:bg-blue-50 transition"
              >
                <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-blue-50 shrink-0">
                  <Icon className="h-5 w-5 text-blue-500" />
                </div>
                <div className="min-w-0 flex-1">
                  <span className="text-sm font-semibold text-gray-900 group-hover:text-blue-700">{action.label}</span>
                  <p className="text-xs text-gray-400 mt-0.5">{action.sub}</p>
                </div>
                <ChevronRight className="h-4 w-4 text-gray-300 group-hover:text-blue-500 shrink-0" />
              </Link>
            );
          })}
        </div>
      </div>
    </div>
  );
}
