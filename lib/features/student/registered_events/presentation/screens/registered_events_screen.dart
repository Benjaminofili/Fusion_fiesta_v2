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
import '../../../../../core/widgets/qr_pass.dart';
import '../../../../../data/models/event.dart';
import '../../../../../data/models/registration.dart'; // Import this
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

  void _showTicketDialog(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        contentPadding: EdgeInsets.all(24.w),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              event.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Scan at entrance',
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: 24.h),

            SizedBox(
              width: 180.w,
              height: 200.h,
              child: Center(
                child: QrPass(data: 'TICKET|${event.id}|$_userId'),
              ),
            ),

            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => context.pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
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
          tabs: const [Tab(text: 'Upcoming'), Tab(text: 'Past')],
        ),
      ),
      body: StreamBuilder<List<Event>>(
        stream: _eventRepository.getEventsStream(),
        builder: (context, eventSnapshot) {
          if (!eventSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          return StreamBuilder<List<String>>(
            stream: _eventRepository.getRegisteredEventIdsStream(_userId!),
            builder: (context, idSnapshot) {
              if (!idSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }

              final allEvents = eventSnapshot.data!;
              final registeredIds = idSnapshot.data!;

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
                onPressed: () => context.go(AppRoutes.events),
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

        // --- NEW: FETCH REGISTRATION STATUS FOR THIS EVENT ---
        return StreamBuilder<List<Registration>>(
            stream: _eventRepository.getEventRegistrationsStream(event.id),
            builder: (context, regSnapshot) {

              // Find current user's registration
              final myReg = regSnapshot.data?.firstWhere(
                      (r) => r.userId == _userId,
                  orElse: () => Registration(id: '', eventId: '', userId: '', status: 'pending', createdAt: DateTime.now())
              );

              final status = myReg?.status ?? 'pending';
              final isApproved = status == 'approved';

              // Define colors
              Color statusColor = Colors.orange;
              if (status == 'approved') statusColor = AppColors.success;
              if (status == 'rejected') statusColor = AppColors.error;
              if (status == 'attended') statusColor = Colors.purple;

              return Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        EventCard(
                          event: event,
                          onTap: () => context.push('${AppRoutes.events}/details', extra: event),
                        ),

                        // --- STATUS BADGE (Top Left) ---
                        if (isUpcoming)
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                      isApproved ? Icons.check_circle : Icons.hourglass_top,
                                      size: 14.sp,
                                      color: statusColor
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    status.toUpperCase(),
                                    style: TextStyle(
                                      color: statusColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10.sp,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        if (!isUpcoming)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.6),
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

                    // --- ONLY SHOW TICKET IF APPROVED ---
                    if (isUpcoming && isApproved)
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(top: 8.h),
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.qr_code),
                          label: const Text('View Digital Pass'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                          ),
                          onPressed: () => _showTicketDialog(context, event),
                        ),
                      )
                    else if (isUpcoming && status == 'pending')
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(top: 8.h),
                        padding: EdgeInsets.all(12.h),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.orange.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info_outline, size: 16.sp, color: Colors.orange[800]),
                            SizedBox(width: 8.w),
                            Text(
                              'Awaiting Organizer Approval',
                              style: TextStyle(color: Colors.orange[800], fontSize: 12.sp, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ).animate().fadeIn(delay: (50 * index).ms).slideY(begin: 0.1);
            }
        );
      },
    );
  }
}