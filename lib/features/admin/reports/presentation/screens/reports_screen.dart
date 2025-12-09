import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/constants/app_colors.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold( // Wrapped in Scaffold for better layout control
      appBar: AppBar(title: const Text('Analytics & Reports')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. KEY METRICS ---
            Text('Key Metrics', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 16.h),
            Row(
              children: [
                _ReportCard(label: 'Total Events', value: '42', color: Colors.blue),
                SizedBox(width: 16.w),
                _ReportCard(label: 'Participation', value: '85%', color: Colors.green),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                _ReportCard(label: 'Certificates', value: '1.2k', color: Colors.orange),
                SizedBox(width: 16.w),
                _ReportCard(label: 'Avg Feedback', value: '4.5', color: Colors.purple),
              ],
            ),

            SizedBox(height: 32.h),

            // --- 2. VISUAL CHART (Department Stats) ---
            Text('Event Distribution by Department', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 4.h),
            Text('Number of events organized this semester', style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
            SizedBox(height: 16.h),

            Container(
              height: 200.h,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _BarChartColumn(label: 'Tech', heightPct: 0.8, color: Colors.blue),
                  _BarChartColumn(label: 'Cultural', heightPct: 0.6, color: Colors.pink),
                  _BarChartColumn(label: 'Sports', heightPct: 0.4, color: Colors.orange),
                  _BarChartColumn(label: 'Arts', heightPct: 0.3, color: Colors.teal),
                  _BarChartColumn(label: 'Mgmt', heightPct: 0.5, color: Colors.purple),
                ],
              ),
            ),

            SizedBox(height: 32.h),

            // --- 3. EXPORT ACTIONS ---
            Text('Export Data', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 16.h),

            _ExportButton(
              icon: Icons.picture_as_pdf,
              label: 'Download Monthly Report (PDF)',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Generating PDF Report...')),
                );
              },
            ),
            SizedBox(height: 12.h),
            _ExportButton(
              icon: Icons.table_chart,
              label: 'Export User Data (Excel)',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exporting Excel Sheet...')),
                );
              },
            ),
            SizedBox(height: 80.h), // Bottom padding
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

  const _ReportCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.grey[700])),
          ],
        ),
      ),
    );
  }
}

class _BarChartColumn extends StatelessWidget {
  final String label;
  final double heightPct;
  final Color color;

  const _BarChartColumn({required this.label, required this.heightPct, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // The Bar
        Container(
          width: 20.w,
          height: 140.h * heightPct, // Scale height
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.vertical(top: Radius.circular(6.r)),
          ),
        ),
        SizedBox(height: 8.h),
        // The Label
        Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
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
            Icon(icon, color: AppColors.primary),
            SizedBox(width: 16.w),
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
            const Icon(Icons.download_rounded, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}