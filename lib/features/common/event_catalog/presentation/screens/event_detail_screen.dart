import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/models/event.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool _isRegistered = false; // Mock state
  bool _isLoading = false;
  bool _isFavorite = false;

  Future<void> _toggleRegistration() async {
    setState(() => _isLoading = true);
    // TODO: Call API to register
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _isRegistered = !_isRegistered;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isRegistered
              ? 'Successfully registered!'
              : 'Registration cancelled'),
          backgroundColor: _isRegistered ? AppColors.success : AppColors.textPrimary,
          behavior: SnackBarBehavior.floating,
        ),
      );
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
              // --- 1. HERO IMAGE HEADER ---
              SliverAppBar(
                expandedHeight: 300.h,
                pinned: true,
                backgroundColor: AppColors.primary,
                // INCREASED MARGIN for Leading Button
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
                  // INCREASED MARGIN for Share Button
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
                      // Gradient Overlay for text readability
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

                      // Info Rows (Date, Time, Location)
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
                      // Toggle Icon based on state
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.pink : AppColors.textSecondary,
                      ),
                      onPressed: _toggleFavorite, // Call new method
                    ),
                  ),
                  SizedBox(width: 16.w),

                  // Register Button
                  Expanded(
                    child: SizedBox(
                      height: 56.h,
                      child: FilledButton(
                        onPressed: _isLoading ? null : _toggleRegistration,
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

// --- HELPER WIDGET ---
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