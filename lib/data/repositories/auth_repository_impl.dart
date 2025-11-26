import 'dart:convert';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_roles.dart';
import '../../core/errors/app_failure.dart';
import '../../core/services/storage_service.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';

// --- MOCK DATABASE (Simulates Backend) ---
// Key: Email, Value: User Object
// We make this global so UserRepositoryImpl can access it too.
final Map<String, User> mockUserDatabase = {};

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

    // 1. CHECK MOCK DATABASE (The Fix)
    // If this user registered before, return their SAVED state (Participant)
    if (mockUserDatabase.containsKey(email)) {
      return mockUserDatabase[email]!;
    }

    // 2. NEW USER (Guest/Visitor Logic)
    // Only create a new visitor if they don't exist in our "Server"
    final user = User(
      id: const Uuid().v4(),
      name: email.split('@').first,
      email: email,
      role: AppRole.visitor,
      profileCompleted: true,
    );

    return user;
  }

  @override
  Future<User> signUp(User user, String password) async {
    await _simulateNetworkDelay();

    if (password.length < 6) {
      throw AppFailure('Password must be at least 6 characters.');
    }

    // 3. SAVE TO MOCK DATABASE
    // This ensures that when they log out and log back in, we remember them.
    mockUserDatabase[user.email] = user;

    return user;
  }

  @override
  Future<void> signOut() async {
    await _simulateNetworkDelay();
    // Note: We do NOT clear mockUserDatabase here.
    // That's the "Server". We only clear the local session in StorageService.
  }
}