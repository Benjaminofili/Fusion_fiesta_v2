import 'dart:async';
import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';
import 'storage_service.dart';

class AuthService {
  AuthService(this._repository, this._storageService);

  final AuthRepository _repository;
  final StorageService _storageService;

  User? _currentUser; // In-memory cache

  // --- NEW: Stream Controller to notify UI of changes ---
  final _userController = StreamController<User?>.broadcast();

  // Expose the stream for the UI to listen to
  Stream<User?> get userStream => _userController.stream;

  Future<User?> get currentUser async {
    if (_currentUser != null) return _currentUser;
    _currentUser = _storageService.getUser();
    if (_currentUser != null) {
      // Ensure stream gets the initial value
      _userController.add(_currentUser);
      return _currentUser;
    }
    _currentUser = await _repository.getCurrentUser();
    _userController.add(_currentUser); // Notify listeners
    return _currentUser;
  }

  Future<User> signIn(String email, String password) async {
    final user = await _repository.signIn(email, password);
    _currentUser = user;
    await _storageService.saveUser(user);
    _userController.add(user); // 🔔 Notify: User Logged In
    return user;
  }

  Future<User> signUp(User user, String password) async {
    final signedUpUser = await _repository.signUp(user, password);
    _currentUser = signedUpUser;
    await _storageService.saveUser(signedUpUser);
    _userController.add(signedUpUser); // 🔔 Notify: User Signed Up
    return signedUpUser;
  }

  Future<void> signOut() async {
    await _repository.signOut();
    _currentUser = null;
    await _storageService.clearUser();
    _userController.add(null); // 🔔 Notify: User Logged Out
  }

  Future<void> updateUserSession(User updatedUser) async {
    _currentUser = updatedUser;
    await _storageService.saveUser(updatedUser);
    _userController.add(updatedUser); // 🔔 Notify: Role Changed!
  }

  void dispose() {
    _userController.close();
  }
}