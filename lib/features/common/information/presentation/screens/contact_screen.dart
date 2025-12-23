import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// Make sure to add this to pubspec.yaml if not present
// If url_launcher isn't added yet, we will fallback to a simulated Snackbar action.

import '../../../../../core/constants/app_colors.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  Future<void> _openMap(BuildContext context) async {
    // Production Logic:
    // final Uri url = Uri.parse('https://maps.google.com/?q=Aptech+Limited');
    // if (!await launchUrl(url)) { ... error ... }

    // Simulation Logic:
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening Google Maps to Aptech Campus...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Contact Us', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Get in Touch',
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.h),
            Text('We are here to help you with any questions.',
                style: TextStyle(color: Colors.grey[600])),

            SizedBox(height: 32.h),

            // --- 1. MAP CARD (POLISH) ---
            Container(
              height: 200.h,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                image: const DecorationImage(
                  // Use a static map image or a placeholder that looks like one
                  image: NetworkImage(
                      'https://maps.googleapis.com/maps/api/staticmap?center=University&zoom=14&size=600x300&sensor=false'), // Example URL or asset
                  fit: BoxFit.cover,
                ),
                color: Colors.blue[50], // Fallback
              ),
              child: Stack(
                children: [
                  // Fallback icon if image fails
                  const Center(
                      child:
                          Icon(Icons.map, size: 50, color: Colors.blueAccent)),

                  // Gradient
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.r),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha:0.6)
                        ],
                      ),
                    ),
                  ),

                  // Info & Button
                  Positioned(
                    bottom: 16.h,
                    left: 16.w,
                    right: 16.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Main Campus',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp)),
                            Text('Aptech Limited',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12.sp)),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _openMap(context),
                          icon: const Icon(Icons.directions, size: 16),
                          label: const Text('Directions'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32.h),

            // --- 2. CONTACT FORM ---
            TextFormField(decoration: _inputDeco('Your Name')),
            SizedBox(height: 16.h),
            TextFormField(decoration: _inputDeco('Email Address')),
            SizedBox(height: 16.h),
            TextFormField(
              decoration: _inputDeco('Message'),
              maxLines: 4,
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: FilledButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Message Sent!')));
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                ),
                child: const Text('Send Message'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300)),
    );
  }
}
