class WebRazorpay {
  static void open({
    required String key,
    required int amount,
    required String currency,
    required String name,
    required String description,
    required String orderId,
    required void Function(String paymentId, String orderId, String signature)
    onSuccess,
    required void Function(String error) onError,
  }) {
    throw UnsupportedError(
      'Razorpay web checkout is not available on this platform',
    );
  }
}
