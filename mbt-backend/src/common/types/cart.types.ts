export interface CartItemRow {
  id: string;
  course_id: string;
  created_at: string;
  courses: {
    id: string;
    title: string;
    slug: string;
    short_description: string | null;
    thumbnail_url: string | null;
    price: number | string;
    discount_price: number | string | null;
    category: string | null;
    level: string;
    estimated_duration: string | null;
    total_lessons: number;
  } | null;
}
