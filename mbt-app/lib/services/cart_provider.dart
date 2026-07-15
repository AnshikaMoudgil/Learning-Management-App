import 'package:flutter/foundation.dart';
import 'cart_service.dart';

class CartProvider extends ChangeNotifier {
  CartProvider._();
  static final CartProvider _instance = CartProvider._();
  factory CartProvider() => _instance;

  final CartService _cartService = CartService();
  int _itemCount = 0;
  bool _initialized = false;

  int get itemCount => _itemCount;
  bool get initialized => _initialized;

  Future<CartResponse?> refresh() async {
    try {
      final cart = await _cartService.getCart();
      _itemCount = cart.totalItems;
      _initialized = true;
      notifyListeners();
      return cart;
    } catch (_) {
      _itemCount = 0;
      _initialized = true;
      notifyListeners();
      return null;
    }
  }

  Future<void> addItem(String courseId) async {
    await _cartService.addItem(courseId);
    await refresh();
  }

  Future<void> removeItem(String courseId) async {
    await _cartService.removeItem(courseId);
    await refresh();
  }
}
