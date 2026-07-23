'use client';

import React, { useEffect, useState } from 'react';
import { useRouter, useParams } from 'next/navigation';
import { supabase } from '@/app/lib/supabaseClient';
import { courseSchema } from '@/app/lib/validations/course.schema';
import Select from '@/components/Select';
import ListEditor from '@/components/ListEditor';
import toast from 'react-hot-toast';
import Image from 'next/image';
import { Loader2, Upload, BookOpen, AlertTriangle } from 'lucide-react';
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
  const [instructorId, setInstructorId] = useState('');
  const [averageRating, setAverageRating] = useState('');
  const [reviewsCount, setReviewsCount] = useState('');
  const [instructors, setInstructors] = useState<{ id: string; full_name: string }[]>([]);
  const [learningOutcomes, setLearningOutcomes] = useState<string[]>([]);
  const [requirements, setRequirements] = useState<string[]>([]);
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [profileIncomplete, setProfileIncomplete] = useState(false);
  const [checkingProfile, setCheckingProfile] = useState(true);

  useEffect(() => {
    supabase
      .from('profiles')
      .select('id, full_name')
      .eq('role', 'instructor')
      .then(({ data, error }) => {
        if (!error && data) setInstructors(data);
      });
  }, []);

  useEffect(() => {
    supabase.auth.getSession().then(async ({ data: { session } }) => {
      if (!session?.user?.id) { setCheckingProfile(false); return; }
      const { data: profile } = await supabase
        .from('profiles')
        .select('role')
        .eq('id', session.user.id)
        .single();
      if (profile?.role !== 'instructor') { setCheckingProfile(false); return; }
      const { data: instructorData } = await supabase
        .from('instructor_profiles')
        .select('phone, specialization, experience_years, education')
        .eq('id', session.user.id)
        .maybeSingle();
      const { data: fullProfile } = await supabase
        .from('profiles')
        .select('full_name, avatar_url')
        .eq('id', session.user.id)
        .single();
      const missing: string[] = [];
      if (!fullProfile?.full_name?.trim()) missing.push('Full Name');
      if (!fullProfile?.avatar_url) missing.push('Profile Photo');
      if (!instructorData?.phone?.trim()) missing.push('Phone');
      if (!instructorData?.specialization?.trim()) missing.push('Specialization');
      if (!instructorData?.experience_years) missing.push('Years of Experience');
      if (!instructorData?.education?.trim()) missing.push('Education');
      if (missing.length > 0) setProfileIncomplete(true);
      setCheckingProfile(false);
    });
  }, []);

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
        setInstructorId(data.instructor_id || '');
        setAverageRating(data.average_rating?.toString() || '');
        setReviewsCount(data.reviews_count?.toString() || '');
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

  const validateImageDimensions = (file: File): Promise<{ width: number; height: number } | null> => {
    return new Promise((resolve) => {
      const img = new window.Image();
      const url = URL.createObjectURL(file);
      img.onload = () => {
        URL.revokeObjectURL(url);
        resolve({ width: img.width, height: img.height });
      };
      img.onerror = () => {
        URL.revokeObjectURL(url);
        resolve(null);
      };
      img.src = url;
    });
  };

  const handleImageUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = e.target.files;
    if (!files || files.length === 0) return;

    const file = files[0];

    if (!file.type.startsWith('image/')) {
      toast.error('Selected file must be an image.');
      return;
    }

    // Validate dimensions
    const dims = await validateImageDimensions(file);
    if (!dims) {
      toast.error('Failed to read image dimensions.');
      return;
    }

    const { width, height } = dims;
    const MIN_W = 1280;
    const MIN_H = 720;
    const TARGET = 16 / 9;
    const TOLERANCE = 0.05;

    if (width < MIN_W || height < MIN_H) {
      toast.error(`Image must be at least ${MIN_W}×${MIN_H}px (received ${width}×${height}px).`);
      return;
    }

    const ratio = width / height;
    if (Math.abs(ratio - TARGET) > TOLERANCE) {
      toast.error(`Image must be 16:9 aspect ratio (received ${width}×${height}).`);
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
      price, discountPrice, instructorId, averageRating, reviewsCount,
      validityDays, estimatedDuration, isPublished,
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
        instructor_id: instructorId || null,
        average_rating: averageRating ? parseFloat(averageRating) : 0,
        reviews_count: reviewsCount ? parseInt(reviewsCount, 10) : 0,
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
    `w-full rounded-lg border ${errors[field] ? 'border-rose-500' : 'border-gray-200'} bg-white py-3 px-4 text-sm text-gray-900 placeholder-gray-400 outline-none focus:border-blue-500 transition`;

  if (isLoading) {
    return (
      <div className="flex h-64 items-center justify-center">
        <Loader2 className="h-8 w-8 animate-spin text-blue-500" />
      </div>
    );
  }

  return (
    <div className="space-y-8 animate-in fade-in duration-300">
      <div>
        <h1 className="text-3xl font-extrabold text-gray-900 tracking-tight">Edit Course</h1>
        <p className="text-gray-500 text-sm mt-1">Modify structural and pricing parameters of the course.</p>
      </div>

      {checkingProfile ? (
        <div className="flex h-48 items-center justify-center">
          <Loader2 className="h-8 w-8 animate-spin text-blue-500" />
        </div>
      ) : profileIncomplete ? (
        <div className="rounded-2xl border border-amber-800 bg-amber-950/20 p-6 space-y-4">
          <div className="flex items-start gap-3">
            <AlertTriangle className="h-6 w-6 text-amber-400 shrink-0 mt-0.5" />
            <div>
              <h3 className="text-lg font-bold text-amber-300">Profile Incomplete</h3>
              <p className="text-sm text-amber-200/80 mt-1">
                You must fill all required fields in your instructor profile before editing courses.
              </p>
            </div>
          </div>
          <Link
            href="/dashboard/instructor-profile"
            className="inline-flex items-center gap-2 rounded-xl bg-amber-500 px-5 py-3 text-sm font-semibold text-white hover:bg-amber-400 transition cursor-pointer"
          >
            Complete My Profile
          </Link>
        </div>
      ) : (
      <form onSubmit={handleSubmit} className="space-y-6">
        <div className="grid gap-6 lg:grid-cols-3">
          <div className="lg:col-span-2 space-y-6">
            <div className="rounded-2xl border border-gray-200 bg-white p-6 space-y-6">
              <h2 className="text-lg font-bold text-gray-900">General Information</h2>

              <div className="space-y-4">
                <div className="space-y-1.5">
                  <label className="text-xs font-semibold uppercase tracking-wider text-gray-500">
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
                  <label className="text-xs font-semibold uppercase tracking-wider text-gray-500">
                    Slug <span className="text-rose-400">*</span>
                  </label>
                  <input
                    type="text"
                    value={slug}
                    readOnly
                    className="w-full rounded-lg border border-gray-200 bg-white py-3 px-4 text-sm text-gray-400 placeholder-gray-400 outline-none cursor-not-allowed"
                  />
                </div>

                <div className="grid gap-4 sm:grid-cols-2">
                  <div className="space-y-1.5">
                  <label className="text-xs font-semibold uppercase tracking-wider text-gray-500">
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
                  <label className="text-xs font-semibold uppercase tracking-wider text-gray-500">
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
                  <label className="text-xs font-semibold uppercase tracking-wider text-gray-500">Short Description <span className="text-rose-400">*</span></label>
                  <textarea
                    rows={2}
                    value={shortDescription}
                    onChange={(e) => setShortDescription(e.target.value)}
                    className="w-full rounded-lg border border-gray-200 bg-white py-3 px-4 text-sm text-gray-900 placeholder-gray-400 outline-none focus:border-blue-500 transition resize-none"
                  />
                </div>

                <ListEditor
                  items={learningOutcomes}
                  onChange={setLearningOutcomes}
                  placeholder="e.g. Identify and test mobile ICs"
                  label="Learning Outcomes *"
                />

                <ListEditor
                  items={requirements}
                  onChange={setRequirements}
                  placeholder="e.g. Basic knowledge of mobile hardware"
                  label="Requirements *"
                />

                <div className="space-y-1.5">
                  <label className="text-xs font-semibold uppercase tracking-wider text-gray-500">Description</label>
                  <textarea
                    rows={6}
                    value={description}
                    onChange={(e) => setDescription(e.target.value)}
                    className="w-full rounded-lg border border-gray-200 bg-white py-3 px-4 text-sm text-gray-900 placeholder-gray-400 outline-none focus:border-blue-500 transition"
                  />
                </div>
              </div>
            </div>

            <div className="rounded-2xl border border-gray-200 bg-white p-6 space-y-6">
              <h2 className="text-lg font-bold text-gray-900">Pricing & Details</h2>
              <div className="grid gap-4 sm:grid-cols-2">
                <div className="space-y-1.5">
                  <label className="text-xs font-semibold uppercase tracking-wider text-gray-500">
                    Base Price (₹) <span className="text-rose-400">*</span>
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
                  <label className="text-xs font-semibold uppercase tracking-wider text-gray-500">Discount Price (₹)</label>
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
                  <label className="text-xs font-semibold uppercase tracking-wider text-gray-500">
                    Validity (Days) <span className="text-rose-400">*</span>
                  </label>
                  <input
                    type="text"
                    placeholder="e.g. 365"
                    value={validityDays}
                    onChange={(e) => setValidityDays(e.target.value)}
                    className="w-full rounded-lg border border-gray-200 bg-white py-3 px-4 text-sm text-gray-900 placeholder-gray-400 outline-none focus:border-blue-500 transition"
                  />
                </div>

                <div className="space-y-1.5">
                  <label className="text-xs font-semibold uppercase tracking-wider text-gray-500">
                    Estimated Duration (hours) <span className="text-rose-400">*</span>
                  </label>
                  <input
                    type="number"
                    min="0"
                    step="1"
                    placeholder="e.g. 35"
                    value={estimatedDuration}
                    onChange={(e) => setEstimatedDuration(e.target.value)}
                    className="w-full rounded-lg border border-gray-200 bg-white py-3 px-4 text-sm text-gray-900 placeholder-gray-400 outline-none focus:border-blue-500 transition"
                  />
                </div>
              </div>
            </div>

            <div className="rounded-2xl border border-gray-200 bg-white p-6 space-y-6">
              <h2 className="text-lg font-bold text-gray-900">Instructor & Ratings</h2>
              <div className="space-y-4">
                <div className="space-y-1.5">
                  <label className="text-xs font-semibold uppercase tracking-wider text-gray-500">Instructor <span className="text-rose-400">*</span></label>
                  <Select
                    value={instructorId}
                    onChange={setInstructorId}
                    options={[
                      { value: '', label: 'No instructor' },
                      ...instructors.map((i) => ({ value: i.id, label: i.full_name })),
                    ]}
                    placeholder="Select instructor"
                    error={errors.instructorId}
                  />
                  {errors.instructorId && <p className="text-xs text-rose-400">{errors.instructorId}</p>}
                </div>
                <div className="grid gap-4 sm:grid-cols-2">
                  <div className="space-y-1.5">
                    <label className="text-xs font-semibold uppercase tracking-wider text-gray-500">Average Rating</label>
                    <input
                      type="text"
                      placeholder="0.0 - 5.0"
                      value={averageRating}
                      onChange={(e) => setAverageRating(e.target.value)}
                      className={inputClass('averageRating')}
                    />
                    {errors.averageRating && <p className="text-xs text-rose-400">{errors.averageRating}</p>}
                  </div>
                  <div className="space-y-1.5">
                    <label className="text-xs font-semibold uppercase tracking-wider text-gray-500">Reviews Count</label>
                    <input
                      type="text"
                      placeholder="e.g. 150"
                      value={reviewsCount}
                      onChange={(e) => setReviewsCount(e.target.value)}
                      className={inputClass('reviewsCount')}
                    />
                    {errors.reviewsCount && <p className="text-xs text-rose-400">{errors.reviewsCount}</p>}
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div className="space-y-6">
            <div className="rounded-2xl border border-gray-200 bg-white p-6 space-y-6">
              <h2 className="text-lg font-bold text-gray-900">Course Thumbnail <span className="text-rose-400">*</span></h2>

              <div className="aspect-video w-full rounded-xl bg-white border border-gray-200 overflow-hidden relative flex flex-col items-center justify-center p-4">
                {thumbnailUrl ? (
                  <>
                    <Image src={thumbnailUrl} alt="Thumbnail preview" width={1280} height={720} className="h-full w-full object-cover rounded-lg" />
                    <button
                      type="button"
                      onClick={handleRemoveImage}
                      className="absolute bottom-2 right-2 bg-rose-950/80 border border-rose-900/30 text-rose-400 text-xs px-2.5 py-1.5 rounded-lg hover:bg-rose-900 font-semibold cursor-pointer"
                    >
                      Remove
                    </button>
                  </>
                ) : (
                  <div className="flex flex-col items-center text-center text-gray-400 space-y-2">
                    <BookOpen className="h-10 w-10 text-gray-400" />
                    <span className="text-xs font-medium">No Image Uploaded</span>
                  </div>
                )}
              </div>

              <div>
                <label className="flex w-full items-center justify-center gap-2 rounded-xl border border-dashed border-gray-200 bg-white py-4 text-sm font-semibold text-blue-600 hover:border-blue-500/40 hover:bg-blue-600/5 transition cursor-pointer select-none">
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
                <p className="text-xs text-gray-400 text-center mt-2">Recommended: 1280 × 720 px (16:9)</p>
              </div>
            </div>

            <div className="rounded-2xl border border-gray-200 bg-white p-6 space-y-6">
              <h2 className="text-lg font-bold text-gray-900">Course Video</h2>

              <div className="space-y-1.5">
                <label className="text-xs font-semibold uppercase tracking-wider text-gray-500">Video URL</label>
                <input
                  type="text"
                  placeholder="https://www.youtube.com/watch?v=..."
                  value={previewVideoUrl}
                  onChange={(e) => setPreviewVideoUrl(e.target.value)}
                  className="w-full rounded-lg border border-gray-200 bg-white py-3 px-4 text-sm text-gray-900 placeholder-gray-400 outline-none focus:border-blue-500 transition"
                />
              </div>

              {previewVideoUrl && (
                <div className="aspect-video w-full rounded-xl bg-white border border-gray-200 overflow-hidden">
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

            <div className="rounded-2xl border border-gray-200 bg-white p-6 space-y-6">
              <h2 className="text-lg font-bold text-gray-900">Publish Settings</h2>

              <div className="space-y-4">
                <div className="space-y-1.5">
                  <label className="text-xs font-semibold uppercase tracking-wider text-gray-500 block">
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
                    className="h-4 w-4 rounded border-gray-200 bg-white text-blue-500 focus:ring-blue-500/20 focus:ring-offset-0 focus:ring-2"
                  />
                  <div>
                    <span className="text-sm font-semibold text-gray-900 block">Publish Course</span>
                    <span className="text-xs text-gray-400">Make this course visible to users</span>
                  </div>
                </label>

                <label className="flex items-center gap-3 cursor-pointer select-none py-2">
                  <input
                    type="checkbox"
                    checked={isBestseller}
                    onChange={(e) => setIsBestseller(e.target.checked)}
                    className="h-4 w-4 rounded border-gray-200 bg-white text-amber-500 focus:ring-amber-500/20 focus:ring-offset-0 focus:ring-2"
                  />
                  <div>
                    <span className="text-sm font-semibold text-gray-900 block">Bestseller</span>
                    <span className="text-xs text-gray-400">Mark this course as bestseller in the store</span>
                  </div>
                </label>
              </div>

              <div className="pt-4 border-t border-gray-200 flex flex-col gap-3">
                <button
                  type="submit"
                  disabled={isSaving || isUploading}
                  className="flex w-full items-center justify-center gap-2 rounded-xl bg-gradient-to-r from-blue-600 to-blue-500 py-3.5 text-sm font-semibold text-white transition hover:from-blue-500 hover:to-blue-400 disabled:opacity-50 cursor-pointer shadow-lg shadow-blue-500/10 active:scale-[0.98]"
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
                  className="flex w-full items-center justify-center gap-2 rounded-xl border border-gray-200 bg-white py-3.5 text-sm font-semibold text-gray-500 hover:text-gray-700 transition"
                >
                  Cancel
                </Link>
              </div>
            </div>
          </div>
        </div>
      </form>
      )}
    </div>
  );
}
