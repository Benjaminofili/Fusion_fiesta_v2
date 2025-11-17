import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Generate Reports',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Download as PDF'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.grid_on),
            label: const Text('Export as Excel'),
          ),
        ],
      ),
    );
  }
}

