import { z } from 'zod';

export const courseSchema = z
  .object({
    title: z.string().min(1, 'Course Title is required.'),
    slug: z.string().min(1, 'Course Slug is required.'),
    shortDescription: z.string().optional(),
    description: z.string().optional(),
    language: z.string().min(1, 'Language is required.'),
    level: z.string().min(1, 'Level is required.'),
    category: z.string().min(1, 'Category is required.'),
    price: z
      .string()
      .min(1, 'Base Price is required.')
      .refine((v) => !isNaN(Number(v)) && Number(v) >= 0, 'Base Price must be a valid positive number.'),
    discountPrice: z
      .string()
      .optional()
      .refine(
        (v) => !v || (!isNaN(Number(v)) && Number(v) >= 0),
        'Discount Price must be a valid positive number.'
      ),
    validityDays: z.string().optional(),
    estimatedDuration: z.string().optional(),
    isPublished: z.boolean(),
    thumbnailUrl: z.string().optional(),
    previewVideoUrl: z.string().optional(),
  })
  .refine(
    (data) => {
      if (!data.discountPrice) return true;
      return Number(data.discountPrice) <= Number(data.price);
    },
    {
      message: 'Discount Price ($) cannot be greater than Base Price ($).',
      path: ['discountPrice'],
    }
  );

export type CourseFormData = z.infer<typeof courseSchema>;
