import 'package:flutter/material.dart';

import '../../../../../core/constants/app_sizes.dart';

class RoleUpgradeScreen extends StatelessWidget {
  const RoleUpgradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Profile')),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Upgrade to Participant',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppSizes.md),
            const Text(
                'Provide enrolment number, department, and ID proof to proceed.'),
            const SizedBox(height: AppSizes.lg),
            TextField(
                decoration:
                    const InputDecoration(labelText: 'Enrolment Number')),
            const SizedBox(height: AppSizes.md),
            TextField(
                decoration: const InputDecoration(labelText: 'Department')),
            const SizedBox(height: AppSizes.md),
            const Placeholder(fallbackHeight: 120),
            const SizedBox(height: AppSizes.lg),
            FilledButton(
                onPressed: () {}, child: const Text('Submit for Review')),
          ],
        ),
      ),
    );
  }
}

