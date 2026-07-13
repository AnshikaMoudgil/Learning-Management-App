enum CourseLevel { beginner, intermediate, advanced }

class Course {
  final String id;
  final String title;
  final String slug;
  final String? shortDescription;
  final String? description;
  final String? thumbnailUrl;
  final String? previewVideoUrl;
  final String language;
  final CourseLevel level;
  final String? category;
  final double price;
  final double? discountPrice;
  final int? validityDays;
  final String? estimatedDuration;
  final bool isPublished;
  final String? instructorId;
  final double averageRating;
  final int reviewsCount;
  final bool isBestseller;
  final int totalLessons;
  final List<String> learningOutcomes;
  final List<String> requirements;
  final DateTime createdAt;
  final DateTime updatedAt;

  Course({
    required this.id,
    required this.title,
    required this.slug,
    this.shortDescription,
    this.description,
    this.thumbnailUrl,
    this.previewVideoUrl,
    required this.language,
    required this.level,
    this.category,
    required this.price,
    this.discountPrice,
    this.validityDays,
    this.estimatedDuration,
    required this.isPublished,
    this.instructorId,
    this.averageRating = 0.0,
    this.reviewsCount = 0,
    this.isBestseller = false,
    this.totalLessons = 0,
    this.learningOutcomes = const [],
    this.requirements = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  double get effectivePrice => discountPrice ?? price;
  bool get hasDiscount => discountPrice != null && discountPrice! < price;

  static CourseLevel _parseLevel(String? level) {
    switch (level) {
      case 'beginner':
        return CourseLevel.beginner;
      case 'intermediate':
        return CourseLevel.intermediate;
      case 'advanced':
        return CourseLevel.advanced;
      default:
        return CourseLevel.beginner;
    }
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      title: (json['title'] ?? json['Title']) as String,
      slug: (json['slug'] ?? json['Slug']) as String,
      shortDescription: (json['short_description'] ?? json['shortDescription']) as String?,
      description: (json['description'] ?? json['Description']) as String?,
      thumbnailUrl: (json['thumbnail_url'] ?? json['thumbnailUrl']) as String?,
      previewVideoUrl: (json['preview_video_url'] ?? json['previewVideoUrl']) as String?,
      language: (json['language'] ?? json['Language'] ?? 'English') as String,
      level: _parseLevel(json['level'] ?? json['Level']),
      category: (json['category'] ?? json['Category']) as String?,
      price: ((json['price'] ?? json['Price'] ?? 0) as num).toDouble(),
      discountPrice: ((json['discount_price'] ?? json['discountPrice']) as num?)?.toDouble(),
      validityDays: (json['validity_days'] ?? json['validityDays']) as int?,
      estimatedDuration: (json['estimated_duration'] ?? json['estimatedDuration']) as String?,
      isPublished: (json['is_published'] ?? json['isPublished'] ?? true) as bool,
      instructorId: (json['instructor_id'] ?? json['instructorId']) as String?,
      averageRating: ((json['average_rating'] ?? json['averageRating'] ?? 0) as num).toDouble(),
      reviewsCount: (json['reviews_count'] ?? json['reviewsCount'] ?? 0) as int,
      isBestseller: (json['is_bestseller'] ?? json['isBestseller'] ?? false) as bool,
      totalLessons: (json['total_lessons'] ?? json['totalLessons'] ?? 0) as int,
      learningOutcomes: (json['learning_outcomes'] ?? json['learningOutcomes'] ?? [])
          .map<String>((e) => e as String)
          .toList(),
      requirements: (json['requirements'] ?? [])
          .map<String>((e) => e as String)
          .toList(),
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']),
      updatedAt: _parseDate(json['updated_at'] ?? json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'short_description': shortDescription,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'preview_video_url': previewVideoUrl,
      'language': language,
      'level': level.name,
      'category': category,
      'price': price,
      'discount_price': discountPrice,
      'validity_days': validityDays,
      'estimated_duration': estimatedDuration,
      'is_published': isPublished,
      'instructor_id': instructorId,
      'average_rating': averageRating,
      'reviews_count': reviewsCount,
      'is_bestseller': isBestseller,
      'total_lessons': totalLessons,
      'learning_outcomes': learningOutcomes.toList(),
      'requirements': requirements.toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
