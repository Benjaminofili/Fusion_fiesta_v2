import 'dart:convert';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_roles.dart'; // Ensure this import is present!
import '../../core/errors/app_failure.dart';
import '../../core/services/storage_service.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final StorageService _storageService;

  AuthRepositoryImpl(this._storageService);

  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  @override
  Future<User?> getCurrentUser() async {
    await _simulateNetworkDelay();
    return _storageService.getUser();
  }

  @override
  Future<User> signIn(String email, String password) async {
    await _simulateNetworkDelay();

    if (email.isEmpty || password.isEmpty) {
      throw AppFailure('Email and password are required.');
    }

    // --- CHANGED: Default profileCompleted to TRUE ---
    // This allows the user to land on the Event Catalog as a Visitor
    // instead of being forced immediately to the Role Upgrade screen.
    final user = User(
      id: const Uuid().v4(),
      name: email.split('@').first,
      email: email,
      role: AppRole.visitor,
      profileCompleted: true, // <--- FIX IS HERE (Was false)
    );

    return user;
  }

  @override
  Future<User> signUp(User user, String password) async {
    await _simulateNetworkDelay();
    if (password.length < 6) {
      throw AppFailure('Password must be at least 6 characters.');
    }
    return user;
  }

  @override
  Future<void> signOut() async {
    await _simulateNetworkDelay();
  }
}