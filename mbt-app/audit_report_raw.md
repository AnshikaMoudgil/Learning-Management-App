# Navigation Audit Report

**Overall navigation completion percentage:** 61%

## Registered Routes
- `RouteNames.course`
- `RouteNames.courseProgress`
- `RouteNames.aboutLiveClasses`
- `RouteNames.popularCourses`
- `RouteNames.more`
- `RouteNames.editProfile`
- `RouteNames.privacy`
- `RouteNames.login`
- `RouteNames.terms`
- `RouteNames.continueWatching`
- `RouteNames.splash`
- `RouteNames.about`
- `RouteNames.recordedPlayer`
- `RouteNames.newlyAddedCourses`
- `RouteNames.dailySchedule`
- `RouteNames.liveClassDetails`
- `RouteNames.myLearning`
- `RouteNames.recentRecordings`
- `RouteNames.activeDevices`
- `RouteNames.notifications`
- `RouteNames.wishlist`
- `RouteNames.myCourses`
- `RouteNames.settings`
- `RouteNames.support`
- `RouteNames.help`
- `RouteNames.certificates`
- `RouteNames.profile`
- `RouteNames.onboarding`
- `RouteNames.downloads`
- `/certificate-preview`
- `RouteNames.recordings`
- `RouteNames.subscriptions`
- `RouteNames.search`
- `RouteNames.courseValidity`
- `RouteNames.otp`
- `RouteNames.classDetails`
- `RouteNames.livePlayer`
- `RouteNames.store`
- `RouteNames.live`
- `RouteNames.home`
- `RouteNames.categoryDetail`
- `RouteNames.createProfile`
- `RouteNames.paymentSuccess`
- `RouteNames.renewCourse`
- `RouteNames.expiringCourses`
- `RouteNames.cart`

## Interactive Elements Audit
| Screen Name | Widget | Expected Action | Current Status | Issue | Fix Required |
|-------------|--------|-----------------|----------------|-------|--------------|
| about_live_classes_screen.dart | IconButton (Line 15) | Navigate/Action | ✅ Working | None | No |
| about_us_screen.dart | IconButton (Line 18) | Navigate/Action | ✅ Working | None | No |
| about_us_screen.dart | Unknown Widget (Line 71) | Navigate/Action | ✅ Working | None | No |
| about_us_screen.dart | Unknown Widget (Line 74) | Navigate/Action | ✅ Working | None | No |
| about_us_screen.dart | Unknown Widget (Line 77) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| about_us_screen.dart | ListTile (Line 110) | Navigate/Action | ❌ Broken | No navigation detected | Verify intent |
| active_devices_screen.dart | IconButton (Line 15) | Navigate/Action | ✅ Working | None | No |
| active_devices_screen.dart | IconButton (Line 26) | Navigate/Action | ✅ Working | None | No |
| active_devices_screen.dart | IconButton (Line 30) | Navigate/Action | ✅ Working | None | No |
| active_devices_screen.dart | OutlinedButton (Line 243) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| categories_screen.dart | IconButton (Line 16) | Navigate/Action | ✅ Working | None | No |
| categories_screen.dart | IconButton (Line 23) | Navigate/Action | ✅ Working | None | No |
| categories_screen.dart | IconButton (Line 36) | Navigate/Action | ✅ Working | None | No |
| categories_screen.dart | GestureDetector (Line 82) | Navigate/Action | ✅ Working | None | No |
| category_detail_screen.dart | IconButton (Line 15) | Navigate/Action | ✅ Working | None | No |
| category_detail_screen.dart | IconButton (Line 19) | Navigate/Action | ✅ Working | None | No |
| certificates_screen.dart | IconButton (Line 22) | Navigate/Action | ✅ Working | None | No |
| certificates_screen.dart | GestureDetector (Line 67) | Navigate/Action | ✅ Working | None | No |
| certificates_screen.dart | GestureDetector (Line 90) | Navigate/Action | ✅ Working | None | No |
| certificates_screen.dart | OutlinedButton (Line 123) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| certificates_screen.dart | OutlinedButton (Line 137) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| certificate_preview_screen.dart | IconButton (Line 15) | Navigate/Action | ✅ Working | None | No |
| certificate_preview_screen.dart | IconButton (Line 26) | Navigate/Action | ✅ Working | None | No |
| certificate_preview_screen.dart | IconButton (Line 30) | Navigate/Action | ✅ Working | None | No |
| certificate_preview_screen.dart | OutlinedButton (Line 176) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| certificate_preview_screen.dart | ElevatedButton (Line 195) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| class_details_screen.dart | IconButton (Line 15) | Navigate/Action | ✅ Working | None | No |
| class_details_screen.dart | IconButton (Line 19) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| class_details_screen.dart | OutlinedButton (Line 132) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| class_details_screen.dart | ElevatedButton (Line 146) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| continue_watching_screen.dart | IconButton (Line 22) | Navigate/Action | ✅ Working | None | No |
| continue_watching_screen.dart | IconButton (Line 35) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| continue_watching_screen.dart | Unknown Widget (Line 106) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| continue_watching_screen.dart | TextButton (Line 118) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| course_details_screen.dart | Unknown Widget (Line 43) | Navigate/Action | ✅ Working | None | No |
| course_details_screen.dart | IconButton (Line 49) | Navigate/Action | ✅ Working | None | No |
| course_details_screen.dart | IconButton (Line 62) | Navigate/Action | ✅ Working | None | No |
| course_details_screen.dart | ElevatedButton (Line 207) | Navigate/Action | ✅ Working | None | No |
| course_details_screen.dart | GestureDetector (Line 275) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| course_progress_screen.dart | IconButton (Line 45) | Navigate/Action | ✅ Working | None | No |
| course_progress_screen.dart | IconButton (Line 50) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| course_progress_screen.dart | GestureDetector (Line 162) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| course_store_screen.dart | GestureDetector (Line 124) | Navigate/Action | ✅ Working | None | No |
| course_store_screen.dart | IconButton (Line 258) | Navigate/Action | ✅ Working | None | No |
| course_store_screen.dart | GestureDetector (Line 282) | Navigate/Action | ❌ Broken | No navigation detected | Verify intent |
| course_store_screen.dart | GestureDetector (Line 305) | Navigate/Action | ✅ Working | None | No |
| course_store_screen.dart | GestureDetector (Line 435) | Navigate/Action | ✅ Working | None | No |
| course_validity_screen.dart | IconButton (Line 18) | Navigate/Action | ✅ Working | None | No |
| course_validity_screen.dart | OutlinedButton (Line 104) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| course_validity_screen.dart | OutlinedButton (Line 252) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| course_validity_screen.dart | ElevatedButton (Line 347) | Navigate/Action | ✅ Working | None | No |
| create_profile_screen.dart | IconButton (Line 105) | Navigate/Action | ✅ Working | None | No |
| create_profile_screen.dart | OutlinedButton (Line 196) | Navigate/Action | ✅ Working | None | No |
| create_profile_screen.dart | ElevatedButton (Line 282) | Navigate/Action | ❌ Broken | No navigation detected | Verify intent |
| daily_schedule_screen.dart | IconButton (Line 24) | Navigate/Action | ✅ Working | None | No |
| daily_schedule_screen.dart | IconButton (Line 28) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| daily_schedule_screen.dart | OutlinedButton (Line 106) | Navigate/Action | ✅ Working | None | No |
| daily_schedule_screen.dart | GestureDetector (Line 133) | Navigate/Action | ✅ Working | None | No |
| daily_schedule_screen.dart | ElevatedButton (Line 231) | Navigate/Action | ✅ Working | None | No |
| daily_schedule_screen.dart | OutlinedButton (Line 254) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| daily_schedule_screen.dart | OutlinedButton (Line 268) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| dashboard_layout.dart | Unknown Widget (Line 23) | Navigate/Action | ❌ Broken | No navigation detected | Verify intent |
| edit_profile_screen.dart | IconButton (Line 99) | Navigate/Action | ✅ Working | None | No |
| edit_profile_screen.dart | IconButton (Line 110) | Navigate/Action | ✅ Working | None | No |
| edit_profile_screen.dart | InkWell (Line 142) | Navigate/Action | ❌ Broken | No navigation detected | Verify intent |
| edit_profile_screen.dart | OutlinedButton (Line 166) | Navigate/Action | ❌ Broken | No navigation detected | Verify intent |
| edit_profile_screen.dart | TextButton (Line 177) | Navigate/Action | ✅ Working | None | No |
| edit_profile_screen.dart | ElevatedButton (Line 210) | Navigate/Action | ❌ Broken | No navigation detected | Verify intent |
| edit_profile_screen.dart | OutlinedButton (Line 225) | Navigate/Action | ✅ Working | None | No |
| expiring_courses_screen.dart | IconButton (Line 22) | Navigate/Action | ✅ Working | None | No |
| expiring_courses_screen.dart | IconButton (Line 29) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| expiring_courses_screen.dart | Unknown Widget (Line 104) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| expiring_courses_screen.dart | Unknown Widget (Line 347) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| global_search_screen.dart | IconButton (Line 64) | Navigate/Action | ✅ Working | None | No |
| global_search_screen.dart | IconButton (Line 67) | Navigate/Action | ✅ Working | None | No |
| global_search_screen.dart | IconButton (Line 114) | Navigate/Action | ✅ Working | None | No |
| global_search_screen.dart | GestureDetector (Line 128) | Navigate/Action | ✅ Working | None | No |
| global_search_screen.dart | TextButton (Line 161) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| global_search_screen.dart | OutlinedButton (Line 265) | Navigate/Action | ✅ Working | None | No |
| global_search_screen.dart | GestureDetector (Line 348) | Navigate/Action | ✅ Working | None | No |
| help_center_screen.dart | IconButton (Line 15) | Navigate/Action | ✅ Working | None | No |
| help_center_screen.dart | Unknown Widget (Line 78) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| home_dashboard.dart | IconButton (Line 84) | Navigate/Action | ✅ Working | None | No |
| home_dashboard.dart | IconButton (Line 97) | Navigate/Action | ✅ Working | None | No |
| home_dashboard.dart | GestureDetector (Line 218) | Navigate/Action | ✅ Working | None | No |
| home_dashboard.dart | GestureDetector (Line 282) | Navigate/Action | ✅ Working | None | No |
| home_dashboard.dart | ElevatedButton (Line 428) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| home_dashboard.dart | GestureDetector (Line 461) | Navigate/Action | ❌ Broken | No navigation detected | Verify intent |
| home_dashboard.dart | IconButton (Line 650) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| home_dashboard.dart | IconButton (Line 651) | Navigate/Action | ✅ Working | None | No |
| live_classes_screen.dart | IconButton (Line 60) | Navigate/Action | ✅ Working | None | No |
| live_classes_screen.dart | IconButton (Line 64) | Navigate/Action | ✅ Working | None | No |
| live_classes_screen.dart | GestureDetector (Line 109) | Navigate/Action | ✅ Working | None | No |
| live_classes_screen.dart | GestureDetector (Line 144) | Navigate/Action | ✅ Working | None | No |
| live_classes_screen.dart | OutlinedButton (Line 257) | Navigate/Action | ✅ Working | None | No |
| live_classes_screen.dart | GestureDetector (Line 309) | Navigate/Action | ✅ Working | None | No |
| live_classes_screen.dart | ElevatedButton (Line 395) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| live_classes_screen.dart | IconButton (Line 423) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| live_classes_screen.dart | IconButton (Line 425) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| live_classes_screen.dart | OutlinedButton (Line 462) | Navigate/Action | ✅ Working | None | No |
| live_classes_screen.dart | ElevatedButton (Line 596) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| live_class_details_screen.dart | IconButton (Line 18) | Navigate/Action | ✅ Working | None | No |
| live_class_details_screen.dart | IconButton (Line 24) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| live_class_details_screen.dart | ElevatedButton (Line 189) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| live_class_details_screen.dart | OutlinedButton (Line 460) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| live_class_player_screen.dart | GestureDetector (Line 68) | Navigate/Action | ✅ Working | None | No |
| live_class_player_screen.dart | GestureDetector (Line 219) | Navigate/Action | ✅ Working | None | No |
| live_class_player_screen.dart | OutlinedButton (Line 415) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| login_screen.dart | IconButton (Line 108) | Navigate/Action | ✅ Working | None | No |
| login_screen.dart | Unknown Widget (Line 137) | Navigate/Action | ✅ Working | None | No |
| login_screen.dart | buildOutlinedButton (Line 150) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| login_screen.dart | ElevatedButton (Line 219) | Navigate/Action | ❌ Broken | No navigation detected | Verify intent |
| login_screen.dart | InkWell (Line 256) | Navigate/Action | ❌ Broken | No navigation detected | Verify intent |
| more_screen.dart | InkWell (Line 99) | Navigate/Action | ✅ Working | None | No |
| more_screen.dart | OutlinedButton (Line 193) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| more_screen.dart | Unknown Widget (Line 214) | Navigate/Action | ✅ Working | None | No |
| more_screen.dart | Unknown Widget (Line 217) | Navigate/Action | ✅ Working | None | No |
| more_screen.dart | Unknown Widget (Line 220) | Navigate/Action | ✅ Working | None | No |
| more_screen.dart | Unknown Widget (Line 223) | Navigate/Action | ✅ Working | None | No |
| more_screen.dart | Unknown Widget (Line 226) | Navigate/Action | ✅ Working | None | No |
| more_screen.dart | Unknown Widget (Line 239) | Navigate/Action | ✅ Working | None | No |
| more_screen.dart | Unknown Widget (Line 242) | Navigate/Action | ✅ Working | None | No |
| more_screen.dart | InkWell (Line 252) | Navigate/Action | ✅ Working | None | No |
| more_screen.dart | InkWell (Line 304) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| my_courses_screen.dart | IconButton (Line 74) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| my_courses_screen.dart | IconButton (Line 81) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| my_courses_screen.dart | Unknown Widget (Line 193) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| my_courses_screen.dart | TextButton (Line 198) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| my_courses_screen.dart | IconButton (Line 254) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| my_courses_screen.dart | Unknown Widget (Line 437) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| my_courses_screen.dart | Unknown Widget (Line 448) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| my_learning_screen.dart | IconButton (Line 34) | Navigate/Action | ✅ Working | None | No |
| my_learning_screen.dart | GestureDetector (Line 74) | Navigate/Action | ✅ Working | None | No |
| my_learning_screen.dart | GestureDetector (Line 92) | Navigate/Action | ✅ Working | None | No |
| my_learning_screen.dart | OutlinedButton (Line 170) | Navigate/Action | ✅ Working | None | No |
| my_learning_screen.dart | IconButton (Line 201) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| my_learning_screen.dart | GestureDetector (Line 284) | Navigate/Action | ✅ Working | None | No |
| my_learning_screen.dart | GestureDetector (Line 413) | Navigate/Action | ✅ Working | None | No |
| my_learning_screen.dart | ElevatedButton (Line 475) | Navigate/Action | ✅ Working | None | No |
| my_subscriptions_screen.dart | IconButton (Line 15) | Navigate/Action | ✅ Working | None | No |
| my_subscriptions_screen.dart | ElevatedButton (Line 114) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| newly_added_courses_screen.dart | IconButton (Line 15) | Navigate/Action | ✅ Working | None | No |
| newly_added_courses_screen.dart | IconButton (Line 22) | Navigate/Action | ✅ Working | None | No |
| newly_added_courses_screen.dart | IconButton (Line 35) | Navigate/Action | ✅ Working | None | No |
| notifications_screen.dart | IconButton (Line 15) | Navigate/Action | ✅ Working | None | No |
| notification_center_screen.dart | IconButton (Line 17) | Navigate/Action | ✅ Working | None | No |
| notification_center_screen.dart | ElevatedButton (Line 233) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| notification_settings_screen.dart | IconButton (Line 30) | Navigate/Action | ✅ Working | None | No |
| onboarding_screen.dart | TextButton (Line 24) | Navigate/Action | ✅ Working | None | No |
| onboarding_screen.dart | ElevatedButton (Line 75) | Navigate/Action | ✅ Working | None | No |
| otp_screen.dart | IconButton (Line 116) | Navigate/Action | ✅ Working | None | No |
| otp_screen.dart | ElevatedButton (Line 176) | Navigate/Action | ❌ Broken | No navigation detected | Verify intent |
| otp_screen.dart | InkWell (Line 204) | Navigate/Action | ❌ Broken | No navigation detected | Verify intent |
| otp_screen.dart | TextButton (Line 229) | Navigate/Action | ✅ Working | None | No |
| payment_success_screen.dart | ElevatedButton (Line 176) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| payment_success_screen.dart | OutlinedButton (Line 196) | Navigate/Action | ✅ Working | None | No |
| popular_courses_screen.dart | IconButton (Line 15) | Navigate/Action | ✅ Working | None | No |
| popular_courses_screen.dart | IconButton (Line 22) | Navigate/Action | ✅ Working | None | No |
| popular_courses_screen.dart | IconButton (Line 35) | Navigate/Action | ✅ Working | None | No |
| privacy_policy_screen.dart | IconButton (Line 47) | Navigate/Action | ✅ Working | None | No |
| profile_courses_screen.dart | IconButton (Line 22) | Navigate/Action | ✅ Working | None | No |
| profile_courses_screen.dart | IconButton (Line 26) | Navigate/Action | ✅ Working | None | No |
| profile_courses_screen.dart | GestureDetector (Line 123) | Navigate/Action | ✅ Working | None | No |
| profile_courses_screen.dart | ElevatedButton (Line 187) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| profile_screen.dart | IconButton (Line 105) | Navigate/Action | ✅ Working | None | No |
| profile_screen.dart | GestureDetector (Line 143) | Navigate/Action | ✅ Working | None | No |
| profile_screen.dart | ListTile (Line 167) | Navigate/Action | ❌ Broken | No navigation detected | Verify intent |
| profile_screen.dart | Unknown Widget (Line 185) | Navigate/Action | ✅ Working | None | No |
| recent_recordings_screen.dart | IconButton (Line 64) | Navigate/Action | ✅ Working | None | No |
| recent_recordings_screen.dart | IconButton (Line 65) | Navigate/Action | ✅ Working | None | No |
| recent_recordings_screen.dart | Unknown Widget (Line 206) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| recent_recordings_screen.dart | TextButton (Line 211) | Navigate/Action | ✅ Working | None | No |
| recorded_class_player_screen.dart | GestureDetector (Line 70) | Navigate/Action | ✅ Working | None | No |
| recorded_class_player_screen.dart | GestureDetector (Line 189) | Navigate/Action | ❌ Broken | No navigation detected | Verify intent |
| recorded_class_player_screen.dart | GestureDetector (Line 225) | Navigate/Action | ✅ Working | None | No |
| recorded_class_player_screen.dart | OutlinedButton (Line 426) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| recorded_class_player_screen.dart | OutlinedButton (Line 439) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| recorded_class_player_screen.dart | ElevatedButton (Line 452) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| recorded_class_player_screen.dart | OutlinedButton (Line 630) | Navigate/Action | ✅ Working | None | No |
| recordings_screen.dart | IconButton (Line 24) | Navigate/Action | ✅ Working | None | No |
| recordings_screen.dart | IconButton (Line 28) | Navigate/Action | ✅ Working | None | No |
| recordings_screen.dart | OutlinedButton (Line 259) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| renew_course_screen.dart | IconButton (Line 24) | Navigate/Action | ✅ Working | None | No |
| renew_course_screen.dart | ElevatedButton (Line 297) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| renew_course_screen.dart | GestureDetector (Line 329) | Navigate/Action | ✅ Working | None | No |
| settings_screen.dart | IconButton (Line 17) | Navigate/Action | ✅ Working | None | No |
| settings_screen.dart | Unknown Widget (Line 36) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| settings_screen.dart | Unknown Widget (Line 54) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| settings_screen.dart | ListTile (Line 112) | Navigate/Action | ✅ Working | None | No |
| settings_screen.dart | InkWell (Line 131) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| shopping_cart_screen.dart | Unknown Widget (Line 42) | Navigate/Action | ✅ Working | None | No |
| shopping_cart_screen.dart | ElevatedButton (Line 126) | Navigate/Action | ✅ Working | None | No |
| shopping_cart_screen.dart | ElevatedButton (Line 199) | Navigate/Action | ✅ Working | None | No |
| shopping_cart_screen.dart | IconButton (Line 272) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| shopping_cart_screen.dart | InkWell (Line 356) | Navigate/Action | ❌ Broken | No navigation detected | Verify intent |
| shopping_cart_screen.dart | InkWell (Line 361) | Navigate/Action | ❌ Broken | No navigation detected | Verify intent |
| shopping_cart_screen.dart | GestureDetector (Line 419) | Navigate/Action | ✅ Working | None | No |
| shopping_cart_screen.dart | ElevatedButton (Line 532) | Navigate/Action | ✅ Working | None | No |
| shopping_cart_screen.dart | InkWell (Line 574) | Navigate/Action | ✅ Working | None | No |
| support_screen.dart | IconButton (Line 15) | Navigate/Action | ✅ Working | None | No |
| support_screen.dart | GestureDetector (Line 33) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| terms_of_service_screen.dart | IconButton (Line 59) | Navigate/Action | ✅ Working | None | No |
| terms_of_service_screen.dart | Unknown Widget (Line 236) | Navigate/Action | ❌ Broken | No navigation detected | Verify intent |
| wishlist_screen.dart | IconButton (Line 51) | Navigate/Action | ✅ Working | None | No |
| wishlist_screen.dart | IconButton (Line 58) | Navigate/Action | ✅ Working | None | No |
| wishlist_screen.dart | Unknown Widget (Line 109) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| wishlist_screen.dart | Unknown Widget (Line 120) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
| wishlist_screen.dart | Unknown Widget (Line 315) | Navigate/Action | ❌ Broken | Empty callback or TODO | Implement navigation |
