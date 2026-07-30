'use strict';
'use client';

import { useEffect, useState, useMemo } from 'react';
import { supabase } from '@/app/lib/supabaseClient';
import { apiPost, apiDelete } from '@/app/lib/api';
import toast from 'react-hot-toast';
import Link from 'next/link';
import { Plus, Search, Video, Trash2, Edit3, Play, StopCircle, MoreVertical } from 'lucide-react';
import ConfirmDialog from '@/components/ConfirmDialog';
import Pagination from '@/components/Pagination';
import { PAGE_SIZE } from '@/app/lib/constants';

interface Session {
  id: string;
  course_id: string;
  instructor_id: string;
  title: string;
  description: string | null;
  start_time: string;
  duration: number;
  status: string;
  created_at: string;
  courses?: { title: string; instructor_id: string | null }[] | null;
  profiles?: { full_name: string }[] | null;
  course_instructor_name?: string;
}

const STATUS_STYLES: Record<string, string> = {
  scheduled: 'bg-blue-500/15 text-blue-400 border-blue-500/20',
  live: 'bg-blue-600/15 text-blue-400 border-blue-500/25',
  finished: 'bg-zinc-500/15 text-zinc-400 border-zinc-500/20',
  cancelled: 'bg-rose-500/15 text-rose-400 border-rose-500/20',
  recording_processing: 'bg-amber-500/15 text-amber-400 border-amber-500/20',
  recording_ready: 'bg-blue-600/15 text-blue-400 border-blue-500/25',
  draft: 'bg-zinc-500/15 text-zinc-500 border-zinc-500/20',
};

export default function LiveClassesPage() {
  const [sessions, setSessions] = useState<Session[]>([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [isLoading, setIsLoading] = useState(true);
  const [deleteTarget, setDeleteTarget] = useState<Session | null>(null);
  const [userRole, setUserRole] = useState('');
  const [openMenuId, setOpenMenuId] = useState<string | null>(null);
  const [statusFilter, setStatusFilter] = useState('all');
  const [currentPage, setCurrentPage] = useState(1);

  const fetchSessions = async () => {
    try {
      setIsLoading(true);

      const { data: { session } } = await supabase.auth.getSession();
      const uid = session?.user?.id;

      let role = '';
      if (uid) {
        const { data: profile } = await supabase
          .from('profiles')
          .select('role')
          .eq('id', uid)
          .single();
        role = profile?.role || '';
        setUserRole(role);
      }

      let query = supabase
        .from('sessions')
        .select('*')
        .order('start_time', { ascending: false });

      if (role === 'instructor' && uid) {
        query = query.eq('instructor_id', uid);
      }

      const { data: sessionsData, error } = await query;

      if (error) throw error;
      if (!sessionsData?.length) {
        setSessions([]);
        return;
      }

      const raw = sessionsData as any[];

      const courseIds = [...new Set(raw.map((s) => s.course_id).filter(Boolean))];
      const creatorIds = [...new Set(raw.map((s) => s.instructor_id).filter(Boolean))];

      const [coursesResult, creatorsResult] = await Promise.all([
        supabase.from('courses').select('id, title, instructor_id').in('id', courseIds),
        supabase.from('profiles').select('id, full_name').in('id', creatorIds),
      ]);

      const courseMap = new Map((coursesResult.data || []).map((c: any) => [c.id, c]));
      const creatorMap = new Map((creatorsResult.data || []).map((p: any) => [p.id, p.full_name]));

      const courseInstructorIds = [
        ...new Set((coursesResult.data || []).map((c: any) => c.instructor_id).filter(Boolean)),
      ];
      let courseInstructorMap = new Map<string, string>();
      if (courseInstructorIds.length > 0) {
        const { data: instructors } = await supabase
          .from('profiles')
          .select('id, full_name')
          .in('id', courseInstructorIds);
        courseInstructorMap = new Map((instructors || []).map((p: any) => [p.id, p.full_name]));
      }

      const enriched: Session[] = raw.map((s: any) => {
        const course = courseMap.get(s.course_id);
        return {
          id: s.id,
          course_id: s.course_id,
          instructor_id: s.instructor_id,
          title: s.title,
          description: s.description,
          start_time: s.start_time,
          duration: s.duration,
          status: s.status,
          created_at: s.created_at,
          courses: course ? [{ title: course.title, instructor_id: course.instructor_id }] : [],
          profiles: creatorMap.has(s.instructor_id) ? [{ full_name: creatorMap.get(s.instructor_id) }] : [],
          course_instructor_name: course?.instructor_id ? courseInstructorMap.get(course.instructor_id) : undefined,
        };
      });

      setSessions(enriched);
    } catch {
      toast.error('Failed to load live sessions.');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchSessions();
  }, []);

  useEffect(() => {
    if (!openMenuId) return;
    const close = () => setOpenMenuId(null);
    document.addEventListener('click', close);
    return () => document.removeEventListener('click', close);
  }, [openMenuId]);

  const handleDelete = async () => {
    if (!deleteTarget) return;

    const loadingToast = toast.loading('Cancelling session...');
    try {
      await apiDelete(`/sessions/${deleteTarget.id}`);

      toast.dismiss(loadingToast);
      toast.success('Session cancelled.');
      setSessions(sessions.map((s) =>
        s.id === deleteTarget.id ? { ...s, status: 'cancelled' } : s,
      ));
      setDeleteTarget(null);
    } catch (err: unknown) {
      toast.dismiss(loadingToast);
      toast.error(err instanceof Error ? err.message : 'Failed to cancel session.');
    }
  };

  const handleJoin = async (id: string) => {
    try {
      const data = await apiPost(`/sessions/${id}/join`, {}) as { join_url?: string };
      if (data.join_url) {
        window.open(data.join_url, '_blank');
      } else {
        toast.error('Meeting URL not available yet.');
      }
    } catch (err: unknown) {
      toast.error(err instanceof Error ? err.message : 'Failed to join session.');
    }
  };

  const handleStatusChange = async (id: string, newStatus: string) => {
    const loadingToast = toast.loading(`Setting session to ${newStatus}...`);
    try {
      await apiPost(`/sessions/${id}/${newStatus === 'live' ? 'start' : 'end'}`, {});

      toast.dismiss(loadingToast);
      toast.success(`Session is now ${newStatus}.`);
      setSessions(sessions.map((s) => (s.id === id ? { ...s, status: newStatus } : s)));
    } catch (err: unknown) {
      toast.dismiss(loadingToast);
      toast.error(err instanceof Error ? err.message : 'Failed to update status.');
    }
  };

  const statusFilters = ['all', 'scheduled', 'live', 'finished', 'cancelled'] as const;

  const filtered = useMemo(() => {
    let list = sessions;
    if (statusFilter !== 'all') {
      list = list.filter((s) => s.status === statusFilter);
    }
    return list.filter((s) =>
      s.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
      (s.courses?.[0]?.title && s.courses[0].title.toLowerCase().includes(searchTerm.toLowerCase())),
    );
  }, [sessions, statusFilter, searchTerm]);

  const totalPages = Math.max(1, Math.ceil(filtered.length / PAGE_SIZE));
  const safePage = Math.min(currentPage, totalPages);
  const paginated = filtered.slice((safePage - 1) * PAGE_SIZE, safePage * PAGE_SIZE);

  return (
    <div className="space-y-8 animate-in fade-in duration-300">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-3xl font-extrabold text-gray-900 tracking-tight">Live Classes</h1>
          <p className="text-gray-500 text-sm mt-1">Schedule and manage Zoom sessions for courses.</p>
        </div>
        <Link
          href="/dashboard/live-classes/new"
          className="inline-flex items-center gap-2 rounded-xl bg-gradient-to-r from-blue-600 to-blue-500 px-5 py-3 text-sm font-semibold text-white transition-all duration-200 hover:from-blue-500 hover:to-blue-400 cursor-pointer shadow-lg shadow-blue-500/10 active:scale-[0.98]"
        >
          <Plus className="h-4 w-4" />
          Create Session
        </Link>
      </div>

      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div className="relative max-w-md w-full sm:w-auto sm:flex-1">
          <Search className="absolute left-3 top-1/2 h-5 w-5 -translate-y-1/2 text-gray-400" />
          <input
            type="text"
            placeholder="Search by session title or course..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full rounded-xl border border-gray-200 bg-white py-3 pl-10 pr-4 text-sm text-gray-900 placeholder-gray-400 outline-none transition-all duration-200 focus:border-blue-500 focus:bg-gray-50"
          />
        </div>
        <div className="flex items-center gap-1.5 flex-wrap sm:flex-nowrap">
          {statusFilters.map((f) => (
            <button
              key={f}
              onClick={() => { setStatusFilter(f); setCurrentPage(1); }}
              className={`text-xs font-semibold uppercase tracking-wider px-3 py-1.5 rounded-full border transition cursor-pointer ${
                statusFilter === f
                  ? 'bg-blue-600/15 text-blue-400 border-blue-500/25'
                  : 'text-gray-400 border-gray-200 hover:text-gray-600 hover:border-gray-300'
              }`}
            >
              {f === 'all' ? 'All' : f}
            </button>
          ))}
        </div>
      </div>

      {isLoading ? (
        <div className="flex h-48 items-center justify-center">
          <span className="text-sm text-gray-400">Loading sessions...</span>
        </div>
      ) : filtered.length === 0 ? (
        <div className="flex flex-col items-center justify-center text-center p-12 rounded-2xl border border-dashed border-gray-200 bg-gray-50">
          <Video className="h-10 w-10 text-gray-400 mb-3" />
          <h3 className="text-lg font-bold text-gray-900">No sessions found</h3>
          <p className="text-gray-400 text-sm mt-1">Schedule your first live class session.</p>
        </div>
      ) : (
        <div className="overflow-hidden rounded-2xl border border-gray-200 bg-white shadow-sm">
          <table className="min-w-full divide-y divide-gray-200">
            <thead>
              <tr className="text-xs font-semibold uppercase tracking-wider text-gray-400">
                <th className="px-6 py-4 text-left">Session</th>
                <th className="px-6 py-4 text-left">Course</th>
                <th className="px-6 py-4 text-left">Course Instructor</th>
                <th className="px-6 py-4 text-left">Created By</th>
                <th className="px-6 py-4 text-left">Start Time</th>
                <th className="px-6 py-4 text-left">Duration</th>
                <th className="px-6 py-4 text-left">Status</th>
                <th className="px-6 py-4 text-left">Created At</th>
                <th className="px-6 py-4 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {paginated.map((session) => (
                <tr key={session.id} className="group hover:bg-gray-50 transition-colors">
                  <td className="px-6 py-4">
                    <p className="font-semibold text-gray-900 text-sm">{session.title}</p>
                    {session.description && (
                      <p className="text-xs text-gray-400 mt-0.5 line-clamp-1">{session.description}</p>
                    )}
                  </td>
                  <td className="px-6 py-4 text-sm text-gray-500">
                    {session.courses?.[0]?.title || '�'}
                  </td>
                  <td className="px-6 py-4 text-sm text-gray-500">
                    {session.course_instructor_name || '�'}
                  </td>
                  <td className="px-6 py-4 text-sm text-gray-500">
                    {session.profiles?.[0]?.full_name || '�'}
                  </td>
                  <td className="px-6 py-4 text-sm text-gray-700">
                    {new Date(session.start_time).toLocaleString()}
                  </td>
                  <td className="px-6 py-4 text-sm text-gray-500">
                    {session.duration} min
                  </td>
                  <td className="px-6 py-4">
                    <span className={`inline-flex text-[10px] font-bold uppercase tracking-wider px-2.5 py-1 rounded-full border ${STATUS_STYLES[session.status] || 'text-zinc-500'}`}>
                      {session.status}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-xs text-gray-400">
                    {session.created_at ? new Date(session.created_at).toLocaleString() : '�'}
                  </td>
                  <td className="px-6 py-4 text-right">
                    <div className="relative flex items-center justify-end">
                      <button
                        onClick={(e) => { e.stopPropagation(); setOpenMenuId(openMenuId === session.id ? null : session.id); }}
                        className="rounded-lg border border-gray-200 hover:bg-gray-100 p-2 text-gray-500 transition cursor-pointer"
                      >
                        <MoreVertical className="h-4 w-4" />
                      </button>

                      {openMenuId === session.id && (
                        <div className="absolute right-0 top-full mt-1 z-50 w-44 rounded-xl border border-gray-200 bg-white py-1.5 shadow-lg shadow-gray-200/50" onClick={(e) => e.stopPropagation()}>
                          {session.status !== 'cancelled' && session.status !== 'finished' && (
                            <button onClick={() => { handleJoin(session.id); setOpenMenuId(null); }} className="flex w-full items-center gap-2.5 px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 hover:text-gray-900 transition cursor-pointer">
                              <Video className="h-4 w-4 text-blue-600" /> Join
                            </button>
                          )}
                          {session.status === 'scheduled' && (
                            <button onClick={() => { handleStatusChange(session.id, 'live'); setOpenMenuId(null); }} className="flex w-full items-center gap-2.5 px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 hover:text-gray-900 transition cursor-pointer">
                              <Play className="h-4 w-4 text-blue-600" /> Start
                            </button>
                          )}
                          {session.status === 'live' && (
                            <button onClick={() => { handleStatusChange(session.id, 'finished'); setOpenMenuId(null); }} className="flex w-full items-center gap-2.5 px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 hover:text-gray-900 transition cursor-pointer">
                              <StopCircle className="h-4 w-4 text-gray-500" /> End
                            </button>
                          )}
                          {(session.status === 'scheduled' || session.status === 'draft') && (
                            <Link href={`/dashboard/live-classes/${session.id}/edit`} onClick={() => setOpenMenuId(null)} className="flex w-full items-center gap-2.5 px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 hover:text-gray-900 transition">
                              <Edit3 className="h-4 w-4 text-blue-600" /> Edit
                            </Link>
                          )}
                          {session.status !== 'cancelled' && session.status !== 'finished' && (
                            <button onClick={() => { setDeleteTarget(session); setOpenMenuId(null); }} className="flex w-full items-center gap-2.5 px-4 py-2 text-sm text-rose-400 hover:bg-gray-100 transition cursor-pointer">
                              <Trash2 className="h-4 w-4" /> Cancel
                            </button>
                          )}
                        </div>
                      )}
                    </div>
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

      <ConfirmDialog
        isOpen={!!deleteTarget}
        title="Cancel Session"
        message={`Are you sure you want to cancel "${deleteTarget?.title}"? This cannot be undone.`}
        confirmLabel="Cancel Session"
        variant="danger"
        onConfirm={handleDelete}
        onCancel={() => setDeleteTarget(null)}
      />
    </div>
  );
}
