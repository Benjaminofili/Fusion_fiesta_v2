import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/services/auth_service.dart';
import '../../../../../data/models/event.dart';
import '../../../../../data/models/feedback_entry.dart';
import '../../../../../data/repositories/event_repository.dart';

class FeedbackFormScreen extends StatefulWidget {
  final Event? event;

  const FeedbackFormScreen({super.key, this.event});

  @override
  State<FeedbackFormScreen> createState() => _FeedbackFormScreenState();
}

class _FeedbackFormScreenState extends State<FeedbackFormScreen> {
  final _commentController = TextEditingController();
  final _eventRepository = serviceLocator<EventRepository>(); // Existing injection

  List<Event> _attendedEvents = [];
  Event? _selectedEvent;
  bool _isLoadingEvents = true;

  double _ratingOverall = 3.0;
  double _ratingOrganization = 3.0;
  double _ratingRelevance = 3.0;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _selectedEvent = widget.event;
      _isLoadingEvents = false;
    } else {
      _loadAttendedEvents();
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadAttendedEvents() async {
    final allEvents = await _eventRepository.getEventsStream().first;
    if (mounted) {
      setState(() {
        _attendedEvents = allEvents.take(3).toList();
        _isLoadingEvents = false;
      });
    }
  }

  Future<void> _submitFeedback() async {
    if (_selectedEvent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an event to rate')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final authService = serviceLocator<AuthService>();
      final user = await authService.currentUser;

      if (user == null) return;

      final feedback = FeedbackEntry(
        id: const Uuid().v4(),
        eventId: _selectedEvent!.id, // Use the selected event ID
        userId: user.id,
        ratingOverall: _ratingOverall,
        ratingOrganization: _ratingOrganization,
        ratingRelevance: _ratingRelevance,
        comment: _commentController.text.trim(),
        createdAt: DateTime.now(),
      );

      // --- UPDATED: Call Real Repository ---
      await _eventRepository.submitFeedback(feedback);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you! Your feedback helps us improve.'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting feedback: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Event Feedback',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.rate_review_outlined, size: 40.sp, color: AppColors.primary),
                  ),
                  SizedBox(height: 24.h),

                  if (widget.event != null)
                    Text(
                      widget.event!.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    )
                  else if (_isLoadingEvents)
                    const CircularProgressIndicator()
                  else
                    DropdownButtonFormField<Event>(
                      value: _selectedEvent,
                      hint: const Text('Select Event to Rate'),
                      isExpanded: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      ),
                      items: _attendedEvents.map((event) {
                        return DropdownMenuItem(
                          value: event,
                          child: Text(event.title, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedEvent = val),
                    ),

                  SizedBox(height: 8.h),
                  Text(
                    'How was your experience?',
                    style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40.h),

            _buildRatingRow('Overall Experience', _ratingOverall, (v) => setState(() => _ratingOverall = v)),
            SizedBox(height: 24.h),
            _buildRatingRow('Organization', _ratingOrganization, (v) => setState(() => _ratingOrganization = v)),
            SizedBox(height: 24.h),
            _buildRatingRow('Content Relevance', _ratingRelevance, (v) => setState(() => _ratingRelevance = v)),

            SizedBox(height: 40.h),

            Text(
              'Additional Comments',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Share your thoughts...',
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.all(16.w),
              ),
            ),

            SizedBox(height: 40.h),

            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: FilledButton(
                onPressed: _isSubmitting ? null : _submitFeedback,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                  'Submit Feedback',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingRow(String label, double rating, ValueChanged<double> onUpdate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              _getRatingLabel(rating),
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        RatingBar.builder(
          initialRating: rating,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemPadding: EdgeInsets.symmetric(horizontal: 4.0.w),
          itemBuilder: (context, _) => const Icon(
            Icons.star_rounded,
            color: Colors.amber,
          ),
          onRatingUpdate: onUpdate,
        ),
      ],
    );
  }

  String _getRatingLabel(double rating) {
    if (rating >= 4.5) return 'Excellent';
    if (rating >= 4.0) return 'Very Good';
    if (rating >= 3.0) return 'Good';
    if (rating >= 2.0) return 'Fair';
    return 'Poor';
  }
}