import 'package:flutter/material.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) => ListTile(
        leading: const Icon(Icons.warning_amber),
        title: Text('Alert #${index + 1}'),
        subtitle: const Text('Multiple failed logins detected.'),
      ),
      separatorBuilder: (_, __) => const Divider(),
      itemCount: 5,
    );
  }
}

