import 'package:flutter/material.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) => ListTile(
          leading: CircleAvatar(child: Text('${index + 1}')),
          title: Text('User ${index + 1}'),
          subtitle: const Text('Role: Student'),
          trailing: const Icon(Icons.more_vert),
        ),
      ),
    );
  }
}

