'use strict';
'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { supabase } from '@/app/lib/supabaseClient';
import toast from 'react-hot-toast';
import { Loader2, Upload, Save, Plus, X } from 'lucide-react';

interface InstructorProfile {
  full_name: string;
  avatar_url: string | null;
  specialization: string;
  bio: string;
  phone: string;
  qualifications: string[];
  experience_years: number | null;
  education: string;
  social_links: {
    linkedin?: string;
    twitter?: string;
    youtube?: string;
    website?: string;
  };
}

export default function InstructorProfilePage() {
  const router = useRouter();
  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [isUploading, setIsUploading] = useState(false);
  const [userId, setUserId] = useState<string | null>(null);

  const [fullName, setFullName] = useState('');
  const [avatarUrl, setAvatarUrl] = useState<string | null>(null);
  const [specialization, setSpecialization] = useState('');
  const [bio, setBio] = useState('');
  const [phone, setPhone] = useState('');
  const [qualifications, setQualifications] = useState<string[]>([]);
  const [qualificationInput, setQualificationInput] = useState('');
  const [experienceYears, setExperienceYears] = useState('');
  const [education, setEducation] = useState('');
  const [linkedin, setLinkedin] = useState('');
  const [twitter, setTwitter] = useState('');
  const [youtube, setYoutube] = useState('');
  const [website, setWebsite] = useState('');
  const [formErrors, setFormErrors] = useState<Record<string, string>>({});

  useEffect(() => {
    async function loadProfile() {
      try {
        const { data: { session } } = await supabase.auth.getSession();
        if (!session) {
          router.push('/login');
          return;
        }

        const uid = session.user.id;
        setUserId(uid);

        const { data: profileData } = await supabase
          .from('profiles')
          .select('full_name, avatar_url, role')
          .eq('id', uid)
          .single();

        if (profileData) {
          setFullName(profileData.full_name || '');
          setAvatarUrl(profileData.avatar_url);
          if (profileData.role !== 'instructor') {
            toast.error('Access denied. Only instructors can access this page.');
            router.push('/dashboard');
            return;
          }
        }

        const { data: instructorData } = await supabase
          .from('instructor_profiles')
          .select('*')
          .eq('id', uid)
          .maybeSingle();

        if (instructorData) {
          setSpecialization(instructorData.specialization || '');
          setBio(instructorData.bio || '');
          setPhone(instructorData.phone || '');
          setQualifications(instructorData.qualifications || []);
          setExperienceYears(instructorData.experience_years?.toString() || '');
          setEducation(instructorData.education || '');
          const links = instructorData.social_links || {};
          setLinkedin(links.linkedin || '');
          setTwitter(links.twitter || '');
          setYoutube(links.youtube || '');
          setWebsite(links.website || '');
        }
      } catch {
        toast.error('Failed to load profile.');
      } finally {
        setIsLoading(false);
      }
    }

    loadProfile();
  }, [router]);

  const addQualification = () => {
    const val = qualificationInput.trim();
    if (val && !qualifications.includes(val)) {
      setQualifications([...qualifications, val]);
      setQualificationInput('');
    }
  };

  const removeQualification = (index: number) => {
    setQualifications(qualifications.filter((_, i) => i !== index));
  };

  const handleAvatarUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = e.target.files;
    if (!files || files.length === 0) return;

    const file = files[0];
    if (!file.type.startsWith('image/')) {
      toast.error('Selected file must be an image.');
      return;
    }

    setIsUploading(true);
    const uploadToast = toast.loading('Uploading avatar...');

    try {
      const fileExt = file.name.split('.').pop();
      const fileName = `avatars/${userId}-${Date.now()}.${fileExt}`;

      const { error: uploadError } = await supabase.storage
        .from('avatars')
        .upload(fileName, file, {
          cacheControl: '3600',
          upsert: true,
        });

      if (uploadError) throw uploadError;

      const { data: { publicUrl } } = supabase.storage
        .from('avatars')
        .getPublicUrl(fileName);

      const { error: updateError } = await supabase
        .from('profiles')
        .update({ avatar_url: publicUrl })
        .eq('id', userId);

      if (updateError) throw updateError;

      setAvatarUrl(publicUrl);
      toast.dismiss(uploadToast);
      toast.success('Avatar updated successfully.');
    } catch (err: unknown) {
      toast.dismiss(uploadToast);
      toast.error(err instanceof Error ? err.message : 'Avatar upload failed.');
    } finally {
      setIsUploading(false);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!userId) return;

    const errors: Record<string, string> = {};
    if (!fullName.trim()) errors.fullName = 'Full Name is required.';
    if (!phone.trim()) errors.phone = 'Phone is required.';
    if (!specialization.trim()) errors.specialization = 'Specialization is required.';
    if (!experienceYears.trim()) errors.experienceYears = 'Years of Experience is required.';
    if (!education.trim()) errors.education = 'Education is required.';
    if (!avatarUrl) errors.avatarUrl = 'Profile photo is required.';

    setFormErrors(errors);
    if (Object.keys(errors).length > 0) {
      toast.error(errors[Object.keys(errors)[0]]);
      return;
    }

    setIsSaving(true);
    const savingToast = toast.loading('Saving profile...');

    try {
      const { error: profileError } = await supabase
        .from('profiles')
        .update({ full_name: fullName })
        .eq('id', userId);

      if (profileError) throw profileError;

      const instructorPayload = {
        specialization: specialization || null,
        bio: bio || null,
        phone: phone || null,
        qualifications: qualifications.length > 0 ? qualifications : null,
        experience_years: experienceYears ? parseInt(experienceYears, 10) : null,
        education: education || null,
        social_links: {
          ...(linkedin && { linkedin }),
          ...(twitter && { twitter }),
          ...(youtube && { youtube }),
          ...(website && { website }),
        },
      };

      const { error: upsertError } = await supabase
        .from('instructor_profiles')
        .upsert({ id: userId, ...instructorPayload });

      if (upsertError) throw upsertError;

      toast.dismiss(savingToast);
      toast.success('Profile saved successfully!');
    } catch (err: unknown) {
      toast.dismiss(savingToast);
      toast.error(err instanceof Error ? err.message : 'Failed to save profile.');
    } finally {
      setIsSaving(false);
    }
  };

  const inputClass = 'w-full rounded-lg border border-gray-200 bg-white py-3 px-4 text-sm text-gray-900 placeholder-gray-400 outline-none focus:border-blue-500 transition';

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
        <h1 className="text-3xl font-extrabold text-gray-900 tracking-tight">My Instructor Profile</h1>
        <p className="text-gray-500 text-sm mt-1">Manage your personal information and professional details.</p>
      </div>

      <form onSubmit={handleSubmit} className="space-y-6">
        <div className="grid gap-6 lg:grid-cols-3">
          <div className="lg:col-span-2 space-y-6">
            {/* Basic Information */}
            <div className="rounded-2xl border border-gray-200 bg-white p-6 space-y-6 shadow-sm">
              <h2 className="text-lg font-bold text-gray-900">Basic Information</h2>

              <div className="space-y-4">
                <div className="space-y-1.5">
                  <label className="text-xs font-semibold uppercase tracking-wider text-gray-500">Full Name <span className="text-rose-400">*</span></label>
                  <input
                    type="text"
                    placeholder="Your full name"
                    value={fullName}
                    onChange={(e) => { setFullName(e.target.value); setFormErrors((prev) => ({ ...prev, fullName: '' })); }}
                    className={`${inputClass} ${formErrors.fullName ? 'border-rose-500' : ''}`}
                  />
                  {formErrors.fullName && <p className="text-xs text-rose-400">{formErrors.fullName}</p>}
                </div>

                <div className="grid gap-4 sm:grid-cols-2">
                  <div className="space-y-1.5">
                    <label className="text-xs font-semibold uppercase tracking-wider text-gray-500">Phone <span className="text-rose-400">*</span></label>
                    <input
                      type="text"
                      placeholder="+1 234 567 8900"
                      value={phone}
                      onChange={(e) => { setPhone(e.target.value); setFormErrors((prev) => ({ ...prev, phone: '' })); }}
                      className={`${inputClass} ${formErrors.phone ? 'border-rose-500' : ''}`}
                    />
                    {formErrors.phone && <p className="text-xs text-rose-400">{formErrors.phone}</p>}
                  </div>

                  <div className="space-y-1.5">
                    <label className="text-xs font-semibold uppercase tracking-wider text-gray-500">Specialization <span className="text-rose-400">*</span></label>
                    <input
                      type="text"
                      placeholder="e.g. Hardware, Software, Both"
                      value={specialization}
                      onChange={(e) => { setSpecialization(e.target.value); setFormErrors((prev) => ({ ...prev, specialization: '' })); }}
                      className={`${inputClass} ${formErrors.specialization ? 'border-rose-500' : ''}`}
                    />
                    {formErrors.specialization && <p className="text-xs text-rose-400">{formErrors.specialization}</p>}
                  </div>
                </div>

                <div className="space-y-1.5">
                  <label className="text-xs font-semibold uppercase tracking-wider text-gray-500">Bio</label>
                  <textarea
                    rows={4}
                    placeholder="Tell us about yourself, your experience and teaching philosophy..."
                    value={bio}
                    onChange={(e) => setBio(e.target.value)}
                    className="w-full rounded-lg border border-gray-200 bg-white py-3 px-4 text-sm text-gray-900 placeholder-gray-400 outline-none focus:border-blue-500 transition resize-none"
                  />
                </div>
              </div>
            </div>

            {/* Professional Details */}
            <div className="rounded-2xl border border-gray-200 bg-white p-6 space-y-6 shadow-sm">
              <h2 className="text-lg font-bold text-gray-900">Professional Details</h2>

              <div className="grid gap-4 sm:grid-cols-2">
                <div className="space-y-1.5">
                  <label className="text-xs font-semibold uppercase tracking-wider text-gray-500">Years of Experience <span className="text-rose-400">*</span></label>
                  <input
                    type="number"
                    min="0"
                    placeholder="e.g. 5"
                    value={experienceYears}
                    onChange={(e) => { setExperienceYears(e.target.value); setFormErrors((prev) => ({ ...prev, experienceYears: '' })); }}
                    className={`${inputClass} ${formErrors.experienceYears ? 'border-rose-500' : ''}`}
                  />
                  {formErrors.experienceYears && <p className="text-xs text-rose-400">{formErrors.experienceYears}</p>}
                </div>

                <div className="space-y-1.5">
                  <label className="text-xs font-semibold uppercase tracking-wider text-gray-500">Education <span className="text-rose-400">*</span></label>
                  <input
                    type="text"
                    placeholder="e.g. B.Tech in Electronics"
                    value={education}
                    onChange={(e) => { setEducation(e.target.value); setFormErrors((prev) => ({ ...prev, education: '' })); }}
                    className={`${inputClass} ${formErrors.education ? 'border-rose-500' : ''}`}
                  />
                  {formErrors.education && <p className="text-xs text-rose-400">{formErrors.education}</p>}
                </div>
              </div>

              <div className="space-y-1.5">
                <label className="text-xs font-semibold uppercase tracking-wider text-gray-500">Qualifications & Certifications</label>
                <div className="flex gap-2">
                  <input
                    type="text"
                    placeholder="e.g. Certified Mobile Hardware Engineer"
                    value={qualificationInput}
                    onChange={(e) => setQualificationInput(e.target.value)}
                    onKeyDown={(e) => { if (e.key === 'Enter') { e.preventDefault(); addQualification(); } }}
                    className={inputClass}
                  />
                  <button
                    type="button"
                    onClick={addQualification}
                    className="flex items-center gap-1 rounded-lg bg-gradient-to-r from-blue-600 to-blue-500 px-4 py-3 text-xs font-semibold text-white hover:from-blue-500 hover:to-blue-400 transition cursor-pointer"
                  >
                    <Plus className="h-4 w-4" />
                    Add
                  </button>
                </div>
                {qualifications.length > 0 && (
                  <div className="flex flex-wrap gap-2 mt-3">
                    {qualifications.map((q, i) => (
                      <span
                        key={i}
                        className="inline-flex items-center gap-1.5 rounded-full bg-gray-100 border border-gray-300 px-3 py-1.5 text-xs font-medium text-gray-700"
                      >
                        {q}
                        <button
                          type="button"
                          onClick={() => removeQualification(i)}
                          className="text-gray-400 hover:text-rose-400 transition cursor-pointer"
                        >
                          <X className="h-3 w-3" />
                        </button>
                      </span>
                    ))}
                  </div>
                )}
              </div>
            </div>

            {/* Social Links */}
            <div className="rounded-2xl border border-gray-200 bg-white p-6 space-y-6 shadow-sm">
              <h2 className="text-lg font-bold text-gray-900">Social Links</h2>

              <div className="grid gap-4 sm:grid-cols-2">
                <div className="space-y-1.5">
                  <label className="text-xs font-semibold uppercase tracking-wider text-gray-500">LinkedIn</label>
                  <input
                    type="url"
                    placeholder="https://linkedin.com/in/..."
                    value={linkedin}
                    onChange={(e) => setLinkedin(e.target.value)}
                    className={inputClass}
                  />
                </div>

                <div className="space-y-1.5">
                  <label className="text-xs font-semibold uppercase tracking-wider text-gray-500">Twitter / X</label>
                  <input
                    type="url"
                    placeholder="https://twitter.com/..."
                    value={twitter}
                    onChange={(e) => setTwitter(e.target.value)}
                    className={inputClass}
                  />
                </div>

                <div className="space-y-1.5">
                  <label className="text-xs font-semibold uppercase tracking-wider text-gray-500">YouTube</label>
                  <input
                    type="url"
                    placeholder="https://youtube.com/@..."
                    value={youtube}
                    onChange={(e) => setYoutube(e.target.value)}
                    className={inputClass}
                  />
                </div>

                <div className="space-y-1.5">
                  <label className="text-xs font-semibold uppercase tracking-wider text-gray-500">Website</label>
                  <input
                    type="url"
                    placeholder="https://..."
                    value={website}
                    onChange={(e) => setWebsite(e.target.value)}
                    className={inputClass}
                  />
                </div>
              </div>
            </div>
          </div>

          <div className="space-y-6">
            {/* Avatar Upload */}
            <div className="rounded-2xl border border-gray-200 bg-white p-6 space-y-6 shadow-sm">
              <h2 className="text-lg font-bold text-gray-900">Profile Photo <span className="text-rose-400">*</span></h2>

              <div className="flex flex-col items-center gap-4">
                <div className="h-32 w-32 rounded-full bg-gray-100 border-2 border-gray-300 overflow-hidden flex items-center justify-center">
                  {avatarUrl ? (
                    <img src={avatarUrl} alt="Avatar" className="h-full w-full object-cover" />
                  ) : (
                    <span className="text-4xl font-bold text-gray-400">
                      {fullName ? fullName.charAt(0).toUpperCase() : '?'}
                    </span>
                  )}
                </div>

                <label className="flex w-full items-center justify-center gap-2 rounded-xl border border-dashed border-gray-200 bg-white py-4 text-sm font-semibold text-blue-600 hover:border-blue-300 hover:bg-blue-50 transition cursor-pointer select-none">
                  <Upload className="h-4 w-4" />
                  {isUploading ? 'Uploading...' : 'Upload Photo'}
                  <input
                    type="file"
                    accept="image/*"
                    onChange={handleAvatarUpload}
                    disabled={isUploading}
                    className="hidden"
                  />
                </label>
                {formErrors.avatarUrl && <p className="text-xs text-rose-400">{formErrors.avatarUrl}</p>}
              </div>
            </div>

            {/* Save Button */}
            <div className="rounded-2xl border border-gray-200 bg-white p-6 shadow-sm">
              <button
                type="submit"
                disabled={isSaving || isUploading}
                className="flex w-full items-center justify-center gap-2 rounded-xl bg-gradient-to-r from-blue-600 to-blue-500 py-3.5 text-sm font-semibold text-white transition hover:from-blue-500 hover:to-blue-400 disabled:opacity-50 cursor-pointer shadow-lg shadow-blue-500/10 active:scale-[0.98]"
              >
                {isSaving ? (
                  <>
                    <Loader2 className="h-4 w-4 animate-spin" />
                    Saving Profile...
                  </>
                ) : (
                  <>
                    <Save className="h-4 w-4" />
                    Save Profile
                  </>
                )}
              </button>
            </div>
          </div>
        </div>
      </form>
    </div>
  );
}
