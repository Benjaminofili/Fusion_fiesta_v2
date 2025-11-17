import 'package:flutter/material.dart';

import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/widgets/upload_picker.dart';

class EventEditorScreen extends StatelessWidget {
  const EventEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Event')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: AppSizes.md),
            TextField(
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: AppSizes.md),
            TextField(decoration: const InputDecoration(labelText: 'Location')),
            const SizedBox(height: AppSizes.md),
            UploadPicker(
              label: 'Upload Banner Image',
              allowedExtensions: const ['jpg', 'png'],
              onFileSelected: (file) {},
            ),
            const SizedBox(height: AppSizes.md),
            UploadPicker(
              label: 'Upload Guidelines (PDF)',
              allowedExtensions: const ['pdf'],
              onFileSelected: (file) {},
            ),
            const SizedBox(height: AppSizes.lg),
            FilledButton(onPressed: () {}, child: const Text('Publish Event')),
          ],
        ),
      ),
    );
  }
}

