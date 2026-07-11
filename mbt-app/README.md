# MBT Institute LMS

A comprehensive Learning Management System (LMS) built with Flutter. MBT Institute provides a unified platform where learners can attend live classes, revisit recordings, track certificates, and manage their profiles in real-time. 

Simultaneously, the platform addresses critical business requirements including strict content protection (device binding), revenue protection (distinct payment flows for hardware vs. software tracks, secure coupon logic), and data compliance.

## 🎯 Project Goals

- **Unify Learning Delivery:** Seamless integration of live interactive classes (via Zoom), high-quality recorded playback, and structured course content.
- **Protect Revenue:** Distinct payment gateways for hardware and software tracks. Secure coupon codes that cannot be exploited across different product categories.
- **Protect Content:** Strict single active device per learner policy. Device transfers require admin approval to prevent piracy.
- **Reach Learners Everywhere:** Native distribution on iOS App Store and Google Play. Support for multilingual AI-assisted voice (Hindi/English) and subtitles (English default).
- **Real-time Verified Profiles:** Live tracking of course progress, certificates, and identity, all tied to a verified mobile number.

## 🚫 Non-Goals (Current Phase)
- Building a proprietary video conferencing engine (Zoom is the chosen integration partner).
- Full LMS content authoring / course-builder tooling (managed externally).
- Marketplace/multi-vendor selling (the platform supports a single-provider catalog).

## 💻 Tech Stack

- **Frontend:** [Flutter](https://flutter.dev/) (Dart) - Cross-platform mobile & web UI.
- **Authentication & Backend:** [Supabase](https://supabase.com/) (Configured for Phone OTP and Google Auth).
- **Typography:** Custom fonts (Poppins) for a modern, clean look.

## 🚀 Setup Instructions

Follow these steps to run the project locally:

### 1. Prerequisites
- Install [Flutter SDK](https://docs.flutter.dev/get-started/install) (Version 3.11.1 or higher recommended).
- Ensure you have an Android Emulator, iOS Simulator, or a connected physical device.
- For Web testing, ensure Google Chrome is installed.

### 2. Clone the Repository
```bash
git clone <repository_url>
cd Mbt-lms-main
```

### 3. Install Dependencies
Fetch all required Dart packages:
```bash
flutter pub get
```

### 4. Configuration
Currently, the authentication flow (Supabase/Google) is bypassed for UI demonstration purposes. You can enter any digits in the Phone login and OTP screens to access the main dashboard. 

*(For production, ensure you restore `Supabase.initialize()` in `main.dart` and provide your specific `url` and `anonKey`.)*

### 5. Run the App
To start the app on your default connected device or emulator:
```bash
flutter run
```

## 📱 Key Features & Screens

- **Onboarding:** Highlighting core features (Live classes, Learn Anywhere).
- **Authentication:** Google Sign-In and Phone/OTP based login workflows.
- **Dashboard (`HomeDashboard`):** Central hub for upcoming live classes, continue watching, and expiring courses.
- **My Learning (`MyLearningScreen`):** Grid layout of enrolled courses tracking progress.
- **Live Classes (`LiveClassesScreen`):** Upcoming schedule and recorded sessions.
- **Store (`CourseStoreScreen`):** Software and Hardware course catalog.
- **Global Search (`GlobalSearchScreen`):** Advanced search categorized by Courses, Recordings, and Teachers.
- **Notification Center (`NotificationCenterScreen`):** Centralized, categorized alerts (Live classes, expiries, logins).
- **More Settings (`MoreScreen`):** Profile management, connected devices, certificates, and support.

## 🔒 Security & Compliance
- **Device Binding:** Accounts are restricted to a single device to prevent unauthorized sharing.
- **Secure Transactions:** SSL and dedicated gateways separating hardware tool purchases from software course enrollments.
