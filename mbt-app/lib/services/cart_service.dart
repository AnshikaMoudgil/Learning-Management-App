import 'api_client.dart';

class CartItem {
  final String id;
  final String courseId;
  final String title;
  final String slug;
  final String? shortDescription;
  final String? thumbnailUrl;
  final double price;
  final double? discountPrice;
  final double effectivePrice;
  final String? category;
  final String level;
  final String? estimatedDuration;
  final int totalLessons;
  final String addedAt;

  CartItem({
    required this.id,
    required this.courseId,
    required this.title,
    required this.slug,
    this.shortDescription,
    this.thumbnailUrl,
    required this.price,
    this.discountPrice,
    required this.effectivePrice,
    this.category,
    required this.level,
    this.estimatedDuration,
    required this.totalLessons,
    required this.addedAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      courseId: json['courseId'] as String,
      title: json['title'] as String,
      slug: json['slug'] as String,
      shortDescription: json['shortDescription'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      price: (json['price'] as num).toDouble(),
      discountPrice: (json['discountPrice'] as num?)?.toDouble(),
      effectivePrice: (json['effectivePrice'] as num).toDouble(),
      category: json['category'] as String?,
      level: json['level'] as String,
      estimatedDuration: json['estimatedDuration'] as String?,
      totalLessons: (json['totalLessons'] as num).toInt(),
      addedAt: json['addedAt'] as String,
    );
  }

  bool get isHardware => category?.toLowerCase().contains('hardware') ?? false;
}

class CartResponse {
  final String cartId;
  final int totalItems;
  final List<CartItem> hardware;
  final List<CartItem> software;

  CartResponse({
    required this.cartId,
    required this.totalItems,
    required this.hardware,
    required this.software,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    return CartResponse(
      cartId: json['cartId'] as String,
      totalItems: (json['totalItems'] as num).toInt(),
      hardware: (json['hardware'] as List)
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      software: (json['software'] as List)
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CartService {
  final ApiClient _api = ApiClient();

  Future<CartResponse> getCart() async {
    final result = await _api.get('/api/v1/cart');
    return CartResponse.fromJson(result as Map<String, dynamic>);
  }

  Future<void> addItem(String courseId) async {
    await _api.post('/api/v1/cart/items', body: {'courseId': courseId});
  }

  Future<void> removeItem(String courseId) async {
    await _api.delete('/api/v1/cart/items/$courseId');
  }
}
