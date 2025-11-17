import 'package:flutter/material.dart';

import '../../app/di/service_locator.dart';
import '../../core/constants/app_roles.dart';
import '../../core/services/auth_service.dart';
import '../../data/models/user.dart';
import '../../features/admin/dashboard/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/reports/presentation/screens/reports_screen.dart';
import '../../features/common/event_catalog/presentation/screens/event_catalog_screen.dart';
import '../../features/common/gallery/presentation/screens/gallery_screen.dart';
import '../../features/common/information/presentation/screens/about_screen.dart';
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
  User? _user;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final current = await _authService.currentUser ??
        const User(
            id: 'guest',
            name: 'Guest',
            email: 'guest@fusionfiesta.dev',
            role: AppRole.visitor);
    if (mounted) {
      setState(() => _user = current);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final destinations = _buildDestinations();
    return Scaffold(
      body: destinations[_index].builder(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: destinations
            .map(
              (destination) => NavigationDestination(
                icon: Icon(destination.icon),
                label: destination.label,
              ),
            )
            .toList(),
      ),
    );
  }

  List<_Destination> _buildDestinations() {
    final list = <_Destination>[
      _Destination(
          label: 'Events',
          icon: Icons.event,
          builder: () => const EventCatalogScreen()),
      _Destination(
          label: 'Gallery', icon: Icons.photo, builder: () => GalleryScreen()),
      _Destination(
          label: 'Profile',
          icon: Icons.person,
          builder: () => const ProfileScreen()),
    ];

    switch (_user!.role) {
      case AppRole.student:
      case AppRole.visitor:
        list.insert(
            0,
            _Destination(
                label: 'Dashboard',
                icon: Icons.dashboard,
                builder: () => StudentDashboardScreen()));
        break;
      case AppRole.organizer:
        list.insert(
            0,
            const _Destination(
                label: 'Dashboard',
                icon: Icons.dashboard,
                builder: OrganizerDashboardScreen.new));
        break;
      case AppRole.admin:
        list
          ..insert(
              0,
              const _Destination(
                  label: 'Dashboard',
                  icon: Icons.dashboard,
                  builder: AdminDashboardScreen.new))
          ..add(const _Destination(
              label: 'Reports',
              icon: Icons.insert_chart,
              builder: ReportsScreen.new));
        break;
    }

    list.add(const _Destination(
        label: 'About', icon: Icons.info_outline, builder: AboutScreen.new));
    return list;
  }
}

class _Destination {
  const _Destination({
    required this.label,
    required this.icon,
    required this.builder,
  });

  final String label;
  final IconData icon;
  final Widget Function() builder;
}
