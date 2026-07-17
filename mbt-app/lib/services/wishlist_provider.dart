import 'package:flutter/foundation.dart';
import 'wishlist_service.dart';

class WishlistProvider extends ChangeNotifier {
  WishlistProvider._();
  static final WishlistProvider _instance = WishlistProvider._();
  factory WishlistProvider() => _instance;

  final WishlistService _service = WishlistService();
  
  List<WishlistItem> _items = [];
  final Set<String> _wishlistedCourseIds = {};
  bool _initialized = false;
  bool _isLoading = false;

  List<WishlistItem> get items => _items;
  bool get initialized => _initialized;
  bool get isLoading => _isLoading;

  bool isWishlisted(String courseId) => _wishlistedCourseIds.contains(courseId);

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _service.getWishlist();
      _items = response.items;
      _wishlistedCourseIds.clear();
      for (var item in _items) {
        _wishlistedCourseIds.add(item.courseId);
      }
      _initialized = true;
    } catch (_) {
      // Keep existing data on error or clear it based on preference
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleWishlist(String courseId) async {
    final currentlyWishlisted = _wishlistedCourseIds.contains(courseId);
    
    // Optimistic update
    if (currentlyWishlisted) {
      _wishlistedCourseIds.remove(courseId);
      _items.removeWhere((item) => item.courseId == courseId);
    } else {
      _wishlistedCourseIds.add(courseId);
    }
    notifyListeners();

    try {
      if (currentlyWishlisted) {
        await _service.removeItem(courseId);
      } else {
        await _service.addItem(courseId);
      }
      // Refresh to ensure full data sync (gets the full item details like instructor, etc)
      await refresh();
    } catch (_) {
      // Revert optimistic update on failure
      if (currentlyWishlisted) {
        _wishlistedCourseIds.add(courseId);
      } else {
        _wishlistedCourseIds.remove(courseId);
      }
      notifyListeners();
      await refresh(); // ensure clean state
    }
  }

  void clear() {
    _items.clear();
    _wishlistedCourseIds.clear();
    _initialized = false;
    notifyListeners();
  }
}
