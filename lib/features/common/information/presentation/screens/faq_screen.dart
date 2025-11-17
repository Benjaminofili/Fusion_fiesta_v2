import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      (
        'How do I register for events?',
        'Upgrade to participant and tap Register on the event card.'
      ),
      (
        'Can organizers edit events?',
        'Yes, edits are allowed before start time.'
      ),
    ];
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemBuilder: (context, index) => ExpansionTile(
        title: Text(faqs[index].$1),
        children: [
          Padding(
              padding: const EdgeInsets.all(16), child: Text(faqs[index].$2))
        ],
      ),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: faqs.length,
    );
  }
}

