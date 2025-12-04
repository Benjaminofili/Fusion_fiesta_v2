import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_roles.dart';
import '../../core/constants/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../data/models/event.dart';

// --- Auth Screens ---
import '../../features/common/auth/presentation/screens/login_screen.dart';
import '../../features/common/auth/presentation/screens/register_screen.dart';
import '../../features/common/auth/presentation/screens/role_upgrade_screen.dart';
import '../../features/common/auth/presentation/screens/splash_screen.dart';
import '../../features/common/auth/presentation/screens/forgot_password_screen.dart';

// --- Common Screens ---
import '../../features/common/event_catalog/presentation/screens/event_catalog_screen.dart';
import '../../features/common/event_catalog/presentation/screens/event_detail_screen.dart';
import '../../features/common/gallery/presentation/screens/gallery_screen.dart';
import '../../features/common/information/presentation/screens/about_screen.dart';
import '../../features/common/information/presentation/screens/contact_screen.dart';
import '../../features/common/information/presentation/screens/faq_screen.dart';
import '../../features/common/information/presentation/screens/sitemap_screen.dart';
import '../../features/common/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/common/profile/presentation/screens/profile_screen.dart';
import '../../features/common/notifications/presentation/screens/notifications_screen.dart';

// --- Student Screens ---
import '../../features/student/registered_events/presentation/screens/registered_events_screen.dart';
import '../../features/student/certificates/presentation/screens/certificates_screen.dart';
import '../../features/student/feedback/presentation/screens/feedback_form_screen.dart';
import '../../features/student/favorites/presentation/screens/favorites_screen.dart';
import '../../features/student/saved_media/presentation/screens/saved_media_screen.dart';
import '../../features/common/gallery/presentation/screens/gallery_image_viewer.dart';
import '../../data/models/gallery_item.dart';


import 'main_navigation_shell.dart';

class AppRouter {
  AppRouter(this._authService);

  final AuthService _authService;

  // --- SECURITY CONFIGURATION ---
  // List of routes that strictly require the 'Student Participant' role.
  // Visitors accessing these will be redirected to the Upgrade Screen.
  static const List<String> _participantOnlyRoutes = [
    AppRoutes.registeredEvents,
    AppRoutes.certificates,
    AppRoutes.feedback,
    AppRoutes.favorites,
    AppRoutes.notifications,
  ];

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      // --- STARTUP & AUTH ---
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.roleUpgrade,
        builder: (context, state) => const RoleUpgradeScreen(),
      ),

      // --- MAIN SHELL ---
      GoRoute(
        path: AppRoutes.main,
        builder: (context, state) => const MainNavigationShell(),
      ),

      // --- EVENTS ---
      GoRoute(
        path: AppRoutes.events,
        builder: (context, state) => const EventCatalogScreen(),
        routes: [
          GoRoute(
            path: 'details',
            builder: (context, state) {
              final event = state.extra as Event;
              return EventDetailScreen(event: event);
            },
          ),
        ],
      ),

      // --- STUDENT FEATURES (PROTECTED) ---
      GoRoute(
        path: AppRoutes.registeredEvents,
        builder: (context, state) => const RegisteredEventsScreen(),
      ),
      GoRoute(
        path: AppRoutes.certificates,
        builder: (context, state) => const CertificatesScreen(),
      ),
      GoRoute(
        path: AppRoutes.feedback,
        builder: (context, state) => const FeedbackFormScreen(),
      ),
      GoRoute(
        path: AppRoutes.favorites,
        builder: (context, state) => const FavoritesScreen(),
      ),

      // --- COMMON FEATURES ---
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.gallery,
        builder: (context, state) => const GalleryScreen(),
        routes: [
          // 1. Saved Media Route
          GoRoute(
            path: 'saved', // /gallery/saved
            builder: (context, state) => const SavedMediaScreen(),
          ),
          // 2. Viewer Route
          GoRoute(
            path: 'view', // /gallery/view
            builder: (context, state) {
              final item = state.extra as GalleryItem;
              return GalleryImageViewer(item: item);
            },
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.about,
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: AppRoutes.contact,
        builder: (context, state) => const ContactScreen(),
      ),
      GoRoute(
        path: AppRoutes.faq,
        builder: (context, state) => const FaqScreen(),
      ),
      GoRoute(
        path: AppRoutes.sitemap,
        builder: (context, state) => const SitemapScreen(),
      ),
    ],
    redirect: _resolveRedirect,
  );

  FutureOr<String?> _resolveRedirect(
      BuildContext context, GoRouterState state) async {
    final location = state.uri.path; // Use .path to ignore query params

    // 1. Public Routes (No Auth Required)
    if (location == AppRoutes.splash ||
        location == AppRoutes.onboarding ||
        location == AppRoutes.register ||
        location == AppRoutes.forgotPassword) {
      return null;
    }

    final user = await _authService.currentUser;
    final loggingIn = location == AppRoutes.login;

    // 2. Unauthenticated Logic
    if (user == null) {
      if (!loggingIn) return AppRoutes.login;
      return null;
    }

    // 3. Authenticated but on Login page -> Go Main
    if (loggingIn) {
      return AppRoutes.main;
    }

    // 4. ROLE GUARD: Visitor trying to access Participant pages
    if (user.role == AppRole.visitor) {
      // A. Force profile completion first if not done
      if (!user.profileCompleted && location != AppRoutes.roleUpgrade) {
        return AppRoutes.roleUpgrade;
      }

      // B. Block access to restricted routes
      if (_participantOnlyRoutes.contains(location)) {
        // Redirect to Upgrade screen instead of letting them access it
        return AppRoutes.roleUpgrade;
      }
    }

    return null;
  }
}