import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/services/auth_service.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../../../core/widgets/upload_picker.dart';
import '../../../../../data/models/event.dart';
import '../../../../../data/models/gallery_item.dart';
import '../../../../../data/repositories/event_repository.dart';
import '../../../../../data/repositories/gallery_repository.dart';

class GalleryUploadScreen extends StatefulWidget {
  const GalleryUploadScreen({super.key});

  @override
  State<GalleryUploadScreen> createState() => _GalleryUploadScreenState();
}

class _GalleryUploadScreenState extends State<GalleryUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _captionCtrl = TextEditingController();

  final _eventRepo = serviceLocator<EventRepository>();
  final _galleryRepo = serviceLocator<GalleryRepository>();
  final _authService = serviceLocator<AuthService>();

  bool _isLoading = false;
  Event? _selectedEvent;
  String? _filePath;

  List<Event> _myEvents = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    // 1. Get Current User ID
    final user = _authService.currentUser;
    if (user == null) return;

    final userId = user.id; // <--- USE ID, NOT NAME

    // 2. Fetch All Events
    // Note: In a real app with many events, you might want a specific query
    // like _eventRepo.getEventsByOrganizer(userId), but filtering the stream works for now.
    final allEvents = await _eventRepo.getEventsStream().first;

    if (mounted) {
      setState(() {
        // 3. FIX: Filter by ID
        _myEvents = allEvents.where((e) {
          return e.organizerId == userId || e.coOrganizers.contains(userId);
        }).toList();
      });
    }
  }

  Future<void> _upload() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedEvent == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please select an event')));
      return;
    }
    if (_filePath == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please pick an image')));
      return;
    }

    setState(() => _isLoading = true);

    // Capture everything you need BEFORE any await
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    try {
      final user = _authService.currentUser;

      final newItem = GalleryItem(
        id: const Uuid().v4(),
        eventId: _selectedEvent!.id,
        mediaType: MediaType.image,
        url: _filePath!,
        caption: _captionCtrl.text.trim(),
        category: _selectedEvent!.category,
        uploadedBy: user?.id ?? 'organizer',
        uploadedAt: DateTime.now(),
      );

      await _galleryRepo.uploadMedia(newItem);

      // Only use context-dependent objects AFTER checking mounted
      if (!mounted) return;

      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Uploaded successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      router.pop();
    } catch (e) {
      if (!mounted) return;

      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload to Gallery')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Share memories from your events.',
                  style: TextStyle(color: Colors.grey[600])),
              SizedBox(height: 24.h),

              // 1. EVENT SELECTOR
              DropdownButtonFormField<Event>(
                initialValue: _selectedEvent,
                hint: const Text('Select Event'),
                isExpanded: true,
                items: _myEvents
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.title, overflow: TextOverflow.ellipsis),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _selectedEvent = val),
                decoration: InputDecoration(
                  labelText: 'Event',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                  prefixIcon: const Icon(Icons.event),
                ),
              ),
              SizedBox(height: 16.h),

              // 2. CAPTION
              AppTextField(
                controller: _captionCtrl,
                label: 'Caption',
                prefixIcon: Icons.description,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 24.h),

              // 3. IMAGE PICKER
              UploadPicker(
                label: _filePath != null ? 'Change Image' : 'Pick Image',
                icon: Icons.image,
                allowedExtensions: const ['jpg', 'png', 'jpeg'],
                onFileSelected: (f) => setState(() => _filePath = f.path),
              ),
              if (_filePath != null) ...[
                SizedBox(height: 12.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.file(
                    File(_filePath!),
                    height: 200.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                        height: 200.h,
                        color: Colors.grey[200],
                        child: const Center(child: Icon(Icons.broken_image))),
                  ),
                ),
              ],

              SizedBox(height: 40.h),

              // 4. SUBMIT
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: FilledButton.icon(
                  onPressed: _isLoading ? null : _upload,
                  icon: const Icon(Icons.cloud_upload),
                  label: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Upload to Gallery'),
                  style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
