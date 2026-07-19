import 'api_client.dart';

class WishlistItem {
  final String id;
  final String courseId;
  final String title;
  final String? instructorName;
  final double price;
  final double? discountPrice;
  final String? thumbnailUrl;
  final String? category;
  final bool isPremium;
  final String addedAt;

  WishlistItem({
    required this.id,
    required this.courseId,
    required this.title,
    this.instructorName,
    required this.price,
    this.discountPrice,
    this.thumbnailUrl,
    this.category,
    required this.isPremium,
    required this.addedAt,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    final course = json['courses'] ?? {};
    final profile = course['profiles'] ?? {};

    return WishlistItem(
      id: json['id'] as String,
      courseId: json['course_id'] as String,
      title: course['title'] as String? ?? 'Unknown',
      instructorName: profile['full_name'] as String?,
      price: ((course['price'] ?? 0) as num).toDouble(),
      discountPrice: course['discount_price'] != null
          ? (course['discount_price'] as num).toDouble()
          : null,
      thumbnailUrl: course['thumbnail_url'] as String?,
      category: course['category'] as String?,
      isPremium: course['is_premium'] as bool? ?? false,
      addedAt: json['created_at'] as String,
    );
  }
}

class WishlistResponse {
  final List<WishlistItem> items;

  WishlistResponse({required this.items});

  factory WishlistResponse.fromJson(Map<String, dynamic> json) {
    return WishlistResponse(
      items:
          (json['items'] as List?)
              ?.map((e) => WishlistItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class WishlistService {
  final ApiClient _api = ApiClient();

  Future<WishlistResponse> getWishlist() async {
    final result = await _api.get('/api/v1/wishlist');
    return WishlistResponse.fromJson(result as Map<String, dynamic>);
  }

  Future<void> addItem(String courseId) async {
    await _api.post('/api/v1/wishlist/items', body: {'courseId': courseId});
  }

  Future<void> removeItem(String courseId) async {
    await _api.delete('/api/v1/wishlist/items/$courseId');
  }
}
