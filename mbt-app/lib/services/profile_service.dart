import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import '../models/learner_profile.dart';
import 'api_client.dart';

class ProfileService {
  final ApiClient _api = ApiClient();

  Future<LearnerProfile?> validateSession(Session session) async {
    final deviceId = await _getDeviceId();
    final result = await _api.get('/api/v1/auth/session', queryParams: {
      'deviceId': deviceId,
    });

    final profileData = result['profile'];
    if (profileData == null) {
      return null;
    }

    final profile = LearnerProfile.fromJson(profileData);

    if (profile.isDeleted) {
      throw Exception('Your account has been deleted. Please contact support.');
    }

    if (!profile.isActive) {
      throw Exception('Your account is currently disabled or suspended.');
    }

    final currentDeviceId = await _getDeviceId();
    if (profile.deviceId != null && profile.deviceId!.isNotEmpty && profile.deviceId != currentDeviceId) {
      throw Exception('DEVICE_MISMATCH');
    }

    return profile;
  }

  Future<void> updateLoginDetails(String userId) async {
    try {
      final deviceId = await _getDeviceId();
      if (deviceId.isEmpty) {
        debugPrint('[updateLoginDetails] deviceId is empty');
        return;
      }
      final response = await _api.post('/api/v1/users/me/login-details', body: {
        'deviceId': deviceId,
      });
      debugPrint('[updateLoginDetails] success: $response');
    } catch (e) {
      debugPrint('[updateLoginDetails] error: $e');
    }
  }

  Future<LearnerProfile> createProfile(User user, String fullName) async {
    final result = await _api.post('/api/v1/users/me/complete', body: {
      'fullName': fullName,
    });

    return LearnerProfile.fromJson(result);
  }

  Future<String> _getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedId = prefs.getString('local_device_id');
    if (storedId != null && storedId.isNotEmpty) {
      return storedId;
    }

    String deviceId = '';
    final deviceInfo = DeviceInfoPlugin();
    try {
      if (kIsWeb) {
        deviceId = const Uuid().v4();
      } else {
        if (defaultTargetPlatform == TargetPlatform.android) {
          final info = await deviceInfo.androidInfo;
          deviceId = info.id;
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          final info = await deviceInfo.iosInfo;
          deviceId = info.identifierForVendor ?? const Uuid().v4();
        } else {
          deviceId = const Uuid().v4();
        }
      }
    } catch (e) {
      deviceId = const Uuid().v4();
    }

    await prefs.setString('local_device_id', deviceId);
    return deviceId;
  }
}
