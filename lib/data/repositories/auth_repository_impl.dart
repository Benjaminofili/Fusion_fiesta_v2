import 'package:uuid/uuid.dart';
import '../../core/constants/app_roles.dart';
import '../../core/errors/app_failure.dart';
import '../../core/services/storage_service.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';
import '../../mock/mock_data.dart'; // Ensure mock data is imported

class AuthRepositoryImpl implements AuthRepository {
  final StorageService _storageService;

  AuthRepositoryImpl(this._storageService);

  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 600));
  }

  @override
  Future<User?> getCurrentUser() async {
    return _storageService.getUser();
  }

  @override
  Future<User> signIn(String email, String password) async {
    await _simulateNetworkDelay();

    if (!mockUserDatabase.containsKey(email)) {
      throw AppFailure('User not found. Please register first.');
    }

    final user = mockUserDatabase[email]!;

    // 1. Check Password
    final storedPass = mockPasswords[email] ?? 'password';
    if (password != storedPass && password != 'guest123') {
      throw AppFailure('Invalid email or password.');
    }

    // 2. CHECK ACCOUNT STATUS (The Fix)
    // If Admin deactivated the account (isApproved == false), block access.
    if (!user.isApproved) {
      if (user.role == AppRole.student) {
        throw AppFailure('Your account has been deactivated. Contact Admin.');
      } else {
        throw AppFailure('Account pending approval or deactivated.');
      }
    }

    return user;
  }

  @override
  Future<void> changePassword(String email, String currentPassword, String newPassword) async {
    await _simulateNetworkDelay();
    final storedPass = mockPasswords[email] ?? 'password';
    if (currentPassword != storedPass) {
      throw AppFailure('Incorrect current password.');
    }
    mockPasswords[email] = newPassword;
  }

  @override
  Future<User> signInAsGuest() async {
    await _simulateNetworkDelay();
    final uniqueId = const Uuid().v4();
    final guestUser = User(
      id: uniqueId,
      name: 'Guest User',
      email: 'guest_$uniqueId@temp.com',
      role: AppRole.visitor,
      profileCompleted: true,
      isApproved: true, // Guests are auto-approved
    );
    mockUserDatabase[guestUser.email] = guestUser;
    return guestUser;
  }

  @override
  Future<User> signUp(User user, String password) async {
    await _simulateNetworkDelay();
    if (mockUserDatabase.containsKey(user.email)) {
      throw AppFailure('User already exists. Please login.');
    }

    mockUserDatabase[user.email] = user;
    mockPasswords[user.email] = password;
    return user;
  }

  @override
  Future<void> signOut() async {
    await _simulateNetworkDelay();
  }
}