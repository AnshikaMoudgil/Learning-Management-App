class NotificationSettings {
  final bool liveClassReminders;
  final bool courseExpiryAlerts;
  final bool paymentConfirmations;
  final bool deviceTransferStatus;
  final bool promotionalMarketing;
  final bool pushNotifications;
  final bool email;
  final bool sms;

  NotificationSettings({
    required this.liveClassReminders,
    required this.courseExpiryAlerts,
    required this.paymentConfirmations,
    required this.deviceTransferStatus,
    required this.promotionalMarketing,
    required this.pushNotifications,
    required this.email,
    required this.sms,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      liveClassReminders: (json['liveClassReminders'] ?? true) as bool,
      courseExpiryAlerts: (json['courseExpiryAlerts'] ?? true) as bool,
      paymentConfirmations: (json['paymentConfirmations'] ?? true) as bool,
      deviceTransferStatus: (json['deviceTransferStatus'] ?? true) as bool,
      promotionalMarketing: (json['promotionalMarketing'] ?? true) as bool,
      pushNotifications: (json['pushNotifications'] ?? true) as bool,
      email: (json['email'] ?? true) as bool,
      sms: (json['sms'] ?? true) as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'liveClassReminders': liveClassReminders,
      'courseExpiryAlerts': courseExpiryAlerts,
      'paymentConfirmations': paymentConfirmations,
      'deviceTransferStatus': deviceTransferStatus,
      'promotionalMarketing': promotionalMarketing,
      'pushNotifications': pushNotifications,
      'email': email,
      'sms': sms,
    };
  }

  NotificationSettings copyWith({
    bool? liveClassReminders,
    bool? courseExpiryAlerts,
    bool? paymentConfirmations,
    bool? deviceTransferStatus,
    bool? promotionalMarketing,
    bool? pushNotifications,
    bool? email,
    bool? sms,
  }) {
    return NotificationSettings(
      liveClassReminders: liveClassReminders ?? this.liveClassReminders,
      courseExpiryAlerts: courseExpiryAlerts ?? this.courseExpiryAlerts,
      paymentConfirmations: paymentConfirmations ?? this.paymentConfirmations,
      deviceTransferStatus: deviceTransferStatus ?? this.deviceTransferStatus,
      promotionalMarketing: promotionalMarketing ?? this.promotionalMarketing,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      email: email ?? this.email,
      sms: sms ?? this.sms,
    );
  }
}
