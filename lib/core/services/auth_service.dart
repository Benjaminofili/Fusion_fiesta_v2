import 'dart:async';
import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';
// Note: Use the implementation class type if you need specific methods,
// or update the interface. For now, we will cast or update interface.
import '../../data/repositories/auth_repository_impl.dart';
import 'storage_service.dart';

class AuthService {
  AuthService(this._repository, this._storageService);

  final AuthRepository _repository;
  final StorageService _storageService;

  User? _currentUser;
  final _userController = StreamController<User?>.broadcast();

  Stream<User?> get userStream => _userController.stream;

  Future<User?> get currentUser async {
    if (_currentUser != null) return _currentUser;
    _currentUser = _storageService.getUser();
    _userController.add(_currentUser);
    return _currentUser;
  }

  Future<User> signIn(String email, String password) async {
    final user = await _repository.signIn(email, password);
    await _updateSession(user);
    return user;
  }

  // --- NEW: Handle Guest Login ---
  // Future<void> loginAsGuest() async {
  //   // We cast to Impl to access the specific method,
  //   // or you should add signInAsGuest to the abstract AuthRepository class.
  //   if (_repository is AuthRepositoryImpl) {
  //     final guest = await (_repository as AuthRepositoryImpl).signInAsGuest();
  //     await _updateSession(guest);
  //   }
  // }

  Future<void> loginAsGuest() async {
    // FIX: Removed the type check
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
    _userController.add(null);
  }

  // Helper to centralize session saving
  Future<void> _updateSession(User user) async {
    _currentUser = user;
    await _storageService.saveUser(user);
    _userController.add(user);
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    final user = _currentUser;
    if (user == null) throw Exception('No user logged in');

    await _repository.changePassword(user.email, currentPassword, newPassword);
    // No need to update session for password change, but next login will require it.
  }
  
  void dispose() {
    _userController.close();
  }
}