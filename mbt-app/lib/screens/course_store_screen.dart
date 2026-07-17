import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import '../models/course.dart';
import '../services/course_service.dart';
import '../widgets/cart_badge.dart';
import '../services/wishlist_provider.dart';

class CourseStoreScreen extends StatefulWidget {
  const CourseStoreScreen({Key? key}) : super(key: key);

  @override
  State<CourseStoreScreen> createState() => _CourseStoreScreenState();
}

class _CourseStoreScreenState extends State<CourseStoreScreen> {
  String? _selectedCategory;
  final _courseService = CourseService();
  late Future<List<Course>> _popularCoursesFuture;
  late Future<List<Course>> _newlyAddedFuture;

  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.grid_view_rounded, 'name': 'All', 'color': Colors.blue},
    {'icon': Icons.code, 'name': 'Development', 'color': Colors.green},
    {'icon': Icons.analytics_outlined, 'name': 'Data Science', 'color': Colors.purple},
    {'icon': Icons.design_services_outlined, 'name': 'Design', 'color': Colors.pink},
    {'icon': Icons.business_center_outlined, 'name': 'Business', 'color': Colors.orange},
    {'icon': Icons.campaign_outlined, 'name': 'Marketing', 'color': Colors.cyan},
  ];

  @override
  void initState() {
    super.initState();
    _popularCoursesFuture = _courseService.getCourses(limit: 6);
    _newlyAddedFuture = _courseService.getCourses(limit: 10);
  }

  void _filterByCategory(String? category) {
    setState(() {
      _selectedCategory = category;
      _popularCoursesFuture = _courseService.getCourses(category: category, limit: 6);
      _newlyAddedFuture = _courseService.getCourses(category: category, limit: 10);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Course Store', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                          SizedBox(height: 4),
                          Text('Discover the best courses to learn and grow', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                        ],
                      ),
                    ),
                    const CartBadge(),
                    const SizedBox(width: 16),
                    AnimatedBuilder(
                      animation: WishlistProvider(),
                      builder: (context, _) {
                        final count = WishlistProvider().items.length;
                        return _buildIconBadge(
                          Icons.favorite_border,
                          count > 0 ? count.toString() : '0',
                          Colors.red,
                          () => context.push('/wishlist'),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    _buildIconBadge(Icons.notifications_outlined, '0', Colors.red, () => context.push('/notifications')),
                  ],
                ),
              ),

              // Search & Filter
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                  hintText: 'Search for courses, topics or teachers...',
                                  hintStyle: TextStyle(fontSize: 12, color: AppColors.textLight),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Categories
              _buildSectionHeader('Categories', onViewAll: () {
                context.push('/categories');
              }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _filterByCategory(_selectedCategory == 'software' ? null : 'software'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: _selectedCategory == 'software' ? Colors.blue.withValues(alpha: 0.1) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _selectedCategory == 'software' ? Colors.blue : Colors.grey.shade200),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.developer_mode, color: _selectedCategory == 'software' ? Colors.blue : Colors.grey, size: 24),
                              const SizedBox(height: 8),
                              Text('Software', style: TextStyle(fontSize: 12, fontWeight: _selectedCategory == 'software' ? FontWeight.bold : FontWeight.normal, color: AppColors.textDark)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _filterByCategory(_selectedCategory == 'hardware' ? null : 'hardware'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: _selectedCategory == 'hardware' ? Colors.blue.withValues(alpha: 0.1) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _selectedCategory == 'hardware' ? Colors.blue : Colors.grey.shade200),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.memory, color: _selectedCategory == 'hardware' ? Colors.blue : Colors.grey, size: 24),
                              const SizedBox(height: 8),
                              Text('Hardware', style: TextStyle(fontSize: 12, fontWeight: _selectedCategory == 'hardware' ? FontWeight.bold : FontWeight.normal, color: AppColors.textDark)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Popular Courses
              _buildSectionHeader('Popular Courses', onViewAll: () {
                context.push('/popular-courses');
              }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: FutureBuilder<List<Course>>(
                  future: _popularCoursesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snapshot.hasError || (snapshot.data ?? []).isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      children: snapshot.data!
                          .map(
                            (course) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildCourseCardFromApi(course),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Newly Added
              _buildSectionHeader('Newly Added', onViewAll: () {
                context.push('/newly-added-courses');
              }),
              FutureBuilder<List<Course>>(
                future: _newlyAddedFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const SizedBox(
                      height: 160,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError || (snapshot.data ?? []).isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return SizedBox(
                    height: 160,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: snapshot.data!
                          .map((course) => Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: _buildNewlyAddedCardFromApi(course),
                              ))
                          .toList(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconBadge(IconData icon, String count, Color badgeColor, VoidCallback onTap) {
    final showBadge = count != '0' && count.isNotEmpty;
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(icon: Icon(icon, color: AppColors.textDark), onPressed: onTap),
        if (showBadge)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(count, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            ),
          )
      ],
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onViewAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          if (onViewAll != null)
            GestureDetector(
              onTap: onViewAll,
              child: const Text('View All', style: TextStyle(fontSize: 12, color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _buildPopularCourseCard({
    String? courseId,
    required ImageProvider image,
    required String title,
    required String subtitle,
    required String author,
    required String authorRole,
    String? authorAvatarUrl,
    required String rating,
    required String reviews,
    required String duration,
    required String level,
    required String price,
    required String oldPrice,
    bool isBestseller = false,
  }) {
    return GestureDetector(
      onTap: () => context.push(courseId == null ? '/course' : '/course?id=$courseId'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Container(
              width: 140,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                image: DecorationImage(image: image, fit: BoxFit.cover),
              ),
              child: Stack(
                children: [
                  if (isBestseller)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(4)),
                        child: const Text('Bestseller', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black)),
                      ),
                    ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), shape: BoxShape.circle),
                      child: const Icon(Icons.play_arrow, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
            // Details Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark), maxLines: 2, overflow: TextOverflow.ellipsis)),
                        const SizedBox(width: 4),
                        AnimatedBuilder(
                          animation: WishlistProvider(),
                          builder: (context, _) {
                            final isWishlisted = courseId != null && WishlistProvider().isWishlisted(courseId);
                            return GestureDetector(
                              onTap: () {
                                if (courseId != null) {
                                  WishlistProvider().toggleWishlist(courseId);
                                }
                              },
                              child: Icon(
                                isWishlisted ? Icons.favorite : Icons.favorite_border,
                                size: 18,
                                color: isWishlisted ? Colors.red : Colors.grey,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textLight), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 10,
                          backgroundImage: authorAvatarUrl != null ? NetworkImage(authorAvatarUrl) : null,
                          child: authorAvatarUrl == null ? const Icon(Icons.person, size: 12, color: Colors.grey) : null,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(author, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                              Text(authorRole, style: const TextStyle(fontSize: 8, color: AppColors.textLight)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 12),
                        const SizedBox(width: 4),
                        Text('$rating ($reviews)', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                        const SizedBox(width: 8),
                        const Text('•', style: TextStyle(fontSize: 10, color: AppColors.textLight)),
                        const SizedBox(width: 8),
                        Text(duration, style: const TextStyle(fontSize: 10, color: AppColors.textDark)),
                        const SizedBox(width: 8),
                        const Text('•', style: TextStyle(fontSize: 10, color: AppColors.textLight)),
                        const SizedBox(width: 8),
                        Expanded(child: Text(level, style: const TextStyle(fontSize: 10, color: AppColors.textDark), overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                        const SizedBox(width: 8),
                        Text(oldPrice, style: const TextStyle(fontSize: 10, color: AppColors.textLight, decoration: TextDecoration.lineThrough)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCardFromApi(Course course) {
    return _buildPopularCourseCard(
      courseId: course.id,
      image: course.thumbnailUrl != null ? NetworkImage(course.thumbnailUrl!) as ImageProvider : const AssetImage('assets/iphone_software.png') as ImageProvider,
      title: course.title,
      subtitle: course.shortDescription ?? course.description ?? '',
      author: course.instructorName ?? 'Instructor',
      authorRole: course.instructorSpecialization ?? course.category ?? 'Instructor',
      authorAvatarUrl: course.instructorAvatarUrl,
      rating: course.averageRating.toStringAsFixed(1),
      reviews: '${course.reviewsCount}',
      duration: course.estimatedDuration ?? 'Self paced',
      level: course.level.name,
      price: '₹${course.effectivePrice.toStringAsFixed(0)}',
      oldPrice: course.hasDiscount ? '₹${course.price.toStringAsFixed(0)}' : '',
      isBestseller: course.isBestseller,
    );
  }

  Widget _buildNewlyAddedCardFromApi(Course course) {
    return GestureDetector(
      onTap: () => context.push('/course?id=${course.id}'),
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    image: course.thumbnailUrl != null
                        ? DecorationImage(image: NetworkImage(course.thumbnailUrl!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: course.thumbnailUrl == null
                      ? const Icon(Icons.menu_book, color: Colors.grey, size: 28)
                      : null,
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: AnimatedBuilder(
                    animation: WishlistProvider(),
                    builder: (context, _) {
                      final isWishlisted = WishlistProvider().isWishlisted(course.id);
                      return GestureDetector(
                        onTap: () {
                          WishlistProvider().toggleWishlist(course.id);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.8),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isWishlisted ? Icons.favorite : Icons.favorite_border,
                            size: 14,
                            color: isWishlisted ? Colors.red : Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(course.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textDark), maxLines: 2),
            const SizedBox(height: 8),
            Row(
              children: [
                CircleAvatar(
                  radius: 8,
                  backgroundImage: course.instructorAvatarUrl != null ? NetworkImage(course.instructorAvatarUrl!) : null,
                  child: course.instructorAvatarUrl == null ? const Icon(Icons.person, size: 10, color: Colors.grey) : null,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(course.instructorName ?? 'Instructor', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                      Text(course.instructorSpecialization ?? course.category ?? '', style: const TextStyle(fontSize: 8, color: AppColors.textLight)),
                    ],
                  ),
                ),
                Text('₹${course.effectivePrice.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textDark)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 10),
                const SizedBox(width: 4),
                Text('${course.averageRating.toStringAsFixed(1)} (${course.reviewsCount})', style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(width: 8),
                const Text('•', style: TextStyle(fontSize: 8, color: AppColors.textLight)),
                const SizedBox(width: 8),
                Text(course.estimatedDuration ?? 'Self paced', style: const TextStyle(fontSize: 8, color: AppColors.textDark)),
                const Spacer(),
                if (course.hasDiscount)
                  Text('₹${course.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 8, color: AppColors.textLight, decoration: TextDecoration.lineThrough)),
              ],
            ),
          ],
        ),
      ),
    );
  }

}
