import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart'; // Optional: Add 'photo_view' to pubspec for zoom
// If you don't want to add a package, use InteractiveViewer

import '../../../../../data/models/gallery_item.dart';

class GalleryImageViewer extends StatelessWidget {
  final GalleryItem item;

  const GalleryImageViewer({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(
            item.url,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const CircularProgressIndicator(color: Colors.white);
            },
          ),
        ),
      ),
      bottomSheet: Container(
        color: Colors.black.withOpacity(0.5),
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        child: Text(
          item.caption,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}