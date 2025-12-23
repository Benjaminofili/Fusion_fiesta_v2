import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart'; // Required for temp directory

import '../../core/errors/app_failure.dart';
import '../../core/constants/app_roles.dart';
import '../models/user.dart';
import 'user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final supabase.SupabaseClient _supabase = supabase.Supabase.instance.client;

  @override
  Future<User> getUser(String userId) async {
    try {
      final data =
          await _supabase.from('profiles').select().eq('id', userId).single();

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
  Future<User> updateUser(User user,
      {File? newProfileImage, File? newCollegeIdImage}) async {
    try {
      String? profileImageUrl = user.profilePictureUrl;
      String? collegeIdPath =
          user.collegeIdUrl; // We store the PATH for private files

      // 1. Upload Profile Picture (Public Bucket)
      if (newProfileImage != null) {
        profileImageUrl = await _uploadFile(
            userId: user.id,
            file: newProfileImage,
            bucketName: 'avatars',
            folder: 'profile');
      }

      // 2. Upload Student ID (Private Bucket)
      if (newCollegeIdImage != null) {
        collegeIdPath = await _uploadFile(
            userId: user.id,
            file: newCollegeIdImage,
            bucketName: 'secure_docs',
            folder: 'ids');
      }

      // 3. Prepare data
      final updates = {
        'name': user.name,
        'mobile_number': user.mobileNumber,
        'department': user.department,
        'enrollment_number': user.enrolmentNumber,
        'profile_picture_url': profileImageUrl,
        'college_id_url':
            collegeIdPath, // Stores the path (e.g. "user_id/ids/file.jpg")
        'profile_completed': true,
      };

      // 4. Update Database
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

  @override
  Future<List<User>> fetchUsers() async {
    try {
      final List<dynamic> data = await _supabase
          .from('profiles')
          .select()
          .order('name', ascending: true);
      return data.map((json) => _mapToUser(json)).toList();
    } catch (e) {
      throw AppFailure('Failed to fetch users: $e');
    }
  }

  @override
  Stream<List<User>> getUsersStream() {
    try {
      return _supabase
          .from('profiles')
          .stream(primaryKey: ['id'])
          .order('name', ascending: true)
          .map((data) => data.map((json) => _mapToUser(json)).toList());
    } catch (e) {
      return Stream.error(AppFailure('Stream error: $e'));
    }
  }

  /// Consolidated Helper to Compress & Upload
  Future<String> _uploadFile({
    required String userId,
    required File file,
    required String bucketName,
    required String folder,
  }) async {
    try {
      // A. Compress if Image
      File fileToUpload = file;
      final extension = path.extension(file.path).toLowerCase();
      if (['.jpg', '.jpeg', '.png'].contains(extension)) {
        fileToUpload = await _compressImage(file);
      }

      // B. Upload to Supabase
      final fileExt = path.extension(file.path);
      final fileName = '$userId/$folder/${const Uuid().v4()}$fileExt';

      await _supabase.storage.from(bucketName).upload(
            fileName,
            fileToUpload,
            fileOptions: const supabase.FileOptions(upsert: true),
          );

      // C. Return URL or Path
      if (bucketName == 'avatars' || bucketName == 'events') {
        // Public Buckets: Return full Web URL
        return _supabase.storage.from(bucketName).getPublicUrl(fileName);
      } else {
        // Private Buckets: Return internal path (Signed URL generated on read)
        return fileName;
      }
    } catch (e) {
      throw AppFailure('Upload failed: $e');
    }
  }

  Future<File> _compressImage(File file) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final targetPath = '${tempDir.path}/${const Uuid().v4()}.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 70, // good balance
        minWidth: 1024,
        minHeight: 1024,
      );

      return result != null ? File(result.path) : file;
    } catch (e) {
      return file; // Fallback to original if compression fails
    }
  }

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
      enrolmentNumber: data['enrollment_number'],
      profilePictureUrl: data['profile_picture_url'],
      collegeIdUrl: data['college_id_url'],
      isApproved: data['is_approved'] ?? false,
      profileCompleted: data['profile_completed'] ?? false,
    );
  }
}
