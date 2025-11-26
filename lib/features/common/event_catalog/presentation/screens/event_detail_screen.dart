import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

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

  @override
  void initState() {
    super.initState();
    _loadUserAndStatus();
  }

  Future<void> _loadUserAndStatus() async {
    final user = await _authService.currentUser;
    if (user != null) {
      if (mounted) setState(() => _userId = user.id);
      await _checkStatus(user.id);
    }
  }

  Future<void> _checkStatus(String userId) async {
    try {
      // FIX: Use .first to wait for the stream's first value
      final favoriteIds = await _eventRepository.getFavoriteEventIdsStream(userId).first;

      if (mounted) {
        setState(() {
          _isFavorite = favoriteIds.contains(widget.event.id);
        });
      }
    } catch (e) {
      print("Error checking status: $e");
    }
  }

  Future<void> _handleRegistrationAction(bool isCurrentlyRegistered) async {
    final user = await _authService.currentUser;
    if (user == null) return;

    if (user.role == AppRole.visitor) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must upgrade to a Participant account to register!'),
          backgroundColor: AppColors.warning,
        ),
      );
      context.push(AppRoutes.roleUpgrade);
      return;
    }

    setState(() => _isActionLoading = true);
    try {
      if (isCurrentlyRegistered) {
        await _eventRepository.cancelRegistration(widget.event.id, user.id);
      } else {
        await _eventRepository.registerForEvent(widget.event.id, user.id);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isFavorite ? 'Added to Favorites' : 'Removed from Favorites'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() => _isFavorite = !_isFavorite);
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final dateFormatted = DateFormat('EEEE, MMMM d').format(event.startTime);
    final timeFormatted = '${DateFormat('h:mm a').format(event.startTime)} - ${DateFormat('h:mm a').format(event.endTime)}';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
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
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        child: Icon(
                          _getCategoryIcon(event.category),
                          size: 80.sp,
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.6),
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
                      // Title
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              event.title,
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
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              event.category,
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

                      // Organizer Info
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
                              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                              child: Text(
                                event.organizer.substring(0, 1),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Organizer',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    event.organizer,
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
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Contact feature coming soon')),
                                );
                              },
                              child: const Text('Contact'),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // Info Rows
                      _InfoRow(icon: Icons.calendar_today_outlined, title: dateFormatted, subtitle: timeFormatted),
                      SizedBox(height: 16.h),
                      _InfoRow(icon: Icons.location_on_outlined, title: event.location, subtitle: 'Get Directions', isLink: true),
                      SizedBox(height: 16.h),
                      _InfoRow(icon: Icons.people_outline, title: '${event.registeredCount} Registered', subtitle: 'Limited seats available'),

                      SizedBox(height: 32.h),
                      Text('About Event', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      SizedBox(height: 12.h),
                      Text(event.description, style: TextStyle(fontSize: 15.sp, color: AppColors.textSecondary, height: 1.6)),

                      // Guidelines Button
                      if (event.guidelinesUrl != null) ...[
                        SizedBox(height: 24.h),
                        OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Downloading Guidelines PDF...')),
                            );
                          },
                          icon: const Icon(Icons.download_rounded),
                          label: const Text('Download Event Guidelines'),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
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

          // --- BOTTOM BAR ---
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: IconButton(
                      icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border, color: _isFavorite ? Colors.pink : AppColors.textSecondary),
                      onPressed: _toggleFavorite,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _userId == null
                        ? const SizedBox()
                        : StreamBuilder<List<String>>(
                      stream: _eventRepository.getRegisteredEventIdsStream(_userId!),
                      initialData: const [],
                      builder: (context, snapshot) {
                        final isRegistered = snapshot.data?.contains(event.id) ?? false;
                        return SizedBox(
                          height: 56.h,
                          child: FilledButton(
                            onPressed: _isActionLoading ? null : () => _handleRegistrationAction(isRegistered),
                            style: FilledButton.styleFrom(
                              backgroundColor: isRegistered ? Colors.white : AppColors.primary,
                              foregroundColor: isRegistered ? AppColors.error : Colors.white,
                              side: isRegistered ? const BorderSide(color: AppColors.error) : null,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                            ),
                            child: _isActionLoading
                                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))
                                : Text(
                              isRegistered ? 'Cancel Registration' : 'Register Now',
                              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
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
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'cultural': return FontAwesomeIcons.masksTheater;
      case 'technical': return FontAwesomeIcons.laptopCode;
      case 'sports': return FontAwesomeIcons.trophy;
      default: return FontAwesomeIcons.calendar;
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
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), shape: BoxShape.circle),
      child: IconButton(icon: Icon(icon, color: Colors.black), onPressed: onTap),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isLink;

  const _InfoRow({required this.icon, required this.title, required this.subtitle, this.isLink = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12.r)),
          child: Icon(icon, color: AppColors.primary, size: 24.sp),
        ),
        SizedBox(width: 16.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            Text(subtitle, style: TextStyle(fontSize: 13.sp, color: isLink ? AppColors.primary : AppColors.textSecondary, fontWeight: isLink ? FontWeight.w600 : FontWeight.normal)),
          ],
        ),
      ],
    );
  }
}