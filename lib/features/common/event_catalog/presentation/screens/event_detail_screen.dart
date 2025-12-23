import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_roles.dart';
import '../../../../../core/constants/app_routes.dart';
import '../../../../../core/services/auth_service.dart';
import '../../../../../data/models/event.dart';
import '../../../../../data/repositories/event_repository.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final AuthService _authService = serviceLocator<AuthService>();
  final EventRepository _eventRepository = serviceLocator<EventRepository>();

  bool _isActionLoading = false;
  bool _isFavorite = false;
  String? _userId;
  AppRole _userRole = AppRole.visitor;

  String _organizerName = '';

  @override
  void initState() {
    super.initState();
    _organizerName = widget.event.organizer;

    _loadUserAndStatus();
    _loadRichEventData();
  }

  Future<void> _loadRichEventData() async {
    try {
      // This calls the 'getEvent' you fixed, which includes the Profile Join
      final richEvent = await _eventRepository.getEvent(widget.event.id);
      if (mounted) {
        setState(() {
          _organizerName = richEvent.organizer; // Update the UI with "Anthony"
        });
      }
    } catch (e) {
      debugPrint('Could not load rich details: $e');
    }
  }

  Future<void> _loadUserAndStatus() async {
    final user = _authService.currentUser;
    if (user != null) {
      if (mounted) {
        setState(() {
          _userId = user.id;
          _userRole = user.role;
        });
      }
      await _checkStatus(user.id);
    }
  }

  Future<void> _checkStatus(String userId) async {
    try {
      final favoriteIds =
          await _eventRepository.getFavoriteEventIdsStream(userId).first;
      if (mounted) {
        setState(() {
          _isFavorite = favoriteIds.contains(widget.event.id);
        });
      }
    } catch (e) {
      debugPrint("Error checking status: $e");
    }
  }

  // --- ADMIN ACTIONS ---
  Future<void> _adminUpdateStatus(Event event, EventStatus status) async {
    setState(() => _isActionLoading = true);
    try {
      final updatedEvent = event.copyWith(approvalStatus: status);
      await _eventRepository.updateEvent(updatedEvent);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Event ${status.name.toUpperCase()} successfully'),
            backgroundColor: status == EventStatus.approved
                ? AppColors.success
                : AppColors.error,
          ),
        );
        context.pop(); // Return to list after action
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  // --- STUDENT ACTIONS ---
  Future<void> _handleRegistrationAction(bool isCurrentlyRegistered) async {
    if (_userRole == AppRole.visitor) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upgrade to Participant to register!')),
      );
      // Optional: Redirect to upgrade screen
      context.push(AppRoutes.roleUpgrade);
      return;
    }

    setState(() => _isActionLoading = true);
    try {
      if (isCurrentlyRegistered) {
        await _eventRepository.cancelRegistration(widget.event.id, _userId!);
      } else {
        await _eventRepository.registerForEvent(widget.event.id, _userId!);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  Future<void> _toggleFavorite() async {
    if (_userId == null) return;
    setState(() => _isFavorite = !_isFavorite);
    try {
      await _eventRepository.toggleFavorite(widget.event.id, _userId!);
    } catch (e) {
      // Revert if failed
      setState(() => _isFavorite = !_isFavorite);
    }
  }

  void _contactOrganizer(String organizerName) {
    final messageCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text('Contact $organizerName', style: TextStyle(fontSize: 18.sp)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Send a query regarding this event.',
              style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: messageCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Type your message here...',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r)),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () {
              if (messageCtrl.text.trim().isEmpty) return;

              // Close Dialog
              context.pop();

              // Simulate Sending
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 8.w),
                      Expanded(child: Text('Message sent to $organizerName!')),
                    ],
                  ),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.send, size: 16),
            label: const Text('Send'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<List<Event>>(
          stream: _eventRepository.getEventsStream(),
          builder: (context, snapshot) {
            // 1. FIND LIVE EVENT (Handle updates or deletions)
            final liveEvent = snapshot.data?.firstWhere(
                  (e) => e.id == widget.event.id,
                  orElse: () => widget.event,
                ) ??
                widget.event;

            // 2. CALCULATE SLOTS
            final limit = liveEvent.registrationLimit;
            final registered = liveEvent.registeredCount;
            final isFull = limit != null && registered >= limit;
            final slotsLeft = limit != null ? (limit - registered) : null;

            String capacityLabel;
            if (limit == null) {
              capacityLabel = 'Unlimited Seats';
            } else if (isFull) {
              capacityLabel = 'Event Full (0 slots left)';
            } else {
              capacityLabel = '$slotsLeft slots remaining';
            }

            final dateFormatted =
                DateFormat('EEEE, MMMM d').format(liveEvent.startTime);
            final timeFormatted =
                '${DateFormat('h:mm a').format(liveEvent.startTime)} - ${DateFormat('h:mm a').format(liveEvent.endTime)}';

            final isAdmin = _userRole == AppRole.admin;
            final isPending = liveEvent.approvalStatus == EventStatus.pending;

            return Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    // --- HEADER ---
                    SliverAppBar(
                      expandedHeight: 300.h,
                      pinned: true,
                      backgroundColor: AppColors.primary,
                      leading: _CircleButton(
                        icon: Icons.arrow_back,
                        onTap: () => context.pop(),
                      ),
                      actions: [
                        _CircleButton(icon: Icons.share_outlined, onTap: () {}),
                        SizedBox(width: 16.w),
                      ],
                      // ... inside SliverAppBar
                      flexibleSpace: FlexibleSpaceBar(
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            // LAYER 1: The Default (Colored Box & Icon)
                            // This is always rendered. If the image loads, it just covers this up.
                            Container(
                              color: AppColors.primary.withValues(alpha:
                                  0.1), // Light version of your primary color
                              child: Center(
                                child: Icon(
                                  _getCategoryIcon(liveEvent
                                      .category), // Shows Music/Tech/Sports icon
                                  size: 80.sp,
                                  color: AppColors.primary.withValues(alpha:0.3),
                                ),
                              ),
                            ),

                            // LAYER 2: The Actual Image (Supabase URL or External Link)
                            // We only try to render this if the URL exists.
                            if (liveEvent.bannerUrl != null &&
                                liveEvent.bannerUrl!.isNotEmpty)
                              CachedNetworkImage(
                                imageUrl: liveEvent.bannerUrl!,
                                fit: BoxFit.cover,

                                // Smooth Fade In
                                fadeInDuration:
                                    const Duration(milliseconds: 500),

                                // Placeholder (keeps the background color while loading)
                                placeholder: (context, url) =>
                                    Container(color: Colors.transparent),

                                // On Error, we just hide this layer so the default icon layer shows below
                                errorWidget: (context, url, error) =>
                                    const SizedBox(),
                              ),

                            // LAYER 3: Gradient Overlay
                            // Makes white text readable even if the image is bright
                            DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha:0.6),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // --- BODY ---
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(24.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ADMIN WARNING BANNER
                            if (isAdmin && isPending)
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(12.w),
                                margin: EdgeInsets.only(bottom: 16.h),
                                decoration: BoxDecoration(
                                  color: Colors.orange[50],
                                  border: Border.all(color: Colors.orange),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.warning_amber,
                                        color: Colors.orange),
                                    SizedBox(width: 12.w),
                                    const Expanded(
                                      child: Text(
                                        "Pending Approval. Review details below.",
                                        style: TextStyle(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // TITLE & CATEGORY
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    liveEvent.title,
                                    style: TextStyle(
                                      fontSize: 26.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12.w, vertical: 6.h),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: Text(
                                    liveEvent.category,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 24.h),

                            // ORGANIZER INFO
                            Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20.r,
                                    backgroundColor: AppColors.primary
                                        .withValues(alpha: 0.2),
                                    child: Text(
                                      _organizerName.isNotEmpty
                                          ? _organizerName.substring(0, 1)
                                          : 'O',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                        fontSize: 16.sp,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Organizer',
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        Text(
                                          _organizerName,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => _contactOrganizer(liveEvent
                                        .organizer), // ✅ NOW FUNCTIONAL
                                    child: const Text('Contact'),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 24.h),

                            // INFO ROWS
                            _InfoRow(
                                icon: Icons.calendar_today_outlined,
                                title: dateFormatted,
                                subtitle: timeFormatted),
                            SizedBox(height: 16.h),
                            _InfoRow(
                                icon: Icons.location_on_outlined,
                                title: liveEvent.location,
                                subtitle: 'Get Directions',
                                isLink: true),
                            SizedBox(height: 16.h),

                            // CAPACITY ROW
                            _InfoRow(
                              icon: Icons.people_outline,
                              title:
                                  '${liveEvent.registeredCount} / ${liveEvent.registrationLimit ?? '∞'} Registered',
                              subtitle: capacityLabel,
                              highlightColor: isFull ? AppColors.error : null,
                            ),

                            SizedBox(height: 32.h),
                            Text('About Event',
                                style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary)),
                            SizedBox(height: 12.h),
                            Text(liveEvent.description,
                                style: TextStyle(
                                    fontSize: 15.sp,
                                    color: AppColors.textSecondary,
                                    height: 1.6)),

                            // GUIDELINES
                            if (liveEvent.guidelinesUrl != null) ...[
                              SizedBox(height: 24.h),
                              OutlinedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Downloading Guidelines PDF...')),
                                  );
                                },
                                icon: const Icon(Icons.download_rounded),
                                label: const Text('Download Event Guidelines'),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  side: const BorderSide(
                                      color: AppColors.primary),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12.r)),
                                ),
                              ),
                            ],

                            SizedBox(height: 100.h),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // --- BOTTOM ACTION BAR ---
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, -5)),
                      ],
                    ),
                    child: isAdmin && isPending
                        ? Row(
                            // ADMIN ACTIONS
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _isActionLoading
                                      ? null
                                      : () => _adminUpdateStatus(
                                          liveEvent, EventStatus.rejected),
                                  style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.error,
                                      side: const BorderSide(
                                          color: AppColors.error),
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16.h)),
                                  child: const Text('Reject'),
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: FilledButton(
                                  onPressed: _isActionLoading
                                      ? null
                                      : () => _adminUpdateStatus(
                                          liveEvent, EventStatus.approved),
                                  style: FilledButton.styleFrom(
                                      backgroundColor: AppColors.success,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16.h)),
                                  child: _isActionLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white)
                                      : const Text('Approve'),
                                ),
                              ),
                            ],
                          )
                        : Row(
                            // STUDENT ACTIONS
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.border),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: IconButton(
                                  icon: Icon(
                                      _isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: _isFavorite
                                          ? Colors.pink
                                          : AppColors.textSecondary),
                                  onPressed: _toggleFavorite,
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: _userId == null
                                    ? const SizedBox()
                                    : StreamBuilder<List<String>>(
                                        stream: _eventRepository
                                            .getRegisteredEventIdsStream(
                                                _userId!),
                                        initialData: const [],
                                        builder: (context, snapshot) {
                                          final isRegistered = snapshot.data
                                                  ?.contains(liveEvent.id) ??
                                              false;
                                          final isDisabled =
                                              isFull && !isRegistered;

                                          return SizedBox(
                                            height: 56.h,
                                            child: FilledButton(
                                              // Disable button for Admins (they don't register) or if full
                                              onPressed: (_isActionLoading ||
                                                      isDisabled ||
                                                      isAdmin)
                                                  ? null
                                                  : () =>
                                                      _handleRegistrationAction(
                                                          isRegistered),
                                              style: FilledButton.styleFrom(
                                                backgroundColor: isRegistered
                                                    ? Colors.white
                                                    : (isDisabled || isAdmin
                                                        ? Colors.grey
                                                        : AppColors.primary),
                                                foregroundColor: isRegistered
                                                    ? AppColors.error
                                                    : Colors.white,
                                                side: isRegistered
                                                    ? const BorderSide(
                                                        color: AppColors.error)
                                                    : null,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16.r)),
                                              ),
                                              child: _isActionLoading
                                                  ? const SizedBox(
                                                      height: 24,
                                                      width: 24,
                                                      child:
                                                          CircularProgressIndicator(
                                                              strokeWidth: 2))
                                                  : Text(
                                                      isAdmin
                                                          ? 'Admin View'
                                                          : (isRegistered
                                                              ? 'Cancel Registration'
                                                              : (isDisabled
                                                                  ? 'Event Full'
                                                                  : 'Register Now')),
                                                      style: TextStyle(
                                                          fontSize: 16.sp,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            );
          }),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'cultural':
        return FontAwesomeIcons.masksTheater;
      case 'technical':
        return FontAwesomeIcons.laptopCode;
      case 'sports':
        return FontAwesomeIcons.trophy;
      default:
        return FontAwesomeIcons.calendar;
    }
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9), shape: BoxShape.circle),
      child:
          IconButton(icon: Icon(icon, color: Colors.black), onPressed: onTap),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isLink;
  final Color? highlightColor;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isLink = false,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12.r)),
          child: Icon(icon, color: AppColors.primary, size: 24.sp),
        ),
        SizedBox(width: 16.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            Text(subtitle,
                style: TextStyle(
                    fontSize: 13.sp,
                    color: highlightColor ??
                        (isLink ? AppColors.primary : AppColors.textSecondary),
                    fontWeight: (isLink || highlightColor != null)
                        ? FontWeight.w600
                        : FontWeight.normal)),
          ],
        ),
      ],
    );
  }
}
