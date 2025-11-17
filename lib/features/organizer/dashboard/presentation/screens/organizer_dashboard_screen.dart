import 'package:flutter/material.dart';

import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/widgets/stat_tile.dart';

class OrganizerDashboardScreen extends StatelessWidget {
  const OrganizerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Organizer Overview',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSizes.md),
          const Row(
            children: [
              Expanded(
                child: StatTile(
                  label: 'Live Events',
                  value: '03',
                  icon: Icons.play_circle,
                  color: Colors.indigo,
                ),
              ),
              SizedBox(width: AppSizes.md),
              Expanded(
                child: StatTile(
                  label: 'Registrations',
                  value: '248',
                  icon: Icons.how_to_reg,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          const Placeholder(fallbackHeight: 200),
        ],
      ),
    );
  }
}

