import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_routes.dart';
import '../../../../../core/services/auth_service.dart';
import '../../../../../data/models/event.dart';
import '../../../../../data/models/user.dart';
import '../../../../../data/repositories/event_repository.dart';

class OrganizerDashboardScreen extends StatefulWidget {
  const OrganizerDashboardScreen({super.key});

  @override
  State<OrganizerDashboardScreen> createState() => _OrganizerDashboardScreenState();
}

class _OrganizerDashboardScreenState extends State<OrganizerDashboardScreen> {
  final EventRepository _eventRepository = serviceLocator<EventRepository>();
  final AuthService _authService = serviceLocator<AuthService>();

  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _authService.currentUser;
    if (mounted) setState(() => _currentUser = user);
  }

  String _getEventStatus(Event event) {
    final now = DateTime.now();
    if (now.isAfter(event.startTime) && now.isBefore(event.endTime)) {
      return 'LIVE';
    } else if (now.isAfter(event.endTime)) {
      return 'COMPLETED';
    } else {
      return 'UPCOMING';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'LIVE': return Colors.red;
      case 'COMPLETED': return Colors.grey;
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              backgroundImage: _currentUser?.profilePictureUrl != null
                  ? NetworkImage(_currentUser!.profilePictureUrl!)
                  : null,
              child: _currentUser?.profilePictureUrl == null
                  ? const Icon(Icons.person, color: AppColors.primary)
                  : null,
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Organizer Panel', style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
                Text(_currentUser!.name, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16.sp)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () => context.push(AppRoutes.notifications),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'dashboard_create_event',
        onPressed: () => context.push('${AppRoutes.events}/create'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Create Event'),
      ),
      body: StreamBuilder<List<Event>>(
        stream: _eventRepository.getEventsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final myEvents = snapshot.data!.where((e) {
            return e.organizer == _currentUser!.name || e.organizer == 'Tech Club';
          }).toList();

          int totalRegistrations = 0;
          for (var e in myEvents) {
            totalRegistrations += e.registeredCount;
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 1. STATISTICS ---
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Total Events',
                        value: myEvents.length.toString(),
                        icon: Icons.event,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: _StatCard(
                        label: 'Registrations',
                        value: totalRegistrations.toString(),
                        icon: Icons.people_outline,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // --- 2. QUICK ACTIONS ---
                Text('Quick Actions', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    _ActionButton(
                      icon: Icons.calendar_month,
                      label: 'Calendar',
                      onTap: () => context.push('/organizer/calendar'),
                    ),
                    SizedBox(width: 12.w),
                    _ActionButton(
                      icon: Icons.chat_bubble_outline,
                      label: 'Queries',
                      onTap: () => context.push('/organizer/messages'),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    _ActionButton(
                      icon: Icons.qr_code_scanner,
                      label: 'Scan QR',
                      onTap: () {
                        if (myEvents.isNotEmpty) {
                          context.push('${AppRoutes.events}/attendance', extra: myEvents.first);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No events to scan')));
                        }
                      },
                    ),
                    SizedBox(width: 12.w),
                    _ActionButton(
                      icon: Icons.photo_library_outlined,
                      label: 'Gallery',
                      onTap: () => context.push(AppRoutes.gallery),
                    ),
                  ],
                ),
                SizedBox(height: 32.h),

                // --- 3. MY EVENTS LIST (REFACTORED CARD) ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('My Events', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                    TextButton(onPressed: () => context.push('/organizer/events'), child: const Text('View All')),
                  ],
                ),

                if (myEvents.isEmpty)
                  Container(
                    padding: EdgeInsets.all(32.h),
                    alignment: Alignment.center,
                    child: const Text('No events created yet.\nTap "+ Create Event" to start.'),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: myEvents.length,
                    itemBuilder: (context, index) {
                      final event = myEvents[index];
                      final status = _getEventStatus(event);
                      final statusColor = _getStatusColor(status);

                      return Card(
                        margin: EdgeInsets.only(bottom: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                        elevation: 0,
                        color: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // TOP ROW: Icon + Title + Menu
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10.w),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Icon(Icons.event_note, color: AppColors.primary, size: 24.sp),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Title (Full Width)
                                        Text(
                                          event.title,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.sp,
                                            color: AppColors.textPrimary,
                                            height: 1.2,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 6.h),
                                        // Metadata + Status
                                        Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                              decoration: BoxDecoration(
                                                color: statusColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(4.r),
                                              ),
                                              child: Text(
                                                status,
                                                style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: statusColor),
                                              ),
                                            ),
                                            SizedBox(width: 8.w),
                                            Expanded(
                                              child: Text(
                                                '${event.registeredCount} Reg. • ${event.location}',
                                                style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Menu Button (Top Right)
                                  SizedBox(
                                    width: 24.w,
                                    height: 24.w,
                                    child: PopupMenuButton<String>(
                                      padding: EdgeInsets.zero,
                                      icon: Icon(Icons.more_vert, size: 20.sp, color: Colors.grey),
                                      onSelected: (value) {
                                        if (value == 'announce') {
                                          context.push('${AppRoutes.events}/announce', extra: event);
                                        } else if (value == 'feedback') {
                                          context.push('${AppRoutes.events}/feedback-review', extra: event);
                                        } else if (value == 'close') {
                                          context.push('${AppRoutes.events}/post-event', extra: event);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'announce',
                                          child: Row(children: [Icon(Icons.campaign, size: 18), SizedBox(width: 8), Text('Announcement')]),
                                        ),
                                        const PopupMenuItem(
                                          value: 'feedback',
                                          child: Row(children: [Icon(Icons.star_half, size: 18), SizedBox(width: 8), Text('View Feedback')]),
                                        ),
                                        const PopupMenuItem(
                                          value: 'close',
                                          child: Row(children: [Icon(Icons.check_circle_outline, size: 18), SizedBox(width: 8), Text('Post-Event')]),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 16.h),
                              const Divider(height: 1),
                              SizedBox(height: 8.h),

                              // BOTTOM ROW: Action Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => context.push('${AppRoutes.events}/participants', extra: event),
                                      icon: const Icon(Icons.people, size: 16),
                                      label: const Text('Participants'),
                                      style: OutlinedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(vertical: 10.h),
                                        side: BorderSide(color: Colors.grey.shade300),
                                        foregroundColor: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => context.push('${AppRoutes.events}/edit', extra: event),
                                      icon: const Icon(Icons.edit, size: 16),
                                      label: const Text('Edit Event'),
                                      style: OutlinedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(vertical: 10.h),
                                        side: BorderSide(color: Colors.grey.shade300),
                                        foregroundColor: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                SizedBox(height: 80.h),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ... _StatCard and _ActionButton classes remain the same ...
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          SizedBox(height: 12.h),
          Text(value, style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary),
              SizedBox(height: 8.h),
              Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}