import 'package:flutter/material.dart';

class NotificationBadge extends StatelessWidget {
  const NotificationBadge({
    super.key,
    required this.count,
  });

  final int count;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count',
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: Colors.white),
      ),
    );
  }
}

