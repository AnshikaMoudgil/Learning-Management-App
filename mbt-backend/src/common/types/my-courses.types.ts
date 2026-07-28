export interface LessonProgress {
  lesson_id: string;
  is_completed: boolean;
  watched_seconds: number;
  last_watched_at: string;
}

export interface LessonWithProgress {
  id: string;
  section_id: string;
  title: string;
  description: string | null;
  video_asset_id?: string | null;
  video_url: string | null;
  video_duration: string | null;
  video_status?: string | null;
  thumbnail_url?: string | null;
  is_free_preview: boolean;
  sort_order: number;
  is_completed: boolean;
  watched_seconds: number;
}

export interface SectionWithContent {
  id: string;
  title: string;
  description: string | null;
  sort_order: number;
  total_lessons: number;
  completed_lessons: number;
  progress_percent: number;
  is_unlocked: boolean;
  lessons: LessonWithProgress[];
  live_classes: LiveClassItem[];
  resources: ResourceItem[];
}

export interface LiveClassItem {
  id: string;
  title: string;
  description: string | null;
  start_time: string;
  duration: number;
  status: string;
  section_id: string | null;
  section_title: string | null;
  instructor_name: string | null;
  join_url: string | null;
}

export interface RecordingItem {
  id: string;
  title: string | null;
  thumbnail_url: string | null;
  storage_url: string | null;
  duration: number | null;
  status: string;
  section_id: string | null;
  section_title: string | null;
  created_at: string;
}

export interface ResourceItem {
  id: string;
  title: string;
  file_url: string;
  file_size: string | null;
  file_type: string | null;
  section_id: string | null;
  created_at: string;
}

export interface CourseContent {
  course_id: string;
  title: string;
  thumbnail_url: string | null;
  enrollment: {
    enrollment_id: string;
    progress_percent: number;
    validity_end_at: string | null;
    status: string;
  };
  sections: SectionWithContent[];
  all_live_classes: LiveClassItem[];
  all_recordings: RecordingItem[];
  all_resources: ResourceItem[];
}
