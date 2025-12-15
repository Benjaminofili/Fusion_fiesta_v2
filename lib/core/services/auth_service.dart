import 'dart:async';
import 'package:flutter/foundation.dart'; // Required for ChangeNotifier
import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';
import 'storage_service.dart';

class AuthService extends ChangeNotifier {
  AuthService(this._repository, this._storageService);

  final AuthRepository _repository;
  final StorageService _storageService;

  User? _currentUser;

  // Keep StreamController for backward compatibility (e.g. ProfileScreen)
  final _userController = StreamController<User?>.broadcast();
  Stream<User?> get userStream => _userController.stream;

  // CHANGED: Synchronous getter for GoRouter
  User? get currentUser => _currentUser;

  // NEW: Initialize method to load user from disk on startup
  Future<void> init() async {
    final storedUser = await _storageService.getUser();
    if (storedUser != null) {
      _currentUser = storedUser;
      _userController.add(_currentUser);
      notifyListeners();
    }
  }

  Future<User> signIn(String email, String password) async {
    final user = await _repository.signIn(email, password);
    await _updateSession(user);
    return user;
  }

  // FIXED: Removed the type check
  Future<void> loginAsGuest() async {
    final guest = await _repository.signInAsGuest();
    await _updateSession(guest);
  }

  Future<User> signUp(User user, String password) async {
    final signedUpUser = await _repository.signUp(user, password);
    await _updateSession(signedUpUser);
    return signedUpUser;
  }

  Future<void> updateUserSession(User updatedUser) async {
    await _updateSession(updatedUser);
  }

  Future<void> signOut() async {
    await _repository.signOut();
    _currentUser = null;
    await _storageService.clearUser();

    _userController.add(null); // Update streams
    notifyListeners();         // Update Router
  }

  // Helper to centralize session saving
  Future<void> _updateSession(User user) async {
    _currentUser = user;
    await _storageService.saveUser(user);

    _userController.add(user); // Update streams
    notifyListeners();         // Update Router
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    final user = _currentUser;
    if (user == null) throw Exception('No user logged in');

    await _repository.changePassword(user.email, currentPassword, newPassword);
  }

  @override
  void dispose() {
    _userController.close();
    super.dispose();
  }
}