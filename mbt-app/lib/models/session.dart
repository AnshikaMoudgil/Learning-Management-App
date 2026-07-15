class LiveSession {
  final String id;
  final String courseId;
  final String instructorId;
  final String title;
  final String? description;
  final DateTime startTime;
  final int duration;
  final String status;
  final String? meetingId;
  final String? recordingStatus;
  final String? recordingUrl;
  final String? courseName;
  final String? courseImageUrl;
  final String? instructorName;
  final String? instructorAvatar;

  LiveSession({
    required this.id,
    required this.courseId,
    required this.instructorId,
    required this.title,
    this.description,
    required this.startTime,
    required this.duration,
    required this.status,
    this.meetingId,
    this.recordingStatus,
    this.recordingUrl,
    this.courseName,
    this.courseImageUrl,
    this.instructorName,
    this.instructorAvatar,
  });

  factory LiveSession.fromJson(Map<String, dynamic> json) {
    final meeting = json['live_session_meetings'] != null && json['live_session_meetings'].isNotEmpty
        ? json['live_session_meetings'][0]
        : (json['live_session_meetings'] is Map ? json['live_session_meetings'] : null);

    final course = json['courses'] as Map<String, dynamic>?;
    final profile = json['profiles'] as Map<String, dynamic>?;

    return LiveSession(
      id: json['id'] as String,
      courseId: json['course_id'] as String,
      instructorId: json['instructor_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      startTime: DateTime.parse(json['start_time'] as String),
      duration: json['duration'] as int,
      status: json['status'] as String,
      meetingId: meeting != null ? meeting['meeting_id'] as String? : null,
      recordingStatus: meeting != null ? meeting['recording_status'] as String? : null,
      recordingUrl: meeting != null ? meeting['recording_url'] as String? : null,
      courseName: course?['title'] as String?,
      courseImageUrl: course?['thumbnail_url'] as String?,
      instructorName: profile?['full_name'] as String?,
      instructorAvatar: profile?['avatar_url'] as String?,
    );
  }
}
