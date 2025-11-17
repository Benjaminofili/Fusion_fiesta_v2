import 'package:flutter/material.dart';

class SupportInboxScreen extends StatelessWidget {
  const SupportInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) => ListTile(
        leading: const Icon(Icons.mail_outline),
        title: Text('User Query ${index + 1}'),
        subtitle: const Text('Pending response'),
      ),
    );
  }
}

