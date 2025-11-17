import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';

class AuthService {
  AuthService(this._repository);

  final AuthRepository _repository;

  Future<User?> get currentUser async => _repository.getCurrentUser();

  Future<User> signIn(String email, String password) =>
      _repository.signIn(email, password);

  Future<User> signUp(User user, String password) =>
      _repository.signUp(user, password);

  Future<void> signOut() => _repository.signOut();
}

