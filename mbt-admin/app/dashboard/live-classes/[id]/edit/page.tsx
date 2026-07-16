'use strict';
'use client';

import { useEffect, useState } from 'react';
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
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [startTime, setStartTime] = useState('');
  const [duration, setDuration] = useState('60');
  const [status, setStatus] = useState('scheduled');

  useEffect(() => {
    supabase
      .from('courses')
      .select('id, title')
      .order('title', { ascending: true })
      .then(({ data, error }) => {
        if (!error && data) setCourses(data);
      });
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
      } catch {
        toast.error('Failed to load session.');
      } finally {
        setIsLoading(false);
      }
    };

    fetchSession();
  }, [sessionId, router]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!courseId || !title || !startTime || !duration) {
      toast.error('Please fill all required fields.');
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
        status: status as any,
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
        <Loader2 className="h-8 w-8 animate-spin text-teal-500" />
      </div>
    );
  }

  return (
    <div className="space-y-8 animate-in fade-in duration-300 max-w-3xl">
      <div>
        <Link
          href="/dashboard/live-classes"
          className="inline-flex items-center gap-2 text-xs font-semibold text-zinc-400 hover:text-white transition-colors"
        >
          <ArrowLeft className="h-4 w-4" />
          Back to Live Classes
        </Link>
        <h1 className="text-3xl font-extrabold text-white tracking-tight mt-2">Edit Session</h1>
        <p className="text-zinc-400 text-sm mt-1">Update session details or change status.</p>
      </div>

      <form onSubmit={handleSubmit} className="space-y-6">
        <div className="rounded-2xl border border-zinc-800 bg-zinc-900/30 p-6 space-y-6">
          <h2 className="text-lg font-bold text-white">Session Details</h2>

          <div className="space-y-4">
            <div className="space-y-1.5">
              <label className="text-xs font-semibold uppercase tracking-wider text-zinc-400">
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

            <div className="space-y-1.5">
              <label className="text-xs font-semibold uppercase tracking-wider text-zinc-400">
                Session Title <span className="text-rose-400">*</span>
              </label>
              <input
                type="text"
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                className="w-full rounded-lg border border-zinc-800 bg-zinc-950 py-3 px-4 text-sm text-zinc-100 placeholder-zinc-600 outline-none focus:border-teal-500 transition"
              />
            </div>

            <div className="space-y-1.5">
              <label className="text-xs font-semibold uppercase tracking-wider text-zinc-400">Description</label>
              <textarea
                rows={3}
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                className="w-full rounded-lg border border-zinc-800 bg-zinc-950 py-3 px-4 text-sm text-zinc-100 placeholder-zinc-600 outline-none focus:border-teal-500 transition resize-none"
              />
            </div>

            <div className="grid gap-4 sm:grid-cols-2">
              <div className="space-y-1.5">
                <label className="text-xs font-semibold uppercase tracking-wider text-zinc-400">
                  Start Date & Time <span className="text-rose-400">*</span>
                </label>
                <input
                  type="datetime-local"
                  value={startTime}
                  onChange={(e) => setStartTime(e.target.value)}
                  className="w-full rounded-lg border border-zinc-800 bg-zinc-950 py-3 px-4 text-sm text-zinc-100 outline-none focus:border-teal-500 transition [color-scheme:dark]"
                />
              </div>

              <div className="space-y-1.5">
                <label className="text-xs font-semibold uppercase tracking-wider text-zinc-400">
                  Duration (minutes) <span className="text-rose-400">*</span>
                </label>
                <input
                  type="number"
                  min="5"
                  max="480"
                  value={duration}
                  onChange={(e) => setDuration(e.target.value)}
                  className="w-full rounded-lg border border-zinc-800 bg-zinc-950 py-3 px-4 text-sm text-zinc-100 outline-none focus:border-teal-500 transition"
                />
              </div>
            </div>

            <div className="space-y-1.5">
              <label className="text-xs font-semibold uppercase tracking-wider text-zinc-400">Status</label>
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
            className="flex items-center gap-2 rounded-xl bg-gradient-to-r from-teal-500 to-emerald-500 px-6 py-3 text-sm font-semibold text-zinc-950 transition hover:from-teal-400 hover:to-emerald-400 disabled:opacity-50 cursor-pointer shadow-lg shadow-teal-500/10 active:scale-[0.98]"
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
            className="flex items-center gap-2 rounded-xl border border-zinc-800 bg-zinc-950 px-6 py-3 text-sm font-semibold text-zinc-400 hover:text-zinc-200 transition"
          >
            Cancel
          </Link>
        </div>
      </form>
    </div>
  );
}
