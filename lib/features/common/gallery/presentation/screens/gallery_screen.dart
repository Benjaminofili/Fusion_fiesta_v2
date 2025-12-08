import 'dart:io'; // Required for File handling
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_roles.dart';
import '../../../../../core/constants/app_routes.dart';
import '../../../../../core/services/auth_service.dart';
import '../../../../../core/widgets/filter_chip_group.dart';
import '../../../../../data/models/gallery_item.dart';
import '../../../../../data/repositories/gallery_repository.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final GalleryRepository _galleryRepository = serviceLocator<GalleryRepository>();
  final AuthService _authService = serviceLocator<AuthService>();

  String _activeCategory = 'All';
  AppRole _userRole = AppRole.visitor;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final user = await _authService.currentUser;
    if (mounted) setState(() => _userRole = user?.role ?? AppRole.visitor);
  }

  void _onToggleFavorite(String itemId) {
    if (_userRole == AppRole.visitor) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Upgrade to Participant to save memories!'),
          action: SnackBarAction(
            label: 'Upgrade',
            textColor: Colors.white,
            onPressed: () => context.push(AppRoutes.roleUpgrade),
          ),
        ),
      );
      return;
    }
    _galleryRepository.toggleFavorite(itemId);
  }

  @override
  Widget build(BuildContext context) {
    final canUpload = _userRole == AppRole.organizer || _userRole == AppRole.admin;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Event Gallery', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (canUpload)
            IconButton(
              icon: const Icon(Icons.add_a_photo, color: AppColors.primary),
              tooltip: 'Upload Media',
              onPressed: () {
                context.push('${AppRoutes.gallery}/upload');
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            width: double.infinity,
            child: FilterChipGroup(
              filters: const ['All', 'Technical', 'Cultural', 'Sports'],
              activeFilter: _activeCategory,
              onSelected: (val) => setState(() => _activeCategory = val),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<GalleryItem>>(
              stream: _galleryRepository.getGalleryStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final items = snapshot.data!.where((item) {
                  return _activeCategory == 'All' || item.category == _activeCategory;
                }).toList();

                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo_library_outlined, size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('No media found', style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _GalleryItemCard(
                      item: item,
                      userRole: _userRole,
                      onFavorite: () => _onToggleFavorite(item.id),
                      onTap: () => context.push('${AppRoutes.gallery}/view', extra: item),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GalleryItemCard extends StatelessWidget {
  final GalleryItem item;
  final AppRole userRole;
  final VoidCallback onFavorite;
  final VoidCallback? onTap;

  const _GalleryItemCard({
    required this.item,
    required this.userRole,
    required this.onFavorite,
    this.onTap,
  });

  // --- HELPER: Handle Local File vs Network URL ---
  ImageProvider _getImageProvider(String url) {
    if (url.startsWith('http')) {
      return NetworkImage(url);
    } else {
      return FileImage(File(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. IMAGE LAYER (Updated)
            Image(
              image: _getImageProvider(item.url),
              fit: BoxFit.cover,
              loadingBuilder: (ctx, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: Colors.grey[100],
                  child: const Center(child: Icon(Icons.image, color: Colors.white)),
                );
              },
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),

            // 2. GRADIENT OVERLAY
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent
                    ],
                  ),
                ),
              ),
            ),

            // 3. CAPTION
            Positioned(
              bottom: 8,
              left: 8,
              right: 40,
              child: Text(
                item.caption,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500
                ),
              ),
            ),

            // 4. FAVORITE BUTTON
            if (userRole != AppRole.visitor)
              Positioned(
                bottom: 0,
                right: 0,
                child: IconButton(
                  icon: Icon(
                    item.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: item.isFavorite ? Colors.redAccent : Colors.white,
                    size: 22,
                  ),
                  onPressed: onFavorite,
                ),
              ),

            // 5. VIDEO INDICATOR
            if (item.mediaType == MediaType.video)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow, color: Colors.white, size: 32),
                ),
              ),
          ],
        ),
      ),
    );
  }
}