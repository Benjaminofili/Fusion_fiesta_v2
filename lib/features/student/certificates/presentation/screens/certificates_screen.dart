import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_routes.dart'; // Import Routes
import '../../../../../core/services/auth_service.dart';
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
    final user = serviceLocator<AuthService>().currentUser;
    if (user == null) return;

    try {
      // 1. Load events (for titles/categories)
      final events = await _eventRepository.getEventsStream().first;
      final eventMap = {for (var e in events) e.id: e};

      // 2. Load user certificates
      final certs = await _eventRepository.getUserCertificates(user.id);

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

  /// Handles Pay → Download flow safely (no context across async gaps)
  Future<void> _handleAction(Certificate cert) async {
    // Capture everything we need BEFORE any await
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    if (cert.isPaid) {
      // Already paid → simulate download
      _showDownloadFeedback(scaffoldMessenger);
      return;
    }

    // Not paid → go to payment screen
    final success = await router.push<bool>(
      '${AppRoutes.certificates}/pay',
      extra: {
        'amount': cert.fee,
        'itemName': 'Certificate Fee: ${cert.id}',
      },
    );

    // Payment result
    if (!mounted) return;
    if (success == true) {
      setState(() {
        final i = _certificates.indexWhere((c) => c.id == cert.id);
        if (i != -1) _certificates[i] = cert.copyWith(isPaid: true);
      });

      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Payment Successful! Certificate Unlocked.'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  /// Reusable download simulation (no context needed after capture)
  void _showDownloadFeedback(ScaffoldMessengerState scaffoldMessenger) {
    scaffoldMessenger.showSnackBar(
      const SnackBar(
        content: Text('Downloading certificate...'),
        backgroundColor: AppColors.success,
      ),
    );

    // Simulate async download
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Download Complete! Saved to Downloads.'),
          backgroundColor: AppColors.success,
        ),
      );
    });
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
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary),
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
          ? const Center(
          child: CircularProgressIndicator(color: AppColors.primary))
          : _certificates.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: EdgeInsets.all(24.w),
        itemCount: _certificates.length,
        itemBuilder: (context, index) {
          final cert = _certificates[index];
          final event = _relatedEvents[cert.eventId];

          return _CertificateCard(
            certificate: cert,
            eventTitle: event?.title ?? 'Unknown Event',
            eventCategory: event?.category ?? 'General',
            onAction: () => _handleAction(cert),
          )
              .animate()
              .fadeIn(delay: (100 * index).ms)
              .slideX(begin: 0.1);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FontAwesomeIcons.fileCircleXmark,
              size: 60.sp, color: Colors.grey[300]),
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
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha:0.05), blurRadius: 10)
        ],
      ),
      child: Row(
        children: [
          // Icon with Lock/Unlock status
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: isLocked ? Colors.grey[100] : Colors.blue.withValues(alpha:0.1),
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
                Text(eventTitle,
                    style: TextStyle(
                        fontSize: 16.sp, fontWeight: FontWeight.bold)),
                if (isLocked)
                  Text('Payment Pending',
                      style: TextStyle(fontSize: 12.sp, color: Colors.orange))
                else
                  Text(
                      'Issued: ${DateFormat('MMM d, yyyy').format(certificate.issuedAt)}',
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
              ],
            ),
          ),

          // Action Button
          TextButton.icon(
            onPressed: onAction,
            icon: Icon(actionIcon, size: 16, color: actionColor),
            label: Text(actionLabel,
                style:
                    TextStyle(color: actionColor, fontWeight: FontWeight.bold)),
            style: TextButton.styleFrom(
              backgroundColor: actionColor.withValues(alpha:0.1),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            ),
          ),
        ],
      ),
    );
  }
}
