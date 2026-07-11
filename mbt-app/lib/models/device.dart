class Device {
  final String id;
  final String userId;
  final String fingerprint;
  final String? platform;
  final bool isActive;
  final DateTime boundAt;
  final DateTime lastSeenAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Device({
    required this.id,
    required this.userId,
    required this.fingerprint,
    this.platform,
    this.isActive = true,
    required this.boundAt,
    required this.lastSeenAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      fingerprint: json['fingerprint'] as String,
      platform: json['platform'] as String?,
      isActive: (json['is_active'] ?? true) as bool,
      boundAt: DateTime.parse(json['bound_at'] as String),
      lastSeenAt: DateTime.parse(json['last_seen_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'fingerprint': fingerprint,
      'platform': platform,
      'is_active': isActive,
      'bound_at': boundAt.toIso8601String(),
      'last_seen_at': lastSeenAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
