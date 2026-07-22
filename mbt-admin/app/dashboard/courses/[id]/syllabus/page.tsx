'use client';

import React, { useEffect, useState, useCallback, useRef } from 'react';
import { useParams, useRouter } from 'next/navigation';
import { supabase } from '@/app/lib/supabaseClient';
import { uploadVideo, createDirectUrlAsset } from '@/app/lib/backendApi';
import toast from 'react-hot-toast';
import ConfirmDialog from '@/components/ConfirmDialog';
import {
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
  Upload,
  Clock,
  AlertCircle,
  RefreshCw,
  Video,
} from 'lucide-react';

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
  video_asset_id: string | null;
  video_status: string | null;
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
      className={`w-full rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm text-gray-900 placeholder-gray-400 outline-none focus:border-blue-500 transition ${className}`}
    />
  );
}

function StatusBadge({ status }: { status: string | null }) {
  if (!status) {
    return (
      <span className="flex items-center gap-1 text-[10px] font-bold uppercase tracking-wider text-amber-400 border border-amber-500/20 bg-amber-500/10 px-2 py-0.5 rounded-full">
        <Clock className="h-3 w-3 animate-pulse" /> PENDING
      </span>
    );
  }
  if (status === 'READY') {
    return (
      <span className="flex items-center gap-1 text-[10px] font-bold uppercase tracking-wider text-emerald-400 border border-emerald-500/20 bg-emerald-500/10 px-2 py-0.5 rounded-full">
        <Video className="h-3 w-3" /> Video
      </span>
    );
  }
  if (status === 'PENDING' || status === 'UPLOADING' || status === 'PROCESSING') {
    return (
      <span className="flex items-center gap-1 text-[10px] font-bold uppercase tracking-wider text-amber-400 border border-amber-500/20 bg-amber-500/10 px-2 py-0.5 rounded-full">
        <Clock className="h-3 w-3 animate-pulse" /> {status}
      </span>
    );
  }
  if (status === 'FAILED') {
    return (
      <span className="flex items-center gap-1 text-[10px] font-bold uppercase tracking-wider text-rose-400 border border-rose-500/20 bg-rose-500/10 px-2 py-0.5 rounded-full">
        <AlertCircle className="h-3 w-3" /> Failed
      </span>
    );
  }
  return null;
}

function VideoUploadButton({
  lessonId,
  onStatusChange,
  isUploading,
  setIsUploading,
}: {
  lessonId: string;
  onStatusChange: (assetId: string, status: string) => void;
  isUploading: boolean;
  setIsUploading: (v: boolean) => void;
}) {
  const inputRef = useRef<HTMLInputElement>(null);
  const [progress, setProgress] = useState(0);

  const handleFile = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    setProgress(0);
    setIsUploading(true);
    try {
      const result = (await uploadVideo(file, lessonId, setProgress)) as {
        asset?: { id: string; status: string };
        duplicate?: boolean;
      };
      if (result.asset) {
        onStatusChange(result.asset.id, result.asset.status);
      }
      toast.success('Video uploaded');
    } catch (err: unknown) {
      toast.error(err instanceof Error ? err.message : 'Upload failed');
    } finally {
      setIsUploading(false);
      if (inputRef.current) inputRef.current.value = '';
    }
  };

  return (
    <>
      <input
        ref={inputRef}
        type="file"
        accept="video/mp4,video/quicktime,video/webm,video/x-matroska"
        onChange={handleFile}
        className="hidden"
      />
      {isUploading ? (
        <div className="flex flex-col gap-1 w-full">
          <div className="flex items-center gap-2 text-xs text-gray-500">
            <Loader2 className="h-3.5 w-3.5 animate-spin shrink-0" />
            <span className="font-medium">
              {progress === 100 ? 'Processing and saving video...' : `Uploading ${progress}%`}
            </span>
          </div>
          <div className="h-2 w-full rounded-full bg-gray-100 overflow-hidden">
            <div
              className="h-full rounded-full bg-gradient-to-r from-blue-600 to-blue-500 transition-all duration-300"
              style={{ width: `${progress}%` }}
            />
          </div>
        </div>
      ) : (
        <button
          type="button"
          onClick={() => inputRef.current?.click()}
          className="flex items-center gap-1.5 rounded-lg border border-gray-300 px-3 py-1.5 text-xs font-semibold text-gray-500 hover:text-blue-600 hover:border-blue-500/40 transition cursor-pointer"
          >
            <Upload className="h-3.5 w-3.5" />
            Upload Video
          </button>
      )}
    </>
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
  const [isUploading, setIsUploading] = useState(false);

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

  const handleUploadStatus = (assetId: string, status: string) => {
    onUpdate({ ...lesson, video_asset_id: assetId, video_status: status });
  };

  if (isEditing) {
    return (
      <div className="rounded-xl border border-blue-500/30 bg-white p-4 space-y-3">
        <InlineInput value={draft.title} onChange={(v) => setDraft({ ...draft, title: v })} placeholder="Lesson title *" />
        <InlineInput value={draft.description || ''} onChange={(v) => setDraft({ ...draft, description: v })} placeholder="Short description (optional)" />
        <div className="grid grid-cols-2 gap-3">
          <InlineInput value={draft.video_url || ''} onChange={(v) => setDraft({ ...draft, video_url: v })} placeholder="Video URL (optional)" />
          <InlineInput value={draft.video_duration || ''} onChange={(v) => setDraft({ ...draft, video_duration: v })} placeholder="Duration e.g. 12:30" />
        </div>
        <label className="flex items-center gap-2 cursor-pointer select-none text-sm text-gray-700">
          <input
            type="checkbox"
            checked={draft.is_free_preview}
            onChange={(e) => setDraft({ ...draft, is_free_preview: e.target.checked })}
            className="h-4 w-4 rounded border-gray-300 bg-white text-blue-500 focus:ring-blue-500/20 focus:ring-offset-0 focus:ring-2"
          />
          Free Preview
        </label>
        <div className="flex flex-wrap items-center justify-between gap-2">
          <VideoUploadButton
            lessonId={lesson.id}
            onStatusChange={handleUploadStatus}
            isUploading={isUploading}
            setIsUploading={setIsUploading}
          />
          <div className="flex gap-2">
            <button type="button" onClick={() => { setDraft(lesson); setIsEditing(false); }} className="flex items-center gap-1.5 rounded-lg border border-gray-300 px-3 py-1.5 text-xs font-semibold text-gray-500 hover:text-gray-700 transition cursor-pointer">
              <X className="h-3.5 w-3.5" /> Cancel
            </button>
            <button type="button" onClick={handleSave} disabled={isSaving} className="flex items-center gap-1.5 rounded-lg bg-blue-700 px-3 py-1.5 text-xs font-semibold text-white hover:bg-blue-600 transition disabled:opacity-50 cursor-pointer">
              {isSaving ? <Loader2 className="h-3.5 w-3.5 animate-spin" /> : <Check className="h-3.5 w-3.5" />} Save
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <>
      <div className="group flex items-center gap-3 rounded-xl border border-gray-200 bg-white px-4 py-3 hover:border-gray-300 transition-all">
        <GripVertical className="h-4 w-4 text-gray-400 shrink-0" />
        <PlayCircle className="h-4 w-4 text-blue-600/70 shrink-0" />
        <div className="flex-1 min-w-0">
          <span className="text-sm font-medium text-gray-700 truncate block">{lesson.title}</span>
          {lesson.video_duration && <span className="text-xs text-gray-400">{lesson.video_duration}</span>}
        </div>
        {lesson.video_status != null || lesson.video_asset_id != null ? (
          <StatusBadge status={lesson.video_status} />
        ) : lesson.video_url ? (
          <span className="flex items-center gap-1 text-[10px] font-bold uppercase tracking-wider text-blue-400 border border-blue-500/20 bg-blue-500/10 px-2 py-0.5 rounded-full">
            <Video className="h-3 w-3" /> External
          </span>
        ) : null}
        {lesson.is_free_preview && (
          <span className="flex items-center gap-1 text-[10px] font-bold uppercase tracking-wider text-emerald-400 border border-emerald-500/20 bg-emerald-500/10 px-2 py-0.5 rounded-full">
            <Eye className="h-3 w-3" /> Free
          </span>
        )}
        <div className="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
          <button type="button" onClick={() => setIsEditing(true)} className="rounded-lg p-1.5 text-gray-500 hover:text-blue-600 hover:bg-gray-100 transition cursor-pointer">
            <Pencil className="h-3.5 w-3.5" />
          </button>
          <button type="button" onClick={() => setConfirmDelete(true)} className="rounded-lg p-1.5 text-gray-500 hover:text-rose-400 hover:bg-gray-100 transition cursor-pointer">
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
  const [isUploading, setIsUploading] = useState(false);
  const [uploadProgress, setUploadProgress] = useState(0);
  const inputRef = useRef<HTMLInputElement>(null);

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

      let videoAssetId: string | null = null;
      let videoStatus: string | null = null;
      const trimmedUrl = videoUrl.trim();

      if (trimmedUrl) {
        const result = (await createDirectUrlAsset(trimmedUrl, data.id)) as {
          asset?: { id: string; status: string };
          duplicate?: boolean;
        };
        videoAssetId = result.asset?.id ?? null;
        videoStatus = result.asset?.status ?? null;
      }

      onAdded({
        ...data,
        is_free_preview: Boolean(data.is_free_preview),
        video_asset_id: videoAssetId,
        video_status: videoStatus,
      } as Lesson);
      toast.success('Lesson added.');
    } catch (err: unknown) {
      toast.error(err instanceof Error ? err.message : 'Failed to add lesson.');
    } finally {
      setIsSaving(false);
    }
  };

  const handleFileUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file || !title.trim()) {
      if (!title.trim()) toast.error('Add a title first, then upload the video.');
      return;
    }
    setUploadProgress(0);
    setIsUploading(true);
    let createdLessonId: string | null = null;
    try {
      const { data: lessonData, error: lessonError } = await supabase
        .from('course_lessons')
        .insert({
          section_id: sectionId,
          course_id: courseId,
          title: title.trim(),
          description: description.trim() || null,
          is_free_preview: Boolean(isFreePreview),
          sort_order: nextOrder,
        })
        .select()
        .single();
      if (lessonError) throw lessonError;
      createdLessonId = lessonData.id;

      const result = (await uploadVideo(file, lessonData.id, setUploadProgress)) as {
        asset?: { id: string; status: string };
        duplicate?: boolean;
      };

      const newLesson = {
        ...lessonData,
        is_free_preview: Boolean(lessonData.is_free_preview),
        video_asset_id: result.asset?.id ?? null,
        video_status: result.asset?.status ?? null,
        video_url: null,
        video_duration: null,
      } as Lesson;

      onAdded(newLesson);
      toast.success('Lesson added with video.');
    } catch (err: unknown) {
      if (createdLessonId) {
        await supabase
          .from('course_lessons')
          .delete()
          .eq('id', createdLessonId)
          .then(() => undefined);
      }
      toast.error(err instanceof Error ? err.message : 'Failed to add lesson with video.');
    } finally {
      setIsUploading(false);
      if (inputRef.current) inputRef.current.value = '';
    }
  };

  return (
    <div className="rounded-xl border border-blue-500/30 bg-blue-600/5 p-4 space-y-3">
      <InlineInput value={title} onChange={setTitle} placeholder="Lesson title *" />
      <InlineInput value={description} onChange={setDescription} placeholder="Short description (optional)" />
      <div className="grid grid-cols-2 gap-3">
        <InlineInput value={videoUrl} onChange={setVideoUrl} placeholder="Video URL (optional)" />
        <InlineInput value={videoDuration} onChange={setVideoDuration} placeholder="Duration e.g. 12:30" />
      </div>
      <label className="flex items-center gap-2 cursor-pointer select-none text-sm text-gray-700">
        <input type="checkbox" checked={isFreePreview} onChange={(e) => setIsFreePreview(e.target.checked)} className="h-4 w-4 rounded border-gray-300 bg-white text-blue-500 focus:ring-blue-500/20 focus:ring-offset-0 focus:ring-2" />
        Free Preview
      </label>
      <div className="flex flex-wrap items-center justify-between gap-2">
        <input
          ref={inputRef}
          type="file"
          accept="video/mp4,video/quicktime,video/webm,video/x-matroska"
          onChange={handleFileUpload}
          className="hidden"
        />
        {isUploading ? (
          <div className="flex flex-col gap-1 w-full">
            <div className="flex items-center gap-2 text-xs text-gray-500">
              <Loader2 className="h-3.5 w-3.5 animate-spin shrink-0" />
              <span className="font-medium">
                {uploadProgress === 100 ? 'Processing and saving video...' : `Uploading ${uploadProgress}%`}
              </span>
            </div>
            <div className="h-2 w-full rounded-full bg-gray-100 overflow-hidden">
              <div
                className="h-full rounded-full bg-gradient-to-r from-blue-600 to-blue-500 transition-all duration-300"
                style={{ width: `${uploadProgress}%` }}
              />
            </div>
          </div>
        ) : (
          <button
            type="button"
            onClick={() => inputRef.current?.click()}
            className="flex items-center gap-1.5 rounded-lg border border-gray-300 px-3 py-1.5 text-xs font-semibold text-gray-500 hover:text-blue-600 hover:border-blue-500/40 transition cursor-pointer"
          >
            <Video className="h-3.5 w-3.5" />
            Upload Video File
          </button>
        )}
        <div className="flex gap-2">
          <button type="button" onClick={onCancel} className="flex items-center gap-1.5 rounded-lg border border-gray-300 px-3 py-1.5 text-xs font-semibold text-gray-500 hover:text-gray-700 transition cursor-pointer">
            <X className="h-3.5 w-3.5" /> Cancel
          </button>
          <button type="button" onClick={handleAdd} disabled={isSaving} className="flex items-center gap-1.5 rounded-lg bg-blue-700 px-3 py-1.5 text-xs font-semibold text-white hover:bg-blue-600 transition disabled:opacity-50 cursor-pointer">
            {isSaving ? <Loader2 className="h-3.5 w-3.5 animate-spin" /> : <Plus className="h-3.5 w-3.5" />} Add Lesson
          </button>
        </div>
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
      <div className="rounded-2xl border border-gray-200 bg-white overflow-hidden">
        <div className="flex items-center gap-3 px-5 py-4 bg-gray-50 border-b border-gray-200">
          <GripVertical className="h-5 w-5 text-gray-400 shrink-0" />
          <button type="button" onClick={() => setIsExpanded(!isExpanded)} className="text-gray-400 hover:text-gray-600 transition cursor-pointer">
            {isExpanded ? <ChevronDown className="h-4 w-4" /> : <ChevronRight className="h-4 w-4" />}
          </button>
          {isEditingTitle ? (
            <div className="flex-1 space-y-2">
              <InlineInput value={titleDraft} onChange={setTitleDraft} placeholder="Section title *" />
              <InlineInput value={descDraft} onChange={setDescDraft} placeholder="Section description (optional)" />
            </div>
          ) : (
            <div className="flex-1 min-w-0">
              <h3 className="font-semibold text-gray-900 truncate">{section.title}</h3>
              {section.description && <p className="text-xs text-gray-400 truncate mt-0.5">{section.description}</p>}
            </div>
          )}
          <span className="text-xs text-gray-400 whitespace-nowrap">{section.lessons.length} lesson{section.lessons.length !== 1 ? 's' : ''}</span>
          {isEditingTitle ? (
            <div className="flex gap-2 shrink-0">
              <button type="button" onClick={() => { setTitleDraft(section.title); setDescDraft(section.description || ''); setIsEditingTitle(false); }} className="rounded-lg p-1.5 text-gray-500 hover:text-gray-700 hover:bg-gray-100 transition cursor-pointer">
                <X className="h-4 w-4" />
              </button>
              <button type="button" onClick={handleSaveTitle} disabled={isSavingTitle} className="rounded-lg p-1.5 text-blue-600 hover:text-blue-500 hover:bg-gray-100 transition cursor-pointer">
                {isSavingTitle ? <Loader2 className="h-4 w-4 animate-spin" /> : <Check className="h-4 w-4" />}
              </button>
            </div>
          ) : (
            <div className="flex gap-1 shrink-0">
              <button type="button" onClick={() => setIsEditingTitle(true)} className="rounded-lg p-1.5 text-gray-400 hover:text-blue-600 hover:bg-gray-100 transition cursor-pointer">
                <Pencil className="h-3.5 w-3.5" />
              </button>
              <button type="button" onClick={() => setConfirmDelete(true)} className="rounded-lg p-1.5 text-gray-400 hover:text-rose-400 hover:bg-gray-100 transition cursor-pointer">
                <Trash2 className="h-3.5 w-3.5" />
              </button>
            </div>
          )}
        </div>
        {isExpanded && (
          <div className="p-4 space-y-2">
            {section.lessons.length === 0 && !isAddingLesson && (
              <div className="text-center py-6 text-gray-400 text-sm">No lessons yet — add one below.</div>
            )}
            {section.lessons.slice().sort((a, b) => a.sort_order - b.sort_order).map((lesson) => (
              <LessonRow key={lesson.id} lesson={lesson} onUpdate={handleLessonUpdated} onDelete={handleLessonDeleted} />
            ))}
            {isAddingLesson ? (
              <AddLessonForm sectionId={section.id} courseId={courseId} nextOrder={section.lessons.length} onAdded={handleLessonAdded} onCancel={() => setIsAddingLesson(false)} />
            ) : (
              <button type="button" onClick={() => setIsAddingLesson(true)} className="flex w-full items-center justify-center gap-1.5 rounded-xl border border-dashed border-gray-300 py-2.5 text-xs font-semibold text-gray-400 hover:border-blue-500/40 hover:text-blue-600 hover:bg-blue-600/5 transition cursor-pointer">
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

      const assetIds = (lessonsData || [])
        .map((l) => (l as Record<string, unknown>).video_asset_id as string | null)
        .filter(Boolean) as string[];

      let assetStatusMap: Record<string, string> = {};
      if (assetIds.length > 0) {
        const { data: assets } = await supabase
          .from('media_assets')
          .select('id, status')
          .in('id', assetIds);
        if (assets) {
          assetStatusMap = Object.fromEntries(
            (assets as { id: string; status: string }[]).map((a) => [a.id, a.status]),
          );
        }
      }

      const sectionsWithLessons: Section[] = (sectionsData || []).map((s) => ({
        ...s,
        lessons: (lessonsData || [])
          .filter((l) => l.section_id === s.id)
          .map((l) => ({
            ...l,
            is_free_preview: Boolean(l.is_free_preview),
            video_status: (l as Record<string, unknown>).video_asset_id
              ? assetStatusMap[(l as Record<string, unknown>).video_asset_id as string] ?? null
              : null,
          })),
      }));
      setSections(sectionsWithLessons as unknown as Section[]);
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
        <Loader2 className="h-8 w-8 animate-spin text-blue-500" />
      </div>
    );
  }

  return (
    <div className="space-y-8 animate-in fade-in duration-300">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-extrabold text-gray-900 tracking-tight">Syllabus</h1>
          <p className="text-gray-500 text-sm mt-1">
            <span className="text-blue-600 font-semibold">{courseTitle}</span>
            {' '}— {sections.length} section{sections.length !== 1 ? 's' : ''}, {totalLessons} lesson{totalLessons !== 1 ? 's' : ''}
          </p>
        </div>
        <button
          type="button"
          onClick={fetchSyllabus}
          className="flex items-center gap-1.5 rounded-lg border border-gray-300 px-3 py-1.5 text-xs font-semibold text-gray-500 hover:text-gray-700 transition cursor-pointer"
        >
          <RefreshCw className="h-3.5 w-3.5" /> Refresh
        </button>
      </div>

      <div className="space-y-4">
        {sections.length === 0 && !isAddingSection && (
          <div className="flex flex-col items-center justify-center text-center p-16 rounded-2xl border border-dashed border-gray-200 bg-gray-50">
            <BookOpen className="h-10 w-10 text-gray-400 mb-3" />
            <h3 className="text-lg font-bold text-gray-900">No sections yet</h3>
            <p className="text-gray-400 text-sm mt-1">Add your first section to get started.</p>
          </div>
        )}
        {sections.slice().sort((a, b) => a.sort_order - b.sort_order).map((section) => (
          <SectionCard key={section.id} section={section} courseId={courseId} onUpdate={handleSectionUpdated} onDelete={handleSectionDeleted} />
        ))}
      </div>

      {isAddingSection ? (
        <div className="rounded-2xl border border-blue-500/30 bg-blue-600/5 p-6 space-y-3">
          <h3 className="text-sm font-bold text-gray-900">New Section</h3>
          <InlineInput value={newSectionTitle} onChange={setNewSectionTitle} placeholder="Section title *" />
          <InlineInput value={newSectionDesc} onChange={setNewSectionDesc} placeholder="Description (optional)" />
          <div className="flex gap-2 justify-end">
            <button type="button" onClick={() => { setIsAddingSection(false); setNewSectionTitle(''); setNewSectionDesc(''); }} className="flex items-center gap-1.5 rounded-lg border border-gray-300 px-4 py-2 text-sm font-semibold text-gray-500 hover:text-gray-700 transition cursor-pointer">
              <X className="h-4 w-4" /> Cancel
            </button>
            <button type="button" onClick={handleAddSection} disabled={isSavingSection} className="flex items-center gap-2 rounded-xl bg-gradient-to-r from-blue-600 to-blue-500 px-5 py-2 text-sm font-semibold text-white hover:from-blue-500 hover:to-blue-400 transition disabled:opacity-50 cursor-pointer">
              {isSavingSection ? <Loader2 className="h-4 w-4 animate-spin" /> : <Plus className="h-4 w-4" />} Add Section
            </button>
          </div>
        </div>
      ) : (
        <button type="button" onClick={() => setIsAddingSection(true)} className="flex w-full items-center justify-center gap-2 rounded-2xl border border-dashed border-gray-300 py-4 text-sm font-semibold text-gray-400 hover:border-blue-500/40 hover:text-blue-600 hover:bg-blue-600/5 transition cursor-pointer">
          <Plus className="h-4 w-4" /> Add Section
        </button>
      )}
    </div>
  );
}
