import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/models/support_message.dart';
import '../../../../../data/repositories/admin_repository.dart';

class SupportInboxScreen extends StatefulWidget {
  const SupportInboxScreen({super.key});

  @override
  State<SupportInboxScreen> createState() => _SupportInboxScreenState();
}

class _SupportInboxScreenState extends State<SupportInboxScreen> {
  final _repo = serviceLocator<AdminRepository>();
  List<SupportMessage> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final data = await _repo.getSupportMessages();
    if (mounted) {
      setState(() {
        _messages = data.where((m) => !m.isReplied).toList();
        _isLoading = false;
      });
    }
  }

  void _openReplyDialog(SupportMessage msg) {
    final replyCtrl = TextEditingController();

    showDialog(
      context: context,
      // 1. RENAME 'context' to 'dialogContext' to prevent shadowing
      builder: (dialogContext) => AlertDialog(
        title: Text('Reply to ${msg.senderName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Subject: Re: ${msg.subject}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 16.h),
            TextField(
              controller: replyCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Type your response...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              // 2. CAPTURE the ScaffodMessenger/Context BEFORE the async gap
              //    We use 'context' (Screen scope), NOT 'dialogContext'.
              final messenger = ScaffoldMessenger.of(context);

              // Close the dialog using the dialog's context
              Navigator.pop(dialogContext);

              // Perform the async operation
              await _repo.replyToMessage(msg.id, replyCtrl.text);

              // 3. CHECK MOUNTED property of the STATE (not context)
              //    This guards the _loadMessages() call which uses setState.
              if (!mounted) return;

              // 4. USE CAPTURED MESSENGER
              //    Using the variable we captured earlier is safe.
              messenger.showSnackBar(
                  const SnackBar(content: Text('Response Sent')));

              _loadMessages();
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Support Inbox')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _messages.isEmpty
          ? const Center(child: Text('No pending inquiries'))
          : ListView.separated(
        padding: EdgeInsets.all(16.w),
        itemCount: _messages.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final msg = _messages[index];
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(msg.senderName[0],
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold)),
            ),
            title: Text(msg.subject,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${msg.senderName} <${msg.email}>',
                    style: TextStyle(
                        fontSize: 12.sp, color: Colors.grey[600])),
                SizedBox(height: 4.h),
                Text(msg.message,
                    maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
            trailing: Text(
              DateFormat('MMM d').format(msg.receivedAt),
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            ),
            onTap: () => _openReplyDialog(msg),
          );
        },
      ),
    );
  }
}