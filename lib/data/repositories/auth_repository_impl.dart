import 'package:uuid/uuid.dart';
import '../../core/constants/app_roles.dart';
import '../../core/errors/app_failure.dart';
import '../../core/services/storage_service.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';

// --- MOCK DATABASE (Persistent in Memory) ---
// This acts as your backend database.
final Map<String, User> mockUserDatabase = {};

class AuthRepositoryImpl implements AuthRepository {
  final StorageService _storageService;

  AuthRepositoryImpl(this._storageService);

  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 600));
  }

  @override
  Future<User?> getCurrentUser() async {
    // Check local storage first (Session persistence)
    return _storageService.getUser();
  }

  @override
  Future<User> signIn(String email, String password) async {
    await _simulateNetworkDelay();

    // 1. STRICT VALIDATION: Check if user exists in our "Backend"
    if (!mockUserDatabase.containsKey(email)) {
      throw AppFailure('User not found. Please register first.');
    }

    final user = mockUserDatabase[email]!;

    // 2. Simple Password Check (Mock)
    // In a real app, you would hash and compare.
    if (password != 'password' && password != 'guest123') {
      // You can add logic here to store passwords in the mock DB too if you want
    }

    return user;
  }

  // --- NEW: Dynamic Guest Generation ---
  // This method creates a temporary unique user every time
  Future<User> signInAsGuest() async {
    await _simulateNetworkDelay();

    final uniqueId = const Uuid().v4();
    final guestUser = User(
      id: uniqueId,
      name: 'Guest User',
      email: 'guest_$uniqueId@temp.com', // Unique pseudo-email
      role: AppRole.visitor,
      profileCompleted: true, // Guests don't need profile setup
    );

    // Save to Mock DB so we can "Upgrade" this specific user later
    mockUserDatabase[guestUser.email] = guestUser;

    return guestUser;
  }

  @override
  Future<User> signUp(User user, String password) async {
    await _simulateNetworkDelay();

    if (mockUserDatabase.containsKey(user.email)) {
      throw AppFailure('User already exists. Please login.');
    }

    // Save to Mock DB
    mockUserDatabase[user.email] = user;

    return user;
  }

  @override
  Future<void> signOut() async {
    await _simulateNetworkDelay();
    // We do NOT clear mockUserDatabase (Backend data persists)
    // The Service layer will handle clearing local storage
  }
}