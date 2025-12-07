import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/constants/app_colors.dart';

class OrganizerMessagesScreen extends StatelessWidget {
  const OrganizerMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Queries
    final queries = [
      {'user': 'Student 101', 'msg': 'Is the laptop required for the workshop?', 'time': '10:30 AM'},
      {'user': 'Alice Smith', 'msg': 'I cannot download my certificate.', 'time': 'Yesterday'},
      {'user': 'Bob Jones', 'msg': 'When will the results be announced?', 'time': 'Yesterday'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Participant Queries')),
      body: ListView.separated(
        padding: EdgeInsets.all(16.w),
        itemCount: queries.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final q = queries[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue[50],
              child: const Icon(Icons.person, color: Colors.blue),
            ),
            title: Text(q['user']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(q['msg']!, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Text(q['time']!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chat feature coming soon')));
            },
          );
        },
      ),
    );
  }
}