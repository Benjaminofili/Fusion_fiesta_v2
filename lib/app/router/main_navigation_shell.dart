import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/di/service_locator.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_roles.dart';
import '../../core/services/auth_service.dart';
import '../../data/models/user.dart'; // Import User model

// Screens
import '../../features/admin/dashboard/presentation/screens/admin_dashboard_screen.dart';
import '../../features/common/event_catalog/presentation/screens/event_catalog_screen.dart';
import '../../features/common/gallery/presentation/screens/gallery_screen.dart';
import '../../features/common/profile/presentation/screens/profile_screen.dart';
import '../../features/organizer/dashboard/presentation/screens/organizer_dashboard_screen.dart';
import '../../features/student/dashboard/presentation/screens/student_dashboard_screen.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  final AuthService _authService = serviceLocator<AuthService>();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // We don't need _loadUserRole anymore, StreamBuilder handles it
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    // --- THE FIX: Listen to the User Stream ---
    return StreamBuilder<User?>(
      stream: _authService.userStream,
      // Initial data tries to fetch from cache synchronously if possible
      initialData: null,
      builder: (context, snapshot) {
        // 1. If we are waiting for the stream, try to fetch async (Bootstrap)
        if (!snapshot.hasData && snapshot.connectionState == ConnectionState.waiting) {
          _authService.currentUser.then((user) {
            // This ensures the stream gets populated if it was empty
          });
          // While fetching, show loading or fallback
          // However, for smoother UX, we can default to Visitor until data arrives
        }

        // 2. Determine Role
        final user = snapshot.data;
        // If user is null (loading) or not logged in, default to Visitor
        final role = user?.role ?? AppRole.visitor;

        // 3. Get Tabs & Pages for this Role
        final tabs = _getTabsForRole(role);
        final pages = _getPagesForRole(role);

        // Safety: If role changed and index is out of bounds, reset
        if (_selectedIndex >= tabs.length) {
          _selectedIndex = 0;
        }

        return Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: pages,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              backgroundColor: Colors.white,
              indicatorColor: AppColors.primary.withOpacity(0.15),
              surfaceTintColor: Colors.white,
              destinations: tabs.map((tab) {
                return NavigationDestination(
                  icon: Icon(tab.icon, color: AppColors.textSecondary),
                  selectedIcon: Icon(tab.activeIcon, color: AppColors.primary),
                  label: tab.label,
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  List<_NavTab> _getTabsForRole(AppRole role) {
    switch (role) {
      case AppRole.admin:
        return const [
          _NavTab(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: 'Overview'),
          _NavTab(icon: Icons.people_outline, activeIcon: Icons.people, label: 'Users'),
          _NavTab(icon: Icons.analytics_outlined, activeIcon: Icons.analytics, label: 'Reports'),
          _NavTab(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
        ];
      case AppRole.organizer:
        return const [
          _NavTab(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: 'Manage'),
          _NavTab(icon: Icons.event_outlined, activeIcon: Icons.event, label: 'My Events'),
          _NavTab(icon: Icons.qr_code_scanner, activeIcon: Icons.qr_code, label: 'Scan'),
          _NavTab(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
        ];
      case AppRole.student:
        return const [
          _NavTab(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'), // Dashboard
          _NavTab(icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month, label: 'Events'),
          _NavTab(icon: Icons.photo_library_outlined, activeIcon: Icons.photo_library, label: 'Gallery'),
          _NavTab(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
        ];
      case AppRole.visitor:
      default:
        return const [
          _NavTab(icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month, label: 'Events'), // Catalog
          _NavTab(icon: Icons.photo_library_outlined, activeIcon: Icons.photo_library, label: 'Gallery'),
          _NavTab(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
        ];
    }
  }

  List<Widget> _getPagesForRole(AppRole role) {
    switch (role) {
      case AppRole.admin:
        return [
          const AdminDashboardScreen(),
          const Center(child: Text("User Management")),
          const Center(child: Text("Reports")),
          const ProfileScreen(),
        ];
      case AppRole.organizer:
        return [
          const OrganizerDashboardScreen(),
          const Center(child: Text("My Events")),
          const Center(child: Text("QR Scanner")),
          const ProfileScreen(),
        ];
      case AppRole.student:
        return [
          const StudentDashboardScreen(),
          const EventCatalogScreen(),
          GalleryScreen(),
          const ProfileScreen(),
        ];
      case AppRole.visitor:
      default:
        return [
          const EventCatalogScreen(),
          GalleryScreen(),
          const ProfileScreen(),
        ];
    }
  }
}

class _NavTab {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavTab({required this.icon, required this.activeIcon, required this.label});
}