import 'package:flutter/material.dart';

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../data/models/gallery_item.dart';
import '../../../../../data/repositories/event_repository.dart';

class GalleryScreen extends StatelessWidget {
  GalleryScreen({super.key});

  final EventRepository _eventRepository = serviceLocator<EventRepository>();

  Future<List<GalleryItem>> _loadGallery() => _eventRepository.fetchGallery();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<GalleryItem>>(
      future: _loadGallery(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return GridView.builder(
          padding: const EdgeInsets.all(AppSizes.lg),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppSizes.md,
            crossAxisSpacing: AppSizes.md,
          ),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) => Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(snapshot.data![index].eventId)),
          ),
        );
      },
    );
  }
}

