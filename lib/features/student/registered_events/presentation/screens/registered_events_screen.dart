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
  String? _userId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _authService.currentUser;
    if (mounted) setState(() => _userId = user?.id);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text('My Schedule', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 20.sp)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary), onPressed: () => context.pop()),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          tabs: const [Tab(text: 'Upcoming'), Tab(text: 'Past')],
        ),
      ),
      // 1. OUTER STREAM: Get All Events (Updates if organizer changes time/details)
      body: StreamBuilder<List<Event>>(
        stream: _eventRepository.getEventsStream(),
        builder: (context, eventSnapshot) {
          if (!eventSnapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.primary));

          // 2. INNER STREAM: Get User's Registrations (Updates if user registers/cancels)
          return StreamBuilder<List<String>>(
            stream: _eventRepository.getRegisteredEventIdsStream(_userId!),
            builder: (context, idSnapshot) {
              if (!idSnapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.primary));

              final allEvents = eventSnapshot.data!;
              final registeredIds = idSnapshot.data!;

              // 3. FILTER: Match Events to IDs
              final myEvents = allEvents.where((e) => registeredIds.contains(e.id)).toList();

              final now = DateTime.now();
              final upcoming = myEvents.where((e) => e.startTime.isAfter(now)).toList();
              final past = myEvents.where((e) => e.startTime.isBefore(now)).toList();

              return TabBarView(
                controller: _tabController,
                children: [
                  _buildEventList(upcoming, isUpcoming: true),
                  _buildEventList(past, isUpcoming: false),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEventList(List<Event> events, {required bool isUpcoming}) {
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isUpcoming ? FontAwesomeIcons.calendarXmark : FontAwesomeIcons.boxOpen, size: 60.sp, color: Colors.grey[300]),
            SizedBox(height: 16.h),
            Text(isUpcoming ? 'No upcoming events' : 'No past events history', style: TextStyle(fontSize: 16.sp, color: Colors.grey[500])),
            if (isUpcoming) ...[
              SizedBox(height: 24.h),
              FilledButton.icon(
                onPressed: () => context.go(AppRoutes.events),
                icon: const Icon(Icons.search),
                label: const Text('Explore Events'),
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary, padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h)),
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
              EventCard(event: event, onTap: () => context.push('${AppRoutes.events}/details', extra: event)),
              if (!isUpcoming)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(16.r)),
                    alignment: Alignment.center,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20.r)),
                      child: Text('COMPLETED', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.sp, letterSpacing: 1)),
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