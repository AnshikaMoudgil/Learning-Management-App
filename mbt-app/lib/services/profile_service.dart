import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../models/profile.dart';
import 'api_client.dart';

typedef ProfileUpdateCallback = void Function();

class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  final ApiClient _api = ApiClient();

  final List<ProfileUpdateCallback> _onProfileUpdated = [];
  final ValueNotifier<int> profileUpdateNotifier = ValueNotifier<int>(0);

  void addUpdateListener(ProfileUpdateCallback callback) {
    _onProfileUpdated.add(callback);
  }

  void removeUpdateListener(ProfileUpdateCallback callback) {
    _onProfileUpdated.remove(callback);
  }

  void _notifyProfileUpdated() {
    profileUpdateNotifier.value++;
    for (final cb in _onProfileUpdated) {
      cb();
    }
  }

  Future<Profile> getProfile() async {
    final result = await _api.get('/api/v1/users/me');
    return Profile.fromJson(result);
  }

  Future<Profile?> validateSession(Session session) async {
    final result = await _api.get('/api/v1/auth/session');

    final profileData = result['profile'];
    if (profileData == null) {
      return null;
    }

    final profile = Profile.fromJson(profileData);

    if (profile.isDeleted) {
      throw Exception('Your account has been deleted. Please contact support.');
    }

    if (!profile.isActive) {
      throw Exception('Your account is currently disabled or suspended.');
    }

    return profile;
  }

  Future<void> updateLoginDetails(String userId) async {
    await _api.post('/api/v1/users/me/login-details', body: {});
  }

  Future<Profile> createProfile(
    String fullName, {
    String? phone,
    String? email,
  }) async {
    final result = await _api.post(
      '/api/v1/users/me/complete',
      body: {
        'fullName': fullName,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
      },
    );
    return Profile.fromJson(result);
  }

  Future<Profile> updateProfile(
    String fullName, {
    String? phone,
    String? email,
    String? about,
  }) async {
    final result = await _api.patch(
      '/api/v1/users/me',
      body: {
        'fullName': fullName,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        if (about != null) 'about': about,
      },
    );
    _notifyProfileUpdated();
    return Profile.fromJson(result);
  }

  Future<void> bindDevice(String userId, {String? fcmToken}) async {
    final fingerprint = await _getDeviceFingerprint();
    final deviceName = await _getDeviceName();
    await _api.post('/api/v1/devices/bind', body: {
      'fingerprint': fingerprint,
      'platform': deviceName,
      if (fcmToken != null) 'fcmToken': fcmToken,
    });
  }

  Future<String> _getDeviceName() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (kIsWeb) {
        final webInfo = await deviceInfo.webBrowserInfo;
        final browser = webInfo.browserName.toString();
        final os = webInfo.platform ?? '';
        return os.isNotEmpty ? '$browser on $os' : browser;
      } else if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return '${androidInfo.brand} ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.model;
      }
    } catch (_) {}
    return 'Unknown Device';
  }

  Future<void> unbindDeviceFcm() async {
    final fingerprint = await _getDeviceFingerprint();
    await _api.post('/api/v1/devices/unbind-fcm', body: {
      'fingerprint': fingerprint,
    });
  }

  Future<String> _getDeviceFingerprint() async {
    final prefs = await SharedPreferences.getInstance();
    String? fingerprint = prefs.getString('device_fingerprint');
    if (fingerprint != null && fingerprint.isNotEmpty) {
      return fingerprint;
    }
    fingerprint = const Uuid().v4();
    await prefs.setString('device_fingerprint', fingerprint);
    return fingerprint;
  }

  Future<void> uploadAvatar(Uint8List bytes, String fileName) async {
    await _api.uploadFile('/api/v1/users/me/photo', 'photo', bytes, fileName);
    _notifyProfileUpdated();
  }

  Future<void> deleteAvatar() async {
    await _api.delete('/api/v1/users/me/photo');
    _notifyProfileUpdated();
  }
}
