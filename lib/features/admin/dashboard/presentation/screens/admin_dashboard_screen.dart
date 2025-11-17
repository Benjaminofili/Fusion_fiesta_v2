import 'package:flutter/material.dart';

import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/widgets/stat_tile.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('System Overview',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSizes.md),
          const Row(
            children: [
              Expanded(
                child: StatTile(
                  label: 'Pending Approvals',
                  value: '05',
                  icon: Icons.pending_actions,
                  color: Colors.purple,
                ),
              ),
              SizedBox(width: AppSizes.md),
              Expanded(
                child: StatTile(
                  label: 'Active Users',
                  value: '1,248',
                  icon: Icons.group,
                  color: Colors.green,
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

