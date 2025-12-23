import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/models/event.dart';
import '../../../../../data/repositories/event_repository.dart';

class EventAnnouncementsScreen extends StatefulWidget {
  final Event event;
  const EventAnnouncementsScreen({super.key, required this.event});

  @override
  State<EventAnnouncementsScreen> createState() =>
      _EventAnnouncementsScreenState();
}

class _EventAnnouncementsScreenState extends State<EventAnnouncementsScreen> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _repository = serviceLocator<EventRepository>();
  bool _isLoading = false;

  Future<void> _sendAnnouncement() async {
    if (_titleController.text.isEmpty || _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() => _isLoading = true);

    await _repository.broadcastAnnouncement(
      widget.event.id,
      _titleController.text.trim(),
      _messageController.text.trim(),
    );

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Announcement Sent!'),
            backgroundColor: AppColors.success),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Announcement'),
      ),
      // 1. Wrap in SingleChildScrollView to fix overflow
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: ConstrainedBox(
          // 2. Constraints ensure full height usage but allow scrolling
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                kToolbarHeight -
                100, // Approximate safe height
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // Distribute space
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Notify Attendees',
                      style: TextStyle(
                          fontSize: 20.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8.h),
                  Text(
                    'Send updates about ${widget.event.title} to all registered participants.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 32.h),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: _messageController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Message',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),
                ],
              ),

              // 3. Button at bottom (but scrolls if needed)
              Padding(
                padding: EdgeInsets.only(top: 40.h),
                child: SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: FilledButton.icon(
                    onPressed: _isLoading ? null : _sendAnnouncement,
                    icon: const Icon(Icons.send),
                    label: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Send Broadcast'),
                    style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
