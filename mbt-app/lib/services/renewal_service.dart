import '../models/renewal_plan.dart';
import 'api_client.dart';

class RenewalService {
  final ApiClient _api = ApiClient();

  Future<List<RenewalPlan>> fetchRenewalPlans(String courseId) async {
    final result = await _api.get(
      '/api/v1/renewal-plans',
      queryParams: {'courseId': courseId},
    );
    if (result is List) {
      return result
          .map((item) => RenewalPlan.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
