import 'api_client.dart';

class MyCourseContent {
  final String courseId;
  final String title;
  final String? thumbnailUrl;
  final MyCourseEnrollmentState enrollment;
  final List<MyCourseSection> sections;
  final List<MyLiveClassItem> allLiveClasses;
  final List<MyRecordingItem> allRecordings;
  final List<MyResourceItem> allResources;

  MyCourseContent({
    required this.courseId,
    required this.title,
    this.thumbnailUrl,
    required this.enrollment,
    required this.sections,
    required this.allLiveClasses,
    required this.allRecordings,
    required this.allResources,
  });

  factory MyCourseContent.fromJson(Map<String, dynamic> json) {
    return MyCourseContent(
      courseId: json['course_id'] as String,
      title: json['title'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      enrollment: MyCourseEnrollmentState.fromJson(json['enrollment'] as Map<String, dynamic>),
      sections: (json['sections'] as List<dynamic>? ?? [])
          .map((e) => MyCourseSection.fromJson(e as Map<String, dynamic>))
          .toList(),
      allLiveClasses: (json['all_live_classes'] as List<dynamic>? ?? [])
          .map((e) => MyLiveClassItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      allRecordings: (json['all_recordings'] as List<dynamic>? ?? [])
          .map((e) => MyRecordingItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      allResources: (json['all_resources'] as List<dynamic>? ?? [])
          .map((e) => MyResourceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class MyCourseEnrollmentState {
  final String enrollmentId;
  final int progressPercent;
  final DateTime? validityEndAt;
  final String status;

  MyCourseEnrollmentState({
    required this.enrollmentId,
    required this.progressPercent,
    this.validityEndAt,
    required this.status,
  });

  factory MyCourseEnrollmentState.fromJson(Map<String, dynamic> json) {
    return MyCourseEnrollmentState(
      enrollmentId: json['enrollment_id'] as String,
      progressPercent: (json['progress_percent'] ?? 0) as int,
      validityEndAt: json['validity_end_at'] != null
          ? DateTime.parse(json['validity_end_at'] as String)
          : null,
      status: (json['status'] ?? 'active') as String,
    );
  }
}

class MyCourseSection {
  final String id;
  final String title;
  final String? description;
  final int sortOrder;
  final int totalLessons;
  final int completedLessons;
  final int progressPercent;
  final bool isUnlocked;
  final List<MyCourseLesson> lessons;
  final List<MyLiveClassItem> liveClasses;
  final List<MyResourceItem> resources;

  MyCourseSection({
    required this.id,
    required this.title,
    this.description,
    required this.sortOrder,
    required this.totalLessons,
    required this.completedLessons,
    required this.progressPercent,
    required this.isUnlocked,
    required this.lessons,
    required this.liveClasses,
    required this.resources,
  });

  factory MyCourseSection.fromJson(Map<String, dynamic> json) {
    return MyCourseSection(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      sortOrder: (json['sort_order'] ?? 0) as int,
      totalLessons: (json['total_lessons'] ?? 0) as int,
      completedLessons: (json['completed_lessons'] ?? 0) as int,
      progressPercent: (json['progress_percent'] ?? 0) as int,
      isUnlocked: (json['is_unlocked'] ?? false) as bool,
      lessons: (json['lessons'] as List<dynamic>? ?? [])
          .map((e) => MyCourseLesson.fromJson(e as Map<String, dynamic>))
          .toList(),
      liveClasses: (json['live_classes'] as List<dynamic>? ?? [])
          .map((e) => MyLiveClassItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      resources: (json['resources'] as List<dynamic>? ?? [])
          .map((e) => MyResourceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class MyCourseLesson {
  final String id;
  final String sectionId;
  final String title;
  final String? description;
  final String? videoUrl;
  final String? videoDuration;
  final bool isFreePreview;
  final int sortOrder;
  final bool isCompleted;
  final int watchedSeconds;

  MyCourseLesson({
    required this.id,
    required this.sectionId,
    required this.title,
    this.description,
    this.videoUrl,
    this.videoDuration,
    required this.isFreePreview,
    required this.sortOrder,
    required this.isCompleted,
    required this.watchedSeconds,
  });

  factory MyCourseLesson.fromJson(Map<String, dynamic> json) {
    return MyCourseLesson(
      id: json['id'] as String,
      sectionId: (json['section_id'] ?? json['sectionId']) as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      videoUrl: json['video_url'] as String?,
      videoDuration: json['video_duration'] as String?,
      isFreePreview: (json['is_free_preview'] ?? false) as bool,
      sortOrder: (json['sort_order'] ?? 0) as int,
      isCompleted: (json['is_completed'] ?? false) as bool,
      watchedSeconds: (json['watched_seconds'] ?? 0) as int,
    );
  }
}

class MyLiveClassItem {
  final String id;
  final String title;
  final String? description;
  final DateTime startTime;
  final int duration; // in minutes
  final String status;
  final String? sectionId;
  final String? sectionTitle;
  final String? instructorName;
  final String? joinUrl;

  MyLiveClassItem({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    required this.duration,
    required this.status,
    this.sectionId,
    this.sectionTitle,
    this.instructorName,
    this.joinUrl,
  });

  factory MyLiveClassItem.fromJson(Map<String, dynamic> json) {
    return MyLiveClassItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      startTime: DateTime.parse(json['start_time'] as String),
      duration: (json['duration'] ?? 0) as int,
      status: (json['status'] ?? 'scheduled') as String,
      sectionId: json['section_id'] as String?,
      sectionTitle: json['section_title'] as String?,
      instructorName: json['instructor_name'] as String?,
      joinUrl: json['join_url'] as String?,
    );
  }
}

class MyRecordingItem {
  final String id;
  final String? title;
  final String? thumbnailUrl;
  final String? r2Url;
  final int? duration;
  final String processingStatus;
  final String? sectionId;
  final String? sectionTitle;
  final DateTime createdAt;

  MyRecordingItem({
    required this.id,
    this.title,
    this.thumbnailUrl,
    this.r2Url,
    this.duration,
    required this.processingStatus,
    this.sectionId,
    this.sectionTitle,
    required this.createdAt,
  });

  factory MyRecordingItem.fromJson(Map<String, dynamic> json) {
    return MyRecordingItem(
      id: json['id'] as String,
      title: json['title'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      r2Url: json['r2_url'] as String?,
      duration: json['duration'] as int?,
      processingStatus: (json['processing_status'] ?? 'ready') as String,
      sectionId: json['section_id'] as String?,
      sectionTitle: json['section_title'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
}

class MyResourceItem {
  final String id;
  final String title;
  final String fileUrl;
  final String? fileSize;
  final String? fileType;
  final String? sectionId;
  final DateTime createdAt;

  MyResourceItem({
    required this.id,
    required this.title,
    required this.fileUrl,
    this.fileSize,
    this.fileType,
    this.sectionId,
    required this.createdAt,
  });

  factory MyResourceItem.fromJson(Map<String, dynamic> json) {
    return MyResourceItem(
      id: json['id'] as String,
      title: json['title'] as String,
      fileUrl: json['file_url'] as String,
      fileSize: json['file_size'] as String?,
      fileType: json['file_type'] as String?,
      sectionId: json['section_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
}

class MyCourseService {
  final ApiClient _api = ApiClient();

  Future<MyCourseContent> getCourseContent(String courseId) async {
    final result = await _api.get('/api/v1/my-courses/$courseId/content');
    return MyCourseContent.fromJson(result as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> toggleLessonProgress(
    String courseId,
    String lessonId,
    bool isCompleted, {
    int? watchedSeconds,
  }) async {
    final result = await _api.post(
      '/api/v1/my-courses/$courseId/lessons/$lessonId/progress',
      body: {
        'is_completed': isCompleted,
        if (watchedSeconds != null) 'watched_seconds': watchedSeconds,
      },
    );
    return result as Map<String, dynamic>;
  }
}
