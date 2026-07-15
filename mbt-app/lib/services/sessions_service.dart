import '../models/session.dart';
import 'api_client.dart';

class SessionsService {
  final ApiClient _api = ApiClient();

  Future<List<LiveSession>> getSessions(String courseId) async {
    final data = await _api.get('/sessions/course/$courseId');
    final List<dynamic> list = data as List<dynamic>;
    return list.map((e) => LiveSession.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<LiveSession>> getUpcoming() async {
    final data = await _api.get('/sessions/upcoming');
    final List<dynamic> list = data as List<dynamic>;
    return list.map((e) => LiveSession.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Map<String, dynamic>> joinSession(String sessionId) async {
    return _api.post('/sessions/$sessionId/join') as Map<String, dynamic>;
  }
}
