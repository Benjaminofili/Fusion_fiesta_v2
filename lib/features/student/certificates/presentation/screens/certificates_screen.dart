import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // For date formatting

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/models/certificate.dart'; // Central Model
import '../../../../../data/models/event.dart'; // Central Model
import '../../../../../data/repositories/event_repository.dart'; // To look up event details

class CertificatesScreen extends StatefulWidget {
  const CertificatesScreen({super.key});

  @override
  State<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen> {
  final EventRepository _eventRepository = serviceLocator<EventRepository>();

  bool _isLoading = true;
  List<Certificate> _certificates = [];
  Map<String, Event> _relatedEvents = {}; // Cache event details here

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      // 1. Fetch All Events (In a real app, you might fetch specific events by ID)
      final events = await _eventRepository.getEventsStream().first;

      // Create a lookup map for easy access: EventID -> Event
      final eventMap = {for (var e in events) e.id: e};

      // 2. Mock Certificates (using your Central Model)
      // We use IDs that match your MockEventRepository (event-0, event-1)
      final certs = [
        Certificate(
          id: 'cert-001',
          userId: 'user-123',
          eventId: 'event-0', // Matches Technical Event in MockRepo
          url: 'https://example.com/cert1.pdf',
          issuedAt: DateTime.now().subtract(const Duration(days: 12)),
        ),
        Certificate(
          id: 'cert-002',
          userId: 'user-123',
          eventId: 'event-1', // Matches Cultural Event in MockRepo
          url: 'https://example.com/cert2.pdf',
          issuedAt: DateTime.now().subtract(const Duration(days: 45)),
        ),
        Certificate(
          id: 'cert-003',
          userId: 'user-123',
          eventId: 'event-2', // Matches another event
          url: 'https://example.com/cert3.pdf',
          issuedAt: DateTime.now().subtract(const Duration(days: 120)),
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
            onDownload: () => _downloadCertificate(cert),
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
  final VoidCallback onDownload;

  const _CertificateCard({
    required this.certificate,
    required this.eventTitle,
    required this.eventCategory,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormatted = DateFormat('MMM d, yyyy').format(certificate.issuedAt);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon / Thumbnail
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: _getCategoryColor(eventCategory).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Icon(
                FontAwesomeIcons.filePdf,
                color: _getCategoryColor(eventCategory),
                size: 28.sp,
              ),
            ),
          ),
          SizedBox(width: 16.w),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eventTitle,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  'Issued: $dateFormatted',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8.h),

                // Actions Row
                Row(
                  children: [
                    // View Button
                    InkWell(
                      onTap: () {
                        // TODO: Open PDF Viewer
                      },
                      child: Text(
                        'View',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    // Download Button
                    InkWell(
                      onTap: onDownload,
                      child: Row(
                        children: [
                          Icon(Icons.download_rounded, size: 16.sp, color: AppColors.textSecondary),
                          SizedBox(width: 4.w),
                          Text(
                            'Download',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                              fontSize: 13.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'technical': return Colors.blue;
      case 'cultural': return Colors.deepPurple;
      case 'sports': return Colors.orange;
      default: return AppColors.primary;
    }
  }
}