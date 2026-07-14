export type CourseLevel = 'beginner' | 'intermediate' | 'advanced';

export interface Course {
  id: string;
  title: string;
  slug: string;
  short_description: string | null;
  description: string | null;
  thumbnail_url: string | null;
  preview_video_url: string | null;
  language: string;
  level: CourseLevel;
  category: string | null;
  price: number;
  discount_price: number | null;
  validity_days: number | null;
  estimated_duration: string | null;
  is_published: boolean;
  instructor_id: string | null;
  instructor_name: string | null;
  average_rating: number;
  reviews_count: number;
  is_bestseller: boolean;
  total_lessons: number;
  learning_outcomes: string[];
  requirements: string[];
  created_at: string;
  updated_at: string;
  sections?: CourseSection[];
  enrollment?: CourseEnrollmentState;
}

export interface CourseSection {
  id: string;
  course_id: string;
  title: string;
  description: string | null;
  sort_order: number;
  lessons: CourseLesson[];
}

export interface CourseLesson {
  id: string;
  section_id: string;
  course_id: string;
  title: string;
  description: string | null;
  video_url?: string | null;
  video_duration: string | null;
  is_free_preview: boolean;
  sort_order: number;
}

export interface CourseEnrollmentState {
  isEnrolled: boolean;
  enrollmentId: string | null;
  status: string | null;
  progressPercent: number;
  validityEndAt: string | null;
}

export interface PaginationMeta {
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

export interface PaginatedResult<T> {
  data: T[];
  meta: PaginationMeta;
}
