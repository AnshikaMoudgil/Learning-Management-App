class LearnerProfile {
  final String id;
  final bool isActive;
  final bool isDeleted;
  final String? deviceId;
  final bool onboardingCompleted;
  final DateTime? lastLoginAt;
  final String? fullName;

  LearnerProfile({
    required this.id,
    this.isActive = true,
    this.isDeleted = false,
    this.deviceId,
    this.onboardingCompleted = false,
    this.lastLoginAt,
    this.fullName,
  });

  factory LearnerProfile.fromJson(Map<String, dynamic> json) {
    return LearnerProfile(
      id: json['id'] as String,
      isActive: (json['is_active'] ?? json['isActive']) as bool? ?? true,
      isDeleted: (json['is_deleted'] ?? json['isDeleted']) as bool? ?? false,
      deviceId: (json['device_id'] ?? json['deviceId']) as String?,
      onboardingCompleted: (json['onboarding_completed'] ?? json['onboardingCompleted']) as bool? ?? false,
      lastLoginAt: _parseDate(json['last_login_at'] ?? json['lastLoginAt']),
      fullName: (json['full_name'] ?? json['fullName']) as String?,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value as String);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'is_active': isActive,
      'is_deleted': isDeleted,
      'device_id': deviceId,
      'onboarding_completed': onboardingCompleted,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'full_name': fullName,
    };
  }
}
