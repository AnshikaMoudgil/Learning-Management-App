'use strict';
'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { supabase } from '@/app/lib/supabaseClient';
import { courseSchema } from '@/app/lib/validations/course.schema';
import Select from '@/components/Select';
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

export default function NewCoursePage() {
  const router = useRouter();
  const [isLoading, setIsLoading] = useState(false);
  const [isUploading, setIsUploading] = useState(false);

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
  const [errors, setErrors] = useState<Record<string, string>>({});

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

    setIsUploading(true);
    const uploadToast = toast.loading('Uploading primary image...');

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
      toast.dismiss(uploadToast);
      toast.success('Course image uploaded successfully.');
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
      thumbnailUrl, previewVideoUrl,
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

    setIsLoading(true);
    const savingToast = toast.loading('Creating your course...');

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
      };

      const { error } = await supabase.from('courses').insert([coursePayload]);

      if (error) throw error;

      toast.dismiss(savingToast);
      toast.success('Course created successfully!');
      router.push('/dashboard/courses');
    } catch (err: unknown) {
      toast.dismiss(savingToast);
      toast.error(err instanceof Error ? err.message : 'Failed to create course.');
    } finally {
      setIsLoading(false);
    }
  };

  const inputClass = (field: string) =>
    `w-full rounded-lg border ${errors[field] ? 'border-rose-500' : 'border-zinc-800'} bg-zinc-950 py-3 px-4 text-sm text-zinc-100 placeholder-zinc-600 outline-none focus:border-teal-500 transition`;

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
        <h1 className="text-3xl font-extrabold text-white tracking-tight mt-2">Create New Course</h1>
        <p className="text-zinc-400 text-sm mt-1">Design and publish new curriculums.</p>
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
                    placeholder="e.g. Introduction to Python Programming"
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
                    placeholder="introduction-to-python"
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
                    placeholder="Brief single sentence overview of the course..."
                    value={shortDescription}
                    onChange={(e) => setShortDescription(e.target.value)}
                    className="w-full rounded-lg border border-zinc-800 bg-zinc-950 py-3 px-4 text-sm text-zinc-100 placeholder-zinc-600 outline-none focus:border-teal-500 transition resize-none"
                  />
                </div>

                <div className="space-y-1.5">
                  <label className="text-xs font-semibold uppercase tracking-wider text-zinc-400">Description</label>
                  <textarea
                    rows={6}
                    placeholder="Detailed rich course outline and materials description..."
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
                    placeholder="0.00"
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
                  Upload Image
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
                    <label className="text-xs font-semibold uppercase tracking-wider text-zinc-400">Preview Video URL</label>
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
                    <span className="text-xs text-zinc-500">Make this course instantly visible to users</span>
                  </div>
                </label>
              </div>

              <div className="pt-4 border-t border-zinc-800 flex flex-col gap-3">
                <button
                  type="submit"
                  disabled={isLoading || isUploading}
                  className="flex w-full items-center justify-center gap-2 rounded-xl bg-gradient-to-r from-teal-500 to-emerald-500 py-3.5 text-sm font-semibold text-zinc-950 transition hover:from-teal-400 hover:to-emerald-400 disabled:opacity-50 cursor-pointer shadow-lg shadow-teal-500/10 active:scale-[0.98]"
                >
                  {isLoading ? (
                    <>
                      <Loader2 className="h-4 w-4 animate-spin" />
                      Saving Course...
                    </>
                  ) : (
                    'Create Course'
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
