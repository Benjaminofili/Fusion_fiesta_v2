import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/services/auth_service.dart';
import '../../../../../core/widgets/app_text_field.dart'; // Reuse your widget!
import '../../../../../core/widgets/upload_picker.dart';
import '../../../../../data/models/event.dart';
import '../../../../../data/repositories/event_repository.dart';

class EventEditorScreen extends StatefulWidget {
  final Event? event; // If null, we are Creating. If provided, we are Editing.

  const EventEditorScreen({super.key, this.event});

  @override
  State<EventEditorScreen> createState() => _EventEditorScreenState();
}

class _EventEditorScreenState extends State<EventEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repo = serviceLocator<EventRepository>();
  final _authService = serviceLocator<AuthService>();

  // Controllers
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _limitCtrl;

  // State
  bool _isLoading = false;
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedCategory = 'Technical';
  String? _bannerPath;
  String? _pdfPath;

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    _titleCtrl = TextEditingController(text: e?.title);
    _descCtrl = TextEditingController(text: e?.description);
    _locationCtrl = TextEditingController(text: e?.location);
    _limitCtrl = TextEditingController(text: e?.registrationLimit?.toString());

    if (e != null) {
      _startDate = e.startTime;
      _endDate = e.endTime;
      _selectedCategory = e.category;
      _bannerPath = e.bannerUrl;
      _pdfPath = e.guidelinesUrl;
    }
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select start and end times')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _authService.currentUser;
      final organizerName = user?.name ?? 'Organizer'; // In real app, use ID

      final newEvent = Event(
        id: widget.event?.id ?? const Uuid().v4(), // Generate ID if new
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        category: _selectedCategory,
        startTime: _startDate!,
        endTime: _endDate!,
        location: _locationCtrl.text.trim(),
        organizer: organizerName,
        registrationLimit: int.tryParse(_limitCtrl.text),
        bannerUrl: _bannerPath,
        guidelinesUrl: _pdfPath,
        registeredCount: widget.event?.registeredCount ?? 0, // Preserve count if editing
      );

      if (widget.event == null) {
        await _repo.createEvent(newEvent);
      } else {
        await _repo.updateEvent(newEvent);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event Saved Successfully!')));
        context.pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDateTime(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (date == null) return;

    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    final dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      if (isStart) {
        _startDate = dateTime;
        // Auto-set end date to 2 hours later if not set
        if (_endDate == null) _endDate = dateTime.add(const Duration(hours: 2));
      } else {
        _endDate = dateTime;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.event != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Event' : 'Create Event'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. BASIC INFO
              AppTextField(controller: _titleCtrl, label: 'Event Title', prefixIcon: Icons.title, validator: (v) => v!.isEmpty ? 'Required' : null),
              SizedBox(height: 16.h),

              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: ['Technical', 'Cultural', 'Sports', 'Workshop']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v!),
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  prefixIcon: const Icon(Icons.category_outlined),
                ),
              ),
              SizedBox(height: 16.h),

              // 2. DATE & TIME
              Row(
                children: [
                  Expanded(
                    child: _DateTimePicker(
                      label: 'Starts',
                      value: _startDate,
                      onTap: () => _pickDateTime(true),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _DateTimePicker(
                      label: 'Ends',
                      value: _endDate,
                      onTap: () => _pickDateTime(false),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // 3. LOCATION & LIMITS
              AppTextField(controller: _locationCtrl, label: 'Venue / Location', prefixIcon: Icons.location_on_outlined, validator: (v) => v!.isEmpty ? 'Required' : null),
              SizedBox(height: 16.h),
              AppTextField(controller: _limitCtrl, label: 'Max Participants (Optional)', prefixIcon: Icons.people_outline, keyboardType: TextInputType.number),
              SizedBox(height: 16.h),

              // 4. DESCRIPTION
              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 24.h),

              // 5. UPLOADS
              Text('Attachments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
              SizedBox(height: 12.h),
              UploadPicker(
                label: _bannerPath != null ? 'Change Banner' : 'Upload Banner',
                icon: Icons.image,
                allowedExtensions: const ['jpg', 'png'],
                onFileSelected: (f) => setState(() => _bannerPath = f.path),
              ),
              if (_bannerPath != null) ...[
                SizedBox(height: 8.h),
                Text('Selected: ${_bannerPath!.split('/').last}', style: const TextStyle(color: Colors.green)),
              ],

              SizedBox(height: 12.h),
              UploadPicker(
                label: _pdfPath != null ? 'Change Guidelines' : 'Upload Guidelines (PDF)',
                icon: Icons.picture_as_pdf,
                allowedExtensions: const ['pdf'],
                onFileSelected: (f) => setState(() => _pdfPath = f.path),
              ),

              SizedBox(height: 40.h),

              // 6. SUBMIT BUTTON
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: FilledButton(
                  onPressed: _isLoading ? null : _saveEvent,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(isEditing ? 'Update Event' : 'Publish Event', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateTimePicker extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  const _DateTimePicker({required this.label, this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
            SizedBox(height: 4.h),
            Text(
              value != null ? DateFormat('MMM d, h:mm a').format(value!) : 'Select...',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
            ),
          ],
        ),
      ),
    );
  }
}