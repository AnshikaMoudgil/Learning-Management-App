import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'home_dashboard.dart';
import 'my_courses_screen.dart';
import 'live_classes_screen.dart';
import 'more_screen.dart';
import 'package:go_router/go_router.dart';
import '../widgets/cart_badge.dart';
import '../services/wishlist_provider.dart';
import '../services/cart_provider.dart';
import '../services/wishlist_service.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final _wishlistProvider = WishlistProvider();
  final _cartProvider = CartProvider();

  @override
  void initState() {
    super.initState();
    _wishlistProvider.addListener(_onChange);
    if (!_wishlistProvider.initialized) {
      _wishlistProvider.refresh();
    }
  }

  @override
  void dispose() {
    _wishlistProvider.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  void _moveToCart(String courseId) async {
    try {
      bool alreadyInCart = false;
      try {
        await _cartProvider.addItem(courseId);
      } catch (e) {
        if (e.toString().contains('409') || e.toString().contains('already in cart')) {
          alreadyInCart = true;
        } else {
          rethrow;
        }
      }

      await _wishlistProvider.toggleWishlist(courseId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(alreadyInCart ? 'Item was already in cart' : 'Moved to cart')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to move to cart: $e')),
        );
      }
    }
  }

  void _removeFromWishlist(String courseId) async {
    await _wishlistProvider.toggleWishlist(courseId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Removed from wishlist')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => context.pop(),
        ),
        title: const Text('Wishlist', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          const CartBadge(),
          const SizedBox(width: 8),
        ],
      ),
      body: _wishlistProvider.isLoading && !_wishlistProvider.initialized
          ? const Center(child: CircularProgressIndicator())
          : _wishlistProvider.items.isEmpty
              ? _buildEmptyState()
              : _buildPopulatedState(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/wishlist_empty.png',
              width: 250,
              height: 250,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.favorite_border, size: 100, color: AppColors.primaryBlue),
            ),
            const SizedBox(height: 24),
            const Text('Your wishlist is empty', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 12),
            const Text(
              'Save courses and products you\'re interested in for later.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textLight),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.school, color: Colors.white, size: 20),
              label: const Text('Explore Courses', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                context.go('/categories');
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.textDark, size: 20),
              label: const Text('Explore Store', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                context.go('/store');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopulatedState() {
    final items = _wishlistProvider.items;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${items.length} items', style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
              Row(
                children: const [
                  Text('Sort by: ', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                  Text('Recently Added', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  Icon(Icons.keyboard_arrow_down, size: 16),
                ],
              )
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.65,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildWishlistItem(item);
            },
          ),
        )
      ],
    );
  }

  Widget _buildWishlistItem(WishlistItem item) {
    bool isCourse = item.category?.toLowerCase() != 'hardware';
    String tag = isCourse ? 'COURSE' : 'HARDWARE';

    return GestureDetector(
      onTap: () {
        context.push('/course?id=${item.courseId}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image and badges
            Stack(
              children: [
                Container(
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    color: Colors.grey[200],
                    image: item.thumbnailUrl != null
                        ? DecorationImage(image: NetworkImage(item.thumbnailUrl!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: item.thumbnailUrl == null
                      ? const Center(child: Icon(Icons.image, color: Colors.grey))
                      : null,
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: isCourse ? AppColors.primaryBlue : Colors.purple, borderRadius: BorderRadius.circular(4)),
                    child: Text(tag, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _removeFromWishlist(item.courseId),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.favorite, color: Colors.red, size: 14),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark), maxLines: 2, overflow: TextOverflow.ellipsis),
                    if (item.instructorName != null && item.instructorName!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text('By ${item.instructorName}', style: const TextStyle(fontSize: 9, color: AppColors.textLight)),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 10),
                        const SizedBox(width: 2),
                        const Text('4.8 (1.2k)', style: TextStyle(fontSize: 8, color: AppColors.textLight)),
                        const SizedBox(width: 4),
                        if (item.isPremium)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                            child: const Text('Premium', style: TextStyle(color: AppColors.primaryBlue, fontSize: 8)),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                            child: const Text('Free', style: TextStyle(color: Colors.green, fontSize: 8)),
                          )
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('₹${item.discountPrice ?? item.price}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.shopping_cart, size: 12),
                            label: const Text('Add to Cart', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 2),
                              minimumSize: const Size(0, 32),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            onPressed: () => _moveToCart(item.courseId),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _removeFromWishlist(item.courseId),
                          child: Container(
                            height: 32,
                            width: 32,
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.delete_outline, size: 16, color: AppColors.textLight),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
