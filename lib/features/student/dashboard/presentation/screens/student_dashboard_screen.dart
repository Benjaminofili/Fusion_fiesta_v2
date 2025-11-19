import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_routes.dart';
import '../../../../../core/services/auth_service.dart';
import '../../../../../core/widgets/event_card.dart';
import '../../../../../data/models/event.dart';
import '../../../../../data/models/user.dart';
import '../../../../../data/repositories/event_repository.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  final EventRepository _eventRepository = serviceLocator<EventRepository>();
  final AuthService _authService = serviceLocator<AuthService>();

  User? _user;
  late Future<List<Event>> _eventsFuture;

  int _registeredCount = 0;
  int _certificateCount = 0;
  int _favoriteCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadDashboardStats();
    _eventsFuture = _eventRepository.fetchEvents();
  }

  Future<void> _loadUserData() async {
    final user = await _authService.currentUser;
    if (mounted) {
      setState(() => _user = user);
    }
  }

  Future<void> _loadDashboardStats() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _registeredCount = 4;
        _certificateCount = 12;
        _favoriteCount = 7;
      });
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _eventsFuture = _eventRepository.fetchEvents();
    });
    await _loadDashboardStats();
  }

  // ✅ Dynamic header height calculator
  double _getHeaderHeight(BuildContext context) {
    final statusBar = MediaQuery.of(context).padding.top;
    // Minimal: 70px content + status bar + 10px buffer
    return 70.0 + statusBar + 10.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            // --- 1. DYNAMIC HEADER ---
            SliverAppBar(
              expandedHeight: _getHeaderHeight(context), // ✅ RESPONSIVE
              pinned: true,
              backgroundColor: AppColors.primary,
              elevation: 0,
              actions: [
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No new notifications')),
                    );
                  },
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, Color(0xFF7C4DFF)],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 16.0,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.white24,
                            backgroundImage: _user?.profilePictureUrl != null
                                ? NetworkImage(_user!.profilePictureUrl!)
                                : null,
                            child: _user?.profilePictureUrl == null
                                ? const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 30,
                            )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Welcome back,',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _user?.name ?? 'Student',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // --- 2. QUICK ACCESS TILES ---
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: const Offset(0, -20),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Row(
                    children: [
                      _QuickAccessCard(
                        label: 'Registered',
                        count: _registeredCount.toString().padLeft(2, '0'),
                        icon: FontAwesomeIcons.ticket,
                        color: Colors.blue,
                        onTap: () => context.push(AppRoutes.registeredEvents),
                      ),
                      const SizedBox(width: 12),
                      _QuickAccessCard(
                        label: 'Certificates',
                        count: _certificateCount.toString().padLeft(2, '0'),
                        icon: FontAwesomeIcons.award,
                        color: Colors.orange,
                        onTap: () => context.push(AppRoutes.certificates),
                      ),
                      const SizedBox(width: 12),
                      _QuickAccessCard(
                        label: 'Favorites',
                        count: _favoriteCount.toString().padLeft(2, '0'),
                        icon: FontAwesomeIcons.heart,
                        color: Colors.pink,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Favorites coming soon'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // --- 3. EVENTS TITLE ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Upcoming Events',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.events),
                      child: const Text('See All'),
                    ),
                  ],
                ),
              ),
            ),

            // --- 4. EVENTS LIST ---
            FutureBuilder<List<Event>>(
              future: _eventsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: Text('No upcoming events.')),
                    ),
                  );
                }

                final events = snapshot.data!;
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final event = events[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        child: EventCard(
                          event: event,
                          onTap: () => context.push(
                            '${AppRoutes.events}/details',
                            extra: event,
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(delay: (50 * index).ms)
                          .slideY(begin: 0.1);
                    },
                    childCount: events.length,
                  ),
                );
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

// ... _QuickAccessCard stays the same

// --- HELPER: COMPACT QUICK ACCESS CARD ---
class _QuickAccessCard extends StatelessWidget {
  final String label;
  final String count;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(height: 12),
              Text(
                count,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11, // Smaller font to fit 3 cards
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}