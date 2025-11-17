import 'package:flutter/material.dart';

class EventApprovalsScreen extends StatelessWidget {
  const EventApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event Approvals')),
      body: ListView.separated(
        itemBuilder: (context, index) => ListTile(
          title: Text('Event Proposal ${index + 1}'),
          subtitle: const Text('Awaiting review'),
          trailing: Wrap(
            spacing: 8,
            children: const [
              Icon(Icons.check),
              Icon(Icons.close),
            ],
          ),
        ),
        separatorBuilder: (_, __) => const Divider(),
        itemCount: 6,
      ),
    );
  }
}

