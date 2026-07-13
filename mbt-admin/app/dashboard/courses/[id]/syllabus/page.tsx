'use strict';
'use client';

import React, { useEffect, useState, useCallback } from 'react';
import { useParams, useRouter } from 'next/navigation';
import { supabase } from '@/app/lib/supabaseClient';
import toast from 'react-hot-toast';
import ConfirmDialog from '@/components/ConfirmDialog';
import {
  ArrowLeft,
  Plus,
  Loader2,
  ChevronDown,
  ChevronRight,
  GripVertical,
  Pencil,
  Trash2,
  Check,
  X,
  BookOpen,
  PlayCircle,
  Eye,
} from 'lucide-react';
import Link from 'next/link';

interface Lesson {
  id: string;
  section_id: string;
  course_id: string;
  title: string;
  description: string | null;
  video_url: string | null;
  video_duration: string | null;
  is_free_preview: boolean;
  sort_order: number;
}

interface Section {
  id: string;
  course_id: string;
  title: string;
  description: string | null;
  sort_order: number;
  lessons: Lesson[];
}

function InlineInput({
  value,
  onChange,
  placeholder,
  className = '',
}: {
  value: string;
  onChange: (v: string) => void;
  placeholder?: string;
  className?: string;
}) {
  return (
    <input
      type="text"
      value={value}
      onChange={(e) => onChange(e.target.value)}
      placeholder={placeholder}
      className={`w-full rounded-lg border border-zinc-700 bg-zinc-950 px-3 py-2 text-sm text-zinc-100 placeholder-zinc-600 outline-none focus:border-teal-500 transition ${className}`}
    />
  );
}

function LessonRow({
  lesson,
  onUpdate,
  onDelete,
}: {
  lesson: Lesson;
  onUpdate: (updated: Lesson) => void;
  onDelete: (id: string) => void;
}) {
  const [isEditing, setIsEditing] = useState(false);
  const [draft, setDraft] = useState<Lesson>({ ...lesson, is_free_preview: Boolean(lesson.is_free_preview) });
  const [isSaving, setIsSaving] = useState(false);
  const [confirmDelete, setConfirmDelete] = useState(false);

  const handleSave = async () => {
    if (!draft.title.trim()) { toast.error('Lesson title is required.'); return; }
    setIsSaving(true);
    try {
      const { error } = await supabase
        .from('course_lessons')
        .update({
          title: draft.title.trim(),
          description: draft.description?.trim() || null,
          video_url: draft.video_url?.trim() || null,
          video_duration: draft.video_duration?.trim() || null,
          is_free_preview: Boolean(draft.is_free_preview),
        })
        .eq('id', lesson.id);
      if (error) throw error;
      onUpdate({ ...draft, title: draft.title.trim() });
      setIsEditing(false);
      toast.success('Lesson updated.');
    } catch (err: unknown) {
      toast.error(err instanceof Error ? err.message : 'Failed to update lesson.');
    } finally {
      setIsSaving(false);
    }
  };

  const handleDelete = async () => {
    try {
      const { error } = await supabase.from('course_lessons').delete().eq('id', lesson.id);
      if (error) throw error;
      onDelete(lesson.id);
      toast.success('Lesson deleted.');
    } catch (err: unknown) {
      toast.error(err instanceof Error ? err.message : 'Failed to delete lesson.');
    }
  };

  if (isEditing) {
    return (
      <div className="rounded-xl border border-teal-500/30 bg-zinc-900/60 p-4 space-y-3">
        <InlineInput value={draft.title} onChange={(v) => setDraft({ ...draft, title: v })} placeholder="Lesson title *" />
        <InlineInput value={draft.description || ''} onChange={(v) => setDraft({ ...draft, description: v })} placeholder="Short description (optional)" />
        <div className="grid grid-cols-2 gap-3">
          <InlineInput value={draft.video_url || ''} onChange={(v) => setDraft({ ...draft, video_url: v })} placeholder="Video URL (optional)" />
          <InlineInput value={draft.video_duration || ''} onChange={(v) => setDraft({ ...draft, video_duration: v })} placeholder="Duration e.g. 12:30" />
        </div>
        <label className="flex items-center gap-2 cursor-pointer select-none text-sm text-zinc-300">
          <input
            type="checkbox"
            checked={draft.is_free_preview}
            onChange={(e) => setDraft({ ...draft, is_free_preview: e.target.checked })}
            className="h-4 w-4 rounded border-zinc-700 bg-zinc-950 text-teal-500 focus:ring-teal-500/20 focus:ring-offset-0 focus:ring-2"
          />
          Free Preview
        </label>
        <div className="flex gap-2 justify-end">
          <button type="button" onClick={() => { setDraft(lesson); setIsEditing(false); }} className="flex items-center gap-1.5 rounded-lg border border-zinc-700 px-3 py-1.5 text-xs font-semibold text-zinc-400 hover:text-zinc-200 transition cursor-pointer">
            <X className="h-3.5 w-3.5" /> Cancel
          </button>
          <button type="button" onClick={handleSave} disabled={isSaving} className="flex items-center gap-1.5 rounded-lg bg-teal-600 px-3 py-1.5 text-xs font-semibold text-white hover:bg-teal-500 transition disabled:opacity-50 cursor-pointer">
            {isSaving ? <Loader2 className="h-3.5 w-3.5 animate-spin" /> : <Check className="h-3.5 w-3.5" />} Save
          </button>
        </div>
      </div>
    );
  }

  return (
    <>
      <div className="group flex items-center gap-3 rounded-xl border border-zinc-800 bg-zinc-900/20 px-4 py-3 hover:border-zinc-700 transition-all">
        <GripVertical className="h-4 w-4 text-zinc-700 shrink-0" />
        <PlayCircle className="h-4 w-4 text-teal-500/70 shrink-0" />
        <div className="flex-1 min-w-0">
          <span className="text-sm font-medium text-zinc-200 truncate block">{lesson.title}</span>
          {lesson.video_duration && <span className="text-xs text-zinc-500">{lesson.video_duration}</span>}
        </div>
        {lesson.is_free_preview && (
          <span className="flex items-center gap-1 text-[10px] font-bold uppercase tracking-wider text-emerald-400 border border-emerald-500/20 bg-emerald-500/10 px-2 py-0.5 rounded-full">
            <Eye className="h-3 w-3" /> Free
          </span>
        )}
        <div className="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
          <button type="button" onClick={() => setIsEditing(true)} className="rounded-lg p-1.5 text-zinc-400 hover:text-teal-400 hover:bg-zinc-800 transition cursor-pointer">
            <Pencil className="h-3.5 w-3.5" />
          </button>
          <button type="button" onClick={() => setConfirmDelete(true)} className="rounded-lg p-1.5 text-zinc-400 hover:text-rose-400 hover:bg-zinc-800 transition cursor-pointer">
            <Trash2 className="h-3.5 w-3.5" />
          </button>
        </div>
      </div>
      <ConfirmDialog
        isOpen={confirmDelete}
        title="Delete Lesson"
        message={`Delete "${lesson.title}"? This cannot be undone.`}
        confirmLabel="Delete"
        variant="danger"
        onConfirm={handleDelete}
        onCancel={() => setConfirmDelete(false)}
      />
    </>
  );
}

function AddLessonForm({
  sectionId,
  courseId,
  nextOrder,
  onAdded,
  onCancel,
}: {
  sectionId: string;
  courseId: string;
  nextOrder: number;
  onAdded: (lesson: Lesson) => void;
  onCancel: () => void;
}) {
  const [title, setTitle] = useState('');
  const [videoUrl, setVideoUrl] = useState('');
  const [videoDuration, setVideoDuration] = useState('');
  const [description, setDescription] = useState('');
  const [isFreePreview, setIsFreePreview] = useState(false);
  const [isSaving, setIsSaving] = useState(false);

  const handleAdd = async () => {
    if (!title.trim()) { toast.error('Lesson title is required.'); return; }
    setIsSaving(true);
    try {
      const { data, error } = await supabase
        .from('course_lessons')
        .insert({
          section_id: sectionId,
          course_id: courseId,
          title: title.trim(),
          description: description.trim() || null,
          video_url: videoUrl.trim() || null,
          video_duration: videoDuration.trim() || null,
          is_free_preview: Boolean(isFreePreview),
          sort_order: nextOrder,
        })
        .select()
        .single();
      if (error) throw error;
      onAdded(data as Lesson);
      toast.success('Lesson added.');
    } catch (err: unknown) {
      toast.error(err instanceof Error ? err.message : 'Failed to add lesson.');
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <div className="rounded-xl border border-teal-500/30 bg-teal-500/5 p-4 space-y-3">
      <InlineInput value={title} onChange={setTitle} placeholder="Lesson title *" />
      <InlineInput value={description} onChange={setDescription} placeholder="Short description (optional)" />
      <div className="grid grid-cols-2 gap-3">
        <InlineInput value={videoUrl} onChange={setVideoUrl} placeholder="Video URL (optional)" />
        <InlineInput value={videoDuration} onChange={setVideoDuration} placeholder="Duration e.g. 12:30" />
      </div>
      <label className="flex items-center gap-2 cursor-pointer select-none text-sm text-zinc-300">
        <input type="checkbox" checked={isFreePreview} onChange={(e) => setIsFreePreview(e.target.checked)} className="h-4 w-4 rounded border-zinc-700 bg-zinc-950 text-teal-500 focus:ring-teal-500/20 focus:ring-offset-0 focus:ring-2" />
        Free Preview
      </label>
      <div className="flex gap-2 justify-end">
        <button type="button" onClick={onCancel} className="flex items-center gap-1.5 rounded-lg border border-zinc-700 px-3 py-1.5 text-xs font-semibold text-zinc-400 hover:text-zinc-200 transition cursor-pointer">
          <X className="h-3.5 w-3.5" /> Cancel
        </button>
        <button type="button" onClick={handleAdd} disabled={isSaving} className="flex items-center gap-1.5 rounded-lg bg-teal-600 px-3 py-1.5 text-xs font-semibold text-white hover:bg-teal-500 transition disabled:opacity-50 cursor-pointer">
          {isSaving ? <Loader2 className="h-3.5 w-3.5 animate-spin" /> : <Plus className="h-3.5 w-3.5" />} Add Lesson
        </button>
      </div>
    </div>
  );
}

function SectionCard({
  section,
  courseId,
  onUpdate,
  onDelete,
}: {
  section: Section;
  courseId: string;
  onUpdate: (updated: Section) => void;
  onDelete: (id: string) => void;
}) {
  const [isExpanded, setIsExpanded] = useState(true);
  const [isEditingTitle, setIsEditingTitle] = useState(false);
  const [titleDraft, setTitleDraft] = useState(section.title);
  const [descDraft, setDescDraft] = useState(section.description || '');
  const [isSavingTitle, setIsSavingTitle] = useState(false);
  const [isAddingLesson, setIsAddingLesson] = useState(false);
  const [confirmDelete, setConfirmDelete] = useState(false);

  const handleSaveTitle = async () => {
    if (!titleDraft.trim()) { toast.error('Section title is required.'); return; }
    setIsSavingTitle(true);
    try {
      const { error } = await supabase.from('course_sections').update({ title: titleDraft.trim(), description: descDraft.trim() || null }).eq('id', section.id);
      if (error) throw error;
      onUpdate({ ...section, title: titleDraft.trim(), description: descDraft.trim() || null });
      setIsEditingTitle(false);
      toast.success('Section updated.');
    } catch (err: unknown) {
      toast.error(err instanceof Error ? err.message : 'Failed to update section.');
    } finally {
      setIsSavingTitle(false);
    }
  };

  const handleDeleteSection = async () => {
    try {
      const { error } = await supabase.from('course_sections').delete().eq('id', section.id);
      if (error) throw error;
      onDelete(section.id);
      toast.success('Section deleted.');
    } catch (err: unknown) {
      toast.error(err instanceof Error ? err.message : 'Failed to delete section.');
    }
  };

  const handleLessonAdded = (lesson: Lesson) => {
    onUpdate({ ...section, lessons: [...section.lessons, lesson] });
    setIsAddingLesson(false);
  };

  const handleLessonUpdated = (updated: Lesson) => {
    onUpdate({ ...section, lessons: section.lessons.map((l) => (l.id === updated.id ? updated : l)) });
  };

  const handleLessonDeleted = (id: string) => {
    onUpdate({ ...section, lessons: section.lessons.filter((l) => l.id !== id) });
  };

  return (
    <>
      <div className="rounded-2xl border border-zinc-800 bg-zinc-900/30 overflow-hidden">
        <div className="flex items-center gap-3 px-5 py-4 bg-zinc-900/50 border-b border-zinc-800">
          <GripVertical className="h-5 w-5 text-zinc-700 shrink-0" />
          <button type="button" onClick={() => setIsExpanded(!isExpanded)} className="text-zinc-500 hover:text-zinc-300 transition cursor-pointer">
            {isExpanded ? <ChevronDown className="h-4 w-4" /> : <ChevronRight className="h-4 w-4" />}
          </button>
          {isEditingTitle ? (
            <div className="flex-1 space-y-2">
              <InlineInput value={titleDraft} onChange={setTitleDraft} placeholder="Section title *" />
              <InlineInput value={descDraft} onChange={setDescDraft} placeholder="Section description (optional)" />
            </div>
          ) : (
            <div className="flex-1 min-w-0">
              <h3 className="font-semibold text-white truncate">{section.title}</h3>
              {section.description && <p className="text-xs text-zinc-500 truncate mt-0.5">{section.description}</p>}
            </div>
          )}
          <span className="text-xs text-zinc-500 whitespace-nowrap">{section.lessons.length} lesson{section.lessons.length !== 1 ? 's' : ''}</span>
          {isEditingTitle ? (
            <div className="flex gap-2 shrink-0">
              <button type="button" onClick={() => { setTitleDraft(section.title); setDescDraft(section.description || ''); setIsEditingTitle(false); }} className="rounded-lg p-1.5 text-zinc-400 hover:text-zinc-200 hover:bg-zinc-800 transition cursor-pointer">
                <X className="h-4 w-4" />
              </button>
              <button type="button" onClick={handleSaveTitle} disabled={isSavingTitle} className="rounded-lg p-1.5 text-teal-400 hover:text-teal-300 hover:bg-zinc-800 transition cursor-pointer">
                {isSavingTitle ? <Loader2 className="h-4 w-4 animate-spin" /> : <Check className="h-4 w-4" />}
              </button>
            </div>
          ) : (
            <div className="flex gap-1 shrink-0">
              <button type="button" onClick={() => setIsEditingTitle(true)} className="rounded-lg p-1.5 text-zinc-500 hover:text-teal-400 hover:bg-zinc-800 transition cursor-pointer">
                <Pencil className="h-3.5 w-3.5" />
              </button>
              <button type="button" onClick={() => setConfirmDelete(true)} className="rounded-lg p-1.5 text-zinc-500 hover:text-rose-400 hover:bg-zinc-800 transition cursor-pointer">
                <Trash2 className="h-3.5 w-3.5" />
              </button>
            </div>
          )}
        </div>
        {isExpanded && (
          <div className="p-4 space-y-2">
            {section.lessons.length === 0 && !isAddingLesson && (
              <div className="text-center py-6 text-zinc-600 text-sm">No lessons yet — add one below.</div>
            )}
            {section.lessons.slice().sort((a, b) => a.sort_order - b.sort_order).map((lesson) => (
              <LessonRow key={lesson.id} lesson={lesson} onUpdate={handleLessonUpdated} onDelete={handleLessonDeleted} />
            ))}
            {isAddingLesson ? (
              <AddLessonForm sectionId={section.id} courseId={courseId} nextOrder={section.lessons.length} onAdded={handleLessonAdded} onCancel={() => setIsAddingLesson(false)} />
            ) : (
              <button type="button" onClick={() => setIsAddingLesson(true)} className="flex w-full items-center justify-center gap-1.5 rounded-xl border border-dashed border-zinc-700 py-2.5 text-xs font-semibold text-zinc-500 hover:border-teal-500/40 hover:text-teal-400 hover:bg-teal-500/5 transition cursor-pointer">
                <Plus className="h-3.5 w-3.5" /> Add Lesson
              </button>
            )}
          </div>
        )}
      </div>
      <ConfirmDialog
        isOpen={confirmDelete}
        title="Delete Section"
        message={`Delete "${section.title}" and all its lessons? This cannot be undone.`}
        confirmLabel="Delete"
        variant="danger"
        onConfirm={handleDeleteSection}
        onCancel={() => setConfirmDelete(false)}
      />
    </>
  );
}

export default function SyllabusPage() {
  const params = useParams();
  const router = useRouter();
  const courseId = params?.id as string;

  const [courseTitle, setCourseTitle] = useState('');
  const [sections, setSections] = useState<Section[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isAddingSection, setIsAddingSection] = useState(false);
  const [newSectionTitle, setNewSectionTitle] = useState('');
  const [newSectionDesc, setNewSectionDesc] = useState('');
  const [isSavingSection, setIsSavingSection] = useState(false);

  const fetchSyllabus = useCallback(async () => {
    try {
      setIsLoading(true);
      const { data: courseData, error: courseError } = await supabase.from('courses').select('title').eq('id', courseId).maybeSingle();
      if (courseError) throw courseError;
      if (!courseData) { toast.error('Course not found.'); router.push('/dashboard/courses'); return; }
      setCourseTitle(courseData.title);

      const { data: sectionsData, error: sectionsError } = await supabase.from('course_sections').select('*').eq('course_id', courseId).order('sort_order', { ascending: true });
      if (sectionsError) throw sectionsError;

      const { data: lessonsData, error: lessonsError } = await supabase.from('course_lessons').select('*').eq('course_id', courseId).order('sort_order', { ascending: true });
      if (lessonsError) throw lessonsError;

      const sectionsWithLessons: Section[] = (sectionsData || []).map((s) => ({
        ...s,
        lessons: (lessonsData || []).filter((l) => l.section_id === s.id),
      }));
      setSections(sectionsWithLessons);
    } catch {
      toast.error('Failed to load syllabus.');
    } finally {
      setIsLoading(false);
    }
  }, [courseId, router]);

  useEffect(() => {
    if (courseId) fetchSyllabus();
  }, [courseId, fetchSyllabus]);

  const handleAddSection = async () => {
    if (!newSectionTitle.trim()) { toast.error('Section title is required.'); return; }
    setIsSavingSection(true);
    try {
      const { data, error } = await supabase.from('course_sections').insert({
        course_id: courseId,
        title: newSectionTitle.trim(),
        description: newSectionDesc.trim() || null,
        sort_order: sections.length,
      }).select().single();
      if (error) throw error;
      setSections((prev) => [...prev, { ...data, lessons: [] } as Section]);
      setNewSectionTitle('');
      setNewSectionDesc('');
      setIsAddingSection(false);
      toast.success('Section added.');
    } catch (err: unknown) {
      toast.error(err instanceof Error ? err.message : 'Failed to add section.');
    } finally {
      setIsSavingSection(false);
    }
  };

  const handleSectionUpdated = (updated: Section) => {
    setSections((prev) => prev.map((s) => (s.id === updated.id ? updated : s)));
  };

  const handleSectionDeleted = (id: string) => {
    setSections((prev) => prev.filter((s) => s.id !== id));
  };

  const totalLessons = sections.reduce((acc, s) => acc + s.lessons.length, 0);

  if (isLoading) {
    return (
      <div className="flex h-64 items-center justify-center">
        <Loader2 className="h-8 w-8 animate-spin text-teal-500" />
      </div>
    );
  }

  return (
    <div className="space-y-8 animate-in fade-in duration-300">
      <div>
        <Link href="/dashboard/courses" className="inline-flex items-center gap-2 text-xs font-semibold text-zinc-400 hover:text-white transition-colors">
          <ArrowLeft className="h-4 w-4" /> Back to Courses
        </Link>
        <div className="flex flex-col sm:flex-row sm:items-end sm:justify-between gap-3 mt-2">
          <div>
            <h1 className="text-3xl font-extrabold text-white tracking-tight">Syllabus</h1>
            <p className="text-zinc-400 text-sm mt-1">
              <span className="text-teal-400 font-semibold">{courseTitle}</span>
              {' '}— {sections.length} section{sections.length !== 1 ? 's' : ''}, {totalLessons} lesson{totalLessons !== 1 ? 's' : ''}
            </p>
          </div>
          <Link href={`/dashboard/courses/${courseId}/edit`} className="inline-flex items-center gap-2 rounded-xl border border-zinc-800 bg-zinc-900 px-4 py-2.5 text-xs font-semibold text-zinc-300 hover:border-zinc-700 hover:text-white transition-all">
            <Pencil className="h-3.5 w-3.5" /> Edit Course Details
          </Link>
        </div>
      </div>

      <div className="space-y-4">
        {sections.length === 0 && !isAddingSection && (
          <div className="flex flex-col items-center justify-center text-center p-16 rounded-2xl border border-dashed border-zinc-800 bg-zinc-900/10">
            <BookOpen className="h-10 w-10 text-zinc-600 mb-3" />
            <h3 className="text-lg font-bold text-white">No sections yet</h3>
            <p className="text-zinc-500 text-sm mt-1">Add your first section to get started.</p>
          </div>
        )}
        {sections.slice().sort((a, b) => a.sort_order - b.sort_order).map((section) => (
          <SectionCard key={section.id} section={section} courseId={courseId} onUpdate={handleSectionUpdated} onDelete={handleSectionDeleted} />
        ))}
      </div>

      {isAddingSection ? (
        <div className="rounded-2xl border border-teal-500/30 bg-teal-500/5 p-6 space-y-3">
          <h3 className="text-sm font-bold text-white">New Section</h3>
          <InlineInput value={newSectionTitle} onChange={setNewSectionTitle} placeholder="Section title *" />
          <InlineInput value={newSectionDesc} onChange={setNewSectionDesc} placeholder="Description (optional)" />
          <div className="flex gap-2 justify-end">
            <button type="button" onClick={() => { setIsAddingSection(false); setNewSectionTitle(''); setNewSectionDesc(''); }} className="flex items-center gap-1.5 rounded-lg border border-zinc-700 px-4 py-2 text-sm font-semibold text-zinc-400 hover:text-zinc-200 transition cursor-pointer">
              <X className="h-4 w-4" /> Cancel
            </button>
            <button type="button" onClick={handleAddSection} disabled={isSavingSection} className="flex items-center gap-2 rounded-xl bg-gradient-to-r from-teal-500 to-emerald-500 px-5 py-2 text-sm font-semibold text-zinc-950 hover:from-teal-400 hover:to-emerald-400 transition disabled:opacity-50 cursor-pointer">
              {isSavingSection ? <Loader2 className="h-4 w-4 animate-spin" /> : <Plus className="h-4 w-4" />} Add Section
            </button>
          </div>
        </div>
      ) : (
        <button type="button" onClick={() => setIsAddingSection(true)} className="flex w-full items-center justify-center gap-2 rounded-2xl border border-dashed border-zinc-700 py-4 text-sm font-semibold text-zinc-500 hover:border-teal-500/40 hover:text-teal-400 hover:bg-teal-500/5 transition cursor-pointer">
          <Plus className="h-4 w-4" /> Add Section
        </button>
      )}
    </div>
  );
}