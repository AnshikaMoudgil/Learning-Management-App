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
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
