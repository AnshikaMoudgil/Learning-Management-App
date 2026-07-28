import 'api_client.dart';

class EnrollmentItem {
  final String enrollmentId;
  final String courseId;
  final String? title;
  final String? thumbnailUrl;
  final String? instructorName;
  final int progressPercent;
  final String status;
  final DateTime? validityEndAt;
  final int totalLessons;
  final String? estimatedDuration;
  final String? category;
  final String? level;
  final DateTime enrolledAt;

  EnrollmentItem({
    required this.enrollmentId,
    required this.courseId,
    this.title,
    this.thumbnailUrl,
    this.instructorName,
    required this.progressPercent,
    required this.status,
    this.validityEndAt,
    required this.totalLessons,
    this.estimatedDuration,
    this.category,
    this.level,
    required this.enrolledAt,
  });

  factory EnrollmentItem.fromJson(Map<String, dynamic> json) {
    return EnrollmentItem(
      enrollmentId: json['enrollment_id'] as String,
      courseId: json['course_id'] as String,
      title: json['title'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      instructorName: json['instructor_name'] as String?,
      progressPercent: (json['progress_percent'] ?? 0) as int,
      status: (json['status'] ?? 'active') as String,
      validityEndAt: json['validity_end_at'] != null
          ? DateTime.parse(json['validity_end_at'] as String)
          : null,
      totalLessons: (json['total_lessons'] ?? 0) as int,
      estimatedDuration: json['estimated_duration'] as String?,
      category: json['category'] as String?,
      level: json['level'] as String?,
      enrolledAt: json['enrolled_at'] != null
          ? DateTime.parse(json['enrolled_at'] as String)
          : DateTime.now(),
    );
  }
}

class EnrollmentsService {
  final ApiClient _api = ApiClient();

  Future<List<EnrollmentItem>> getMyEnrollments() async {
    final result = await _api.get('/api/v1/enrollments');
    final List<dynamic> data = result is Map
        ? (result['data'] as List<dynamic>?) ?? []
        : (result as List<dynamic>);
    return data
        .map((e) => EnrollmentItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
