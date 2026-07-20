import 'api_client.dart';

class AppNotification {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: (json['type'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      body: (json['body'] ?? '') as String,
      data: json['data'] as Map<String, dynamic>?,
      isRead: (json['is_read'] ?? false) as bool,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
}

class NotificationsResult {
  final List<AppNotification> data;
  final int total;

  NotificationsResult({required this.data, required this.total});
}

class NotificationService {
  final ApiClient _api = ApiClient();

  Future<int> getUnreadCount() async {
    try {
      final result = await _api.get('/notifications/unread-count');
      if (result is Map) {
        return (result['unread'] ?? 0) as int;
      }
    } catch (_) {}
    return 0;
  }

  Future<NotificationsResult> getNotifications({int page = 1, int limit = 20}) async {
    try {
      final result = await _api.get(
        '/notifications',
        queryParams: {'page': page.toString(), 'limit': limit.toString()},
      );
      final List<dynamic> data = result is Map ? (result['data'] as List<dynamic>?) ?? [] : (result as List<dynamic>);
      final total = result is Map && result['meta'] != null
          ? ((result['meta'] as Map)['total'] as int?) ?? data.length
          : data.length;
      final notifications = data
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList();
      return NotificationsResult(data: notifications, total: total);
    } catch (_) {
      return NotificationsResult(data: [], total: 0);
    }
  }

  Future<bool> markRead(String notificationId) async {
    try {
      await _api.patch('/notifications/$notificationId/read');
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> markAllRead() async {
    try {
      await _api.patch('/notifications/read-all');
      return true;
    } catch (_) {
      return false;
    }
  }
}
