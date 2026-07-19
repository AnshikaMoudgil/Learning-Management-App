enum UserRole { learner, admin, superadmin, instructor }

enum UserStatus { ACTIVE, SUSPENDED, BLOCKED }

class Profile {
  final String id;
  final bool isActive;
  final bool isDeleted;
  final bool onboardingCompleted;
  final DateTime? lastLoginAt;
  final String? fullName;
  final String? avatarUrl;
  final String? email;
  final String? phone;
  final UserRole role;
  final UserStatus status;
  final String? about;

  Profile({
    required this.id,
    this.isActive = true,
    this.isDeleted = false,
    this.onboardingCompleted = false,
    this.lastLoginAt,
    this.fullName,
    this.avatarUrl,
    this.email,
    this.phone,
    this.role = UserRole.learner,
    this.status = UserStatus.ACTIVE,
    this.about,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      isActive: (json['is_active'] ?? json['isActive']) as bool? ?? true,
      isDeleted: (json['is_deleted'] ?? json['isDeleted']) as bool? ?? false,
      onboardingCompleted:
          (json['onboarding_completed'] ?? json['onboardingCompleted'])
              as bool? ??
          false,
      lastLoginAt: _parseDate(json['last_login_at'] ?? json['lastLoginAt']),
      fullName: (json['full_name'] ?? json['fullName']) as String?,
      avatarUrl: (json['avatar_url'] ?? json['avatarUrl']) as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      role: _parseRole(json['role'] ?? json['role']),
      status: _parseStatus(json['status'] ?? json['status']),
      about: (json['about'] ?? json['about']) as String?,
    );
  }

  static UserRole _parseRole(dynamic value) {
    if (value == null) return UserRole.learner;
    switch (value.toString().toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'superadmin':
        return UserRole.superadmin;
      case 'instructor':
        return UserRole.instructor;
      default:
        return UserRole.learner;
    }
  }

  static UserStatus _parseStatus(dynamic value) {
    if (value == null) return UserStatus.ACTIVE;
    switch (value.toString().toUpperCase()) {
      case 'SUSPENDED':
        return UserStatus.SUSPENDED;
      case 'BLOCKED':
        return UserStatus.BLOCKED;
      default:
        return UserStatus.ACTIVE;
    }
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
      'onboarding_completed': onboardingCompleted,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'email': email,
      'phone': phone,
      'role': role.name,
      'status': status.name,
      'about': about,
    };
  }
}
