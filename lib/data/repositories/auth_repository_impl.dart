import 'dart:async'; // Required for TimeoutException
import 'dart:io'; // Required for SocketException
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../core/constants/app_roles.dart';
import '../../core/errors/app_failure.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final supabase.SupabaseClient _supabase;

  // Global timeout duration for network calls
  static const Duration _requestTimeout = Duration(seconds: 15);

  AuthRepositoryImpl(this._supabase);

  @override
  Future<User?> getCurrentUser() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null || session.user.id.isEmpty) {
        return null;
      }

      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', session.user.id)
          .single()
          .timeout(_requestTimeout);

      return _mapToUser(data);
    } catch (e) {
      // Quietly return null for startup checks so the app doesn't crash on splash
      return null;
    }
  }

  @override
  Future<User> signIn(String email, String password) async {
    try {
      // 1. Authenticate (with Timeout)
      final response = await _supabase.auth
          .signInWithPassword(
            email: email,
            password: password,
          )
          .timeout(_requestTimeout);

      if (response.user == null) {
        throw AppFailure('Sign in failed: User is null');
      }

      // 2. Fetch Profile (with Timeout)
      final profileData = await _supabase
          .from('profiles')
          .select()
          .eq('id', response.user!.id)
          .single()
          .timeout(_requestTimeout);

      final user = _mapToUser(profileData);

      // Block access for unapproved non-visitor accounts
      if (!user.isApproved && user.role != AppRole.visitor) {
        throw AppFailure(
            'Your account is pending approval by an administrator.');
      }

      return user;
    } on supabase.AuthException catch (e) {
      _handleAuthException(e);
      throw AppFailure(e.message); // Fallback
    } on TimeoutException {
      throw AppFailure(
          'Connection timed out. Please check your internet speed.');
    } on SocketException {
      throw AppFailure('No internet connection.');
    } catch (e) {
      _checkForNetworkError(e);
      throw AppFailure('Login failed: ${e.toString()}');
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
          'full_name': user.name,
          'role': user.role.name,
        },
      ).timeout(_requestTimeout);

      if (response.user == null) {
        throw AppFailure('Sign up failed: User creation returned null');
      }

      final userId = response.user!.id;

      // 2. Insert into 'profiles' table
      final profileData = {
        'id': userId,
        'email': user.email,
        'name': user.name,
        'role': user.role.name,
        'department': user.department,
        'mobile_number': user.mobileNumber,
        'enrollment_number': user.enrolmentNumber,
        'profile_picture_url': user.profilePictureUrl,
        'college_id_url': user.collegeIdUrl,
        'is_approved': user.isApproved,
        'profile_completed': user.profileCompleted,
      };

      await _supabase
          .from('profiles')
          .insert(profileData)
          .timeout(_requestTimeout);

      return user.copyWith(id: userId);
    } on supabase.AuthException catch (e) {
      _handleAuthException(e);
      throw AppFailure(e.message);
    } on supabase.PostgrestException catch (e) {
      // Handle Database Violations (Duplicate keys, etc.)
      if (e.code == '23505') {
        // Postgres code for Unique Violation
        throw AppFailure(
            'An account with this email or enrollment number already exists.');
      }
      if (e.code == '42501') {
        // Postgres code for Permission Denied (RLS)
        throw AppFailure(
            'System permission denied. You cannot create this profile.');
      }
      throw AppFailure('Database error: ${e.message}');
    } on TimeoutException {
      throw AppFailure('Sign up timed out. Please try again.');
    } catch (e) {
      _checkForNetworkError(e);
      throw AppFailure('Sign up failed: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      // Ignored
    }
  }

  @override
  Future<void> changePassword(
      String email, String currentPassword, String newPassword) async {
    try {
      // Verify old password by logging in
      await _supabase.auth
          .signInWithPassword(
            email: email,
            password: currentPassword,
          )
          .timeout(_requestTimeout);

      // Update
      await _supabase.auth
          .updateUser(
            supabase.UserAttributes(password: newPassword),
          )
          .timeout(_requestTimeout);
    } on supabase.AuthException catch (e) {
      _handleAuthException(e);
      throw AppFailure(e.message);
    } on TimeoutException {
      throw AppFailure('Request timed out.');
    } catch (e) {
      _checkForNetworkError(e);
      throw AppFailure('Password change failed: $e');
    }
  }

  @override
  Future<User> signInAsGuest() async {
    return const User(
      id: 'guest',
      name: 'Guest Visitor',
      email: '',
      role: AppRole.visitor,
      profileCompleted: true,
      isApproved: true,
    );
  }

  // --- HELPERS ---

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

  void _handleAuthException(supabase.AuthException e) {
    final msg = e.message.toLowerCase();

    if (msg.contains('invalid login credentials')) {
      throw AppFailure('Incorrect email or password.');
    }
    if (msg.contains('email not confirmed')) {
      throw AppFailure('Please verify your email address before logging in.');
    }
    if (msg.contains('user already registered')) {
      throw AppFailure('This email is already in use. Try logging in.');
    }
    if (msg.contains('weak password')) {
      throw AppFailure('Password is too weak. Please use a stronger password.');
    }
  }

  void _checkForNetworkError(Object e) {
    final msg = e.toString();
    if (msg.contains('SocketException') || msg.contains('Failed host lookup')) {
      throw AppFailure(
          'Unable to connect to server. Please check your internet connection.');
    }
  }
}
