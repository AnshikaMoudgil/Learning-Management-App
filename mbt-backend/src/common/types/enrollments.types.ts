export interface EnrolledCourse {
  title: string;
  thumbnail_url: string | null;
  estimated_duration: string | null;
  profiles: { full_name: string | null } | null;
}

export interface LessonCountRow {
  course_id: string;
}

export interface EnrollmentRow {
  id: string;
  course_id: string;
  status: string;
  progress_percent: number;
  validity_end_at: string | null;
  enrolled_at: string;
  courses: EnrolledCourse | null;
}
