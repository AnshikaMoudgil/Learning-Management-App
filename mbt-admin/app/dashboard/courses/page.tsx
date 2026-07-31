'use client';

import { useEffect, useState, useCallback, startTransition } from 'react';
import { supabase } from '@/app/lib/supabaseClient';
import { useAuth } from '@/app/lib/AuthContext';
import toast from 'react-hot-toast';
import Link from 'next/link';
import Image from 'next/image';
import { Plus, Search, BookOpen, Trash2, Edit3, ChevronDown, X } from 'lucide-react';
import ConfirmDialog from '@/components/ConfirmDialog';
import Pagination from '@/components/Pagination';
import Select from '@/components/Select';
import { COURSES_PAGE_SIZE as PAGE_SIZE } from '@/app/lib/constants';

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
  const { role, userId } = useAuth();
  const [courses, setCourses] = useState<Course[]>([]);
  const [totalCount, setTotalCount] = useState(0);
  const [searchTerm, setSearchTerm] = useState('');
  const [filterLevel, setFilterLevel] = useState('');
  const [filterCategory, setFilterCategory] = useState('');
  const [filterMinPrice, setFilterMinPrice] = useState('');
  const [filterMaxPrice, setFilterMaxPrice] = useState('');
  const [showFilters, setShowFilters] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const [currentPage, setCurrentPage] = useState(1);
  const [deleteTarget, setDeleteTarget] = useState<Course | null>(null);

  const fetchCourses = useCallback(async () => {
    try {
      setIsLoading(true);

      const uid = userId;
      const from = (currentPage - 1) * PAGE_SIZE;
      const to = from + PAGE_SIZE - 1;

      let query = supabase
        .from('courses')
        .select('id, title, slug, price, is_published, category, level, thumbnail_url, average_rating, reviews_count, instructor_id, profiles!instructor_id ( full_name )', { count: 'exact' });
      if (role === 'instructor' && uid) {
        query = query.eq('created_by', uid);
      }
      if (filterLevel) query = query.eq('level', filterLevel);
      if (filterCategory) query = query.eq('category', filterCategory);
      if (filterMinPrice) query = query.gte('price', parseFloat(filterMinPrice));
      if (filterMaxPrice) query = query.lte('price', parseFloat(filterMaxPrice));

      const { data, count, error } = await query
        .order('created_at', { ascending: false })
        .range(from, to);

      if (error) throw error;
      setCourses(data || []);
      setTotalCount(count || 0);
    } catch {
      toast.error('Failed to load courses.');
    } finally {
      setIsLoading(false);
    }
  }, [currentPage, role, userId, filterLevel, filterCategory, filterMinPrice, filterMaxPrice]);

  useEffect(() => {
    startTransition(() => { fetchCourses(); });
  }, [fetchCourses]);

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

  const filteredCourses = searchTerm
    ? courses.filter((course) =>
        course.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
        (course.category && course.category.toLowerCase().includes(searchTerm.toLowerCase()))
      )
    : courses;

  const totalPages = Math.ceil(totalCount / PAGE_SIZE);

  useEffect(() => {
    startTransition(() => { setCurrentPage(1); });
  }, [searchTerm]);

  return (
    <div className="space-y-8 animate-in fade-in duration-200">
      
      {/* Title Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-3xl font-extrabold text-gray-900 tracking-tight">Courses</h1>
          <p className="text-gray-500 text-sm mt-1">Manage and edit your course curricula.</p>
        </div>
        <Link
          href="/dashboard/courses/new"
          className="inline-flex items-center gap-2 rounded-lg bg-blue-600 px-5 py-2.5 text-sm font-semibold text-white transition-all duration-150 hover:bg-blue-500 cursor-pointer shadow-lg shadow-blue-500/10 active:scale-[0.98]"
        >
          <Plus className="h-4 w-4" />
          Create Course
        </Link>
      </div>

      {/* Search Input and Filter Toggle */}
      <div className="flex items-center gap-3 w-full">
        <div className="relative max-w-md flex-1">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" />
          <input
            type="text"
            placeholder="Search by course title or category..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full rounded-lg border border-gray-200 bg-white py-2.5 pl-10 pr-4 text-sm text-gray-700 placeholder-gray-400 outline-none transition-all duration-150 focus:border-blue-500/50"
          />
        </div>
        <button
          onClick={() => setShowFilters(!showFilters)}
          className={`inline-flex items-center gap-1.5 rounded-lg border px-4 py-2.5 text-sm font-medium transition cursor-pointer ${
            showFilters ? 'border-blue-200 bg-blue-50 text-blue-600' : 'border-gray-200 bg-transparent text-gray-500 hover:text-gray-900 hover:border-gray-300'
          }`}
        >
          <Search className="h-4 w-4 rotate-90" />
          Filter
          <ChevronDown className={`h-3.5 w-3.5 ml-1 transition-transform ${showFilters ? 'rotate-180' : ''}`} />
        </button>
      </div>

      {/* Filter Panel */}
      {showFilters && (
        <div className="rounded-xl border border-gray-200 bg-white p-4 shadow-sm">
          <div className="flex flex-wrap items-end gap-4">
            <div className="space-y-1 min-w-[160px]">
              <label className="text-xs font-semibold uppercase tracking-wider text-gray-500">Level</label>
              <Select
                value={filterLevel}
                onChange={(v) => { setFilterLevel(v); setCurrentPage(1); }}
                options={[
                  { value: '', label: 'All Levels' },
                  { value: 'beginner', label: 'Beginner' },
                  { value: 'intermediate', label: 'Intermediate' },
                  { value: 'advanced', label: 'Advanced' },
                ]}
              />
            </div>
            <div className="space-y-1 min-w-[160px]">
              <label className="text-xs font-semibold uppercase tracking-wider text-gray-500">Category</label>
              <Select
                value={filterCategory}
                onChange={(v) => { setFilterCategory(v); setCurrentPage(1); }}
                options={[
                  { value: '', label: 'All Categories' },
                  { value: 'Hardware', label: 'Hardware' },
                  { value: 'Software', label: 'Software' },
                ]}
              />
            </div>
            <div className="space-y-1 min-w-[120px]">
              <label className="text-xs font-semibold uppercase tracking-wider text-gray-500">Min Price</label>
              <input
                type="number"
                min="0"
                step="0.01"
                placeholder="₹0"
                value={filterMinPrice}
                onChange={(e) => { const v = e.target.value; if (v === '' || parseFloat(v) >= 0) { setFilterMinPrice(v); setCurrentPage(1); } }}
                onKeyDown={(e) => { if (e.key === '-') e.preventDefault(); }}
                className="w-full rounded-lg border border-gray-200 bg-white py-2.5 px-3 text-sm text-gray-700 placeholder-gray-400 outline-none focus:border-blue-500 transition"
              />
            </div>
            <div className="space-y-1 min-w-[120px]">
              <label className="text-xs font-semibold uppercase tracking-wider text-gray-500">Max Price</label>
              <input
                type="number"
                min="0"
                step="0.01"
                placeholder="₹999"
                value={filterMaxPrice}
                onChange={(e) => { const v = e.target.value; if (v === '' || parseFloat(v) >= 0) { setFilterMaxPrice(v); setCurrentPage(1); } }}
                onKeyDown={(e) => { if (e.key === '-') e.preventDefault(); }}
                className="w-full rounded-lg border border-gray-200 bg-white py-2.5 px-3 text-sm text-gray-700 placeholder-gray-400 outline-none focus:border-blue-500 transition"
              />
            </div>
            <button
              onClick={() => { setFilterLevel(''); setFilterCategory(''); setFilterMinPrice(''); setFilterMaxPrice(''); setCurrentPage(1); }}
              className="inline-flex items-center gap-1.5 rounded-lg border border-gray-200 px-4 py-2.5 text-sm font-medium text-gray-500 hover:text-gray-700 hover:border-gray-300 transition cursor-pointer"
            >
              <X className="h-3.5 w-3.5" />
              Clear
            </button>
          </div>
        </div>
      )}

      {isLoading ? (
        <div className="flex h-48 items-center justify-center">
          <span className="text-sm text-gray-400">Loading courses...</span>
        </div>
      ) : filteredCourses.length === 0 ? (
        <div className="flex flex-col items-center justify-center text-center p-12 rounded-2xl border border-dashed border-gray-200 bg-gray-50">
          <BookOpen className="h-10 w-10 text-gray-400 mb-3" />
          <h3 className="text-lg font-bold text-gray-900">No courses found</h3>
          <p className="text-gray-400 text-sm mt-1">Get started by creating a new course module.</p>
        </div>
      ) : (
        <>
          <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
            {filteredCourses.map((course) => (
              <div
                key={course.id}
                className="group flex flex-col justify-between rounded-xl border border-gray-200 bg-white shadow-sm overflow-hidden"
              >
                
                {/* Thumbnail Header Area */}
                <div className="aspect-video w-full bg-gray-50 relative overflow-hidden border-b border-gray-200">
                  {course.thumbnail_url ? (
                    <Image
                      src={course.thumbnail_url}
                      alt={course.title}
                      width={400}
                      height={225}
                      className="h-full w-full object-cover"
                    />
                  ) : (
                    <div className="flex h-full w-full items-center justify-center text-gray-300">
                      <BookOpen className="h-10 w-10" />
                    </div>
                  )}
                  <span className={`absolute top-3 right-3 text-[10px] uppercase font-bold tracking-wider px-2.5 py-1 rounded ${
                    course.is_published
                      ? 'bg-blue-600 text-white'
                      : 'bg-gray-100 text-gray-500'
                  }`}>
                    {course.is_published ? 'Published' : 'Draft'}
                  </span>
                </div>

                {/* Details Portion */}
                <div className="p-5 flex-1 flex flex-col justify-between">
                  <div className="space-y-2">
                    <span className="text-[10px] font-bold text-blue-600 uppercase tracking-widest block">
                      {course.category || 'Uncategorized'}
                    </span>
                    <h3 className="font-semibold text-gray-900 text-base leading-snug line-clamp-2">
                      {course.title}
                    </h3>
                    <div className="flex items-center gap-1.5 text-xs text-gray-500">
                      <span className="capitalize">{course.level}</span>
                      <span className="text-blue-600">•</span>
                      <span className="font-semibold text-gray-700">
                        ₹{course.price.toFixed(2)}
                      </span>
                    </div>
                    
                    <div className="flex items-center gap-1.5 text-xs mt-2">
                      <span className="text-blue-600 text-sm">★</span>
                      <span className="text-blue-600 font-semibold">
                        {course.average_rating > 0 ? course.average_rating.toFixed(1) : '0.0'}
                      </span>
                      <span className="text-gray-400">
                        ({course.reviews_count > 0 ? `${course.reviews_count} reviews` : '0 reviews'})
                      </span>
                    </div>
                  </div>

                  {/* Actions (Edit / Delete) */}
                  <div className="flex items-center justify-between pt-4 mt-5 border-t border-gray-200 gap-3">
                    <Link
                      href={`/dashboard/courses/${course.id}/edit`}
                      className="flex items-center justify-center gap-1.5 rounded-lg border border-blue-200 hover:border-blue-400 bg-transparent py-2.5 text-xs font-semibold text-blue-600 transition-all duration-150 cursor-pointer w-full"
                    >
                      <Edit3 className="h-3.5 w-3.5" />
                      Edit
                    </Link>

                    <button
                      onClick={() => setDeleteTarget(course)}
                      className="flex items-center justify-center gap-1.5 rounded-lg border border-red-300 hover:border-red-400 bg-transparent py-2.5 text-xs font-semibold text-red-500 transition-all duration-150 cursor-pointer w-full"
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
