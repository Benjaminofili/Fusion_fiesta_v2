import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/models/event.dart';
import '../../../../../data/models/feedback_entry.dart';
import '../../../../../data/repositories/event_repository.dart';

class FeedbackReviewScreen extends StatefulWidget {
  final Event event;
  const FeedbackReviewScreen({super.key, required this.event});

  @override
  State<FeedbackReviewScreen> createState() => _FeedbackReviewScreenState();
}

class _FeedbackReviewScreenState extends State<FeedbackReviewScreen> {
  // In a real app, you'd have a getFeedbackForEvent stream in repository.
  // For mock, we'll generate some dummy data or add a method to MockEventRepo.
  List<FeedbackEntry> _feedbacks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFeedback();
  }

  Future<void> _loadFeedback() async {
    final data = await serviceLocator<EventRepository>()
        .getFeedbackForEvent(widget.event.id);
    if (mounted) {
      setState(() {
        _isLoading = false;
        // Mock Data Generator
        // _feedbacks = List.generate(5, (index) => FeedbackEntry(
        //   id: 'fb-$index',
        //   eventId: widget.event.id,
        //   userId: 'student-${index + 10}',
        //   ratingOverall: (index % 2 == 0) ? 5.0 : 4.0,
        //   ratingOrganization: 4.0,
        //   ratingRelevance: 5.0,
        //   comment: index == 0 ? 'Amazing event! Learned so much.' : 'Great content but started late.',
        //   createdAt: DateTime.now().subtract(Duration(days: index)),
        // ));
        _feedbacks = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate Average
    double avgRating = 0;
    if (_feedbacks.isNotEmpty) {
      avgRating =
          _feedbacks.map((e) => e.ratingOverall).reduce((a, b) => a + b) /
              _feedbacks.length;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title:
            const Text('Event Feedback', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Summary Card
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(24.w),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(avgRating.toStringAsFixed(1),
                              style: TextStyle(
                                  fontSize: 48.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary)),
                          RatingBarIndicator(
                            rating: avgRating,
                            itemBuilder: (context, index) =>
                                const Icon(Icons.star, color: Colors.amber),
                            itemCount: 5,
                            itemSize: 20.sp,
                          ),
                          SizedBox(height: 4.h),
                          Text('${_feedbacks.length} Reviews',
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 14.sp)),
                        ],
                      ),
                      const Spacer(),
                      // Breakdown (Mock Visualization)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _RatingBarRow(label: '5 Star', pct: 0.6),
                          _RatingBarRow(label: '4 Star', pct: 0.3),
                          _RatingBarRow(label: '3 Star', pct: 0.1),
                          _RatingBarRow(label: '2 Star', pct: 0.0),
                          _RatingBarRow(label: '1 Star', pct: 0.0),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 1), // Divider line look

                // List
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.all(16.w),
                    itemCount: _feedbacks.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final fb = _feedbacks[index];
                      return Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha:0.05),
                                blurRadius: 4)
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                RatingBarIndicator(
                                  rating: fb.ratingOverall,
                                  itemBuilder: (context, index) => const Icon(
                                      Icons.star,
                                      color: Colors.amber),
                                  itemCount: 5,
                                  itemSize: 14.sp,
                                ),
                                const Spacer(),
                                Text(
                                  DateFormat('MMM d').format(fb.createdAt),
                                  style: TextStyle(
                                      fontSize: 12.sp, color: Colors.grey),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Text(fb.comment, style: TextStyle(fontSize: 14.sp)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _RatingBarRow extends StatelessWidget {
  final String label;
  final double pct;
  const _RatingBarRow({required this.label, required this.pct});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
        SizedBox(width: 8.w),
        Container(
          width: 80.w,
          height: 6.h,
          decoration: BoxDecoration(
              color: Colors.grey[200], borderRadius: BorderRadius.circular(3)),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: pct,
            child: Container(
                decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(3))),
          ),
        ),
      ],
    );
  }
}
