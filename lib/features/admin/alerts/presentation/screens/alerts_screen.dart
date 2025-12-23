import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/models/system_alert.dart';
import '../../../../../data/repositories/admin_repository.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  // Ensure your AdminRepositoryImpl is updated to return Stream<List<SystemAlert>>
  final _repo = serviceLocator<AdminRepository>();

  Future<void> _resolve(String id) async {
    // We only call the repo. The StreamBuilder will handle the UI update automatically.
    await _repo.resolveAlert(id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alert resolved'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('System Alerts')),
      body: StreamBuilder<List<SystemAlert>>(
        stream: _repo.getSystemAlertsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final alerts = snapshot.data ?? [];

          if (alerts.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemCount: alerts.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return _AlertCard(
                alert: alert,
                onResolve: () => _resolve(alert.id),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline,
              size: 64.sp, color: Colors.green[200]),
          SizedBox(height: 16.h),
          Text(
            'System Healthy',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          Text('No active alerts', style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final SystemAlert alert;
  final VoidCallback onResolve;

  const _AlertCard({required this.alert, required this.onResolve});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (alert.type) {
      case AlertType.security:
        color = Colors.red;
        icon = Icons.security;
        break;
      case AlertType.content:
        color = Colors.orange;
        icon = Icons.flag;
        break;
      case AlertType.technical:
        color = Colors.blue;
        icon = Icons.dns;
        break;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: color.withValues(alpha:0.3)),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  alert.type.name.toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                  ),
                ),
                if (alert.severity == AlertSeverity.high) ...[
                  SizedBox(width: 8.w),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(4)),
                    child: Text('HIGH',
                        style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.red,
                            fontWeight: FontWeight.bold)),
                  )
                ],
                const Spacer(),
                Text(
                  DateFormat('h:mm a').format(alert.timestamp),
                  style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              alert.title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
            ),
            SizedBox(height: 4.h),
            Text(
              alert.message,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
            ),
            SizedBox(height: 16.h),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onResolve,
                icon: const Icon(Icons.check, size: 16),
                label: const Text('Resolve'),
                style: TextButton.styleFrom(foregroundColor: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
