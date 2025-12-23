import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/upload_picker.dart';
import '../../../../../data/models/event.dart';
import '../../../../../data/repositories/event_repository.dart';

class PostEventScreen extends StatefulWidget {
  final Event event;
  const PostEventScreen({super.key, required this.event});

  @override
  State<PostEventScreen> createState() => _PostEventScreenState();
}

class _PostEventScreenState extends State<PostEventScreen> {
  final _winnersController = TextEditingController();
  bool _isLoading = false;
  String? _certPath;
  String? _resultsPath;

  Future<void> _publishUpdates() async {
    // Validation
    if (_certPath == null && _resultsPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a file to upload.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = serviceLocator<EventRepository>();

      // 1. Generate Certificates if a file was picked
      if (_certPath != null) {
        await repo.generateCertificatesForEvent(widget.event.id, _certPath!);
      }

      // 2. Broadcast Results (using existing announcement system)
      if (_resultsPath != null) {
        await repo.broadcastAnnouncement(widget.event.id, 'Results Published',
            'The results and winners for ${widget.event.title} are now available!');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Published successfully! Students notified.'),
              backgroundColor: AppColors.success),
        );
        context.pop();
      }
    } catch (e) {
      // ... handle error
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post-Event Management')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Event: ${widget.event.title}',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 24.h),

            // 1. WINNERS
            Text('Event Results',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
            SizedBox(height: 8.h),
            TextField(
              controller: _winnersController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter names of winners or key highlights...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.h),
            UploadPicker(
              label: _resultsPath ?? 'Upload Detailed Results (PDF)',
              icon: Icons.assessment_outlined,
              allowedExtensions: const ['pdf'],
              onFileSelected: (f) => setState(() => _resultsPath = f.name),
            ),

            SizedBox(height: 32.h),

            // 2. CERTIFICATES
            Text('Digital Certificates',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
            SizedBox(height: 4.h),
            Text('Upload bulk certificates for attendees.',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
            SizedBox(height: 12.h),
            UploadPicker(
              label: _certPath ?? 'Select Certificate Bundle (ZIP/PDF)',
              icon: Icons.workspace_premium,
              allowedExtensions: const ['pdf', 'zip'],
              onFileSelected: (f) => setState(() => _certPath = f.name),
            ),

            SizedBox(height: 40.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: FilledButton.icon(
                onPressed: _isLoading ? null : _publishUpdates,
                icon: const Icon(Icons.publish),
                label: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Publish & Notify Students'),
                style:
                    FilledButton.styleFrom(backgroundColor: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
