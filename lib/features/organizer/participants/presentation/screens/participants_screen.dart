import 'package:flutter/material.dart';

class ParticipantsScreen extends StatelessWidget {
  const ParticipantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Participants')),
      body: ListView.builder(
        itemCount: 8,
        itemBuilder: (context, index) => ListTile(
          leading: CircleAvatar(child: Text('${index + 1}')),
          title: Text('Participant ${index + 1}'),
          subtitle: const Text('Status: Pending'),
          trailing: Wrap(
            spacing: 8,
            children: const [
              Icon(Icons.check_circle_outline),
              Icon(Icons.cancel_outlined),
            ],
          ),
        ),
      ),
    );
  }
}

