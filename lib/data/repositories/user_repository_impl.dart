import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

import '../../core/errors/app_failure.dart';
import '../../core/constants/app_roles.dart';
import '../models/user.dart';
import 'user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final supabase.SupabaseClient _supabase = supabase.Supabase.instance.client;

  @override
  Future<User> getUser(String userId) async {
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return _mapToUser(data);
    } catch (e) {
      throw AppFailure('Failed to fetch profile: $e');
    }
  }

  @override
  Stream<User?> getUserStream(String userId) {
    return _supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .map((data) {
      if (data.isEmpty) return null;
      return _mapToUser(data.first);
    });
  }

  @override
  Future<User> updateUser(User user, {File? newProfileImage}) async {
    try {
      String? profileImageUrl = user.profilePictureUrl;

      // 1. Upload new image if provided
      if (newProfileImage != null) {
        profileImageUrl = await _uploadImage(user.id, newProfileImage);
      }

      // 2. Prepare data (Snake_case for DB)
      final updates = {
        'name': user.name,
        'mobile_number': user.mobileNumber,
        'department': user.department,
        'enrollment_number': user.enrolmentNumber, // DOUBLE 'L' to match DB
        'profile_picture_url': profileImageUrl,
        'profile_completed': true,
      };

      // 3. Update 'profiles' table
      final data = await _supabase
          .from('profiles')
          .update(updates)
          .eq('id', user.id)
          .select()
          .single();

      return _mapToUser(data);
    } catch (e) {
      throw AppFailure('Failed to update profile: $e');
    }
  }

  // --- NEW: Implement fetchUsers ---
  @override
  Future<List<User>> fetchUsers() async {
    try {
      // Fetch all profiles, ordered by name
      final List<dynamic> data = await _supabase
          .from('profiles')
          .select()
          .order('name', ascending: true);

      return data.map((json) => _mapToUser(json)).toList();
    } catch (e) {
      throw AppFailure('Failed to fetch users: $e');
    }
  }

  // --- NEW: Implement getUsersStream ---
  @override
  Stream<List<User>> getUsersStream() {
    try {
      return _supabase
          .from('profiles')
          .stream(primaryKey: ['id'])
          .order('name', ascending: true)
          .map((data) => data.map((json) => _mapToUser(json)).toList());
    } catch (e) {
      // Streams can't easily throw AppFailure, so we return an empty stream or rethrow
      // Often better to just return the stream and let the UI handle errors
      return Stream.error(AppFailure('Stream error: $e'));
    }
  }

  /// Helper to upload image to Supabase Storage
  Future<String> _uploadImage(String userId, File file) async {
    try {
      final fileExt = path.extension(file.path);
      final fileName = '$userId/avatar_${const Uuid().v4()}$fileExt';

      await _supabase.storage.from('user_uploads').upload(
        fileName,
        file,
        fileOptions: const supabase.FileOptions(upsert: true),
      );

      return _supabase.storage.from('user_uploads').getPublicUrl(fileName);
    } catch (e) {
      throw AppFailure('Image upload failed: $e');
    }
  }

  /// Helper to map DB JSON to User model
  User _mapToUser(Map<String, dynamic> data) {
    return User(
      id: data['id'],
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: AppRole.values.firstWhere(
            (e) => e.name == data['role'],
        orElse: () => AppRole.visitor,
      ),
      department: data['department'],
      mobileNumber: data['mobile_number'],
      enrolmentNumber: data['enrollment_number'], // Handle Double L
      profilePictureUrl: data['profile_picture_url'],
      collegeIdUrl: data['college_id_url'],
      isApproved: data['is_approved'] ?? false,
      profileCompleted: data['profile_completed'] ?? false,
    );
  }
}