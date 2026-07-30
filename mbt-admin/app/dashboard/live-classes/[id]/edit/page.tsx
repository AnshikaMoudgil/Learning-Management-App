'use strict';
'use client';

import { useEffect, useState, startTransition } from 'react';
import { useRouter, useParams } from 'next/navigation';
import { supabase } from '@/app/lib/supabaseClient';
import { apiPatch } from '@/app/lib/api';
import toast from 'react-hot-toast';
import { ArrowLeft, Loader2, Save } from 'lucide-react';
import Link from 'next/link';
import Select from '@/components/Select';

export default function EditSessionPage() {
  const router = useRouter();
  const params = useParams();
  const sessionId = params?.id as string;

  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [courses, setCourses] = useState<{ id: string; title: string }[]>([]);

  const [courseId, setCourseId] = useState('');
  const [sectionId, setSectionId] = useState('');
  const [sections, setSections] = useState<{ id: string; title: string }[]>([]);
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [startTime, setStartTime] = useState('');
  const [duration, setDuration] = useState('60');
  const [status, setStatus] = useState('scheduled');

  useEffect(() => {
    if (!courseId) {
      startTransition(() => {
        setSections([]);
        setSectionId('');
      });
      return;
    }
    (async () => {
      const { data, error } = await supabase
        .from('course_sections')
        .select('id, title')
        .eq('course_id', courseId)
        .order('sort_order', { ascending: true });
      if (!error && data) setSections(data);
    })();
  }, [courseId]);

  useEffect(() => {
    (async () => {
      const { data: { session } } = await supabase.auth.getSession();
      const uid = session?.user?.id;

      let query = supabase.from('courses').select('id, title');

      if (uid) {
        const { data: profile } = await supabase
          .from('profiles')
          .select('role')
          .eq('id', uid)
          .single();

        if (profile?.role === 'instructor') {
          query = query.or(`created_by.eq.${uid},instructor_id.eq.${uid}`);
        }
      }

      const { data, error } = await query.order('title', { ascending: true });
      if (!error && data) setCourses(data);
    })();
  }, []);

  useEffect(() => {
    if (!sessionId) return;

    const fetchSession = async () => {
      try {
        setIsLoading(true);

        const { data, error } = await supabase
          .from('sessions')
          .select('*')
          .eq('id', sessionId)
          .maybeSingle();

        if (error) throw error;
        if (!data) {
          toast.error('Session not found.');
          router.push('/dashboard/live-classes');
          return;
        }

        setCourseId(data.course_id || '');
        setTitle(data.title || '');
        setDescription(data.description || '');
        setStartTime(data.start_time
          ? new Date(data.start_time).toISOString().slice(0, 16)
          : '');
        setDuration(data.duration?.toString() || '60');
        setStatus(data.status || 'scheduled');
        setSectionId(data.section_id || '');
      } catch {
        toast.error('Failed to load session.');
      } finally {
        setIsLoading(false);
      }
    };

    fetchSession();
  }, [sessionId, router]);

  const now = new Date();
  const minDateTime = new Date(now.getTime() - now.getTimezoneOffset() * 60000)
    .toISOString()
    .slice(0, 16);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!courseId || !title || !startTime || !duration) {
      toast.error('Please fill all required fields.');
      return;
    }

    if (new Date(startTime) <= new Date()) {
      toast.error('Session start time must be in the future.');
      return;
    }

    setIsSaving(true);
    const savingToast = toast.loading('Updating session...');

    try {
      await apiPatch(`/sessions/${sessionId}`, {
        title,
        description: description || undefined,
        start_time: new Date(startTime).toISOString(),
        duration: parseInt(duration, 10),
        status: status as 'draft' | 'scheduled' | 'live' | 'finished' | 'cancelled',
        section_id: sectionId || undefined,
      });

      toast.dismiss(savingToast);
      toast.success('Session updated successfully!');
      router.push('/dashboard/live-classes');
    } catch (err: unknown) {
      toast.dismiss(savingToast);
      toast.error(err instanceof Error ? err.message : 'Failed to update session.');
    } finally {
      setIsSaving(false);
    }
  };

  if (isLoading) {
    return (
      <div className="flex h-64 items-center justify-center">
        <Loader2 className="h-8 w-8 animate-spin text-blue-500" />
      </div>
    );
  }

  return (
    <div className="space-y-8 animate-in fade-in duration-300 max-w-3xl">
      <div>
        <Link
          href="/dashboard/live-classes"
          className="inline-flex items-center gap-2 text-xs font-semibold text-gray-500 hover:text-gray-900 transition-colors"
        >
          <ArrowLeft className="h-4 w-4" />
          Back to Live Classes
        </Link>
        <h1 className="text-3xl font-extrabold text-gray-900 tracking-tight mt-2">Edit Session</h1>
        <p className="text-gray-500 text-sm mt-1">Update session details or change status.</p>
      </div>

      <form onSubmit={handleSubmit} className="space-y-6">
        <div className="rounded-2xl border border-gray-200 bg-white p-6 space-y-6">
          <h2 className="text-lg font-bold text-gray-900">Session Details</h2>

          <div className="space-y-4">
            <div className="space-y-1.5">
              <label className="text-xs font-semibold uppercase tracking-wider text-gray-500">
                Course <span className="text-rose-400">*</span>
              </label>
              <Select
                value={courseId}
                onChange={setCourseId}
                options={[
                  { value: '', label: 'Select a course' },
                  ...courses.map((c) => ({ value: c.id, label: c.title })),
                ]}
                placeholder="Select course"
              />
            </div>

            {sections.length > 0 && (
              <div className="space-y-1.5">
                <label className="text-xs font-semibold uppercase tracking-wider text-gray-500">
                  Module (Optional)
                </label>
                <Select
                  value={sectionId}
                  onChange={setSectionId}
                  options={[
                    { value: '', label: 'No specific module' },
                    ...sections.map((s) => ({ value: s.id, label: s.title })),
                  ]}
                  placeholder="Select module"
                />
              </div>
            )}

            <div className="space-y-1.5">
              <label className="text-xs font-semibold uppercase tracking-wider text-gray-500">
                Session Title <span className="text-rose-400">*</span>
              </label>
              <input
                type="text"
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                className="w-full rounded-lg border border-gray-200 bg-white py-3 px-4 text-sm text-gray-900 placeholder-gray-400 outline-none focus:border-blue-500 transition"
              />
            </div>

            <div className="space-y-1.5">
              <label className="text-xs font-semibold uppercase tracking-wider text-gray-500">Description</label>
              <textarea
                rows={3}
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                className="w-full rounded-lg border border-gray-200 bg-white py-3 px-4 text-sm text-gray-900 placeholder-gray-400 outline-none focus:border-blue-500 transition resize-none"
              />
            </div>

            <div className="grid gap-4 sm:grid-cols-2">
              <div className="space-y-1.5">
                <label className="text-xs font-semibold uppercase tracking-wider text-gray-500">
                  Start Date & Time <span className="text-rose-400">*</span>
                </label>
                <input
                  type="datetime-local"
                  value={startTime}
                  onChange={(e) => setStartTime(e.target.value)}
                  min={minDateTime}
                  className="w-full rounded-lg border border-gray-200 bg-white py-3 px-4 text-sm text-gray-900 outline-none focus:border-blue-500 transition"
                />
              </div>

              <div className="space-y-1.5">
                <label className="text-xs font-semibold uppercase tracking-wider text-gray-500">
                  Duration (minutes) <span className="text-rose-400">*</span>
                </label>
                <input
                  type="number"
                  min="5"
                  max="480"
                  value={duration}
                  onChange={(e) => setDuration(e.target.value)}
                  className="w-full rounded-lg border border-gray-200 bg-white py-3 px-4 text-sm text-gray-900 outline-none focus:border-blue-500 transition"
                />
              </div>
            </div>

            <div className="space-y-1.5">
              <label className="text-xs font-semibold uppercase tracking-wider text-gray-500">Status</label>
              <Select
                value={status}
                onChange={setStatus}
                options={[
                  { value: 'draft', label: 'Draft' },
                  { value: 'scheduled', label: 'Scheduled' },
                  { value: 'live', label: 'Live' },
                  { value: 'finished', label: 'Finished' },
                  { value: 'cancelled', label: 'Cancelled' },
                ]}
              />
            </div>
          </div>
        </div>

        <div className="flex items-center gap-4 pt-2">
          <button
            type="submit"
            disabled={isSaving}
            className="flex items-center gap-2 rounded-xl bg-gradient-to-r from-blue-600 to-blue-500 px-6 py-3 text-sm font-semibold text-white transition hover:from-blue-500 hover:to-blue-400 disabled:opacity-50 cursor-pointer shadow-lg shadow-blue-500/10 active:scale-[0.98]"
          >
            {isSaving ? (
              <>
                <Loader2 className="h-4 w-4 animate-spin" />
                Saving...
              </>
            ) : (
              <>
                <Save className="h-4 w-4" />
                Save Changes
              </>
            )}
          </button>

          <Link
            href="/dashboard/live-classes"
            className="flex items-center gap-2 rounded-xl border border-gray-200 bg-white px-6 py-3 text-sm font-semibold text-gray-500 hover:text-gray-700 transition"
          >
            Cancel
          </Link>
        </div>
      </form>
    </div>
  );
}
