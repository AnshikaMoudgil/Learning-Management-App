import '../models/course.dart';
import 'api_client.dart';

class CourseService {
  final ApiClient _api = ApiClient();

  Future<List<Course>> getCourses({
    String? category,
    String? level,
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (category != null) params['category'] = category;
    if (level != null) params['level'] = level;
    if (search != null) params['search'] = search;

    final result = await _api.get('/api/v1/courses', queryParams: params);

    final List<dynamic> data = result is Map
        ? (result['data'] as List<dynamic>?) ?? []
        : (result as List<dynamic>);
    return data.map((e) => Course.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Course> getCourseDetails(String idOrSlug) async {
    final result = await _api.get('/api/v1/courses/$idOrSlug');
    return Course.fromJson(result as Map<String, dynamic>);
  }
}
