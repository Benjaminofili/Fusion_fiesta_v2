import 'package:flutter/material.dart';

class SitemapScreen extends StatelessWidget {
  const SitemapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = {
      'Students': [
        'Dashboard',
        'Registered Events',
        'Certificates',
        'Feedback'
      ],
      'Organizers': [
        'Dashboard',
        'Event Creator',
        'Participants',
        'Attendance'
      ],
      'Admins': ['Dashboard', 'Approvals', 'Users', 'Reports', 'Moderation'],
    };
    return ListView(
      padding: const EdgeInsets.all(24),
      children: sections.entries
          .map(
            (entry) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.key,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ...entry.value.map((item) => Text('• $item')),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

