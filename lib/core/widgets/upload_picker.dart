import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/app_sizes.dart';

typedef UploadPickerCallback = void Function(PlatformFile file);

class UploadPicker extends StatelessWidget {
  const UploadPicker({
    super.key,
    required this.label,
    required this.allowedExtensions,
    required this.onFileSelected,
    this.icon = Icons.upload_file,
  });

  final String label;
  final List<String> allowedExtensions;
  final UploadPickerCallback onFileSelected;
  final IconData icon;

  Future<void> _pickFile(BuildContext context) async {
    if (allowedExtensions.contains('jpg') ||
        allowedExtensions.contains('png')) {
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

    final result = await FilePicker.platform.pickFiles(
      allowedExtensions: allowedExtensions,
      type: FileType.custom,
    );
    if (result != null && result.files.isNotEmpty) {
      onFileSelected(result.files.first);
    }
  }

  @override
  Widget build(BuildContext context) {
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

