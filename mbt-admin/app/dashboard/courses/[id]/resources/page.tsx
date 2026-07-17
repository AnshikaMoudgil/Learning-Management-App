'use client';

import React, { useEffect, useState, useCallback } from 'react';
import { useParams, useRouter } from 'next/navigation';
import { supabase } from '@/app/lib/supabaseClient';
import toast from 'react-hot-toast';
import ConfirmDialog from '@/components/ConfirmDialog';
import {
  Plus,
  Loader2,
  Trash2,
  Check,
  X,
  FileText,
  Download,
  File,
} from 'lucide-react';
import Select from '@/components/Select';

interface CourseResource {
  id: string;
  course_id: string;
  section_id: string | null;
  title: string;
  file_url: string;
  file_size: string | null;
  file_type: string | null;
  created_at: string;
  section_title?: string;
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

function ResourceRow({
  resource,
  onDelete,
}: {
  resource: CourseResource;
  onDelete: (id: string) => void;
}) {
  const [confirmDelete, setConfirmDelete] = useState(false);

  const handleDelete = async () => {
    try {
      const { error } = await supabase.from('course_resources').delete().eq('id', resource.id);
      if (error) throw error;
      onDelete(resource.id);
      toast.success('Resource deleted.');
    } catch (err: unknown) {
      toast.error(err instanceof Error ? err.message : 'Failed to delete resource.');
    }
  };

  const getFileIcon = (type: string | null) => {
    if (!type) return <File className="h-5 w-5 text-zinc-500" />;
    const t = type.toLowerCase();
    if (t.includes('pdf')) return <FileText className="h-5 w-5 text-rose-400" />;
    if (t.includes('zip') || t.includes('rar')) return <Download className="h-5 w-5 text-amber-400" />;
    return <File className="h-5 w-5 text-teal-400" />;
  };

  return (
    <>
      <div className="flex items-center gap-4 rounded-xl border border-zinc-800 bg-zinc-900/30 px-5 py-4 transition hover:border-zinc-700">
        <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-zinc-800">
          {getFileIcon(resource.file_type)}
        </div>
        <div className="flex-1 min-w-0">
          <p className="text-sm font-bold text-white truncate">{resource.title}</p>
          <div className="flex items-center gap-3 mt-1">
            {resource.section_title && (
              <span className="text-xs text-teal-400 font-semibold">
                {resource.section_title}
              </span>
            )}
            {resource.file_type && (
              <span className="rounded-full bg-zinc-800 px-2 py-0.5 text-xs text-zinc-400 uppercase">
                {resource.file_type}
              </span>
            )}
            {resource.file_size && (
              <span className="text-xs text-zinc-500">{resource.file_size}</span>
            )}
          </div>
        </div>
        <a
          href={resource.file_url}
          target="_blank"
          rel="noopener noreferrer"
          className="flex items-center gap-1.5 rounded-lg border border-zinc-700 px-3 py-1.5 text-xs font-semibold text-zinc-400 hover:text-zinc-200 transition"
        >
          <Download className="h-3.5 w-3.5" /> Open
        </a>
        <button
          type="button"
          onClick={() => setConfirmDelete(true)}
          className="rounded-lg p-2 text-zinc-600 hover:bg-rose-500/10 hover:text-rose-400 transition cursor-pointer"
        >
          <Trash2 className="h-4 w-4" />
        </button>
      </div>
      <ConfirmDialog
        isOpen={confirmDelete}
        onCancel={() => setConfirmDelete(false)}
        onConfirm={handleDelete}
        title="Delete Resource"
        message={`Delete "${resource.title}"? This cannot be undone.`}
        variant="danger"
      />
    </>
  );
}

export default function CourseResourcesPage() {
  const router = useRouter();
  const params = useParams();
  const courseId = params?.id as string;

  const [courseTitle, setCourseTitle] = useState('');
  const [resources, setResources] = useState<CourseResource[]>([]);
  const [sections, setSections] = useState<{ id: string; title: string }[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  // Add form state
  const [isAdding, setIsAdding] = useState(false);
  const [newTitle, setNewTitle] = useState('');
  const [newFileUrl, setNewFileUrl] = useState('');
  const [newSectionId, setNewSectionId] = useState('');
  const [newFileSize, setNewFileSize] = useState('');
  const [newFileType, setNewFileType] = useState('');
  const [isSaving, setIsSaving] = useState(false);

  const fetchData = useCallback(async () => {
    try {
      setIsLoading(true);

      // Fetch course title
      const { data: courseData, error: courseError } = await supabase
        .from('courses')
        .select('title')
        .eq('id', courseId)
        .maybeSingle();
      if (courseError) throw courseError;
      if (!courseData) {
        toast.error('Course not found.');
        router.push('/dashboard/courses');
        return;
      }
      setCourseTitle(courseData.title);

      // Fetch sections for dropdown
      const { data: sectionsData, error: sectionsError } = await supabase
        .from('course_sections')
        .select('id, title')
        .eq('course_id', courseId)
        .order('sort_order', { ascending: true });
      if (sectionsError) throw sectionsError;
      setSections(sectionsData || []);

      // Fetch resources with section title
      const { data: resourcesData, error: resourcesError } = await supabase
        .from('course_resources')
        .select('*, course_sections(title)')
        .eq('course_id', courseId)
        .order('created_at', { ascending: false });
      if (resourcesError) throw resourcesError;

      const mapped: CourseResource[] = (resourcesData || []).map((r: any) => ({
        id: r.id,
        course_id: r.course_id,
        section_id: r.section_id,
        title: r.title,
        file_url: r.file_url,
        file_size: r.file_size,
        file_type: r.file_type,
        created_at: r.created_at,
        section_title: r.course_sections?.title || null,
      }));
      setResources(mapped);
    } catch {
      toast.error('Failed to load resources.');
    } finally {
      setIsLoading(false);
    }
  }, [courseId, router]);

  useEffect(() => {
    if (courseId) fetchData();
  }, [courseId, fetchData]);

  const handleAdd = async () => {
    if (!newTitle.trim() || !newFileUrl.trim()) {
      toast.error('Title and File URL are required.');
      return;
    }
    setIsSaving(true);
    try {
      const { data, error } = await supabase
        .from('course_resources')
        .insert({
          course_id: courseId,
          section_id: newSectionId || null,
          title: newTitle.trim(),
          file_url: newFileUrl.trim(),
          file_size: newFileSize.trim() || null,
          file_type: newFileType.trim() || null,
        })
        .select('*, course_sections(title)')
        .single();
      if (error) throw error;

      const mapped: CourseResource = {
        id: data.id,
        course_id: data.course_id,
        section_id: data.section_id,
        title: data.title,
        file_url: data.file_url,
        file_size: data.file_size,
        file_type: data.file_type,
        created_at: data.created_at,
        section_title: (data as any).course_sections?.title || null,
      };

      setResources((prev) => [mapped, ...prev]);
      setNewTitle('');
      setNewFileUrl('');
      setNewSectionId('');
      setNewFileSize('');
      setNewFileType('');
      setIsAdding(false);
      toast.success('Resource added.');
    } catch (err: unknown) {
      toast.error(err instanceof Error ? err.message : 'Failed to add resource.');
    } finally {
      setIsSaving(false);
    }
  };

  const handleDelete = (id: string) => {
    setResources((prev) => prev.filter((r) => r.id !== id));
  };

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
        <h1 className="text-3xl font-extrabold text-white tracking-tight">Resources</h1>
        <p className="text-zinc-400 text-sm mt-1">
          <span className="text-teal-400 font-semibold">{courseTitle}</span>
          {' '}— {resources.length} resource{resources.length !== 1 ? 's' : ''}
        </p>
      </div>

      {/* Resources List */}
      <div className="space-y-3">
        {resources.length === 0 && !isAdding && (
          <div className="flex flex-col items-center justify-center text-center p-16 rounded-2xl border border-dashed border-zinc-800 bg-zinc-900/10">
            <FileText className="h-10 w-10 text-zinc-600 mb-3" />
            <h3 className="text-lg font-bold text-white">No resources yet</h3>
            <p className="text-zinc-500 text-sm mt-1">
              Upload PDFs, ZIPs, slides, or other files for your students.
            </p>
          </div>
        )}
        {resources.map((resource) => (
          <ResourceRow key={resource.id} resource={resource} onDelete={handleDelete} />
        ))}
      </div>

      {/* Add Resource Form */}
      {isAdding ? (
        <div className="rounded-2xl border border-teal-500/30 bg-teal-500/5 p-6 space-y-4">
          <h3 className="text-sm font-bold text-white">New Resource</h3>
          <InlineInput value={newTitle} onChange={setNewTitle} placeholder="Resource title *" />
          <InlineInput value={newFileUrl} onChange={setNewFileUrl} placeholder="File URL * (e.g. https://storage.example.com/file.pdf)" />
          <div className="grid gap-3 sm:grid-cols-3">
            <div className="space-y-1.5">
              <label className="text-xs font-semibold uppercase tracking-wider text-zinc-400">Module (Optional)</label>
              <Select
                value={newSectionId}
                onChange={setNewSectionId}
                options={[
                  { value: '', label: 'No specific module' },
                  ...sections.map((s) => ({ value: s.id, label: s.title })),
                ]}
                placeholder="Select module"
              />
            </div>
            <div className="space-y-1.5">
              <label className="text-xs font-semibold uppercase tracking-wider text-zinc-400">File Type</label>
              <InlineInput value={newFileType} onChange={setNewFileType} placeholder="e.g. pdf, zip, pptx" />
            </div>
            <div className="space-y-1.5">
              <label className="text-xs font-semibold uppercase tracking-wider text-zinc-400">File Size</label>
              <InlineInput value={newFileSize} onChange={setNewFileSize} placeholder="e.g. 2.4 MB" />
            </div>
          </div>
          <div className="flex gap-2 justify-end">
            <button
              type="button"
              onClick={() => {
                setIsAdding(false);
                setNewTitle('');
                setNewFileUrl('');
                setNewSectionId('');
                setNewFileSize('');
                setNewFileType('');
              }}
              className="flex items-center gap-1.5 rounded-lg border border-zinc-700 px-4 py-2 text-sm font-semibold text-zinc-400 hover:text-zinc-200 transition cursor-pointer"
            >
              <X className="h-4 w-4" /> Cancel
            </button>
            <button
              type="button"
              onClick={handleAdd}
              disabled={isSaving}
              className="flex items-center gap-2 rounded-xl bg-gradient-to-r from-teal-500 to-emerald-500 px-5 py-2 text-sm font-semibold text-zinc-950 hover:from-teal-400 hover:to-emerald-400 transition disabled:opacity-50 cursor-pointer"
            >
              {isSaving ? <Loader2 className="h-4 w-4 animate-spin" /> : <Check className="h-4 w-4" />} Add Resource
            </button>
          </div>
        </div>
      ) : (
        <button
          type="button"
          onClick={() => setIsAdding(true)}
          className="flex w-full items-center justify-center gap-2 rounded-2xl border border-dashed border-zinc-700 py-4 text-sm font-semibold text-zinc-500 hover:border-teal-500/40 hover:text-teal-400 hover:bg-teal-500/5 transition cursor-pointer"
        >
          <Plus className="h-4 w-4" /> Add Resource
        </button>
      )}
    </div>
  );
}
