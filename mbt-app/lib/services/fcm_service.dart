import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import '../router/app_router.dart';
import 'profile_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messaging if required
  if (kDebugMode) {
    print('Handling background message: ${message.messageId}');
  }
}

class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final ProfileService _profileService = ProfileService();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
    playSound: true,
  );

  bool _initialized = false;

  Future<void> init(String userId) async {
    if (_initialized) return;

    // 1. Request notification permissions
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (kDebugMode) {
      print('User granted notification permission: ${settings.authorizationStatus}');
    }

    // 2. Initialize Local Notifications for Foreground message alerts
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    if (!kIsWeb && Platform.isAndroid) {
      final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(_channel);
      }
    }

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payloadString = response.payload;
        if (payloadString != null) {
          try {
            final Map<String, dynamic> data = json.decode(payloadString);
            _handleRouting(data);
          } catch (e) {
            if (kDebugMode) {
              print('Error parsing local notification payload: $e');
            }
          }
        }
      },
    );

    // 3. Configure Foreground listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && !kIsWeb) {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              icon: android?.smallIcon ?? '@mipmap/ic_launcher',
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: json.encode(message.data),
        );
      }
    });

    // 4. Configure click/navigation handlers
    // When the app is in background but open, and user taps notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleRouting(message.data);
    });

    // When the app is opened from terminated state
    _fcm.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        _handleRouting(message.data);
      }
    });

    // 5. Token lifecycle
    await refreshAndBindToken(userId);

    _fcm.onTokenRefresh.listen((token) async {
      try {
        await _profileService.bindDevice(userId, fcmToken: token);
        if (kDebugMode) {
          print('FCM Token refreshed and bound to backend: $token');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Failed to bind refreshed FCM token: $e');
        }
      }
    });

    _initialized = true;
  }

  Future<void> refreshAndBindToken(String userId) async {
    try {
      String? token = await _fcm.getToken();
      if (token != null) {
        await _profileService.bindDevice(userId, fcmToken: token);
        if (kDebugMode) {
          print('FCM Token bound successfully: $token');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting or binding FCM token: $e');
      }
    }
  }

  Future<void> disposeToken() async {
    try {
      await _profileService.unbindDeviceFcm();
      await _fcm.deleteToken();
      _initialized = false;
      if (kDebugMode) {
        print('FCM Token deleted locally and unbound from backend.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error disposing FCM token: $e');
      }
    }
  }

  void _handleRouting(Map<String, dynamic> data) {
    if (kDebugMode) {
      print('Handling routing with payload data: $data');
    }

    final String? type = data['type'];
    final String? courseId = data['courseId'];
    final String? lessonId = data['lessonId'];

    if (courseId != null && courseId.isNotEmpty) {
      appRouter.push('${RouteNames.course}?id=$courseId');
      return;
    }

    if (lessonId != null && lessonId.isNotEmpty) {
      appRouter.push('${RouteNames.recordedPlayer}?lessonId=$lessonId');
      return;
    }

    if (type == 'session_live' || type == 'session_created' || type == 'session_updated') {
      appRouter.push(RouteNames.live);
      return;
    }

    if (type == 'recording_ready') {
      appRouter.push(RouteNames.recordings);
      return;
    }

    // Default fallback to notifications list
    appRouter.push(RouteNames.notifications);
  }
}
