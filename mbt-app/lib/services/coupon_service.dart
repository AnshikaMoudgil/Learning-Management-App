import 'api_client.dart';

class CouponItem {
  final String id;
  final String code;
  final String discountType;
  final dynamic discountValue;
  final DateTime? expiresAt;

  CouponItem({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    this.expiresAt,
  });

  factory CouponItem.fromJson(Map<String, dynamic> json) {
    return CouponItem(
      id: json['id'] as String,
      code: json['code'] as String,
      discountType: json['discount_type'] as String,
      discountValue: json['discount_value'],
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
    );
  }

  String get discountText {
    if (discountType == 'percentage') {
      return '${discountValue}% OFF';
    }
    return '₹${discountValue} OFF';
  }
}

class CouponService {
  final ApiClient _api = ApiClient();

  Future<List<CouponItem>> getActiveCoupons() async {
    try {
      final result = await _api.get('/api/v1/coupons/active');
      final List<dynamic> data = result is Map
          ? (result['data'] as List<dynamic>?) ?? []
          : (result as List<dynamic>);
      return data
          .map((e) => CouponItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
