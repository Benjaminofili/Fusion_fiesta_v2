import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_routes.dart';
import '../../../../../core/widgets/event_card.dart';
import '../../../../../data/models/event.dart';
import '../../../../../data/repositories/event_repository.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final EventRepository _eventRepository = serviceLocator<EventRepository>();
  bool _isLoading = true;
  List<Event> _favoriteEvents = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      // In a real app, call _eventRepository.fetchFavorites()
      final allEvents = await _eventRepository.getEventsStream().first;
      // Mocking: Pick 2 random events as "Favorites"
      if (mounted) {
        setState(() {
          _favoriteEvents = allEvents.take(2).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _removeFavorite(Event event) {
    setState(() {
      _favoriteEvents.removeWhere((e) => e.id == event.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${event.title} removed from favorites'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => setState(() => _favoriteEvents.add(event)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Saved Events',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _favoriteEvents.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: EdgeInsets.all(24.w),
        itemCount: _favoriteEvents.length,
        itemBuilder: (context, index) {
          final event = _favoriteEvents[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: Stack(
              children: [
                EventCard(
                  event: event,
                  onTap: () => context.push('${AppRoutes.events}/details', extra: event),
                ),
                // Remove Button Overlay
                Positioned(
                  top: 12,
                  left: 12,
                  child: GestureDetector(
                    onTap: () => _removeFavorite(event),
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.favorite, color: Colors.pink, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.1);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FontAwesomeIcons.heartCrack, size: 60.sp, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(
            'No saved events yet',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey[500]),
          ),
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
        ],
      ),
    );
  }
}