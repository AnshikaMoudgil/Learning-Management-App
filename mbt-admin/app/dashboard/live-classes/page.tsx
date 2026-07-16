'use strict';
'use client';

import { useEffect, useState } from 'react';
import { supabase } from '@/app/lib/supabaseClient';
import { apiPost, apiDelete } from '@/app/lib/api';
import toast from 'react-hot-toast';
import Link from 'next/link';
import { Plus, Search, Video, Trash2, Edit3, Play, StopCircle, Link as LinkIcon, Unlink } from 'lucide-react';
import ConfirmDialog from '@/components/ConfirmDialog';

interface Session {
  id: string;
  course_id: string;
  instructor_id: string;
  title: string;
  description: string | null;
  start_time: string;
  duration: number;
  status: string;
  courses?: { title: string }[] | null;
  profiles?: { full_name: string }[] | null;
}

const STATUS_STYLES: Record<string, string> = {
  scheduled: 'bg-blue-500/15 text-blue-400 border-blue-500/20',
  live: 'bg-green-500/15 text-green-400 border-green-500/20',
  finished: 'bg-zinc-500/15 text-zinc-400 border-zinc-500/20',
  cancelled: 'bg-rose-500/15 text-rose-400 border-rose-500/20',
  recording_processing: 'bg-amber-500/15 text-amber-400 border-amber-500/20',
  recording_ready: 'bg-teal-500/15 text-teal-400 border-teal-500/20',
  draft: 'bg-zinc-500/15 text-zinc-500 border-zinc-500/20',
};

export default function LiveClassesPage() {
  const [sessions, setSessions] = useState<Session[]>([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [isLoading, setIsLoading] = useState(true);
  const [deleteTarget, setDeleteTarget] = useState<Session | null>(null);
  const [userRole, setUserRole] = useState('');
  const [zoomConnected, setZoomConnected] = useState<boolean | null>(null);

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
      const instructorIds = [...new Set(raw.map((s) => s.instructor_id).filter(Boolean))];

      const [coursesResult, profilesResult] = await Promise.all([
        supabase.from('courses').select('id, title').in('id', courseIds),
        supabase.from('profiles').select('id, full_name').in('id', instructorIds),
      ]);

      const courseMap = new Map((coursesResult.data || []).map((c: any) => [c.id, c.title]));
      const profileMap = new Map((profilesResult.data || []).map((p: any) => [p.id, p.full_name]));

      const enriched: Session[] = raw.map((s: any) => ({
        id: s.id,
        course_id: s.course_id,
        instructor_id: s.instructor_id,
        title: s.title,
        description: s.description,
        start_time: s.start_time,
        duration: s.duration,
        status: s.status,
        courses: courseMap.has(s.course_id) ? [{ title: courseMap.get(s.course_id) }] : [],
        profiles: profileMap.has(s.instructor_id) ? [{ full_name: profileMap.get(s.instructor_id) }] : [],
      }));

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

  const filtered = sessions.filter((s) =>
    s.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
    (s.courses?.[0]?.title && s.courses[0].title.toLowerCase().includes(searchTerm.toLowerCase())),
  );

  return (
    <div className="space-y-8 animate-in fade-in duration-300">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-3xl font-extrabold text-white tracking-tight">Live Classes</h1>
          <p className="text-zinc-400 text-sm mt-1">Schedule and manage Zoom sessions for courses.</p>
        </div>
        <Link
          href="/dashboard/live-classes/new"
          className="inline-flex items-center gap-2 rounded-xl bg-gradient-to-r from-teal-500 to-emerald-500 px-5 py-3 text-sm font-semibold text-zinc-950 transition-all duration-200 hover:from-teal-400 hover:to-emerald-400 cursor-pointer shadow-lg shadow-teal-500/10 active:scale-[0.98]"
        >
          <Plus className="h-4 w-4" />
          Create Session
        </Link>
      </div>

      <div className="relative max-w-md">
        <Search className="absolute left-3 top-1/2 h-5 w-5 -translate-y-1/2 text-zinc-500" />
        <input
          type="text"
          placeholder="Search by session title or course..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          className="w-full rounded-xl border border-zinc-800 bg-zinc-900/40 py-3 pl-10 pr-4 text-sm text-zinc-100 placeholder-zinc-500 outline-none transition-all duration-200 focus:border-teal-500 focus:bg-zinc-900/50"
        />
      </div>

      {isLoading ? (
        <div className="flex h-48 items-center justify-center">
          <span className="text-sm text-zinc-500">Loading sessions...</span>
        </div>
      ) : filtered.length === 0 ? (
        <div className="flex flex-col items-center justify-center text-center p-12 rounded-2xl border border-dashed border-zinc-800 bg-zinc-900/10">
          <Video className="h-10 w-10 text-zinc-600 mb-3" />
          <h3 className="text-lg font-bold text-white">No sessions found</h3>
          <p className="text-zinc-500 text-sm mt-1">Schedule your first live class session.</p>
        </div>
      ) : (
        <div className="overflow-hidden rounded-2xl border border-zinc-800 bg-zinc-900/20">
          <table className="min-w-full divide-y divide-zinc-800">
            <thead>
              <tr className="text-xs font-semibold uppercase tracking-wider text-zinc-500">
                <th className="px-6 py-4 text-left">Session</th>
                <th className="px-6 py-4 text-left">Course</th>
                <th className="px-6 py-4 text-left">Instructor</th>
                <th className="px-6 py-4 text-left">Start Time</th>
                <th className="px-6 py-4 text-left">Duration</th>
                <th className="px-6 py-4 text-left">Status</th>
                <th className="px-6 py-4 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-zinc-800/50">
              {filtered.map((session) => (
                <tr key={session.id} className="group hover:bg-zinc-900/40 transition-colors">
                  <td className="px-6 py-4">
                    <p className="font-semibold text-white text-sm">{session.title}</p>
                    {session.description && (
                      <p className="text-xs text-zinc-500 mt-0.5 line-clamp-1">{session.description}</p>
                    )}
                  </td>
                  <td className="px-6 py-4 text-sm text-zinc-400">
                    {session.courses?.[0]?.title || '—'}
                  </td>
                  <td className="px-6 py-4 text-sm text-zinc-400">
                    {session.profiles?.[0]?.full_name || '—'}
                  </td>
                  <td className="px-6 py-4 text-sm text-zinc-300">
                    {new Date(session.start_time).toLocaleString()}
                  </td>
                  <td className="px-6 py-4 text-sm text-zinc-400">
                    {session.duration} min
                  </td>
                  <td className="px-6 py-4">
                    <span className={`inline-flex text-[10px] font-bold uppercase tracking-wider px-2.5 py-1 rounded-full border ${STATUS_STYLES[session.status] || 'text-zinc-500'}`}>
                      {session.status}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-right">
                    <div className="flex items-center justify-end gap-1.5 opacity-0 group-hover:opacity-100 transition-opacity">
                      {session.status === 'scheduled' && (
                        <button
                          onClick={() => handleStatusChange(session.id, 'live')}
                          className="rounded-lg border border-green-800/30 hover:bg-green-950/20 p-2 text-green-400 transition cursor-pointer"
                          title="Start"
                        >
                          <Play className="h-3.5 w-3.5" />
                        </button>
                      )}
                      {session.status === 'live' && (
                        <button
                          onClick={() => handleStatusChange(session.id, 'finished')}
                          className="rounded-lg border border-zinc-800 hover:bg-zinc-800 p-2 text-zinc-400 transition cursor-pointer"
                          title="End"
                        >
                          <StopCircle className="h-3.5 w-3.5" />
                        </button>
                      )}
                      {(session.status === 'scheduled' || session.status === 'draft') && (
                        <Link
                          href={`/dashboard/live-classes/${session.id}/edit`}
                          className="rounded-lg border border-zinc-800 hover:border-zinc-700 hover:bg-zinc-800 p-2 text-zinc-400 transition cursor-pointer"
                          title="Edit"
                        >
                          <Edit3 className="h-3.5 w-3.5" />
                        </Link>
                      )}
                      {session.status !== 'cancelled' && session.status !== 'finished' && (
                        <button
                          onClick={() => setDeleteTarget(session)}
                          className="rounded-lg border border-zinc-800 hover:border-rose-900/30 hover:bg-rose-950/20 p-2 text-rose-400 transition cursor-pointer"
                          title="Cancel"
                        >
                          <Trash2 className="h-3.5 w-3.5" />
                        </button>
                      )}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
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
