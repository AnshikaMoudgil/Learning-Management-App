import '../models/device.dart';
import '../models/device_change_request.dart';
import 'api_client.dart';

class DeviceService {
  final ApiClient _api = ApiClient();

  Future<List<Device>> getDevices() async {
    final result = await _api.get('/api/v1/devices');
    return (result as List).map((d) => Device.fromJson(d)).toList();
  }

  Future<Map<String, dynamic>?> getActiveDevice() async {
    try {
      final result = await _api.get('/api/v1/devices/active');
      return result as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  Future<DeviceChangeRequest> createChangeRequest({
    required String fingerprint,
    String? reason,
  }) async {
    final result = await _api.post(
      '/api/v1/devices/change-request',
      body: {'fingerprint': fingerprint, if (reason != null) 'reason': reason},
    );
    return DeviceChangeRequest.fromJson(result);
  }

  Future<List<DeviceChangeRequest>> getUserChangeRequests() async {
    final result = await _api.get('/api/v1/devices/change-requests');
    return (result as List)
        .map((r) => DeviceChangeRequest.fromJson(r))
        .toList();
  }
}
