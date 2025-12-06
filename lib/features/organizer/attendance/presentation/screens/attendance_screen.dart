import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/models/event.dart';
import '../../../../../data/repositories/event_repository.dart';

class AttendanceScreen extends StatefulWidget {
  final Event event;
  const AttendanceScreen({super.key, required this.event});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final MobileScannerController _controller = MobileScannerController();
  final _repository = serviceLocator<EventRepository>();

  bool _isProcessing = false;
  String? _lastScannedCode;

  Future<void> _processCode(String rawData) async {
    if (_isProcessing) return;
    if (rawData == _lastScannedCode) return; // Prevent duplicate scans

    setState(() => _isProcessing = true);

    // QR Format expected: "TICKET-eventId-userId"
    // Example: "TICKET-event-0-student-1"

    try {
      final parts = rawData.split('-');
      if (parts[0] != 'TICKET' || parts.length < 3) {
        throw Exception("Invalid Ticket Format");
      }

      // Logic to extract ID could be more robust, assuming simple split for mock
      // Let's assume the ID might contain dashes, so we need to be careful.
      // For this mock: TICKET - {eventId} - {userId}
      // We know our mock IDs don't have extra dashes, so simple split is fine.

      final scannedEventId = parts[1] + (parts.length > 3 ? "-${parts[2]}" : ""); // Handle 'event-0'
      final userId = parts.last;

      if (scannedEventId != widget.event.id) {
        _showResultDialog(false, "Wrong Event", "This ticket is for a different event.");
        return;
      }

      await _repository.markAttendance(widget.event.id, userId);
      _showResultDialog(true, "Check-in Successful", "Student ID: $userId");
      _lastScannedCode = rawData;

    } catch (e) {
      _showResultDialog(false, "Error", e.toString());
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showResultDialog(bool success, String title, String msg) {
    // Play sound here if audio plugin installed
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error,
              color: success ? AppColors.success : AppColors.error,
              size: 60,
            ),
            SizedBox(height: 16.h),
            Text(title, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.h),
            Text(msg, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Allow scanning again after closing dialog
                  if(!success) _lastScannedCode = null;
                },
                style: FilledButton.styleFrom(
                  backgroundColor: success ? AppColors.success : AppColors.error,
                ),
                child: const Text('Scan Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Tickets'), backgroundColor: Colors.transparent),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _processCode(barcode.rawValue!);
                  break; // Process one at a time
                }
              }
            },
          ),

          // Overlay
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
            ),
            child: Center(
              child: Container(
                width: 250.w,
                height: 250.w,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary, width: 2),
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Text(
              "Align QR code within the frame",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}