import 'dart:async';
import 'package:uuid/uuid.dart';
import '../core/constants/app_roles.dart';
import '../data/models/user.dart';
import '../data/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  User? _currentUser;

  @override
  Future<User?> getCurrentUser() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _currentUser;
  }

  @override
  Future<User> signIn(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _currentUser = User(
      id: const Uuid().v4(),
      name: 'Student Demo',
      email: email,
      role: AppRole.student,
      profileCompleted: true,
    );
    return _currentUser!;
  }

  @override
  Future<void> changePassword(String email, String currentPassword, String newPassword) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<User> signUp(User user, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _currentUser = user;
    return user;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
  }

  @override
  Future<User> signInAsGuest() {
    // TODO: implement signInAsGuest
    throw UnimplementedError();
  }
}