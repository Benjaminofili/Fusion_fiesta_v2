import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_routes.dart'; // Import Routes
import '../../../../../data/models/certificate.dart';
import '../../../../../data/models/event.dart';
import '../../../../../data/repositories/event_repository.dart';

class CertificatesScreen extends StatefulWidget {
  const CertificatesScreen({super.key});

  @override
  State<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen> {
  final EventRepository _eventRepository = serviceLocator<EventRepository>();

  bool _isLoading = true;
  List<Certificate> _certificates = [];
  Map<String, Event> _relatedEvents = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      final events = await _eventRepository.getEventsStream().first;
      final eventMap = {for (var e in events) e.id: e};

      // Mock Data with Payment Logic
      final certs = [
        Certificate(
          id: 'cert-001',
          userId: 'user-123',
          eventId: 'event-0',
          url: 'https://example.com/cert1.pdf',
          issuedAt: DateTime.now().subtract(const Duration(days: 12)),
          isPaid: true, // Free/Already Paid
        ),
        Certificate(
          id: 'cert-002',
          userId: 'user-123',
          eventId: 'event-1',
          url: 'https://example.com/cert2.pdf',
          issuedAt: DateTime.now().subtract(const Duration(days: 45)),
          fee: 5.00,
          isPaid: false, // REQUIRES PAYMENT
        ),
      ];

      if (mounted) {
        setState(() {
          _certificates = certs;
          _relatedEvents = eventMap;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAction(Certificate cert) async {
    if (cert.isPaid) {
      // Logic for Download
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloading ${cert.id}.pdf...'), backgroundColor: AppColors.success),
      );
    } else {
      // Logic for Payment
      final success = await context.push<bool>(
          '${AppRoutes.certificates}/pay',
          extra: {'amount': cert.fee, 'itemName': 'Certificate Fee: ${cert.id}'}
      );

      if (success == true) {
        // Update local state to show as paid
        setState(() {
          final index = _certificates.indexWhere((c) => c.id == cert.id);
          if (index != -1) {
            _certificates[index] = cert.copyWith(isPaid: true);
          }
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment Successful! Certificate Unlocked.')),
          );
        }
      }
    }
  }

  Future<void> _downloadCertificate(Certificate cert) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading ${cert.id}.pdf...'),
        duration: const Duration(seconds: 1),
      ),
    );
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Download Complete! Saved to Downloads.'),
          backgroundColor: AppColors.success,
        ),
      );
    }
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
          'My Certificates',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _certificates.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: EdgeInsets.all(24.w),
        itemCount: _certificates.length,
        itemBuilder: (context, index) {
          final cert = _certificates[index];
          // Look up the event to get Title/Category.
          // Fallback to "Unknown Event" if not found.
          final event = _relatedEvents[cert.eventId];

          return _CertificateCard(
            certificate: cert,
            eventTitle: event?.title ?? 'Unknown Event',
            eventCategory: event?.category ?? 'General',
            onAction: () => _handleAction(cert),
          ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.1);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FontAwesomeIcons.fileCircleXmark, size: 60.sp, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(
            'No certificates earned yet',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

// --- UI WIDGETS ---

class _CertificateCard extends StatelessWidget {
  final Certificate certificate;
  final String eventTitle;
  final String eventCategory;
  final VoidCallback onAction;

  const _CertificateCard({
    required this.certificate,
    required this.eventTitle,
    required this.eventCategory,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    // Determine status
    final isLocked = !certificate.isPaid;
    final actionLabel = isLocked ? 'Pay \$${certificate.fee}' : 'Download';
    final actionIcon = isLocked ? Icons.lock_outline : Icons.download_rounded;
    final actionColor = isLocked ? Colors.orange : AppColors.primary;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          // Icon with Lock/Unlock status
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: isLocked ? Colors.grey[100] : Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Icon(
                isLocked ? Icons.lock : FontAwesomeIcons.filePdf,
                color: isLocked ? Colors.grey : Colors.blue,
                size: 24.sp,
              ),
            ),
          ),
          SizedBox(width: 16.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(eventTitle, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                if (isLocked)
                  Text('Payment Pending', style: TextStyle(fontSize: 12.sp, color: Colors.orange))
                else
                  Text('Issued: ${DateFormat('MMM d, yyyy').format(certificate.issuedAt)}', style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
              ],
            ),
          ),

          // Action Button
          TextButton.icon(
            onPressed: onAction,
            icon: Icon(actionIcon, size: 16, color: actionColor),
            label: Text(actionLabel, style: TextStyle(color: actionColor, fontWeight: FontWeight.bold)),
            style: TextButton.styleFrom(
              backgroundColor: actionColor.withOpacity(0.1),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            ),
          ),
        ],
      ),
    );
  }
}