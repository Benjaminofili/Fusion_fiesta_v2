import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/models/gallery_item.dart';
import '../../../../../data/repositories/gallery_repository.dart';

class ModerationScreen extends StatefulWidget {
  const ModerationScreen({super.key});

  @override
  State<ModerationScreen> createState() => _ModerationScreenState();
}

class _ModerationScreenState extends State<ModerationScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Content Moderation'),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(icon: Icon(Icons.photo_library), text: 'Gallery'),
              Tab(icon: Icon(Icons.feedback), text: 'Feedback'),
              Tab(icon: Icon(Icons.workspace_premium), text: 'Certificates'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _GalleryModerationTab(),
            _FeedbackModerationTab(),
            _CertificateModerationTab(),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 1. GALLERY MODERATION TAB
// -----------------------------------------------------------------------------
class _GalleryModerationTab extends StatelessWidget {
  const _GalleryModerationTab();

  @override
  Widget build(BuildContext context) {
    final repo = serviceLocator<GalleryRepository>();

    return StreamBuilder<List<GalleryItem>>(
      stream: repo.getGalleryStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = snapshot.data!;

        if (items.isEmpty) {
          return const Center(child: Text('No media items to moderate.'));
        }

        return GridView.builder(
          padding: EdgeInsets.all(16.w),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    item.url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child:
                            const Icon(Icons.broken_image, color: Colors.grey)),
                  ),
                  // Overlay Actions
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Row(
                      children: [
                        // Highlight Button
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.white,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.star_border,
                                size: 20, color: Colors.orange),
                            tooltip: 'Highlight on Home Page',
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Item highlighted on Home Page!')),
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 8.w),
                        // Delete Button
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.white,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.delete_outline,
                                size: 20, color: Colors.red),
                            tooltip: 'Remove Content',
                            onPressed: () =>
                                _confirmDelete(context, repo, item.id),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Caption
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      color: Colors.black54,
                      child: Text(
                        item.caption,
                        style: TextStyle(color: Colors.white, fontSize: 12.sp),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, GalleryRepository repo, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove Content?'),
        content: const Text(
            'This action cannot be undone. The media will be removed from the gallery.'),
        actions: [
          TextButton(
              onPressed: () => context.pop(), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              repo.deleteMedia(id);
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Content removed successfully')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 2. FEEDBACK MODERATION TAB (Mocked)
// -----------------------------------------------------------------------------
class _FeedbackModerationTab extends StatefulWidget {
  const _FeedbackModerationTab();

  @override
  State<_FeedbackModerationTab> createState() => _FeedbackModerationTabState();
}

class _FeedbackModerationTabState extends State<_FeedbackModerationTab> {
  // Mock Data
  final List<Map<String, dynamic>> _flaggedFeedback = [
    {
      'id': '1',
      'user': 'Anonymous',
      'event': 'TechViz 2025',
      'comment':
          'This event was terrible and a waste of time. [Abusive Language]',
      'reason': 'Abusive Language',
      'date': DateTime.now().subtract(const Duration(hours: 4)),
    },
    {
      'id': '2',
      'user': 'Student-88',
      'event': 'Cultural Night',
      'comment': 'Click here for free crypto: http://spam.link',
      'reason': 'Spam / Link',
      'date': DateTime.now().subtract(const Duration(days: 1)),
    },
  ];

  void _handleAction(String id, bool isDelete) {
    setState(() {
      _flaggedFeedback.removeWhere((f) => f['id'] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            isDelete ? 'Comment deleted' : 'Comment approved and restored'),
        backgroundColor: isDelete ? AppColors.error : AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_flaggedFeedback.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline,
                size: 64, color: Colors.green[200]),
            SizedBox(height: 16.h),
            Text('No flagged feedback pending review.',
                style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: _flaggedFeedback.length,
      itemBuilder: (context, index) {
        final item = _flaggedFeedback[index];
        return Card(
          elevation: 0,
          margin: EdgeInsets.only(bottom: 12.h),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
              side: BorderSide(color: Colors.red.withValues(alpha:0.3))),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'FLAGGED: ${item['reason']}',
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 10.sp),
                      ),
                    ),
                    Text(
                      DateFormat('MMM d').format(item['date']),
                      style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  '"${item['comment']}"',
                  style:
                      TextStyle(fontSize: 14.sp, fontStyle: FontStyle.italic),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Event: ${item['event']} • User: ${item['user']}',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _handleAction(item['id'], false),
                      child: const Text('Dismiss (Keep)'),
                    ),
                    SizedBox(width: 8.w),
                    FilledButton.icon(
                      onPressed: () => _handleAction(item['id'], true),
                      style: FilledButton.styleFrom(
                          backgroundColor: AppColors.error),
                      icon: const Icon(Icons.delete_forever, size: 16),
                      label: const Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// 3. CERTIFICATE MODERATION TAB (Mocked)
// -----------------------------------------------------------------------------
class _CertificateModerationTab extends StatefulWidget {
  const _CertificateModerationTab();

  @override
  State<_CertificateModerationTab> createState() =>
      _CertificateModerationTabState();
}

class _CertificateModerationTabState extends State<_CertificateModerationTab> {
  // Mock Certificates
  final List<Map<String, String>> _certificates = [
    {
      'id': 'CERT-001',
      'event': 'TechViz 2025',
      'uploader': 'Tech Club',
      'status': 'Live'
    },
    {
      'id': 'CERT-002',
      'event': 'TechViz 2025',
      'uploader': 'Tech Club',
      'status': 'Error Reported'
    },
    {
      'id': 'CERT-005',
      'event': 'Cultural Night',
      'uploader': 'Cultural Comm.',
      'status': 'Live'
    },
  ];

  void _revokeCertificate(String id) {
    setState(() {
      _certificates.removeWhere((c) => c['id'] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Certificate Bundle Revoked.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: _certificates.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final cert = _certificates[index];
        final hasError = cert['status'] == 'Error Reported';

        return ListTile(
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
              side: BorderSide(color: AppColors.border)),
          leading: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: hasError ? Colors.orange[50] : Colors.blue[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.workspace_premium,
              color: hasError ? Colors.orange : Colors.blue,
            ),
          ),
          title: Text(cert['event']!,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('Uploaded by: ${cert['uploader']}'),
          trailing: PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'revoke') _revokeCertificate(cert['id']!);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'view',
                child: Row(children: [
                  Icon(Icons.visibility, size: 18),
                  SizedBox(width: 8),
                  Text('Preview')
                ]),
              ),
              const PopupMenuItem(
                value: 'revoke',
                child: Row(children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Revoke & Remove', style: TextStyle(color: Colors.red))
                ]),
              ),
            ],
          ),
        );
      },
    );
  }
}
