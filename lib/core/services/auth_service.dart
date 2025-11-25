import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';
import 'storage_service.dart';

class AuthService {
  AuthService(this._repository, this._storageService);

  final AuthRepository _repository;
  final StorageService _storageService;

  User? _currentUser; // In-memory cache

  Future<User?> get currentUser async {
    // 1. Check in-memory cache
    if (_currentUser != null) return _currentUser;

    // 2. Check persistent storage
    _currentUser = _storageService.getUser();
    if (_currentUser != null) return _currentUser;

    // 3. Check repository
    _currentUser = await _repository.getCurrentUser();
    return _currentUser;
  }

  Future<User> signIn(String email, String password) async {
    final user = await _repository.signIn(email, password);
    _currentUser = user;
    await _storageService.saveUser(user);
    return user;
  }

  Future<User> signUp(User user, String password) async {
    final signedUpUser = await _repository.signUp(user, password);
    _currentUser = signedUpUser;
    await _storageService.saveUser(signedUpUser);
    return signedUpUser;
  }

  Future<void> signOut() async {
    await _repository.signOut();
    _currentUser = null;
    await _storageService.clearUser();
  }

  // --- NEW METHOD FOR ROLE UPGRADE ---
  // Updates the user in Memory, Storage, and (optionally) Backend
  Future<void> updateUserSession(User updatedUser) async {
    _currentUser = updatedUser;
    await _storageService.saveUser(updatedUser);
    // Note: In a real app, you would also call _repository.updateUser(updatedUser) here
  }
}