import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: const [
        CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
        SizedBox(height: 16),
        TextField(decoration: InputDecoration(labelText: 'Name')),
        SizedBox(height: 16),
        TextField(decoration: InputDecoration(labelText: 'Email')),
        SizedBox(height: 16),
        SwitchListTile(
            value: true, onChanged: null, title: Text('Push Notifications')),
      ],
    );
  }
}

