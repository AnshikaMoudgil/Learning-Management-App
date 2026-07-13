class DeviceChangeRequest {
  final String id;
  final String userId;
  final String? oldFingerprint;
  final String newFingerprint;
  final String? reason;
  final String status;
  final String? reviewedBy;
  final String? reviewedAt;
  final String createdAt;

  DeviceChangeRequest({
    required this.id,
    required this.userId,
    this.oldFingerprint,
    required this.newFingerprint,
    this.reason,
    required this.status,
    this.reviewedBy,
    this.reviewedAt,
    required this.createdAt,
  });

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  factory DeviceChangeRequest.fromJson(Map<String, dynamic> json) {
    return DeviceChangeRequest(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      oldFingerprint: json['old_fingerprint'] as String?,
      newFingerprint: json['new_fingerprint'] as String,
      reason: json['reason'] as String?,
      status: json['status'] as String,
      reviewedBy: json['reviewed_by'] as String?,
      reviewedAt: json['reviewed_at'] as String?,
      createdAt: json['created_at'] as String,
    );
  }
}
