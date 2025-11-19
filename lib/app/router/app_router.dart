import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_roles.dart';
import '../../core/constants/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../data/models/event.dart';
import '../../features/common/auth/presentation/screens/login_screen.dart';
import '../../features/common/auth/presentation/screens/register_screen.dart';
import '../../features/common/auth/presentation/screens/role_upgrade_screen.dart';
import '../../features/common/auth/presentation/screens/splash_screen.dart';
import '../../features/common/event_catalog/presentation/screens/event_catalog_screen.dart';
import '../../features/common/event_catalog/presentation/screens/event_detail_screen.dart';
import '../../features/common/gallery/presentation/screens/gallery_screen.dart';
import '../../features/common/information/presentation/screens/about_screen.dart';
import '../../features/common/information/presentation/screens/contact_screen.dart';
import '../../features/common/information/presentation/screens/faq_screen.dart';
import '../../features/common/information/presentation/screens/sitemap_screen.dart';
import '../../features/common/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/common/profile/presentation/screens/profile_screen.dart';
import 'main_navigation_shell.dart';

class AppRouter {
  AppRouter(this._authService);

  final AuthService _authService;

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
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
        path: AppRoutes.roleUpgrade,
        builder: (context, state) => const RoleUpgradeScreen(),
      ),
      GoRoute(
        path: AppRoutes.main,
        builder: (context, state) => const MainNavigationShell(),
      ),
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
      GoRoute(
        path: AppRoutes.gallery,
        builder: (context, state) => GalleryScreen(),
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
    final location = state.uri.toString();

    // 1. PUBLIC ROUTES: Allow access without login
    // Added AppRoutes.register to this list so users can sign up!
    if (location == AppRoutes.splash ||
        location == AppRoutes.onboarding ||
        location == AppRoutes.register) {
      return null;
    }

    final user = await _authService.currentUser;
    final loggingIn = location == AppRoutes.login;

    // 2. Guard protected routes: Force login if no user
    // If user is NULL and they are NOT on the login page, send them to login
    if (user == null && !loggingIn) {
      return AppRoutes.login;
    }

    // 3. Redirect logged-in users away from Login page
    if (user != null && loggingIn) {
      return AppRoutes.main;
    }

    // 4. Role upgrade guard
    if (user != null &&
        user.role == AppRole.visitor &&
        !user.profileCompleted &&
        location != AppRoutes.roleUpgrade) {
      return AppRoutes.roleUpgrade;
    }

    return null;
  }
}