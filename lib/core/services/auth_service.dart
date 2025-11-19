import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';
import 'storage_service.dart'; // 1. Import StorageService

class AuthService {
  // 2. Update constructor
  AuthService(this._repository, this._storageService);

  final AuthRepository _repository;
  final StorageService _storageService; // 3. Add StorageService

  User? _currentUser; // In-memory cache

  // 4. Enhanced getter for SplashScreen
  Future<User?> get currentUser async {
    // 1. Check in-memory cache
    if (_currentUser != null) return _currentUser;

    // 2. Check persistent storage
    _currentUser = _storageService.getUser();
    if (_currentUser != null) return _currentUser;

    // 3. As a last resort, check repository (e.g., for a "remember me" token)
    _currentUser = await _repository.getCurrentUser();
    return _currentUser;
  }

  // 5. Enhanced signIn
  Future<User> signIn(String email, String password) async {
    final user = await _repository.signIn(email, password);
    _currentUser = user; // cache in memory
    await _storageService.saveUser(user); // cache in storage
    return user;
  }

  // 6. Enhanced signUp
  Future<User> signUp(User user, String password) async {
    final signedUpUser = await _repository.signUp(user, password);
    _currentUser = signedUpUser; // cache in memory
    await _storageService.saveUser(signedUpUser); // cache in storage
    return signedUpUser;
  }

  // 7. Enhanced signOut
  Future<void> signOut() async {
    await _repository.signOut();
    _currentUser = null; // clear in-memory cache
    await _storageService.clearUser(); // clear storage
  }
}