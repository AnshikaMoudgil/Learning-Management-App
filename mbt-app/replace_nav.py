import os
import re

SCREEN_DIR = r"d:\mbt-lms\mbt-app\mbt-app\lib\screens"

ROUTE_MAP = {
    "SplashScreen": "/splash",
    "OnboardingScreen": "/onboarding",
    "LoginScreen": "/login",
    "CreateProfileScreen": "/create-profile",
    "HomeDashboard": "/home",
    "CategoriesScreen": "/categories",
    "CategoryDetailScreen": "/category-detail",
    "CourseDetailsScreen": "/course",
    "CourseProgressScreen": "/course-progress",
    "LiveClassesScreen": "/live",
    "LiveClassDetailsScreen": "/live-class-details",
    "LiveClassPlayerScreen": "/live-player",
    "RecordingsScreen": "/recordings",
    "RecordedClassPlayerScreen": "/recorded-player",
    "MyLearningScreen": "/my-learning",
    "DownloadsScreen": "/downloads",
    "CertificatesScreen": "/certificates",
    "WishlistScreen": "/wishlist",
    "MoreScreen": "/more",
    "ProfileScreen": "/profile",
    "EditProfileScreen": "/edit-profile",
    "SettingsScreen": "/settings",
    "ActiveDevicesScreen": "/active-devices",
    "NotificationCenterScreen": "/notifications",
    "NotificationsScreen": "/notifications",
    "SupportScreen": "/support",
    "HelpCenterScreen": "/help",
    "PrivacyPolicyScreen": "/privacy",
    "TermsOfServiceScreen": "/terms",
    "AboutUsScreen": "/about",
    "MySubscriptionsScreen": "/subscriptions",
    "PaymentSuccessScreen": "/payment-success",
    "GlobalSearchScreen": "/search",
    "PopularCoursesScreen": "/popular-courses",
    "NewlyAddedCoursesScreen": "/newly-added-courses",
    "ContinueWatchingScreen": "/continue-watching",
    "ExpiringCoursesScreen": "/expiring-courses",
    "RenewCourseScreen": "/renew-course",
    "CourseValidityScreen": "/course-validity",
    "DailyScheduleScreen": "/daily-schedule",
    "ClassDetailsScreen": "/class-details",
    "AboutLiveClassesScreen": "/about-live-classes",
    "MyCoursesScreen": "/my-courses",
    "DashboardLayout": "/home",
    "RecentRecordingsScreen": "/recent-recordings"
}

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content
    modified = False

    # Check if we need to import go_router
    if "Navigator." in content:
        if "import 'package:go_router/go_router.dart';" not in content:
            # Find the last import
            imports = re.findall(r"^import\s+.*?;", content, re.MULTILINE)
            if imports:
                last_import = imports[-1]
                content = content.replace(last_import, last_import + "\nimport 'package:go_router/go_router.dart';")
            else:
                content = "import 'package:go_router/go_router.dart';\n" + content
            modified = True

    # 1. Navigator.pop(context) or Navigator.pop(ctx)
    if re.search(r"Navigator\.pop\(\s*(context|ctx)\s*\)", content):
        content = re.sub(r"Navigator\.pop\(\s*(context|ctx)\s*\)", r"\1.pop()", content)
        modified = True

    # 1.b Navigator.pop(context, something)
    if re.search(r"Navigator\.pop\(\s*(context|ctx)\s*,\s*([^)]+)\)", content):
        content = re.sub(r"Navigator\.pop\(\s*(context|ctx)\s*,\s*([^)]+)\)", r"\1.pop(\2)", content)
        modified = True

    # 2. Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const ScreenName()), (route) => false)
    # Becomes context.go('/route')
    pattern_push_remove = r"Navigator\.pushAndRemoveUntil\(\s*(context|ctx)\s*,\s*MaterialPageRoute\(\s*builder:\s*\(\s*_\s*\)\s*=>\s*const\s+([A-Za-z0-9_]+)\(\)\s*\)\s*,\s*\(route\)\s*=>\s*false\s*,?\s*\)"
    def repl_push_remove(m):
        ctx = m.group(1)
        screen = m.group(2)
        route = ROUTE_MAP.get(screen, "/unknown")
        return f"{ctx}.go('{route}')"
    
    if re.search(pattern_push_remove, content):
        content = re.sub(pattern_push_remove, repl_push_remove, content)
        modified = True

    # 3. Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ScreenName()))
    pattern_push_repl = r"Navigator\.pushReplacement\(\s*(context|ctx)\s*,\s*MaterialPageRoute\(\s*builder:\s*\(\s*_\s*\)\s*=>\s*const\s+([A-Za-z0-9_]+)\(\)\s*\)\s*\)"
    def repl_push_repl(m):
        ctx = m.group(1)
        screen = m.group(2)
        route = ROUTE_MAP.get(screen, "/unknown")
        return f"{ctx}.pushReplacement('{route}')"
    
    if re.search(pattern_push_repl, content):
        content = re.sub(pattern_push_repl, repl_push_repl, content)
        modified = True

    # 4. Navigator.push(context, MaterialPageRoute(builder: (_) => const ScreenName()))
    pattern_push = r"Navigator\.push\(\s*(context|ctx)\s*,\s*MaterialPageRoute\(\s*builder:\s*\(\s*_\s*\)\s*=>\s*const\s+([A-Za-z0-9_]+)\(\)\s*\)\s*\)"
    def repl_push(m):
        ctx = m.group(1)
        screen = m.group(2)
        route = ROUTE_MAP.get(screen, "/unknown")
        return f"{ctx}.push('{route}')"
    
    if re.search(pattern_push, content):
        content = re.sub(pattern_push, repl_push, content)
        modified = True
        
    # OtpScreen is special because it takes a parameter: Navigator.push(context, MaterialPageRoute(builder: (_) => OtpScreen(phone: '$_countryCode$phone')))
    otp_pattern = r"Navigator\.push\(\s*(context|ctx)\s*,\s*MaterialPageRoute\(\s*builder:\s*\(\s*_\s*\)\s*=>\s*OtpScreen\(phone:\s*([^)]+)\)\s*\)\s*\)"
    def repl_otp(m):
        ctx = m.group(1)
        phone = m.group(2)
        clean_phone = phone.strip("'")
        return f"{ctx}.push('/otp?phone={clean_phone}')"
    if re.search(otp_pattern, content):
        content = re.sub(otp_pattern, repl_otp, content)
        modified = True

    if modified and content != original_content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Modified {filepath}")

for root, _, files in os.walk(SCREEN_DIR):
    for f in files:
        if f.endswith('.dart'):
            process_file(os.path.join(root, f))
