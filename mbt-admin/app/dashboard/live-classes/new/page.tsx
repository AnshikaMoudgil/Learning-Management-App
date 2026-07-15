'use strict';
'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { supabase } from '@/app/lib/supabaseClient';
import { apiPost } from '@/app/lib/api';
import toast from 'react-hot-toast';
import { ArrowLeft, Loader2, Video } from 'lucide-react';
import Link from 'next/link';
import Select from '@/components/Select';

export default function NewSessionPage() {
  const router = useRouter();
  const [isLoading, setIsLoading] = useState(false);
  const [courses, setCourses] = useState<{ id: string; title: string }[]>([]);

  const [courseId, setCourseId] = useState('');
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [startTime, setStartTime] = useState('');
  const [duration, setDuration] = useState('60');

  useEffect(() => {
    supabase
      .from('courses')
      .select('id, title')
      .order('title', { ascending: true })
      .then(({ data, error }) => {
        if (!error && data) setCourses(data);
      });
  }, []);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!courseId || !title || !startTime || !duration) {
      toast.error('Please fill all required fields.');
      return;
    }

    setIsLoading(true);
    const savingToast = toast.loading('Creating session...');

    try {
      await apiPost('/sessions', {
        course_id: courseId,
        title,
        description: description || undefined,
        start_time: new Date(startTime).toISOString(),
        duration: parseInt(duration, 10),
      });

      toast.dismiss(savingToast);
      toast.success('Session created successfully!');
      router.push('/dashboard/live-classes');
    } catch (err: unknown) {
      toast.dismiss(savingToast);
      toast.error(err instanceof Error ? err.message : 'Failed to create session.');
    } finally {
      setIsLoading(false);
    }
  };

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
        <h1 className="text-3xl font-extrabold text-white tracking-tight mt-2">Create Live Session</h1>
        <p className="text-zinc-400 text-sm mt-1">Schedule a new Zoom meeting for a course.</p>
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
                placeholder="e.g. Week 1: Introduction to Circuits"
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                className="w-full rounded-lg border border-zinc-800 bg-zinc-950 py-3 px-4 text-sm text-zinc-100 placeholder-zinc-600 outline-none focus:border-teal-500 transition"
              />
            </div>

            <div className="space-y-1.5">
              <label className="text-xs font-semibold uppercase tracking-wider text-zinc-400">Description</label>
              <textarea
                rows={3}
                placeholder="Optional session description..."
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
                  placeholder="60"
                  value={duration}
                  onChange={(e) => setDuration(e.target.value)}
                  className="w-full rounded-lg border border-zinc-800 bg-zinc-950 py-3 px-4 text-sm text-zinc-100 placeholder-zinc-600 outline-none focus:border-teal-500 transition"
                />
              </div>
            </div>

            <div className="space-y-1.5">
              <label className="text-xs font-semibold uppercase tracking-wider text-zinc-400">Initial Status</label>
              <p className="text-sm text-zinc-500">Will be set to <strong>Scheduled</strong> automatically. Change later from the edit page.</p>
            </div>
          </div>
        </div>

        <div className="flex items-center gap-4 pt-2">
          <button
            type="submit"
            disabled={isLoading}
            className="flex items-center gap-2 rounded-xl bg-gradient-to-r from-teal-500 to-emerald-500 px-6 py-3 text-sm font-semibold text-zinc-950 transition hover:from-teal-400 hover:to-emerald-400 disabled:opacity-50 cursor-pointer shadow-lg shadow-teal-500/10 active:scale-[0.98]"
          >
            {isLoading ? (
              <>
                <Loader2 className="h-4 w-4 animate-spin" />
                Creating...
              </>
            ) : (
              <>
                <Video className="h-4 w-4" />
                Create Session
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
