import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/notification_service.dart';
import 'package:go_router/go_router.dart';
import '../widgets/cart_badge.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({Key? key}) : super(key: key);

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  final NotificationService _notificationService = NotificationService();
  final ScrollController _scrollController = ScrollController();

  List<AppNotification> _notifications = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _page = 1;
  int _total = 0;
  String _selectedFilter = 'All';
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    final result = await _notificationService.getNotifications(page: 1, limit: _pageSize);
    if (mounted) {
      setState(() {
        _notifications = result.data;
        _total = result.total;
        _page = 1;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _notifications.length >= _total) return;
    setState(() => _isLoadingMore = true);
    final nextPage = _page + 1;
    final result = await _notificationService.getNotifications(page: nextPage, limit: _pageSize);
    if (mounted) {
      setState(() {
        _notifications.addAll(result.data);
        _total = result.total;
        _page = nextPage;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _markRead(String id) async {
    await _notificationService.markRead(id);
    if (mounted) {
      setState(() {
        _notifications = _notifications.map((n) {
          if (n.id == id) {
            return AppNotification(
              id: n.id,
              userId: n.userId,
              type: n.type,
              title: n.title,
              body: n.body,
              data: n.data,
              isRead: true,
              createdAt: n.createdAt,
            );
          }
          return n;
        }).toList();
      });
    }
  }

  Future<void> _markAllRead() async {
    await _notificationService.markAllRead();
    if (mounted) {
      setState(() {
        _notifications = _notifications.map((n) {
          return AppNotification(
            id: n.id,
            userId: n.userId,
            type: n.type,
            title: n.title,
            body: n.body,
            data: n.data,
            isRead: true,
            createdAt: n.createdAt,
          );
        }).toList();
      });
    }
  }

  List<AppNotification> get _filteredNotifications {
    if (_selectedFilter == 'All') return _notifications;
    return _notifications.where((n) {
      final type = n.type.toLowerCase();
      switch (_selectedFilter) {
        case 'Live Class':
          return type.contains('session') || type.contains('reminder') || type.contains('recording');
        case 'Expiry':
          return type.contains('expire');
        case 'Payment':
          return type.contains('payment');
        case 'Device':
          return type.contains('device') || type.contains('login');
        case 'Announcements':
          return type == 'announcement';
        default:
          return true;
      }
    }).toList();
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  Map<String, List<AppNotification>> _groupByDate(List<AppNotification> notifications) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final grouped = <String, List<AppNotification>>{};

    for (final n in notifications) {
      final date = DateTime(n.createdAt.year, n.createdAt.month, n.createdAt.day);
      String key;
      if (date == today) {
        key = 'Today';
      } else if (date == yesterday) {
        key = 'Yesterday';
      } else {
        key = '${date.day}/${date.month}/${date.year}';
      }
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(n);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredNotifications;
    final grouped = _groupByDate(filtered);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notification Center',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            Text(_unreadCount > 0 ? '$_unreadCount unread notifications' : 'Stay updated with important alerts',
                style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
          ],
        ),
        actions: [
          if (_unreadCount > 0)
            IconButton(
              icon: const Icon(Icons.done_all, color: AppColors.primaryBlue, size: 20),
              tooltip: 'Mark all read',
              onPressed: _markAllRead,
            ),
          const CartBadge(),
          const SizedBox(width: 8),
          Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.lightBlueBg, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.notifications_outlined, color: AppColors.textDark, size: 18),
              ),
              if (_unreadCount > 0)
                Positioned(
                  right: 0, top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text('$_unreadCount',
                        style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', _selectedFilter == 'All', Icons.all_inclusive),
                  _buildFilterChip('Live Class', _selectedFilter == 'Live Class', Icons.videocam),
                  _buildFilterChip('Expiry', _selectedFilter == 'Expiry', Icons.access_time),
                  _buildFilterChip('Payment', _selectedFilter == 'Payment', Icons.payment),
                  _buildFilterChip('Device', _selectedFilter == 'Device', Icons.devices),
                  _buildFilterChip('Announcements', _selectedFilter == 'Announcements', Icons.campaign),
                ],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadNotifications,
                        child: ListView(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          children: [
                            for (final entry in grouped.entries) ...[
                              Padding(
                                padding: const EdgeInsets.only(top: 8, bottom: 12),
                                child: Text(entry.key,
                                    style: const TextStyle(
                                        fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                              ),
                              for (final notification in entry.value)
                                _buildNotificationCard(notification),
                            ],
                            if (_isLoadingMore)
                              const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text('No notifications',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 8),
            const Text('You\'re all caught up!',
                style: TextStyle(fontSize: 14, color: AppColors.textLight)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = label),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? AppColors.primaryBlue : AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: isSelected ? Colors.white : AppColors.textLight),
              const SizedBox(width: 4),
              Text(label,
                  style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textDark)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    final isUnread = !notification.isRead;
    final iconData = _iconForType(notification.type);
    final iconColor = _colorForType(notification.type);
    final badgeLabel = _badgeForType(notification.type);
    final timeText = _formatTime(notification.createdAt);

    return GestureDetector(
      onTap: () {
        if (isUnread) _markRead(notification.id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUnread ? AppColors.lightBlueBg : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isUnread ? AppColors.primaryBlue.withValues(alpha: 0.2) : AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(iconData, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(notification.title,
                                  style: TextStyle(
                                      fontSize: 13, fontWeight: FontWeight.bold,
                                      color: isUnread ? AppColors.textDark : AppColors.textDark),
                                  overflow: TextOverflow.ellipsis),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: iconColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(badgeLabel,
                                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: iconColor)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(notification.body,
                      style: const TextStyle(fontSize: 11, color: AppColors.textLight, height: 1.3)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(timeText, style: const TextStyle(fontSize: 9, color: AppColors.textLight)),
                const SizedBox(height: 6),
                if (isUnread)
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForType(String type) {
    final t = type.toLowerCase();
    if (t.contains('session') || t.contains('reminder') || t.contains('recording')) {
      return Icons.videocam_outlined;
    }
    if (t.contains('expire')) return Icons.access_time;
    if (t.contains('payment')) return Icons.check_circle_outline;
    if (t.contains('device') || t.contains('login')) return Icons.devices_outlined;
    if (t == 'announcement') return Icons.campaign_outlined;
    return Icons.notifications_none;
  }

  Color _colorForType(String type) {
    final t = type.toLowerCase();
    if (t.contains('session') || t.contains('reminder') || t.contains('recording')) {
      return const Color(0xFFE53935);
    }
    if (t.contains('expire')) return const Color(0xFFFF9800);
    if (t.contains('payment')) return const Color(0xFF43A047);
    if (t.contains('device') || t.contains('login')) return AppColors.primaryBlue;
    if (t == 'announcement') return const Color(0xFF7B1FA2);
    return AppColors.textLight;
  }

  String _badgeForType(String type) {
    final t = type.toLowerCase();
    if (t.contains('session') || t.contains('reminder') || t.contains('recording')) return 'Live Class';
    if (t.contains('expire')) return 'Expiry';
    if (t.contains('payment')) return 'Payment';
    if (t.contains('device') || t.contains('login')) return 'Device';
    if (t == 'announcement') return 'Announcements';
    return type;
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dt.year, dt.month, dt.day);
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final timeStr = '$hour:$minute';

    if (date == today) return timeStr;
    final yesterday = today.subtract(const Duration(days: 1));
    if (date == yesterday) return 'Yesterday, $timeStr';
    return '${dt.day}/${dt.month}/${dt.year}, $timeStr';
  }
}
