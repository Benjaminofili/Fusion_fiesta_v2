import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_routes.dart';
import '../../../../../core/services/auth_service.dart';
import '../../../../../core/services/storage_service.dart';
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
  final StorageService _storageService = serviceLocator<StorageService>();

  // We use a single stream source for efficiency
  late Stream<List<Event>> _eventsStream;

  // Counters (Mocked for now)
  int _certificateCount = 0;
  int _feedbackCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardStats();
    _eventsStream = _eventRepository.getEventsStream().asBroadcastStream();
  }

  Future<void> _loadDashboardStats() async {
    final user = _storageService.getUser();
    if (user == null) return;

    try {
      final certCount = await _eventRepository.getCertificateCount(user.id);
      final feedCount = await _eventRepository.getFeedbackCount(user.id);

      if (mounted) {
        setState(() {
          _certificateCount = certCount;
          _feedbackCount = feedCount;
        });
      }
    } catch (e) {
      debugPrint('Failed to load dashboard stats: $e');
    }
  }

  Future<void> _refresh() async {
    await _loadDashboardStats();
    setState(() {
      _eventsStream = _eventRepository.getEventsStream().asBroadcastStream();
    });
  }

  ImageProvider? _getProfileImage(String? path) {
    if (path == null) return null;
    if (path.startsWith('http')) {
      return NetworkImage(path);
    } else {
      return FileImage(File(path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.userStream,
      initialData: _storageService.getUser(),
      builder: (context, userSnapshot) {
        final user = userSnapshot.data;

        final registeredIdsStream = user != null
            ? _eventRepository.getRegisteredEventIdsStream(user.id).asBroadcastStream()
            : const Stream<List<String>>.empty();

        final favoriteIdsStream = user != null
            ? _eventRepository.getFavoriteEventIdsStream(user.id).asBroadcastStream()
            : const Stream<List<String>>.empty();

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          body: RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.primary,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          _buildHeader(context, user),
                          SizedBox(height: 55.h),
                        ],
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: _buildQuickAccessSection(
                            context, registeredIdsStream, favoriteIdsStream),
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 24.h)),

                // --- STREAM BUILDER WRAPPER ---
                // We wrap both sections in one builder to filter the data once
                StreamBuilder<List<Event>>(
                  stream: _eventsStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
                    }

                    final now = DateTime.now();

                    // --- FIX: Filter for Active & Approved Events ---
                    final activeEvents = snapshot.data!.where((e) {
                      return e.endTime.isAfter(now) && // Not ended
                          e.approvalStatus == EventStatus.approved; // Approved
                    }).toList();

                    // If no events, show empty state
                    if (activeEvents.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(24.w),
                          child: const Center(child: Text("No upcoming events right now.")),
                        ),
                      );
                    }

                    // Split: First one is "Next Event", rest are "Upcoming"
                    final nextEvent = activeEvents.first;
                    final upcomingEvents = activeEvents.length > 1
                        ? activeEvents.sublist(1)
                        : <Event>[];

                    return SliverList(
                      delegate: SliverChildListDelegate([
                        // Next Event Section
                        _buildNextEventSection(context, nextEvent),

                        // Upcoming Events Section
                        _buildUpcomingEventsHeader(context),
                        ...upcomingEvents.map((event) => Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                          child: EventCard(
                            event: event,
                            onTap: () => context.push('${AppRoutes.events}/details', extra: event),
                          ),
                        ).animate().fadeIn().slideY(begin: 0.1)),

                        SizedBox(height: 100.h),
                      ]),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- WIDGETS ---

  Widget _buildNextEventSection(BuildContext context, Event event) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Next Event',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
              color: AppColors.primary.withOpacity(0.05),
            ),
            child: EventCard(
              event: event,
              onTap: () => context.push('${AppRoutes.events}/details', extra: event),
            ),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildUpcomingEventsHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Explore Events',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          TextButton(
            onPressed: () => context.push(AppRoutes.events),
            child: Text('See All', style: TextStyle(fontSize: 14.sp)),
          ),
        ],
      ),
    );
  }

  // Header and QuickAccess widgets remain unchanged...
  Widget _buildHeader(BuildContext context, User? user) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(bottom: 60.h),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Color(0xFF7C4DFF)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: SafeArea(
        bottom: false,
        minimum: EdgeInsets.only(top: 20.h),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 26.r,
                backgroundColor: Colors.white24,
                backgroundImage: _getProfileImage(user?.profilePictureUrl),
                child: user?.profilePictureUrl == null
                    ? Icon(Icons.person, color: Colors.white, size: 28.sp)
                    : null,
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      user?.name ?? 'Student',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.notifications_outlined, color: Colors.white, size: 24.sp),
                  onPressed: () => context.push(AppRoutes.notifications),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccessSection(
      BuildContext context,
      Stream<List<String>> registeredStream,
      Stream<List<String>> favoriteStream,
      ) {
    return SizedBox(
      height: 110.h,
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          StreamBuilder<List<String>>(
            stream: registeredStream,
            initialData: const [],
            builder: (context, snapshot) {
              final count = snapshot.data?.length ?? 0;
              return _QuickAccessCard(
                label: 'Registered',
                count: count.toString().padLeft(2, '0'),
                icon: FontAwesomeIcons.ticket,
                color: Colors.blue,
                onTap: () => context.push(AppRoutes.registeredEvents),
              );
            },
          ),
          SizedBox(width: 12.w),
          _QuickAccessCard(
            label: 'Certificates',
            count: _certificateCount.toString().padLeft(2, '0'),
            icon: FontAwesomeIcons.award,
            color: Colors.orange,
            onTap: () => context.push(AppRoutes.certificates),
          ),
          SizedBox(width: 12.w),
          StreamBuilder<List<String>>(
            stream: favoriteStream,
            initialData: const [],
            builder: (context, snapshot) {
              final count = snapshot.data?.length ?? 0;
              return _QuickAccessCard(
                label: 'Favorites',
                count: count.toString().padLeft(2, '0'),
                icon: FontAwesomeIcons.heart,
                color: Colors.pink,
                onTap: () => context.push(AppRoutes.favorites),
              );
            },
          ),
          SizedBox(width: 12.w),
          _QuickAccessCard(
            label: 'Feedback',
            count: _feedbackCount.toString().padLeft(2, '0'),
            icon: FontAwesomeIcons.commentDots,
            color: Colors.teal,
            onTap: () => context.push(AppRoutes.feedback),
          ),
        ],
      ),
    );
  }
}

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100.w,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
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
            Align(
              alignment: Alignment.topRight,
              child: Icon(icon, color: color, size: 20.sp),
            ),
            const Spacer(),
            Text(
              count,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}