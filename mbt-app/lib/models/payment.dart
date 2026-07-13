class CouponValidation {
  final bool valid;
  final String? couponId;
  final String? code;
  final double discountAmount;
  final double finalPrice;
  final double baseAmount;
  final String? reason;

  CouponValidation({
    required this.valid,
    this.couponId,
    this.code,
    required this.discountAmount,
    required this.finalPrice,
    required this.baseAmount,
    this.reason,
  });

  factory CouponValidation.fromJson(Map<String, dynamic> json) {
    return CouponValidation(
      valid: json['valid'] as bool? ?? false,
      couponId: json['couponId'] as String?,
      code: json['code'] as String?,
      discountAmount: ((json['discountAmount'] ?? 0) as num).toDouble(),
      finalPrice: ((json['finalPrice'] ?? 0) as num).toDouble(),
      baseAmount: ((json['baseAmount'] ?? 0) as num).toDouble(),
      reason: json['reason'] as String?,
    );
  }
}

class PaymentOrder {
  final String orderId;
  final int amount;
  final String currency;
  final String keyId;
  final String courseId;
  final DateTime expiresAt;
  final bool reused;

  PaymentOrder({
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.keyId,
    required this.courseId,
    required this.expiresAt,
    required this.reused,
  });

  factory PaymentOrder.fromJson(Map<String, dynamic> json) {
    return PaymentOrder(
      orderId: json['orderId'] as String,
      amount: (json['amount'] as num).toInt(),
      currency: json['currency'] as String? ?? 'INR',
      keyId: json['keyId'] as String,
      courseId: json['courseId'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      reused: json['reused'] as bool? ?? false,
    );
  }
}

class PaymentCheckoutResult {
  final PaymentOrder order;
  final dynamic verificationResult;
  final bool pendingVerification;

  PaymentCheckoutResult({
    required this.order,
    this.verificationResult,
    this.pendingVerification = false,
  });
}

class PaymentPendingException implements Exception {
  final PaymentOrder order;
  final Object cause;

  PaymentPendingException(this.order, this.cause);

  @override
  String toString() {
    return 'Payment received. Confirmation is pending.';
  }
}
