import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/di/service_locator.dart';
import '../../../../../data/models/gallery_item.dart';
import '../../../../../data/repositories/event_repository.dart';

class GalleryImageViewer extends StatefulWidget {
  final GalleryItem item;

  const GalleryImageViewer({super.key, required this.item});

  @override
  State<GalleryImageViewer> createState() => _GalleryImageViewerState();
}

class _GalleryImageViewerState extends State<GalleryImageViewer> {
  bool _isLiked = false;
  bool _showInfo = true;
  String _organizerName = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadOrganizerName();
    // Optional: Check if user has already liked this item from repository
    // _isLiked = widget.item.isFavorite;
  }

  Future<void> _loadOrganizerName() async {
    try {
      // FIX: Explicitly handle nullable string return
      final String? name = await serviceLocator<EventRepository>()
          .getOrganizerName(widget.item.uploadedBy);

      if (mounted) {
        setState(() {
          // Use 'Unknown' if the name comes back null
          _organizerName = name ?? 'Unknown';
        });
      }
    } catch (e) {
      if (mounted) setState(() => _organizerName = 'Unknown');
    }
    }

  void _toggleLike() {
    setState(() => _isLiked = !_isLiked);
    // TODO: Call repository to save/unsave to 'gallery_favorites'
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(_isLiked ? 'Saved to favorites' : 'Removed from favorites'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _shareImage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing functionality coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha:0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 20),
          ),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha:0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(_showInfo ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white, size: 20),
            ),
            onPressed: () => setState(() => _showInfo = !_showInfo),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: GestureDetector(
        onTap: () => setState(() => _showInfo = !_showInfo),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Zoomable Image View
            PhotoView(
              imageProvider: CachedNetworkImageProvider(item.url),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2.5,
              heroAttributes: PhotoViewHeroAttributes(tag: item.id),
              loadingBuilder: (context, event) => Center(
                child: CircularProgressIndicator(
                  value: event == null
                      ? null
                      : event.cumulativeBytesLoaded /
                          (event.expectedTotalBytes ?? 1),
                  color: Colors.white,
                ),
              ),
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image, color: Colors.grey, size: 64),
                    SizedBox(height: 8),
                    Text("Could not load image",
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),

            // 2. Info Overlay (Animated)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              bottom: _showInfo ? 0 : -300, // Move off-screen when hidden
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 40.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha:0.9),
                      Colors.black.withValues(alpha:0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.category.isNotEmpty ? item.category : 'Event Photo',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Row(
                                  children: [
                                    Icon(Icons.person,
                                        color: Colors.white70, size: 12.sp),
                                    SizedBox(width: 4.w),
                                    Text(
                                      _organizerName,
                                      style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12.sp),
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      dateFormat.format(item.uploadedAt),
                                      style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12.sp),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Action Buttons
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  _isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: _isLiked ? Colors.red : Colors.white,
                                  size: 24.sp,
                                ),
                                onPressed: _toggleLike,
                              ),
                              IconButton(
                                icon: Icon(Icons.share,
                                    color: Colors.white, size: 24.sp),
                                onPressed: _shareImage,
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Caption Section
                      if (item.caption.isNotEmpty) ...[
                        SizedBox(height: 12.h),
                        Text(
                          item.caption,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha:0.9),
                              fontSize: 14.sp,
                              height: 1.4),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
