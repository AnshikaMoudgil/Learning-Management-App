import 'package:flutter/foundation.dart';
import 'enrollments_service.dart';
import 'my_course_service.dart';

class EnrollmentProvider extends ChangeNotifier {
  EnrollmentProvider._();
  static final EnrollmentProvider _instance = EnrollmentProvider._();
  factory EnrollmentProvider() => _instance;

  final EnrollmentsService _enrollmentsService = EnrollmentsService();
  final MyCourseService _myCourseService = MyCourseService();

  List<EnrollmentItem> _enrollments = [];
  List<ContinueWatchingItem> _continueWatching = [];
  bool _initialized = false;
  bool _isLoading = false;

  List<EnrollmentItem> get enrollments => _enrollments;
  List<ContinueWatchingItem> get continueWatching => _continueWatching;
  bool get initialized => _initialized;
  bool get isLoading => _isLoading;

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _enrollmentsService.getMyEnrollments(),
        _myCourseService.getContinueWatching(),
      ]);
      _enrollments = results[0] as List<EnrollmentItem>;
      _continueWatching = results[1] as List<ContinueWatchingItem>;
      _initialized = true;
    } catch (_) {
      _initialized = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _enrollments = [];
    _continueWatching = [];
    _initialized = false;
    notifyListeners();
  }
}
