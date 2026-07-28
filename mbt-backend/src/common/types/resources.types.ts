export interface CourseResource {
  id: string;
  course_id: string;
  section_id: string | null;
  section_title: string | null;
  title: string;
  file_url: string;
  file_size: string | null;
  file_type: string | null;
  created_at: string;
}
