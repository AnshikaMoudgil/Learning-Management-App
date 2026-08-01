import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/renewal_plan.dart';
import '../services/payment_service.dart';
import '../services/renewal_service.dart';
import '../services/api_client.dart';
import '../theme/app_colors.dart';
import '../widgets/cart_badge.dart';
import 'package:intl/intl.dart';

class RenewCourseScreen extends StatefulWidget {
  final String courseId;
  final String enrollmentId;

  const RenewCourseScreen({
    Key? key,
    required this.courseId,
    required this.enrollmentId,
  }) : super(key: key);

  @override
  State<RenewCourseScreen> createState() => _RenewCourseScreenState();
}

class _RenewCourseScreenState extends State<RenewCourseScreen> {
  final RenewalService _renewalService = RenewalService();
  final PaymentService _paymentService = PaymentService();
  final ApiClient _api = ApiClient();

  bool _loading = true;
  String? _errorMessage;

  String _courseTitle = '';
  DateTime? _validityEndAt;
  List<RenewalPlan> _plans = [];
  int _selectedPlanIndex = 0;
  bool _isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _loading = true;
        _errorMessage = null;
      });

      // 1. Fetch course detail / enrollment info (specifically the validity end date and name)
      final enrollmentRes = await _api.get('/api/v1/enrollments');
      final List<dynamic> enrollmentList = enrollmentRes is Map
          ? (enrollmentRes['data'] as List<dynamic>?) ?? []
          : (enrollmentRes as List<dynamic>);

      Map<String, dynamic>? currentEnrollment;
      for (final e in enrollmentList) {
        if (e['enrollment_id'] == widget.enrollmentId) {
          currentEnrollment = e as Map<String, dynamic>;
          break;
        }
      }

      if (currentEnrollment != null) {
        _courseTitle = currentEnrollment['title'] ?? 'Course';
        if (currentEnrollment['validity_end_at'] != null) {
          _validityEndAt = DateTime.parse(currentEnrollment['validity_end_at'] as String);
        }
      } else {
        // Fallback fetch courses directly if enrollment details couldn't be parsed
        final courseRes = await _api.get('/api/v1/courses/${widget.courseId}');
        _courseTitle = courseRes['title'] ?? 'Course';
      }

      // 2. Fetch renewal plans
      final plans = await _renewalService.fetchRenewalPlans(widget.courseId);
      setState(() {
        _plans = plans;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load renewal plans: $e';
        _loading = false;
      });
    }
  }

  Future<void> _handlePayment() async {
    if (_plans.isEmpty) return;
    final plan = _plans[_selectedPlanIndex];

    setState(() {
      _isProcessingPayment = true;
    });

    try {
      final result = await _paymentService.checkoutCourses(
        courseIds: [widget.courseId],
        checkoutTitle: 'Renew Course - ${plan.label}',
        allowRenewal: true,
        renewalPlanId: plan.id,
      );

      if (mounted) {
        context.pushReplacement(
          '/payment-success?courseTitle=${Uri.encodeComponent(_courseTitle)}&orderId=${result.order.orderId}&status=success',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed or cancelled: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
        });
      }
    }
  }

  int get _daysRemaining {
    if (_validityEndAt == null) return 0;
    final diff = _validityEndAt!.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Renew Course',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            Text(
              'Extend your access and keep learning without interruption.',
              style: TextStyle(fontSize: 10, color: AppColors.textLight),
            ),
          ],
        ),
        actions: const [
          CartBadge(),
          SizedBox(width: 16),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadData,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      // Course Info Card
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A237E),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Icon(Icons.book, color: Colors.white, size: 28),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _courseTitle,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today_outlined,
                                        size: 10,
                                        color: AppColors.textLight,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _validityEndAt != null
                                            ? 'Current valid till: ${DateFormat('dd MMM yyyy').format(_validityEndAt!)}'
                                            : 'No active validity date',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (_daysRemaining > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFEBEE),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFE53935)),
                                ),
                                child: Column(
                                  children: [
                                    const Text(
                                      'Expires in',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Color(0xFFE53935),
                                      ),
                                    ),
                                    Text(
                                      '$_daysRemaining',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFE53935),
                                      ),
                                    ),
                                    const Text(
                                      'Days',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Color(0xFFE53935),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Select Renewal Plan Header
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Select Renewal Plan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Choose a plan to extend your course validity.',
                          style: TextStyle(fontSize: 11, color: AppColors.textLight),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Dynamic Plan List
                      if (_plans.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'No active renewal plans available for this course.',
                            style: TextStyle(color: Colors.red, fontSize: 13),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _plans.length,
                          itemBuilder: (context, index) {
                            final plan = _plans[index];
                            final isSelected = _selectedPlanIndex == index;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedPlanIndex = index),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.lightBlueBg : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected ? AppColors.primaryBlue : AppColors.border,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isSelected
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_unchecked,
                                      color: isSelected ? AppColors.primaryBlue : AppColors.textLight,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            plan.label,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textDark,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Extend access by ${plan.durationValue} ${plan.durationUnit}.',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: AppColors.textLight,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '₹${plan.price.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: AppColors.textLight,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                      const SizedBox(height: 16),

                      // Info Box
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.lightBlueBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: AppColors.primaryBlue,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Your progress, certificates, and access will be continued after renewal.',
                                style: TextStyle(fontSize: 11, color: AppColors.textDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Payment Summary (Only show if plans are loaded)
                      if (_plans.isNotEmpty) ...[
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Payment Summary',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Course', style: TextStyle(fontSize: 13, color: AppColors.textLight)),
                                  Text(_courseTitle, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textDark)),
                                ],
                              ),
                              const Divider(height: 24, color: AppColors.border),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Plan', style: TextStyle(fontSize: 13, color: AppColors.textLight)),
                                  Text(_plans[_selectedPlanIndex].label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textDark)),
                                ],
                              ),
                              const Divider(height: 24, color: AppColors.border),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  Text(
                                    '₹${_plans[_selectedPlanIndex].price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Proceed Button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: _isProcessingPayment ? null : _handlePayment,
                              icon: _isProcessingPayment
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Icon(
                                      Icons.lock_outline,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                              label: Text(
                                _isProcessingPayment ? 'Processing...' : 'Proceed to Payment',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Secure payment info
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.verified_user_outlined,
                              size: 14,
                              color: AppColors.primaryBlue,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Secure payment powered by Razorpay',
                              style: TextStyle(fontSize: 10, color: AppColors.textLight),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),
    );
  }
}
