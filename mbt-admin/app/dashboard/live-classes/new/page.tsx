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
  const [sectionId, setSectionId] = useState('');
  const [sections, setSections] = useState<{ id: string; title: string }[]>([]);
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [startTime, setStartTime] = useState('');
  const [duration, setDuration] = useState('60');

  useEffect(() => {
    if (!courseId) {
      setSections([]);
      setSectionId('');
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
        section_id: sectionId || undefined,
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
          className="inline-flex items-center gap-2 text-xs font-semibold text-gray-500 hover:text-gray-900 transition-colors"
        >
          <ArrowLeft className="h-4 w-4" />
          Back to Live Classes
        </Link>
        <h1 className="text-3xl font-extrabold text-gray-900 tracking-tight mt-2">Create Live Session</h1>
        <p className="text-gray-500 text-sm mt-1">Schedule a new Zoom meeting for a course.</p>
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
                placeholder="e.g. Week 1: Introduction to Circuits"
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                className="w-full rounded-lg border border-gray-200 bg-white py-3 px-4 text-sm text-gray-900 placeholder-gray-400 outline-none focus:border-blue-500 transition"
              />
            </div>

            <div className="space-y-1.5">
              <label className="text-xs font-semibold uppercase tracking-wider text-gray-500">Description</label>
              <textarea
                rows={3}
                placeholder="Optional session description..."
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
                  placeholder="60"
                  value={duration}
                  onChange={(e) => setDuration(e.target.value)}
                  className="w-full rounded-lg border border-gray-200 bg-white py-3 px-4 text-sm text-gray-900 placeholder-gray-400 outline-none focus:border-blue-500 transition"
                />
              </div>
            </div>

            <div className="space-y-1.5">
              <label className="text-xs font-semibold uppercase tracking-wider text-gray-500">Initial Status</label>
              <p className="text-sm text-gray-400">Will be set to <strong>Scheduled</strong> automatically. Change later from the edit page.</p>
            </div>
          </div>
        </div>

        <div className="flex items-center gap-4 pt-2">
          <button
            type="submit"
            disabled={isLoading}
            className="flex items-center gap-2 rounded-xl bg-gradient-to-r from-blue-600 to-blue-500 px-6 py-3 text-sm font-semibold text-white transition hover:from-blue-500 hover:to-blue-400 disabled:opacity-50 cursor-pointer shadow-lg shadow-blue-500/10 active:scale-[0.98]"
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
            className="flex items-center gap-2 rounded-xl border border-gray-200 bg-white px-6 py-3 text-sm font-semibold text-gray-500 hover:text-gray-700 transition"
          >
            Cancel
          </Link>
        </div>
      </form>
    </div>
  );
}
