import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/profile.dart';
import 'api_client.dart';

class ProfileService {
  final ApiClient _api = ApiClient();

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

  Future<Profile> createProfile(String fullName) async {
    final result = await _api.post('/api/v1/users/me/complete', body: {
      'fullName': fullName,
    });
    return Profile.fromJson(result);
  }

  Future<Profile> updateProfile(String fullName, {String? phone, String? about}) async {
    final result = await _api.patch('/api/v1/users/me', body: {
      'fullName': fullName,
      if (phone != null) 'phone': phone,
      if (about != null) 'about': about,
    });
    return Profile.fromJson(result);
  }

  Future<void> bindDevice(String userId) async {
    final fingerprint = await _getDeviceFingerprint();
    await _api.post('/api/v1/devices/bind', body: {
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
    await _api.uploadFile(
      '/api/v1/users/me/photo',
      'photo',
      bytes,
      fileName,
    );
  }

  Future<void> deleteAvatar() async {
    await _api.delete('/api/v1/users/me/photo');
  }
}
