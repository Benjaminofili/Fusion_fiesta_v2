import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/app_sizes.dart'; //

typedef UploadPickerCallback = void Function(PlatformFile file);

class UploadPicker extends StatelessWidget {
  const UploadPicker({
    super.key,
    required this.label,
    required this.allowedExtensions,
    required this.onFileSelected,
    this.icon = Icons.upload_file,
    this.customChild,
  });

  final String label;
  final List<String> allowedExtensions;
  final UploadPickerCallback onFileSelected;
  final IconData icon;
  final Widget? customChild;

  Future<void> _pickFile(BuildContext context) async {
    try {
      // 1. Handle Images (Gallery)
      if (allowedExtensions.contains('jpg') ||
          allowedExtensions.contains('png') ||
          allowedExtensions.contains('jpeg')) {
        final imagePicker = ImagePicker();
        final file = await imagePicker.pickImage(source: ImageSource.gallery);

        if (file != null) {
          onFileSelected(
            PlatformFile(
              path: file.path,
              name: file.name,
              size: await file.length(),
            ),
          );
        }
        return;
      }

      // 2. Handle Documents (File Picker)
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
      );

      if (result != null && result.files.isNotEmpty) {
        if (result.files.first.path != null) {
          onFileSelected(result.files.first);
        }
      }
    } catch (e) {
      // FIX: Check if the widget is still on screen before using 'context'
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick file: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (customChild != null) {
      return GestureDetector(
        onTap: () => _pickFile(context),
        child: customChild,
      );
    }

    return OutlinedButton.icon(
      onPressed: () => _pickFile(context),
      icon: Icon(icon),
      label: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
        child: Text(label),
      ),
    );
  }
}