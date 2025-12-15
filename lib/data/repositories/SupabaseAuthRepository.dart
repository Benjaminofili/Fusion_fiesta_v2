import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../core/errors/app_failure.dart'; // Make sure this path matches your project
import '../models/user.dart';
import '../../core/constants/app_roles.dart'; // Import your AppRole enum
import '../repositories/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  final supabase.SupabaseClient _supabase;

  SupabaseAuthRepository(this._supabase);

  @override
  Future<User?> getCurrentUser() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null || session.user.id.isEmpty) {
        return null;
      }

      // Fetch from 'profiles' table
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', session.user.id)
          .single();

      return _mapToUser(data);
    } catch (e) {
      // If profile fetch fails (e.g. network), return null or throw depending on preference
      return null;
    }
  }

  @override
  Future<User> signIn(String email, String password) async {
    try {
      // 1. Authenticate with Supabase Auth
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AppFailure('Sign in failed: User is null');
      }

      // 2. Fetch the detailed profile from Postgres 'profiles' table
      final profileData = await _supabase
          .from('profiles')
          .select()
          .eq('id', response.user!.id)
          .single();

      return _mapToUser(profileData);
    } on supabase.AuthException catch (e) {
      throw AppFailure(e.message);
    } catch (e) {
      throw AppFailure('Login failed: $e');
    }
  }

  @override
  Future<User> signUp(User user, String password) async {
    try {
      // 1. Create Auth User
      final response = await _supabase.auth.signUp(
        email: user.email,
        password: password,
        data: {
          'full_name': user.name, // Stored in auth metadata as backup
          'role': user.role.name,
        },
      );

      if (response.user == null) {
        throw AppFailure('Sign up failed: User creation returned null');
      }

      final userId = response.user!.id;

      // 2. Insert into 'profiles' table (Mapping CamelCase -> snake_case)
      final profileData = {
        'id': userId,
        'email': user.email,
        'name': user.name,
        'role': user.role.name,
        'department': user.department,
        'mobile_number': user.mobileNumber,
        'enrollment_number': user.enrolmentNumber, // Mapped correctly
        'profile_picture_url': user.profilePictureUrl,
        'college_id_url': user.collegeIdUrl,
        'is_approved': user.isApproved,
        'profile_completed': user.profileCompleted,
      };

      await _supabase.from('profiles').insert(profileData);

      // Return the user with the new ID
      return user.copyWith(id: userId);
    } on supabase.AuthException catch (e) {
      throw AppFailure(e.message);
    } catch (e) {
      throw AppFailure('Sign up failed: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw AppFailure('Logout failed: $e');
    }
  }

  @override
  Future<void> changePassword(
      String email, String currentPassword, String newPassword) async {
    try {
      // Supabase v2 requires verify logic or just update if session is active
      // For security, we usually re-login to verify old password first
      await _supabase.auth.signInWithPassword(
        email: email,
        password: currentPassword,
      );

      await _supabase.auth.updateUser(
        supabase.UserAttributes(password: newPassword),
      );
    } on supabase.AuthException catch (e) {
      throw AppFailure(e.message);
    } catch (e) {
      throw AppFailure('Password change failed: $e');
    }
  }

  // Add this inside SupabaseAuthRepository class
  @override
  Future<User> signInAsGuest() async {
    // We do NOT create a session in Supabase for guests to save money/resources.
    // We just return a local 'Visitor' user.
    return const User(
      id: 'guest',
      name: 'Guest Visitor',
      email: '',
      role: AppRole.visitor,
      profileCompleted: true,
      isApproved: true,
    );
  }

  /// Helper to safely map Database JSON (snake_case) to User Model (camelCase)
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
      enrolmentNumber: data['enrollment_number'], // Handles snake_case from DB
      profilePictureUrl: data['profile_picture_url'],
      collegeIdUrl: data['college_id_url'],
      isApproved: data['is_approved'] ?? false,
      profileCompleted: data['profile_completed'] ?? false,
    );
  }
}