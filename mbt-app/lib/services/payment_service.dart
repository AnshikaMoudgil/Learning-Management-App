import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../models/payment.dart';
import 'api_client.dart';
import 'web_razorpay.dart';

class PaymentService {
  final ApiClient _api = ApiClient();

  Future<CouponValidation> validateCoupon({
    required String code,
    required String courseId,
  }) async {
    final result = await _api.post('/api/v1/coupons/validate', body: {
      'code': code,
      'courseId': courseId,
    });
    return CouponValidation.fromJson(result as Map<String, dynamic>);
  }

  Future<PaymentOrder> createOrder({
    required String courseId,
    String? couponCode,
    bool allowRenewal = false,
  }) async {
    final result = await _api.post('/api/v1/payments/create-order', body: {
      'courseId': courseId,
      'allowRenewal': allowRenewal,
      if (couponCode != null && couponCode.trim().isNotEmpty)
        'couponCode': couponCode.trim(),
    });
    return PaymentOrder.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) {
    return _api.post('/api/v1/payments/verify', body: {
      'razorpayOrderId': razorpayOrderId,
      'razorpayPaymentId': razorpayPaymentId,
      'razorpaySignature': razorpaySignature,
    });
  }

  Future<PaymentCheckoutResult> checkoutCourse({
    required String courseId,
    required String courseTitle,
    String? couponCode,
    bool allowRenewal = false,
  }) async {
    final order = await createOrder(
      courseId: courseId,
      couponCode: couponCode,
      allowRenewal: allowRenewal,
    );

    if (kIsWeb) {
      return _checkoutWeb(order: order, courseTitle: courseTitle);
    }

    return _checkoutMobile(order: order, courseTitle: courseTitle);
  }

  Future<PaymentCheckoutResult> _checkoutMobile({
    required PaymentOrder order,
    required String courseTitle,
  }) async {
    final completer = Completer<PaymentCheckoutResult>();
    final razorpay = Razorpay();

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse response) async {
      try {
        final result = await verifyPayment(
          razorpayOrderId: response.orderId ?? order.orderId,
          razorpayPaymentId: response.paymentId ?? '',
          razorpaySignature: response.signature ?? '',
        );
        if (!completer.isCompleted) {
          completer.complete(
            PaymentCheckoutResult(order: order, verificationResult: result),
          );
        }
      } catch (error) {
        if (!completer.isCompleted) {
          completer.completeError(PaymentPendingException(order, error));
        }
      } finally {
        razorpay.clear();
      }
    });

    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse response) {
      if (!completer.isCompleted) {
        completer.completeError(Exception(response.message ?? 'Payment failed'));
      }
      razorpay.clear();
    });

    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (_) {});

    razorpay.open({
      'key': order.keyId,
      'amount': order.amount,
      'currency': order.currency,
      'name': 'MBT LMS',
      'description': courseTitle,
      'order_id': order.orderId,
      'prefill': const {},
      'theme': {'color': '#1E88E5'},
    });

    return completer.future.timeout(
      const Duration(minutes: 10),
      onTimeout: () {
        razorpay.clear();
        throw TimeoutException('Payment confirmation timed out');
      },
    );
  }

  Future<PaymentCheckoutResult> _checkoutWeb({
    required PaymentOrder order,
    required String courseTitle,
  }) async {
    final completer = Completer<PaymentCheckoutResult>();

    WebRazorpay.open(
      key: order.keyId,
      amount: order.amount,
      currency: order.currency,
      name: 'MBT LMS',
      description: courseTitle,
      orderId: order.orderId,
      onSuccess: (paymentId, razorpayOrderId, signature) async {
        try {
          final result = await verifyPayment(
            razorpayOrderId: razorpayOrderId,
            razorpayPaymentId: paymentId,
            razorpaySignature: signature,
          );
          if (!completer.isCompleted) {
            completer.complete(
              PaymentCheckoutResult(order: order, verificationResult: result),
            );
          }
        } catch (error) {
          if (!completer.isCompleted) {
            completer.completeError(PaymentPendingException(order, error));
          }
        }
      },
      onError: (error) {
        if (!completer.isCompleted) {
          completer.completeError(Exception(error));
        }
      },
    );

    return completer.future.timeout(
      const Duration(minutes: 10),
      onTimeout: () {
        throw TimeoutException('Payment confirmation timed out');
      },
    );
  }
}
