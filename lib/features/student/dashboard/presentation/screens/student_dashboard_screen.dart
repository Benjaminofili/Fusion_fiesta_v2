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

  // Streams for Lists
  late Stream<List<Event>> _highlightEventsStream;
  late Stream<List<Event>> _upcomingEventsStream;

  // ✅ FIX: Initialize these streams properly
  Stream<List<String>>? _registeredIdsStream;
  Stream<List<String>>? _favoriteIdsStream;

  // Static Counters (can remain for certificates/feedback)
  int _certificateCount = 0;
  int _feedbackCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadDashboardStats();

    _highlightEventsStream = _eventRepository.getEventsStream().asBroadcastStream();
    _upcomingEventsStream = _eventRepository.getEventsStream().asBroadcastStream();
  }

  Future<void> _loadUserData() async {
    final user = await _authService.currentUser;
    if (mounted) {
      setState(() {
        _user = user;

        // ✅ FIX: Initialize streams once user is loaded
        if (user != null) {
          _registeredIdsStream = _eventRepository
              .getRegisteredEventIdsStream(user.id)
              .asBroadcastStream();

          _favoriteIdsStream = _eventRepository
              .getFavoriteEventIdsStream(user.id)
              .asBroadcastStream();
        }
      });
    }
  }

  Future<void> _loadDashboardStats() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _certificateCount = 3;
        _feedbackCount = 2;
      });
    }
  }

  Future<void> _refresh() async {
    await _loadDashboardStats();
    setState(() {
      _highlightEventsStream = _eventRepository.getEventsStream().asBroadcastStream();
      _upcomingEventsStream = _eventRepository.getEventsStream().asBroadcastStream();

      // ✅ FIX: Refresh user streams too
      if (_user != null) {
        _registeredIdsStream = _eventRepository
            .getRegisteredEventIdsStream(_user!.id)
            .asBroadcastStream();

        _favoriteIdsStream = _eventRepository
            .getFavoriteEventIdsStream(_user!.id)
            .asBroadcastStream();
      }
    });
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
            // --- 1. HEADER SECTION & CARDS ---
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  Column(
                    children: [
                      _buildHeader(context),
                      SizedBox(height: 55.h),
                    ],
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildQuickAccessSection(context),
                  ),
                ],
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 24.h)),
            SliverToBoxAdapter(child: _buildNextEventSection(context)),
            _buildUpcomingEventsSection(context),
            SliverToBoxAdapter(child: SizedBox(height: 100.h)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      // Padding ensures content inside header (text/avatar) doesn't touch the cards
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
                backgroundImage: _user?.profilePictureUrl != null
                    ? NetworkImage(_user!.profilePictureUrl!)
                    : null,
                child: _user?.profilePictureUrl == null
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
                      _user?.name ?? 'Student',
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
                  onPressed: () { context.push(AppRoutes.notifications); },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccessSection(BuildContext context) {
    if (_registeredIdsStream == null || _favoriteIdsStream == null) {
      return SizedBox(
        height: 110.h,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return SizedBox(
      height: 110.h,
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          // 1. Registered Card (Now properly streamed)
          StreamBuilder<List<String>>(
            stream: _registeredIdsStream, // ✅ Now initialized
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

          // 2. Certificates (Static for now)
          _QuickAccessCard(
            label: 'Certificates',
            count: _certificateCount.toString().padLeft(2, '0'),
            icon: FontAwesomeIcons.award,
            color: Colors.orange,
            onTap: () => context.push(AppRoutes.certificates),
          ),
          SizedBox(width: 12.w),

          // 3. Favorites Card (Now properly streamed)
          StreamBuilder<List<String>>(
            stream: _favoriteIdsStream, // ✅ Now initialized
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

          // 4. Feedback (Static)
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

  Widget _buildNextEventSection(BuildContext context) {
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
              border: Border.all(
                  color: AppColors.primary.withOpacity(0.3), width: 1),
              color: AppColors.primary.withOpacity(0.05),
            ),
            child: StreamBuilder<List<Event>>(
              stream: _highlightEventsStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.all(16.w),
                    child: const Text(
                        "You haven't registered for any upcoming events."),
                  );
                }
                return EventCard(
                  event: snapshot.data!.first,
                  onTap: () => context.push('${AppRoutes.events}/details',
                      extra: snapshot.data!.first),
                );
              },
            ),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildUpcomingEventsSection(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
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
                onPressed: () => context.go(AppRoutes.events),
                child: Text('See All', style: TextStyle(fontSize: 14.sp)),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        StreamBuilder<List<Event>>(
          stream: _upcomingEventsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No events found.'));
            }

            final events = snapshot.data!.length > 1
                ? snapshot.data!.sublist(1)
                : <Event>[];

            if (events.isEmpty) {
              return Padding(
                padding: EdgeInsets.all(24.w),
                child: const Center(
                    child: Text("Check back later for more events!")),
              );
            }

            return Column(
              children: events.map((event) {
                return Padding(
                  padding:
                  EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                  child: EventCard(
                    event: event,
                    onTap: () => context.push(
                      '${AppRoutes.events}/details',
                      extra: event,
                    ),
                  ),
                ).animate().fadeIn().slideY(begin: 0.1);
              }).toList(),
            );
          },
        ),
      ]),
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