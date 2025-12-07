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

  // --- NEW: Status Logic ---
  String _getEventStatus(Event event) {
    // 1. Check Approval First
    if (event.approvalStatus == EventStatus.pending) {
      return 'PENDING';
    } else if (event.approvalStatus == EventStatus.rejected) {
      return 'REJECTED';
    } else if (event.approvalStatus == EventStatus.cancelled) {
      return 'CANCELLED';
    }

    // 2. If Approved, check Time
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
      case 'PENDING': return Colors.orange;
      case 'REJECTED': return Colors.red;
      case 'CANCELLED': return Colors.red;
      case 'LIVE': return Colors.green;
      case 'COMPLETED': return Colors.grey;
      default: return AppColors.primary; // Upcoming
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
          // FIX: Working Notification Button
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () => context.push(AppRoutes.notifications),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('${AppRoutes.events}/create'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Create Event'),
      ),
      body: StreamBuilder<List<Event>>(
        stream: _eventRepository.getEventsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          // Filter for THIS organizer
          final myEvents = snapshot.data!.where((e) {
            return e.organizer == _currentUser!.name || e.organizer == 'Tech Club';
          }).toList();

          // Calculate Stats
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

                // --- 2. QUICK ACTIONS (Calendar & Messages Added) ---
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
                    SizedBox(width: 12.w),
                    _ActionButton(
                      icon: Icons.qr_code_scanner,
                      label: 'Scan QR',
                      onTap: () {
                        if (myEvents.isNotEmpty) {
                          // For mock, just grab the first event or show picker
                          context.push('${AppRoutes.events}/attendance', extra: myEvents.first);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No events to scan')));
                        }
                      },
                    ),
                  ],
                ),
                SizedBox(height: 32.h),

                // --- 3. MY EVENTS LIST (With Status) ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('My Events', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                    TextButton(onPressed: () {}, child: const Text('View All')),
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
                        margin: EdgeInsets.only(bottom: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                        color: Colors.white,
                        child: Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                              leading: Container(
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.event_note, color: AppColors.primary),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                      child: Text(
                                          event.title,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis
                                      )
                                  ),
                                  // STATUS BADGE
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                        status,
                                        style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: statusColor)
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                '${event.registeredCount} Registered • ${event.location}',
                                style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                              ),
                              trailing: PopupMenuButton<String>(
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
                            const Divider(height: 1),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.people, size: 16),
                                  label: const Text('Participants'),
                                  onPressed: () => context.push('${AppRoutes.events}/participants', extra: event),
                                ),
                                TextButton.icon(
                                  icon: const Icon(Icons.edit, size: 16),
                                  label: const Text('Edit'),
                                  onPressed: () => context.push('${AppRoutes.events}/edit', extra: event),
                                ),
                              ],
                            )
                          ],
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

// --- KEEP YOUR WIDGET CLASSES (_StatCard, _ActionButton) AS THEY WERE ---
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