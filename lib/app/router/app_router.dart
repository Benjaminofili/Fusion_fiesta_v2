import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_roles.dart';
import '../../core/constants/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../data/models/event.dart';
import '../../data/models/gallery_item.dart';

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
import '../../features/common/gallery/presentation/screens/gallery_image_viewer.dart';
import '../../features/common/information/presentation/screens/about_screen.dart';
import '../../features/common/information/presentation/screens/contact_screen.dart';
import '../../features/common/information/presentation/screens/faq_screen.dart';
import '../../features/common/information/presentation/screens/sitemap_screen.dart';
import '../../features/common/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/common/profile/presentation/screens/profile_screen.dart';
import '../../features/common/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/common/profile/presentation/screens/change_password_screen.dart';
import '../../features/common/notifications/presentation/screens/notifications_screen.dart';

// --- Student Screens ---
import '../../features/student/registered_events/presentation/screens/registered_events_screen.dart';
import '../../features/student/certificates/presentation/screens/certificates_screen.dart';
import '../../features/student/feedback/presentation/screens/feedback_form_screen.dart';
import '../../features/student/favorites/presentation/screens/favorites_screen.dart';
import '../../features/student/saved_media/presentation/screens/saved_media_screen.dart';
import '../../features/student/payment/presentation/screens/mock_payment_screen.dart';

// --- Organizer Screens ---
import '../../features/organizer/event_editor/presentation/screens/event_editor_screen.dart';
import '../../features/organizer/participants/presentation/screens/participants_screen.dart';
import '../../features/organizer/attendance/presentation/screens/attendance_screen.dart';
import '../../features/organizer/announcements/presentation/screens/event_announcements_screen.dart';
import '../../features/organizer/feedback/presentation/screens/feedback_review_screen.dart';
import '../../features/organizer/post_event/presentation/screens/post_event_screen.dart';
import '../../features/organizer/calendar/presentation/screens/organizer_calendar_screen.dart';
import '../../features/organizer/messages/presentation/screens/organizer_messages_screen.dart';
import '../../features/organizer/gallery/presentation/screens/gallery_upload_screen.dart';
import '../../features/organizer/events/presentation/screens/organizer_events_screen.dart';
import '../../features/organizer/attendance/presentation/screens/organizer_scan_selector_screen.dart';
import '../../features/organizer/communication/presentation/screens/communication_log_screen.dart';

// --- ADMIN Screens ---
import '../../features/admin/event_approvals/presentation/screens/event_approvals_screen.dart';
import '../../features/admin/moderation/presentation/screens/moderation_screen.dart';
import '../../features/admin/support/presentation/screens/support_inbox_screen.dart';
import '../../features/admin/alerts/presentation/screens/alerts_screen.dart';

import 'main_navigation_shell.dart';

class AppRouter {
  AppRouter(this._authService);

  final AuthService _authService;

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

      // --- ORGANIZER FEATURES (Top Level) ---
      // These are defined as siblings to /main, /events, etc.
      GoRoute(
        path: '/organizer/calendar',
        builder: (context, state) => const OrganizerCalendarScreen(),
      ),
      GoRoute(
        path: '/organizer/messages',
        builder: (context, state) => const OrganizerMessagesScreen(),
      ),
      GoRoute(
        path: '/organizer/communication-log',
        builder: (context, state) => const CommunicationLogScreen(),
      ),
      GoRoute(
        path: '/organizer/events',
        builder: (context, state) => const OrganizerEventsScreen(),
      ),

      // --- EVENTS (PARENT ROUTE) ---
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
          GoRoute(
            path: 'create',
            builder: (context, state) => const EventEditorScreen(),
          ),
          GoRoute(
            path: 'edit',
            builder: (context, state) {
              final event = state.extra as Event;
              return EventEditorScreen(event: event);
            },
          ),

          // --- ADMIN FEATURES (Top Level) ---
          GoRoute(
            path: '/admin/approvals',
            builder: (context, state) => const EventApprovalsScreen(),
          ),
          GoRoute(
            path: '/admin/moderation',
            builder: (context, state) => const ModerationScreen(),
          ),
          GoRoute(
            path: '/admin/support',
            builder: (context, state) => const SupportInboxScreen(),
          ),
          GoRoute(
            path: '/admin/alerts',
            builder: (context, state) => const AlertsScreen(),
          ),


          // --- ORGANIZER SUB-ROUTES ---
          GoRoute(
            path: 'participants',
            builder: (context, state) {
              final event = state.extra as Event;
              return ParticipantsScreen(event: event);
            },
          ),
          GoRoute(
            path: 'attendance',
            builder: (context, state) {
              final event = state.extra as Event;
              return AttendanceScreen(event: event);
            },
          ),
          GoRoute(
            path: 'announce',
            builder: (context, state) {
              final event = state.extra as Event;
              return EventAnnouncementsScreen(event: event);
            },
          ),
          GoRoute(
            path: 'feedback-review',
            builder: (context, state) {
              final event = state.extra as Event;
              return FeedbackReviewScreen(event: event);
            },
          ),
          GoRoute(
            path: 'post-event',
            builder: (context, state) {
              final event = state.extra as Event;
              return PostEventScreen(event: event);
            },
          ),
        ],
      ),

      // --- STUDENT FEATURES ---
      GoRoute(
        path: AppRoutes.registeredEvents,
        builder: (context, state) => const RegisteredEventsScreen(),
      ),
      GoRoute(
        path: AppRoutes.certificates,
        builder: (context, state) => const CertificatesScreen(),
        routes: [
          GoRoute(
            path: 'pay',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>;
              return MockPaymentScreen(
                amount: extra['amount'] as double,
                itemName: extra['itemName'] as String,
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.feedback,
        builder: (context, state) {
          final event = state.extra as Event?;
          return FeedbackFormScreen(event: event);
        },
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
          GoRoute(
            path: 'saved',
            builder: (context, state) => const SavedMediaScreen(),
          ),
          GoRoute(
            path: 'view',
            builder: (context, state) {
              final item = state.extra as GalleryItem;
              return GalleryImageViewer(item: item);
            },
          ),
          GoRoute(
            path: 'upload', // /gallery/upload
            builder: (context, state) => const GalleryUploadScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (context, state) => const EditProfileScreen(),
          ),
          GoRoute(
            path: 'change-password',
            builder: (context, state) => const ChangePasswordScreen(),
          ),
        ],
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

  FutureOr<String?> _resolveRedirect(BuildContext context, GoRouterState state) async {
    final location = state.uri.path;

    if (location == AppRoutes.splash ||
        location == AppRoutes.onboarding ||
        location == AppRoutes.register ||
        location == AppRoutes.forgotPassword) {
      return null;
    }

    final user = await _authService.currentUser;
    final loggingIn = location == AppRoutes.login;

    if (user == null) {
      if (!loggingIn) return AppRoutes.login;
      return null;
    }

    if (loggingIn) {
      return AppRoutes.main;
    }

    if (user.role == AppRole.visitor) {
      if (!user.profileCompleted && location != AppRoutes.roleUpgrade) {
        return AppRoutes.roleUpgrade;
      }
      if (_participantOnlyRoutes.contains(location)) {
        return AppRoutes.roleUpgrade;
      }
    }

    return null;
  }
}