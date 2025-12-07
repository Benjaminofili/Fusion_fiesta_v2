import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_routes.dart';
import '../../../../../data/models/event.dart';
import '../../../../../data/repositories/event_repository.dart';

class OrganizerCalendarScreen extends StatelessWidget {
  const OrganizerCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final eventRepo = serviceLocator<EventRepository>();

    return Scaffold(
      appBar: AppBar(title: const Text('Event Calendar')),
      body: StreamBuilder<List<Event>>(
        stream: eventRepo.getEventsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final events = snapshot.data!;
          events.sort((a, b) => a.startTime.compareTo(b.startTime));

          // Group by Month/Day for a simple calendar list view
          // In a real app, you'd use 'table_calendar' package here.
          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              final day = DateFormat('d').format(event.startTime);
              final month = DateFormat('MMM').format(event.startTime);
              final year = DateFormat('y').format(event.startTime);

              return Card(
                margin: EdgeInsets.only(bottom: 12.h),
                child: ListTile(
                  leading: Container(
                    width: 60.w,
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(day, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        Text(month, style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  title: Text(event.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                  subtitle: Text('${DateFormat('h:mm a').format(event.startTime)} • ${event.location}'),
                  onTap: () => context.push('${AppRoutes.events}/details', extra: event),
                ),
              );
            },
          );
        },
      ),
    );
  }
}