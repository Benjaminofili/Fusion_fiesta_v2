import 'package:cached_network_image/cached_network_image.dart'; // <--- NEW IMPORT
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../constants/app_colors.dart';
import '../../data/models/event.dart';

class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  final Event event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateFormatted = DateFormat('MMM d, yyyy').format(event.startTime);
    final timeFormatted = DateFormat('h:mm a').format(event.startTime);

    final limit = event.registrationLimit;
    final registered = event.registeredCount;
    final isFull = limit != null && registered >= limit;
    final slotsLeft = limit != null ? (limit - registered) : null;

    final hasBanner = event.bannerUrl != null && event.bannerUrl!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. IMAGE & CATEGORY BADGE ---
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: SizedBox(
                    height: 140,
                    width: double.infinity,
                    // LOGIC: Use CachedImage if URL exists, otherwise Default BG
                    child: hasBanner
                        ? CachedNetworkImage(
                      imageUrl: event.bannerUrl!,
                      fit: BoxFit.cover,
                      memCacheWidth: 800, // Optimize memory (resize large images)
                      placeholder: (context, url) => Container(
                        color: AppColors.primary.withOpacity(0.05),
                        child: const Center(
                            child: SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2)
                            )
                        ),
                      ),
                      errorWidget: (context, url, error) => _buildDefaultBackground(),
                      fadeInDuration: const Duration(milliseconds: 300),
                    )
                        : _buildDefaultBackground(),
                  ),
                ),

                // Category Badge (Overlay)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getCategoryIcon(event.category),
                          size: 12,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          event.category,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // --- 2. DETAILS SECTION ---
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        '$dateFormatted • $timeFormatted',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 16, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                event.location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Availability Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isFull
                              ? AppColors.error.withOpacity(0.1)
                              : AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isFull
                              ? 'FULL'
                              : (slotsLeft != null ? '$slotsLeft Slots Left' : 'Open'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isFull ? AppColors.error : AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Extracted this to use in the errorWidget
  Widget _buildDefaultBackground() {
    return Container(
      color: AppColors.primary.withOpacity(0.1),
      child: Center(
        child: Icon(
          _getCategoryIcon(event.category),
          size: 40,
          color: AppColors.primary.withOpacity(0.4),
        ),
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