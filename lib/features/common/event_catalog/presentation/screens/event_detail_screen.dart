import 'package:flutter/material.dart';

import '../../../../../core/constants/app_sizes.dart';
import '../../../../../data/models/event.dart';

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(event.title)),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.scheduleLabel,
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: AppSizes.md),
            Text(event.description),
            const Spacer(),
            FilledButton(onPressed: () {}, child: const Text('Register')),
          ],
        ),
      ),
    );
  }
}

