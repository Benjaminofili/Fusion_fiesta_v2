import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Optional animation
import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_routes.dart';
import '../../../../../data/models/gallery_item.dart';
import '../../../../../data/repositories/gallery_repository.dart';

class SavedMediaScreen extends StatefulWidget {
  const SavedMediaScreen({super.key});

  @override
  State<SavedMediaScreen> createState() => _SavedMediaScreenState();
}

class _SavedMediaScreenState extends State<SavedMediaScreen> {
  final GalleryRepository _repository = serviceLocator<GalleryRepository>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Saved Memories', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.textPrimary),
      ),
      // Use StreamBuilder for Real-Time Updates
      body: StreamBuilder<List<GalleryItem>>(
        stream: _repository.getGalleryStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          // Filter for favorites locally
          final savedItems = snapshot.data!.where((item) => item.isFavorite).toList();

          if (savedItems.isEmpty) {
            return _buildEmptyState();
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: savedItems.length,
            itemBuilder: (context, index) {
              final item = savedItems[index];
              return _SavedItemCard(
                item: item,
                onTap: () => context.push('${AppRoutes.gallery}/view', extra: item),
                onRemove: () => _repository.toggleFavorite(item.id),
              ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No saved media yet',
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.go(AppRoutes.gallery),
            child: const Text('Browse Gallery'),
          ),
        ],
      ),
    );
  }
}

class _SavedItemCard extends StatelessWidget {
  final GalleryItem item;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _SavedItemCard({
    required this.item,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              item.url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.grey[200]),
            ),
          ),

          // Gradient Overlay
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                ),
              ),
            ),
          ),

          // Remove Button (Top Right)
          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 2,
              child: InkWell(
                onTap: onRemove,
                customBorder: const CircleBorder(),
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.close, size: 16, color: Colors.black),
                ),
              ),
            ),
          ),

          // Caption (Bottom)
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Text(
              item.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}