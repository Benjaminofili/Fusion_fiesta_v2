import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrPass extends StatelessWidget {
  const QrPass({
    super.key,
    required this.data,
    this.label,
  });

  final String data;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        QrImageView(
          data: data,
          version: QrVersions.auto,
          size: 160,
        ),
        if (label != null) ...[
          const SizedBox(height: 8),
          Text(label!, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ],
    );
  }
}

