import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  String get baseUrl {
    return dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';
  }

  Future<Map<String, String>> _headers({bool withBody = false}) async {
    final session = Supabase.instance.client.auth.currentSession;
    final headers = <String, String>{};
    if (withBody) {
      headers['Content-Type'] = 'application/json';
    }
    if (session?.accessToken != null) {
      headers['Authorization'] = 'Bearer ${session!.accessToken}';
    }
    final fingerprint = await _getDeviceFingerprint();
    if (fingerprint.isNotEmpty) {
      headers['X-Device-Fingerprint'] = fingerprint;
    }
    return headers;
  }

  Future<String> _getDeviceFingerprint() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('device_fingerprint') ?? '';
  }

  Future<dynamic> get(String path, {Map<String, String>? queryParams}) async {
    var uri = Uri.parse('$baseUrl$path');
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }
    final response = await http.get(uri, headers: await _headers());
    return _handleResponse(response);
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.post(
      uri,
      headers: await _headers(withBody: true),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<dynamic> patch(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.patch(
      uri,
      headers: await _headers(withBody: true),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<dynamic> delete(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.delete(uri, headers: await _headers());
    return _handleResponse(response);
  }

  Future<dynamic> uploadFile(String path, String fieldName, Uint8List bytes, String fileName) async {
    final uri = Uri.parse('$baseUrl$path');
    final request = http.MultipartRequest('POST', uri);

    final headers = await _headers(withBody: true);
    headers.remove('Content-Type');
    request.headers.addAll(headers);
    request.files.add(http.MultipartFile.fromBytes(fieldName, bytes, filename: fileName));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    Object? body;
    try {
      body = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    } catch (_) {
      body = null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    final message = body is Map ? (body['message'] ?? body['error'] ?? response.reasonPhrase) : response.reasonPhrase;
    final fullMessage = '[${response.statusCode}] ${message ?? 'Request failed'}';
    debugPrint('API ERROR: $fullMessage | body: ${response.body} | url: ${response.request?.url}');
    throw ApiException(response.statusCode, fullMessage);
  }
}
