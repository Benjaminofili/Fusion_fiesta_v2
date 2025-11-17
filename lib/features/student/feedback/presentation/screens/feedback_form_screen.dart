import 'package:flutter/material.dart';

class FeedbackFormScreen extends StatelessWidget {
  const FeedbackFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text('Event Feedback',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          const Text('Rating'),
          const SizedBox(height: 8),
          const Placeholder(fallbackHeight: 56),
          const SizedBox(height: 24),
          const TextField(
              maxLines: 5,
              decoration: InputDecoration(labelText: 'Share your thoughts')),
          const SizedBox(height: 24),
          FilledButton(onPressed: () {}, child: const Text('Submit Feedback')),
        ],
      ),
    );
  }
}

