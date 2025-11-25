import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_roles.dart'; // Import AppRole
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
  // Dependencies
  final AuthService _authService = serviceLocator<AuthService>();
  final EventRepository _eventRepository = serviceLocator<EventRepository>();

  // State
  bool _isRegistered = false;
  bool _isLoading = true;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkRegistrationStatus();
  }

  /// Checks if the current user is already registered for this specific event
  Future<void> _checkRegistrationStatus() async {
    final user = await _authService.currentUser;
    if (user != null) {
      // Fetch list of IDs user is registered for
      final registeredIds = await _eventRepository.getRegisteredEventIds(user.id);
      if (mounted) {
        setState(() {
          _isRegistered = registeredIds.contains(widget.event.id);
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Handles the logic when the user clicks "Register" or "Cancel"
  Future<void> _handleRegistrationAction() async {
    // 1. Get Current User
    final user = await _authService.currentUser;
    if (user == null) return; // Should be handled by auth guard, but safety check

    // 2. ROLE CHECK: VISITOR GUARD 🛡️
    // If the user is a Visitor, they cannot register.
    if (user.role == AppRole.visitor) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must upgrade to a Participant account to register!'),
          backgroundColor: AppColors.warning,
          duration: Duration(seconds: 3),
        ),
      );
      // Redirect to Role Upgrade Screen
      context.push(AppRoutes.roleUpgrade);
      return;
    }

    // 3. PERFORM REGISTRATION / CANCELLATION
    setState(() => _isLoading = true);

    try {
      if (_isRegistered) {
        await _eventRepository.cancelRegistration(widget.event.id, user.id);
      } else {
        await _eventRepository.registerForEvent(widget.event.id, user.id);
      }

      // 4. Refresh Status to update UI
      await _checkRegistrationStatus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isRegistered ? 'Successfully registered!' : 'Registration cancelled'),
            backgroundColor: _isRegistered ? AppColors.success : AppColors.textPrimary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorite ? 'Added to Favorites' : 'Removed from Favorites'),
        duration: const Duration(seconds: 1),
      ),
    );
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
              // --- 1. HERO IMAGE HEADER ---
              SliverAppBar(
                expandedHeight: 300.h,
                pinned: true,
                backgroundColor: AppColors.primary,
                leading: Container(
                  margin: EdgeInsets.only(left: 8.w, top: 8.h, bottom: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => context.pop(),
                  ),
                ),
                actions: [
                  Container(
                    margin: EdgeInsets.only(right: 16.w, top: 8.h, bottom: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.share_outlined, color: Colors.black),
                      onPressed: () {},
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        color: AppColors.primary.withOpacity(0.1),
                        child: Icon(
                          _getCategoryIcon(event.category),
                          size: 80.sp,
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                        // TODO: Use Image.network(event.imageUrl) here
                      ),
                      // Gradient Overlay
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.6),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- 2. CONTENT BODY ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & Category
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
                              color: AppColors.primary.withOpacity(0.1),
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

                      // Info Rows
                      _InfoRow(
                        icon: Icons.calendar_today_outlined,
                        title: dateFormatted,
                        subtitle: timeFormatted,
                      ),
                      SizedBox(height: 16.h),
                      _InfoRow(
                        icon: Icons.location_on_outlined,
                        title: event.location,
                        subtitle: 'Get Directions',
                        isLink: true,
                      ),
                      SizedBox(height: 16.h),
                      _InfoRow(
                        icon: Icons.people_outline,
                        title: '${event.registeredCount} Registered',
                        subtitle: 'Limited seats available',
                      ),

                      SizedBox(height: 32.h),

                      // Description
                      Text(
                        'About Event',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        event.description,
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),

                      SizedBox(height: 100.h), // Space for bottom bar
                    ],
                  ),
                ),
              ),
            ],
          ),

          // --- 3. STICKY BOTTOM BAR ---
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
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Favorite Button
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.pink : AppColors.textSecondary,
                      ),
                      onPressed: _toggleFavorite,
                    ),
                  ),
                  SizedBox(width: 16.w),

                  // Register Button (UPDATED)
                  Expanded(
                    child: SizedBox(
                      height: 56.h,
                      child: FilledButton(
                        // Call the new handler
                        onPressed: _isLoading ? null : _handleRegistrationAction,
                        style: FilledButton.styleFrom(
                          backgroundColor: _isRegistered ? Colors.white : AppColors.primary,
                          foregroundColor: _isRegistered ? AppColors.error : Colors.white,
                          side: _isRegistered ? const BorderSide(color: AppColors.error) : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2)
                        )
                            : Text(
                          _isRegistered ? 'Cancel Registration' : 'Register Now',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isLink;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isLink = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, color: AppColors.primary, size: 24.sp),
        ),
        SizedBox(width: 16.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13.sp,
                color: isLink ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isLink ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ],
    );
  }
}