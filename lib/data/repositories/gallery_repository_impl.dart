import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:uuid/uuid.dart';
import '../../core/errors/app_failure.dart';
import '../models/gallery_item.dart';
import 'gallery_repository.dart';

class GalleryRepositoryImpl implements GalleryRepository {
  final supabase.SupabaseClient _supabase;

  GalleryRepositoryImpl(this._supabase);

  @override
  Stream<List<GalleryItem>> getGalleryStream() {
    return _supabase
        .from('gallery_items')
        .stream(primaryKey: ['id'])
        .order('uploaded_at', ascending: false)
        .map((data) => data.map((json) => GalleryItem.fromJson(json)).toList());
  }

  @override
  Future<void> uploadMedia(GalleryItem item) async {
    try {
      // 1. If the URL is a local file path, upload it to Storage first
      String finalUrl = item.url;
      final file = File(item.url);

      if (file.existsSync()) {
        final fileExt = item.url.split('.').last;
        final fileName = '${const Uuid().v4()}.$fileExt';
        final filePath = 'uploads/$fileName';

        // Upload to 'gallery_images' bucket
        await _supabase.storage.from('gallery_images').upload(
          filePath,
          file,
          fileOptions: const supabase.FileOptions(upsert: false),
        );

        // Get the public URL
        finalUrl = _supabase.storage.from('gallery_images').getPublicUrl(filePath);
      }

      // 2. Insert metadata into Database
      final itemToInsert = item.copyWith(url: finalUrl); // Use the web URL
      await _supabase.from('gallery_items').insert(itemToInsert.toJson());

    } catch (e) {
      throw AppFailure('Failed to upload media: $e');
    }
  }

  @override
  Future<void> deleteMedia(String itemId) async {
    try {
      // Note: Triggers in Supabase usually handle deleting the storage file
      // when the row is deleted, or we can do it manually here if needed.
      await _supabase.from('gallery_items').delete().eq('id', itemId);
    } catch (e) {
      throw AppFailure('Failed to delete media: $e');
    }
  }

  @override
  Future<void> toggleFavorite(String itemId) async {
    // Requires a 'gallery_favorites' table.
    // If not created yet, we can skip or implement simple local toggle.
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final exists = await _supabase
          .from('gallery_favorites')
          .select()
          .eq('user_id', userId)
          .eq('item_id', itemId)
          .maybeSingle();

      if (exists != null) {
        await _supabase.from('gallery_favorites').delete().eq('user_id', userId).eq('item_id', itemId);
      } else {
        await _supabase.from('gallery_favorites').insert({
          'user_id': userId,
          'item_id': itemId,
        });
      }
    } catch (e) {
      // Fail silently for UI toggles usually
      print('Toggle failed: $e');
    }
  }

  @override
  Future<List<GalleryItem>> getSavedMedia() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      // Fetch items joined with favorites table
      final data = await _supabase
          .from('gallery_items')
          .select('*, gallery_favorites!inner(user_id)')
          .eq('gallery_favorites.user_id', userId);

      return (data as List).map((json) {
        final item = GalleryItem.fromJson(json);
        return item.copyWith(isFavorite: true);
      }).toList();
    } catch (e) {
      return [];
    }
  }
}