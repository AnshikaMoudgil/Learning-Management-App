import { z } from 'zod';

export const courseSchema = z
  .object({
    title: z.string().min(1, 'Course Title is required.'),
    slug: z.string().min(1, 'Course Slug is required.'),
    shortDescription: z.string().min(1, 'Short Description is required.'),
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
    instructorId: z.string().min(1, 'Instructor is required.'),
    averageRating: z
      .string()
      .optional()
      .refine(
        (v) => !v || (!isNaN(Number(v)) && Number(v) >= 0 && Number(v) <= 5),
        'Average Rating must be between 0 and 5.'
      ),
    reviewsCount: z
      .string()
      .optional()
      .refine(
        (v) => !v || (!isNaN(Number(v)) && Number(v) >= 0 && Number.isInteger(Number(v))),
        'Reviews Count must be a valid positive integer.'
      ),
    validityDays: z
      .string()
      .min(1, 'Validity (Days) is required.')
      .refine((v) => !isNaN(Number(v)) && Number(v) >= 0, 'Validity (Days) must be a valid positive number.'),
    estimatedDuration: z
      .string()
      .min(1, 'Estimated Duration is required.')
      .refine((v) => !isNaN(Number(v)) && Number(v) >= 0, 'Estimated Duration must be a valid positive number.'),
    isPublished: z.boolean(),
    thumbnailUrl: z.string().min(1, 'Course Thumbnail is required.'),

    isBestseller: z.boolean().optional().default(false),
    learningOutcomes: z.array(z.string()).min(1, 'At least one Learning Outcome is required.'),
    requirements: z.array(z.string()).min(1, 'At least one Requirement is required.'),
  })
  .refine(
    (data) => {
      if (!data.discountPrice) return true;
      return Number(data.discountPrice) <= Number(data.price);
    },
    {
      message: 'Discount Price (₹) cannot be greater than Base Price (₹).',
      path: ['discountPrice'],
    }
  );

export type CourseFormData = z.infer<typeof courseSchema>;
