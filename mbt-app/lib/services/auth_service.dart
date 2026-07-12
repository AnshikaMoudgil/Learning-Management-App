import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _api = ApiClient();
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> signInWithGoogle() async {
    if (kIsWeb) {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: Uri.base.toString(),
      );
      return {};
    }

    final webClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'];
    final iosClientId = dotenv.env['GOOGLE_IOS_CLIENT_ID'];

    final GoogleSignIn googleSignIn = GoogleSignIn(
      serverClientId: webClientId,
      clientId: iosClientId,
    );

    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google Sign-In was cancelled by the user.');
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final String? idToken = googleAuth.idToken;
    final String? accessToken = googleAuth.accessToken;

    if (idToken == null) {
      throw Exception('No ID Token found. Make sure GOOGLE_WEB_CLIENT_ID is provided in .env.');
    }

    final result = await _api.post('/api/v1/auth/google', body: {
      'idToken': idToken,
      if (accessToken != null) 'accessToken': accessToken,
    });

    if (result != null && result['refreshToken'] != null) {
      await _supabase.auth.setSession(
        result['refreshToken'] ?? '',
        accessToken: result['accessToken'],
      );
    }

    return result ?? {};
  }

  Future<void> sendOtp(String phone) async {
    await _api.post('/api/v1/auth/send-otp', body: {'phone': phone});
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String token) async {
    final result = await _api.post('/api/v1/auth/verify-otp', body: {
      'phone': phone,
      'token': token,
    });

    if (result != null && result['refreshToken'] != null) {
      await _supabase.auth.setSession(
        result['refreshToken'] ?? '',
        accessToken: result['accessToken'],
      );
    }

    return result ?? {};
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
