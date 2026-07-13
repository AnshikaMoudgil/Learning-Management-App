'use strict';
'use client';

import React, { useEffect, useState } from 'react';
import { useRouter, useParams } from 'next/navigation';
import { supabase } from '@/app/lib/supabaseClient';
import { courseSchema } from '@/app/lib/validations/course.schema';
import Select from '@/components/Select';
import ListEditor from '@/components/ListEditor';
import toast from 'react-hot-toast';
import { ArrowLeft, Loader2, Upload, BookOpen } from 'lucide-react';
import Link from 'next/link';

function extractStoragePathFromUrl(url: string): string | null {
  try {
    const u = new URL(url);
    const parts = u.pathname.split('/');
    const objectIndex = parts.indexOf('object');
    if (objectIndex === -1 || objectIndex + 2 >= parts.length) return null;
    return parts.slice(objectIndex + 2).join('/');
  } catch {
    return null;
  }
}

async function deleteImageFromBucket(imageUrl: string) {
  const filePath = extractStoragePathFromUrl(imageUrl);
  if (!filePath) return;
  await supabase.storage.from('courses').remove([filePath]);
}

export default function EditCoursePage() {
  const router = useRouter();
  const params = useParams();
  const courseId = params?.id as string;

  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [isUploading, setIsUploading] = useState(false);
  const [isAuthorized, setIsAuthorized] = useState(true);

  const [title, setTitle] = useState('');
  const [slug, setSlug] = useState('');
  const [shortDescription, setShortDescription] = useState('');
  const [description, setDescription] = useState('');
  const [language, setLanguage] = useState('English');
  const [level, setLevel] = useState('beginner');
  const [category, setCategory] = useState('');
  const [price, setPrice] = useState('');
  const [discountPrice, setDiscountPrice] = useState('');
  const [validityDays, setValidityDays] = useState('');
  const [estimatedDuration, setEstimatedDuration] = useState('');
  const [isPublished, setIsPublished] = useState(false);
  const [thumbnailUrl, setThumbnailUrl] = useState('');
  const [previewVideoUrl, setPreviewVideoUrl] = useState('');
  const [isBestseller, setIsBestseller] = useState(false);
  const [learningOutcomes, setLearningOutcomes] = useState<string[]>([]);
  const [requirements, setRequirements] = useState<string[]>([]);
  const [errors, setErrors] = useState<Record<string, string>>({});

  useEffect(() => {
    if (!courseId) return;

    const fetchCourse = async () => {
      try {
        setIsLoading(true);

        const { data: { session } } = await supabase.auth.getSession();
        const uid = session?.user?.id;

        let userRole = '';
        if (uid) {
          const { data: profile } = await supabase
            .from('profiles')
            .select('role')
            .eq('id', uid)
            .single();
          userRole = profile?.role || '';
        }

        const { data, error } = await supabase
          .from('courses')
          .select('*')
          .eq('id', courseId)
          .maybeSingle();

        if (error) throw error;
        if (!data) {
          toast.error('Course not found.');
          router.push('/dashboard/courses');
          return;
        }

        if (userRole === 'instructor' && data.created_by !== uid) {
          toast.error('You can only edit your own courses.');
          router.push('/dashboard/courses');
          return;
        }

        setIsAuthorized(true);
        setTitle(data.title || '');
        setSlug(data.slug || '');
        setShortDescription(data.short_description || '');
        setDescription(data.description || '');
        setLanguage(data.language || 'English');
        setLevel(data.level || 'beginner');
        setCategory(data.category || '');
        setPrice(data.price?.toString() || '0.00');
        setDiscountPrice(data.discount_price?.toString() || '');
        setValidityDays(data.validity_days?.toString() || '');
        setEstimatedDuration(data.estimated_duration || '');
        setIsPublished(data.is_published || false);
        setThumbnailUrl(data.thumbnail_url || '');
        setPreviewVideoUrl(data.preview_video_url || '');
        setIsBestseller(data.is_bestseller || false);
        setLearningOutcomes(Array.isArray(data.learning_outcomes) ? data.learning_outcomes : []);
        setRequirements(Array.isArray(data.requirements) ? data.requirements : []);
      } catch {
        toast.error('Failed to load course details.');
      } finally {
        setIsLoading(false);
      }
    };

    fetchCourse();
  }, [courseId, router]);

  const handleTitleChange = (val: string) => {
    setTitle(val);
    setSlug(
      val
        .toLowerCase()
        .replace(/[^a-z0-9]+/g, '-')
        .replace(/(^-|-$)+/g, '')
    );
  };

  const handleImageUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = e.target.files;
    if (!files || files.length === 0) return;

    const file = files[0];

    if (!file.type.startsWith('image/')) {
      toast.error('Selected file must be an image.');
      return;
    }

    const oldImageUrl = thumbnailUrl;

    setIsUploading(true);
    const uploadToast = toast.loading('Uploading course image...');

    try {
      const fileExt = file.name.split('.').pop();
      const fileName = `${Date.now()}-${Math.random().toString(36).substring(7)}.${fileExt}`;
      const filePath = `thumbnails/${fileName}`;

      const { error: uploadError } = await supabase.storage
        .from('courses')
        .upload(filePath, file, {
          cacheControl: '3600',
          upsert: false,
        });

      if (uploadError) throw uploadError;

      const { data: { publicUrl } } = supabase.storage
        .from('courses')
        .getPublicUrl(filePath);

      setThumbnailUrl(publicUrl);

      if (oldImageUrl) {
        await deleteImageFromBucket(oldImageUrl);
      }

      toast.dismiss(uploadToast);
      toast.success('Course image updated successfully.');
    } catch (err: unknown) {
      toast.dismiss(uploadToast);
      toast.error(err instanceof Error ? err.message : 'Image upload failed.');
    } finally {
      setIsUploading(false);
    }
  };

  const handleRemoveImage = async () => {
    if (thumbnailUrl) {
      await deleteImageFromBucket(thumbnailUrl);
    }
    setThumbnailUrl('');
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setErrors({});

    const formData = {
      title, slug, shortDescription, description, language, level, category,
      price, discountPrice, validityDays, estimatedDuration, isPublished,
      thumbnailUrl, previewVideoUrl, isBestseller,
      learningOutcomes, requirements,
    };

    const result = courseSchema.safeParse(formData);
    if (!result.success) {
      const fieldErrors: Record<string, string> = {};
      result.error.issues.forEach((issue) => {
        const path = issue.path.join('.');
        if (!fieldErrors[path]) fieldErrors[path] = issue.message;
      });
      setErrors(fieldErrors);
      toast.error(fieldErrors[Object.keys(fieldErrors)[0]]);
      return;
    }

    setIsSaving(true);
    const savingToast = toast.loading('Updating course details...');

    try {
      const coursePayload = {
        title,
        slug,
        short_description: shortDescription || null,
        description: description || null,
        language,
        level,
        category,
        price: Number(price),
        discount_price: discountPrice ? Number(discountPrice) : null,
        validity_days: validityDays ? parseInt(validityDays, 10) : null,
        estimated_duration: estimatedDuration || null,
        is_published: isPublished,
        thumbnail_url: thumbnailUrl || null,
        preview_video_url: previewVideoUrl || null,
        is_bestseller: isBestseller,
        learning_outcomes: (Array.isArray(learningOutcomes) ? learningOutcomes : [])
          .map((s) => s.trim())
          .filter(Boolean),
        requirements: (Array.isArray(requirements) ? requirements : [])
          .map((s) => s.trim())
          .filter(Boolean),
      };

      const { error } = await supabase
        .from('courses')
        .update(coursePayload)
        .eq('id', courseId);

      if (error) throw error;

      toast.dismiss(savingToast);
      toast.success('Course updated successfully!');
      router.push('/dashboard/courses');
    } catch (err: unknown) {
      toast.dismiss(savingToast);
      toast.error(err instanceof Error ? err.message : 'Failed to update course.');
    } finally {
      setIsSaving(false);
    }
  };

  const inputClass = (field: string) =>
    `w-full rounded-lg border ${errors[field] ? 'border-rose-500' : 'border-zinc-800'} bg-zinc-950 py-3 px-4 text-sm text-zinc-100 placeholder-zinc-600 outline-none focus:border-teal-500 transition`;

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
        <Link
          href="/dashboard/courses"
          className="inline-flex items-center gap-2 text-xs font-semibold text-zinc-400 hover:text-white transition-colors"
        >
          <ArrowLeft className="h-4 w-4" />
          Back to Courses
        </Link>
        <h1 className="text-3xl font-extrabold text-white tracking-tight mt-2">Edit Course</h1>
        <p className="text-zinc-400 text-sm mt-1">Modify structural and pricing parameters of the course.</p>
      </div>

      <form onSubmit={handleSubmit} className="space-y-6">
        <div className="grid gap-6 lg:grid-cols-3">
          <div className="lg:col-span-2 space-y-6">
            <div className="rounded-2xl border border-zinc-800 bg-zinc-900/30 p-6 space-y-6">
              <h2 className="text-lg font-bold text-white">General Information</h2>

              <div className="space-y-4">
                <div className="space-y-1.5">
                  <label className="text-xs font-semibold uppercase tracking-wider text-zinc-400">
                    Course Title <span className="text-rose-400">*</span>
                  </label>
                  <input
                    type="text"
                    value={title}
                    onChange={(e) => handleTitleChange(e.target.value)}
                    className={inputClass('title')}
                  />
                  {errors.title && <p className="text-xs text-rose-400">{errors.title}</p>}
                </div>

                <div className="space-y-1.5">
                  <label className="text-xs font-semibold uppercase tracking-wider text-zinc-400">
                    Slug <span className="text-rose-400">*</span>
                  </label>
                  <input
                    type="text"
                    value={slug}
                    readOnly
                    className="w-full rounded-lg border border-zinc-800 bg-zinc-950 py-3 px-4 text-sm text-zinc-500 placeholder-zinc-600 outline-none cursor-not-allowed"
                  />
                </div>

                <div className="grid gap-4 sm:grid-cols-2">
                  <div className="space-y-1.5">
                    <label className="text-xs font-semibold uppercase tracking-wider text-zinc-400">
                      Category <span className="text-rose-400">*</span>
                    </label>
                    <Select
                      value={category}
                      onChange={setCategory}
                      options={[
                        { value: '', label: 'Select category' },
                        { value: 'Hardware', label: 'Hardware' },
                        { value: 'Software', label: 'Software' },
                      ]}
                      placeholder="Select category"
                      error={errors.category}
                    />
                    {errors.category && <p className="text-xs text-rose-400">{errors.category}</p>}
                  </div>

                  <div className="space-y-1.5">
                    <label className="text-xs font-semibold uppercase tracking-wider text-zinc-400">
                      Language <span className="text-rose-400">*</span>
                    </label>
                    <input
                      type="text"
                      value={language}
                      onChange={(e) => setLanguage(e.target.value)}
                      className={inputClass('language')}
                    />
                    {errors.language && <p className="text-xs text-rose-400">{errors.language}</p>}
                  </div>
                </div>

                <div className="space-y-1.5">
                  <label className="text-xs font-semibold uppercase tracking-wider text-zinc-400">Short Description</label>
                  <textarea
                    rows={2}
                    value={shortDescription}
                    onChange={(e) => setShortDescription(e.target.value)}
                    className="w-full rounded-lg border border-zinc-800 bg-zinc-950 py-3 px-4 text-sm text-zinc-100 placeholder-zinc-600 outline-none focus:border-teal-500 transition resize-none"
                  />
                </div>

                <ListEditor
                  items={learningOutcomes}
                  onChange={setLearningOutcomes}
                  placeholder="e.g. Identify and test mobile ICs"
                  label="Learning Outcomes"
                />

                <ListEditor
                  items={requirements}
                  onChange={setRequirements}
                  placeholder="e.g. Basic knowledge of mobile hardware"
                  label="Requirements"
                />

                <div className="space-y-1.5">
                  <label className="text-xs font-semibold uppercase tracking-wider text-zinc-400">Description</label>
                  <textarea
                    rows={6}
                    value={description}
                    onChange={(e) => setDescription(e.target.value)}
                    className="w-full rounded-lg border border-zinc-800 bg-zinc-950 py-3 px-4 text-sm text-zinc-100 placeholder-zinc-600 outline-none focus:border-teal-500 transition"
                  />
                </div>
              </div>
            </div>

            <div className="rounded-2xl border border-zinc-800 bg-zinc-900/30 p-6 space-y-6">
              <h2 className="text-lg font-bold text-white">Pricing & Details</h2>
              <div className="grid gap-4 sm:grid-cols-2">
                <div className="space-y-1.5">
                  <label className="text-xs font-semibold uppercase tracking-wider text-zinc-400">
                    Base Price ($) <span className="text-rose-400">*</span>
                  </label>
                  <input
                    type="text"
                    value={price}
                    onChange={(e) => setPrice(e.target.value)}
                    className={inputClass('price')}
                  />
                  {errors.price && <p className="text-xs text-rose-400">{errors.price}</p>}
                </div>

                <div className="space-y-1.5">
                  <label className="text-xs font-semibold uppercase tracking-wider text-zinc-400">Discount Price ($)</label>
                  <input
                    type="text"
                    placeholder="Optional"
                    value={discountPrice}
                    onChange={(e) => setDiscountPrice(e.target.value)}
                    className={inputClass('discountPrice')}
                  />
                  {errors.discountPrice && <p className="text-xs text-rose-400">{errors.discountPrice}</p>}
                </div>

                <div className="space-y-1.5">
                  <label className="text-xs font-semibold uppercase tracking-wider text-zinc-400">
                    Validity (Days) <span className="text-rose-400">*</span>
                  </label>
                  <input
                    type="text"
                    placeholder="e.g. 365"
                    value={validityDays}
                    onChange={(e) => setValidityDays(e.target.value)}
                    className="w-full rounded-lg border border-zinc-800 bg-zinc-950 py-3 px-4 text-sm text-zinc-100 placeholder-zinc-600 outline-none focus:border-teal-500 transition"
                  />
                </div>

                <div className="space-y-1.5">
                  <label className="text-xs font-semibold uppercase tracking-wider text-zinc-400">
                    Estimated Duration <span className="text-rose-400">*</span>
                  </label>
                  <input
                    type="text"
                    placeholder="e.g. 12 hours"
                    value={estimatedDuration}
                    onChange={(e) => setEstimatedDuration(e.target.value)}
                    className="w-full rounded-lg border border-zinc-800 bg-zinc-950 py-3 px-4 text-sm text-zinc-100 placeholder-zinc-600 outline-none focus:border-teal-500 transition"
                  />
                </div>
              </div>
            </div>
          </div>

          <div className="space-y-6">
            <div className="rounded-2xl border border-zinc-800 bg-zinc-900/30 p-6 space-y-6">
              <h2 className="text-lg font-bold text-white">Course Thumbnail</h2>

              <div className="aspect-video w-full rounded-xl bg-zinc-950 border border-zinc-800 overflow-hidden relative flex flex-col items-center justify-center p-4">
                {thumbnailUrl ? (
                  <>
                    <img src={thumbnailUrl} alt="Thumbnail preview" className="h-full w-full object-cover rounded-lg" />
                    <button
                      type="button"
                      onClick={handleRemoveImage}
                      className="absolute bottom-2 right-2 bg-rose-950/80 border border-rose-900/30 text-rose-400 text-xs px-2.5 py-1.5 rounded-lg hover:bg-rose-900 font-semibold cursor-pointer"
                    >
                      Remove
                    </button>
                  </>
                ) : (
                  <div className="flex flex-col items-center text-center text-zinc-500 space-y-2">
                    <BookOpen className="h-10 w-10 text-zinc-700" />
                    <span className="text-xs font-medium">No Image Uploaded</span>
                  </div>
                )}
              </div>

              <div>
                <label className="flex w-full items-center justify-center gap-2 rounded-xl border border-dashed border-zinc-800 bg-zinc-950 py-4 text-sm font-semibold text-teal-400 hover:border-teal-500/40 hover:bg-teal-500/5 transition cursor-pointer select-none">
                  <Upload className="h-4 w-4" />
                  Upload New Image
                  <input
                    type="file"
                    accept="image/*"
                    onChange={handleImageUpload}
                    disabled={isUploading}
                    className="hidden"
                  />
                </label>
              </div>
            </div>

            <div className="rounded-2xl border border-zinc-800 bg-zinc-900/30 p-6 space-y-6">
              <h2 className="text-lg font-bold text-white">Course Video</h2>

              <div className="space-y-1.5">
                <label className="text-xs font-semibold uppercase tracking-wider text-zinc-400">Video URL</label>
                <input
                  type="text"
                  placeholder="https://www.youtube.com/watch?v=..."
                  value={previewVideoUrl}
                  onChange={(e) => setPreviewVideoUrl(e.target.value)}
                  className="w-full rounded-lg border border-zinc-800 bg-zinc-950 py-3 px-4 text-sm text-zinc-100 placeholder-zinc-600 outline-none focus:border-teal-500 transition"
                />
              </div>

              {previewVideoUrl && (
                <div className="aspect-video w-full rounded-xl bg-zinc-950 border border-zinc-800 overflow-hidden">
                  {previewVideoUrl.includes('youtube.com') || previewVideoUrl.includes('youtu.be') ? (
                    <iframe
                      src={previewVideoUrl.replace('watch?v=', 'embed/').replace('youtu.be/', 'youtube.com/embed/')}
                      className="h-full w-full"
                      allowFullScreen
                      allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                    />
                  ) : previewVideoUrl.includes('vimeo.com') ? (
                    <iframe
                      src={previewVideoUrl.replace('vimeo.com', 'player.vimeo.com/video')}
                      className="h-full w-full"
                      allowFullScreen
                    />
                  ) : (
                    <video src={previewVideoUrl} controls className="h-full w-full" />
                  )}
                </div>
              )}
            </div>

            <div className="rounded-2xl border border-zinc-800 bg-zinc-900/30 p-6 space-y-6">
              <h2 className="text-lg font-bold text-white">Publish Settings</h2>

              <div className="space-y-4">
                <div className="space-y-1.5">
                  <label className="text-xs font-semibold uppercase tracking-wider text-zinc-400 block">
                    Course Level <span className="text-rose-400">*</span>
                  </label>
                  <Select
                    value={level}
                    onChange={setLevel}
                    options={[
                      { value: 'beginner', label: 'Beginner' },
                      { value: 'intermediate', label: 'Intermediate' },
                      { value: 'advanced', label: 'Advanced' },
                    ]}
                    error={errors.level}
                  />
                  {errors.level && <p className="text-xs text-rose-400">{errors.level}</p>}
                </div>

                <label className="flex items-center gap-3 cursor-pointer select-none py-2">
                  <input
                    type="checkbox"
                    checked={isPublished}
                    onChange={(e) => setIsPublished(e.target.checked)}
                    className="h-4 w-4 rounded border-zinc-800 bg-zinc-950 text-teal-500 focus:ring-teal-500/20 focus:ring-offset-0 focus:ring-2"
                  />
                  <div>
                    <span className="text-sm font-semibold text-white block">Publish Course</span>
                    <span className="text-xs text-zinc-500">Make this course visible to users</span>
                  </div>
                </label>

                <label className="flex items-center gap-3 cursor-pointer select-none py-2">
                  <input
                    type="checkbox"
                    checked={isBestseller}
                    onChange={(e) => setIsBestseller(e.target.checked)}
                    className="h-4 w-4 rounded border-zinc-800 bg-zinc-950 text-amber-500 focus:ring-amber-500/20 focus:ring-offset-0 focus:ring-2"
                  />
                  <div>
                    <span className="text-sm font-semibold text-white block">Bestseller</span>
                    <span className="text-xs text-zinc-500">Mark this course as bestseller in the store</span>
                  </div>
                </label>
              </div>

              <div className="pt-4 border-t border-zinc-800 flex flex-col gap-3">
                <button
                  type="submit"
                  disabled={isSaving || isUploading}
                  className="flex w-full items-center justify-center gap-2 rounded-xl bg-gradient-to-r from-teal-500 to-emerald-500 py-3.5 text-sm font-semibold text-zinc-950 transition hover:from-teal-400 hover:to-emerald-400 disabled:opacity-50 cursor-pointer shadow-lg shadow-teal-500/10 active:scale-[0.98]"
                >
                  {isSaving ? (
                    <>
                      <Loader2 className="h-4 w-4 animate-spin" />
                      Saving Changes...
                    </>
                  ) : (
                    'Save Changes'
                  )}
                </button>

                <Link
                  href="/dashboard/courses"
                  className="flex w-full items-center justify-center gap-2 rounded-xl border border-zinc-800 bg-zinc-950 py-3.5 text-sm font-semibold text-zinc-400 hover:text-zinc-200 transition"
                >
                  Cancel
                </Link>
              </div>
            </div>
          </div>
        </div>
      </form>
    </div>
  );
}
