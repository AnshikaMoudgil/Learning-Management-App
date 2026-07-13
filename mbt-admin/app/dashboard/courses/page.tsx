'use strict';
'use client';

import { useEffect, useState } from 'react';
import { supabase } from '@/app/lib/supabaseClient';
import toast from 'react-hot-toast';
import Link from 'next/link';
import { Plus, Search, BookOpen, Trash2, Edit3, LayoutList } from 'lucide-react';
import ConfirmDialog from '@/components/ConfirmDialog';
import Pagination from '@/components/Pagination';

const PAGE_SIZE = 9;

interface Course {
  id: string;
  title: string;
  slug: string;
  price: number;
  is_published: boolean;
  category: string | null;
  level: string;
  thumbnail_url: string | null;
  average_rating: number;
  reviews_count: number;
  instructor_id: string | null;
  profiles?: { full_name: string }[] | null;
}

export default function CoursesPage() {
  const [courses, setCourses] = useState<Course[]>([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [isLoading, setIsLoading] = useState(true);
  const [currentPage, setCurrentPage] = useState(1);
  const [deleteTarget, setDeleteTarget] = useState<Course | null>(null);
  const [userRole, setUserRole] = useState<string>('');

  const fetchCourses = async () => {
    try {
      setIsLoading(true);

      const { data: { session } } = await supabase.auth.getSession();
      const uid = session?.user?.id;

      let userRoleValue = '';
      if (uid) {
        const { data: profile } = await supabase
          .from('profiles')
          .select('role')
          .eq('id', uid)
          .single();
        userRoleValue = profile?.role || '';
        setUserRole(userRoleValue);
      }

      let query = supabase
        .from('courses')
        .select('id, title, slug, price, is_published, category, level, thumbnail_url, average_rating, reviews_count, instructor_id, profiles!instructor_id ( full_name )', { count: 'exact' });        
      if (userRoleValue === 'instructor' && uid) {
        query = query.eq('created_by', uid);
      }

      const { data, error } = await query.order('created_at', { ascending: false });

      if (error) throw error;
      setCourses(data || []);
    } catch {
      toast.error('Failed to load courses.');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchCourses();
  }, []);

  const handleDelete = async () => {
    if (!deleteTarget) return;

    const loadingToast = toast.loading('Deleting course...');
    try {
      const { error } = await supabase.from('courses').delete().eq('id', deleteTarget.id);
      if (error) throw error;

      toast.dismiss(loadingToast);
      toast.success('Course deleted successfully.');
      setCourses(courses.filter((course) => course.id !== deleteTarget.id));
      setDeleteTarget(null);
    } catch (err: unknown) {
      toast.dismiss(loadingToast);
      toast.error(err instanceof Error ? err.message : 'Failed to delete course.');
    }
  };

  const filteredCourses = courses.filter((course) =>
    course.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
    (course.category && course.category.toLowerCase().includes(searchTerm.toLowerCase()))
  );

  const totalPages = Math.ceil(filteredCourses.length / PAGE_SIZE);
  const paginatedCourses = filteredCourses.slice(
    (currentPage - 1) * PAGE_SIZE,
    currentPage * PAGE_SIZE
  );

  useEffect(() => {
    setCurrentPage(1);
  }, [searchTerm]);

  return (
    <div className="space-y-8 animate-in fade-in duration-300">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-3xl font-extrabold text-white tracking-tight">Courses</h1>
          <p className="text-zinc-400 text-sm mt-1">Manage and edit your course curricula.</p>
        </div>
        <Link
          href="/dashboard/courses/new"
          className="inline-flex items-center gap-2 rounded-xl bg-gradient-to-r from-teal-500 to-emerald-500 px-5 py-3 text-sm font-semibold text-zinc-950 transition-all duration-200 hover:from-teal-400 hover:to-emerald-400 cursor-pointer shadow-lg shadow-teal-500/10 active:scale-[0.98]"
        >
          <Plus className="h-4 w-4" />
          Create Course
        </Link>
      </div>

      <div className="relative max-w-md">
        <Search className="absolute left-3 top-1/2 h-5 w-5 -translate-y-1/2 text-zinc-500" />
        <input
          type="text"
          placeholder="Search by course title or category..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          className="w-full rounded-xl border border-zinc-800 bg-zinc-900/40 py-3 pl-10 pr-4 text-sm text-zinc-100 placeholder-zinc-500 outline-none transition-all duration-200 focus:border-teal-500 focus:bg-zinc-900/50"
        />
      </div>

      {isLoading ? (
        <div className="flex h-48 items-center justify-center">
          <span className="text-sm text-zinc-500">Loading courses...</span>
        </div>
      ) : paginatedCourses.length === 0 ? (
        <div className="flex flex-col items-center justify-center text-center p-12 rounded-2xl border border-dashed border-zinc-800 bg-zinc-900/10">
          <BookOpen className="h-10 w-10 text-zinc-600 mb-3" />
          <h3 className="text-lg font-bold text-white">No courses found</h3>
          <p className="text-zinc-500 text-sm mt-1">Get started by creating a new course module.</p>
        </div>
      ) : (
        <>
          <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
            {paginatedCourses.map((course) => (
              <div
                key={course.id}
                className="group overflow-hidden rounded-2xl border border-zinc-800 bg-zinc-900/30 transition-all duration-300 hover:border-zinc-700/80 hover:bg-zinc-900/50 flex flex-col justify-between"
              >
                <div className="aspect-video w-full bg-zinc-900 relative overflow-hidden border-b border-zinc-850">
                  {course.thumbnail_url ? (
                    <img
                      src={course.thumbnail_url}
                      alt={course.title}
                      className="h-full w-full object-cover transition-transform duration-500 group-hover:scale-105"
                    />
                  ) : (
                    <div className="flex h-full w-full items-center justify-center text-zinc-700">
                      <BookOpen className="h-10 w-10" />
                    </div>
                  )}
                  <span className={`absolute top-3 right-3 text-[10px] uppercase font-bold tracking-wider px-2.5 py-1 rounded-full ${
                    course.is_published
                      ? 'bg-teal-500/15 text-teal-400 border border-teal-500/20'
                      : 'bg-amber-500/15 text-amber-400 border border-amber-500/20'
                  }`}>
                    {course.is_published ? 'Published' : 'Draft'}
                  </span>
                </div>

                <div className="p-6 flex-1 flex flex-col justify-between">
                  <div className="space-y-2">
                    <span className="text-[10px] font-semibold text-teal-400 uppercase tracking-widest block">
                      {course.category || 'Uncategorized'}
                    </span>
                    <h3 className="font-bold text-white line-clamp-1 group-hover:text-teal-400 transition-colors">
                      {course.title}
                    </h3>
                    <div className="flex gap-2 text-xs text-zinc-500">
                      <span className="capitalize">{course.level}</span>
                      <span>•</span>
                      <span className="flex items-center gap-1 font-semibold text-zinc-300">
                        ${course.price.toFixed(2)}
                      </span>
                    </div>
                    <div className="flex gap-3 text-xs text-zinc-500 mt-2">
                      {course.average_rating > 0 && (
                        <span className="flex items-center gap-1 text-amber-400">
                          ★ {course.average_rating.toFixed(1)}
                        </span>
                      )}
                      {course.reviews_count > 0 && (
                        <span>({course.reviews_count} reviews)</span>
                      )}
                      {course.profiles?.[0]?.full_name && (
                        <span className="text-teal-400">by {course.profiles[0].full_name}</span>
                      )}
                    </div>
                  </div>

                  <div className="flex items-center justify-between pt-6 mt-6 border-t border-zinc-800">
                    <div className="flex items-center gap-2">
                      <Link
                        href={`/dashboard/courses/${course.id}/edit`}
                        className="flex items-center gap-1.5 rounded-lg border border-zinc-800 hover:border-zinc-700 hover:bg-zinc-800 px-3.5 py-2 text-xs font-semibold text-zinc-300 transition-all cursor-pointer"
                      >
                        <Edit3 className="h-3.5 w-3.5" />
                        Edit
                      </Link>
                      <Link
                        href={`/dashboard/courses/${course.id}/syllabus`}
                        className="flex items-center gap-1.5 rounded-lg border border-zinc-800 hover:border-teal-700/40 hover:bg-teal-950/20 px-3.5 py-2 text-xs font-semibold text-teal-400 transition-all cursor-pointer"
                      >
                        <LayoutList className="h-3.5 w-3.5" />
                        Syllabus
                      </Link>
                    </div>

                    <button
                      onClick={() => setDeleteTarget(course)}
                      className="flex items-center gap-1.5 rounded-lg border border-zinc-800 hover:border-rose-900/30 hover:bg-rose-950/20 px-3.5 py-2 text-xs font-semibold text-rose-400 transition-all cursor-pointer"
                    >
                      <Trash2 className="h-3.5 w-3.5" />
                      Delete
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>

          <Pagination
            currentPage={currentPage}
            totalPages={totalPages}
            onPageChange={setCurrentPage}
          />
        </>
      )}

      <ConfirmDialog
        isOpen={!!deleteTarget}
        title="Delete Course"
        message={`Are you sure you want to delete course "${deleteTarget?.title}"? This action cannot be undone.`}
        confirmLabel="Delete"
        variant="danger"
        onConfirm={handleDelete}
        onCancel={() => setDeleteTarget(null)}
      />
    </div>
  );
}
