import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/models/event.dart';
import '../../../../../data/models/user.dart';
import '../../../../../data/repositories/event_repository.dart';
import '../../../../../data/repositories/user_repository.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _eventRepo = serviceLocator<EventRepository>();
  final _userRepo = serviceLocator<UserRepository>();

  bool _isLoading = true;

  // Statistics
  int _totalEvents = 0;
  int _activeUsers = 0;
  double _participationRate = 0.0;
  int _certificatesIssued = 0;
  double _avgFeedback = 0.0;

  // Department Data: Map<DepartmentName, EventCount>
  Map<String, int> _deptStats = {};
  int _maxDeptEvents = 1; // To scale the chart

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    try {
      // 1. Fetch Data
      final events = await _eventRepo.getEventsStream().first;
      final users = await _userRepo.fetchUsers();

      // 2. Calculate Key Metrics
      final totalEvents = events.length;
      final activeUsers = users.length;

      // Participation: Registered / Capacity (where capacity exists)
      int totalCapacity = 0;
      int totalRegistered = 0;
      int completedEventAttendees = 0;

      for (var e in events) {
        totalRegistered += e.registeredCount;
        if (e.registrationLimit != null) {
          totalCapacity += e.registrationLimit!;
        }

        // Approx. certificates (Completed events * attendees)
        final isCompleted = DateTime.now().isAfter(e.endTime);
        if (isCompleted) {
          completedEventAttendees += e.registeredCount;
        }
      }

      double participation = 0;
      if (totalCapacity > 0) {
        participation = (totalRegistered / totalCapacity) * 100;
      }

      // 3. Department Stats Calculation
      // Map Organizer Name -> Department
      final Map<String, String> organizerDeptMap = {};
      for (var u in users) {
        if (u.department != null && u.department!.isNotEmpty) {
          organizerDeptMap[u.name] = u.department!;
        }
      }

      // Count events per department
      final Map<String, int> deptCounts = {};
      for (var e in events) {
        // Try to find department by organizer name
        String dept = organizerDeptMap[e.organizer] ?? 'General';
        // Normalize "Tech Club" -> "Computer Science" if needed, or just use Dept

        deptCounts[dept] = (deptCounts[dept] ?? 0) + 1;
      }

      // Determine max for scaling bar chart
      int maxEvents = 1;
      if (deptCounts.isNotEmpty) {
        maxEvents = deptCounts.values.reduce((a, b) => a > b ? a : b);
      }

      // 4. Mock Average Feedback (Since fetching all would be heavy)
      // In a real backend, this would be a single aggregation query.
      double mockFeedback = 4.2;

      if (mounted) {
        setState(() {
          _totalEvents = totalEvents;
          _activeUsers = activeUsers;
          _participationRate = participation;
          _certificatesIssued = completedEventAttendees; // Proxy for certificates
          _avgFeedback = mockFeedback;
          _deptStats = deptCounts;
          _maxDeptEvents = maxEvents;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading analytics: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _generateReport(String format) {
    // Simulation of report generation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12.w),
            Expanded(child: Text('Report generated: Monthly_Analytics.$format')),
          ],
        ),
        backgroundColor: AppColors.success,
        action: SnackBarAction(label: 'OPEN', textColor: Colors.white, onPressed: () {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics & Reports')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. KEY METRICS ---
            Text('System Overview', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 16.h),
            Row(
              children: [
                _ReportCard(label: 'Total Events', value: '$_totalEvents', color: Colors.blue, icon: Icons.event),
                SizedBox(width: 16.w),
                _ReportCard(label: 'Participation', value: '${_participationRate.toStringAsFixed(1)}%', color: Colors.green, icon: Icons.people),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                _ReportCard(label: 'Certificates', value: '$_certificatesIssued', color: Colors.orange, icon: Icons.workspace_premium),
                SizedBox(width: 16.w),
                _ReportCard(label: 'Avg Feedback', value: '$_avgFeedback', color: Colors.purple, icon: Icons.star),
              ],
            ),

            SizedBox(height: 32.h),

            // --- 2. DEPARTMENT CHARTS ---
            Text('Event Distribution', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 4.h),
            Text('Events organized by department', style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
            SizedBox(height: 16.h),

            Container(
              height: 220.h,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: _deptStats.isEmpty
                  ? const Center(child: Text("No data available"))
                  : Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _deptStats.entries.map((entry) {
                  final pct = entry.value / _maxDeptEvents;
                  // Pick a color based on hash or random
                  final color = Colors.primaries[entry.key.length % Colors.primaries.length];
                  return _BarChartColumn(
                    label: entry.key.length > 8 ? '${entry.key.substring(0,6)}..' : entry.key,
                    count: entry.value,
                    heightPct: pct,
                    color: color,
                  );
                }).toList(),
              ),
            ),

            SizedBox(height: 32.h),

            // --- 3. EXPORT ACTIONS ---
            Text('Export Reports', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 16.h),

            _ExportButton(
              icon: Icons.picture_as_pdf,
              label: 'Download Executive Summary (PDF)',
              onTap: () => _generateReport('pdf'),
            ),
            SizedBox(height: 12.h),
            _ExportButton(
              icon: Icons.table_chart,
              label: 'Export Raw Data (Excel)',
              onTap: () => _generateReport('xlsx'),
            ),
            SizedBox(height: 80.h),
          ],
        ),
      ),
    );
  }
}

// --- HELPER WIDGETS ---

class _ReportCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _ReportCard({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 20.sp),
                if (label == 'Participation') // Small indicator
                  Icon(Icons.arrow_upward, color: Colors.green, size: 14.sp),
              ],
            ),
            SizedBox(height: 12.h),
            Text(value, style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.grey[700])),
          ],
        ),
      ),
    );
  }
}

class _BarChartColumn extends StatelessWidget {
  final String label;
  final int count;
  final double heightPct;
  final Color color;

  const _BarChartColumn({required this.label, required this.count, required this.heightPct, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('$count', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: color)),
        SizedBox(height: 4.h),
        // The Bar
        Container(
          width: 24.w,
          height: 120.h * (heightPct < 0.1 ? 0.1 : heightPct), // Min height for visibility
          decoration: BoxDecoration(
            color: color.withOpacity(0.8),
            borderRadius: BorderRadius.vertical(top: Radius.circular(6.r)),
          ),
        ),
        SizedBox(height: 8.h),
        // The Label
        SizedBox(
          width: 40.w,
          child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis
          ),
        ),
      ],
    );
  }
}

class _ExportButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ExportButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary),
            SizedBox(width: 16.w),
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
            const Icon(Icons.download_rounded, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}