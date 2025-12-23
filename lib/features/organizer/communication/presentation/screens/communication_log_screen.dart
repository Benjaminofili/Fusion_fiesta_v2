import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/repositories/event_repository.dart';

class CommunicationLogScreen extends StatelessWidget {
  const CommunicationLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = serviceLocator<EventRepository>();

    return Scaffold(
      appBar: AppBar(title: const Text('Communication Log')),
      backgroundColor: const Color(0xFFF9FAFB),
      body: FutureBuilder<List<Map<String, String>>>(
        future: repo.getCommunicationLogs(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final logs = snapshot.data!;
          if (logs.isEmpty) {
            return const Center(child: Text("No announcements sent yet."));
          }

          return ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemCount: logs.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final log = logs[index];
              final date = DateTime.tryParse(log['date']!) ?? DateTime.now();

              return Card(
                elevation: 0,
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(log['title']!,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.sp)),
                          Text(DateFormat('MMM d, h:mm a').format(date),
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 12.sp)),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text('Event: ${log['event']}',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500)),
                      SizedBox(height: 8.h),
                      Text(log['msg']!,
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 14.sp)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
