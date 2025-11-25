import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_routes.dart';
import '../../../../../core/services/auth_service.dart';
import '../../../../../core/widgets/event_card.dart';
import '../../../../../data/models/event.dart';
import '../../../../../data/repositories/event_repository.dart';

class RegisteredEventsScreen extends StatefulWidget {
  const RegisteredEventsScreen({super.key});

  @override
  State<RegisteredEventsScreen> createState() => _RegisteredEventsScreenState();
}

class _RegisteredEventsScreenState extends State<RegisteredEventsScreen>
    with SingleTickerProviderStateMixin {
  final EventRepository _eventRepository = serviceLocator<EventRepository>();
  final AuthService _authService = serviceLocator<AuthService>();

  late TabController _tabController;

  // State
  bool _isLoading = true;
  List<Event> _upcomingEvents = [];
  List<Event> _pastEvents = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRegisteredEvents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Fetches only the events the user has registered for
  Future<void> _loadRegisteredEvents() async {
    setState(() => _isLoading = true);

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      // 1. Get Current User ID
      final user = await _authService.currentUser;
      if (user == null) {
        // Should not happen due to route guards
        if(mounted) setState(() => _isLoading = false);
        return;
      }

      // 2. Get List of Registered IDs (e.g., ['event-1', 'event-3'])
      final registeredIds = await _eventRepository.getRegisteredEventIds(user.id);

      // 3. Fetch All Events (to get the details for those IDs)
      final allEvents = await _eventRepository.getEventsStream().first;

      // 4. Filter: Keep only events that are in our registered list
      final myEvents = allEvents.where((e) => registeredIds.contains(e.id)).toList();

      final now = DateTime.now();

      if (mounted) {
        setState(() {
          // 5. Sort into Upcoming and Past
          _upcomingEvents = myEvents.where((e) => e.startTime.isAfter(now)).toList();
          _pastEvents = myEvents.where((e) => e.startTime.isBefore(now)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading events: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'My Schedule',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : TabBarView(
        controller: _tabController,
        children: [
          _buildEventList(_upcomingEvents, isUpcoming: true),
          _buildEventList(_pastEvents, isUpcoming: false),
        ],
      ),
    );
  }

  Widget _buildEventList(List<Event> events, {required bool isUpcoming}) {
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isUpcoming ? FontAwesomeIcons.calendarXmark : FontAwesomeIcons.boxOpen,
              size: 60.sp,
              color: Colors.grey[300],
            ),
            SizedBox(height: 16.h),
            Text(
              isUpcoming ? 'No upcoming events' : 'No past events history',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey[500]),
            ),
            if (isUpcoming) ...[
              SizedBox(height: 24.h),
              FilledButton.icon(
                onPressed: () => context.go(AppRoutes.events), // Go to Catalog
                icon: const Icon(Icons.search),
                label: const Text('Explore Events'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                ),
              )
            ]
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(24.w),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Stack(
            children: [
              EventCard(
                event: event,
                onTap: () => context.push('${AppRoutes.events}/details', extra: event),
              ),

              // "COMPLETED" Badge for Past Events
              if (!isUpcoming)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6), // Fade out the card
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    alignment: Alignment.center,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'COMPLETED',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ).animate().fadeIn(delay: (50 * index).ms).slideY(begin: 0.1);
      },
    );
  }
}