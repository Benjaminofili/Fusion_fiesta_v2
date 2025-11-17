import 'package:flutter/material.dart';

import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/widgets/upload_picker.dart';

class PostEventScreen extends StatelessWidget {
  const PostEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post-Event Updates')),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextField(
                decoration: InputDecoration(labelText: 'Winner Details')),
            const SizedBox(height: AppSizes.md),
            UploadPicker(
              label: 'Upload Certificates (PDF)',
              allowedExtensions: const ['pdf'],
              onFileSelected: (file) {},
            ),
            const SizedBox(height: AppSizes.md),
            UploadPicker(
              label: 'Upload Highlight Images',
              allowedExtensions: const ['jpg', 'png'],
              onFileSelected: (file) {},
            ),
            const SizedBox(height: AppSizes.lg),
            FilledButton(
                onPressed: () {}, child: const Text('Publish Updates')),
          ],
        ),
      ),
    );
  }
}

