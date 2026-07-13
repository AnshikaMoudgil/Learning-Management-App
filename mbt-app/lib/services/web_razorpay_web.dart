import 'dart:html' as html;
import 'dart:js_util' as js_util;

class WebRazorpay {
  static void open({
    required String key,
    required int amount,
    required String currency,
    required String name,
    required String description,
    required String orderId,
    required void Function(String paymentId, String orderId, String signature) onSuccess,
    required void Function(String error) onError,
  }) {
    final razorpay = js_util.getProperty(html.window, 'Razorpay');
    if (razorpay == null) {
      onError('Razorpay SDK not loaded. Please refresh the page.');
      return;
    }

    final options = {
      'key': key,
      'amount': amount,
      'currency': currency,
      'name': name,
      'description': description,
      'order_id': orderId,
      'handler': (dynamic response) {
        onSuccess(
          js_util.getProperty(response, 'razorpay_payment_id') as String? ?? '',
          js_util.getProperty(response, 'razorpay_order_id') as String? ?? '',
          js_util.getProperty(response, 'razorpay_signature') as String? ?? '',
        );
      },
      'modal': {
        'ondismiss': () {
          onError('Payment cancelled by user');
        },
      },
      'theme': {'color': '#1E88E5'},
    };

    final jsOptions = js_util.jsify(options);
    final instance = js_util.callConstructor(razorpay, [jsOptions]);
    js_util.callMethod(instance, 'open', []);
  }
}
