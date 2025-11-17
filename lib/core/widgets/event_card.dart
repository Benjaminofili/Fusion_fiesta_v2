import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../data/models/event.dart';

class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    this.trailing,
  });

  final Event event;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppSizes.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.title,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      '${event.category} · ${event.location}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      event.scheduleLabel,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppSizes.md),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

