import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/user.dart';

class StorageService {
  static const String _userBoxName = 'sessionBox';
  static const String _userKey = 'currentUser';
  static const String _firstLaunchKey = 'isFirstLaunch';

  late Box<dynamic> _userBox;

  Future<void> init() async {
    _userBox = await Hive.openBox(_userBoxName);
  }

  bool get isFirstLaunch {
    return _userBox.get(_firstLaunchKey, defaultValue: true);
  }

  Future<void> setFirstLaunchComplete() async {
    await _userBox.put(_firstLaunchKey, false);
  }

  Future<void> saveUser(User user) async {
    await _userBox.put(_userKey, user.toMap());
  }

  // --- THE FIX IS HERE ---
  User? getUser() {
    final dynamic userMap = _userBox.get(_userKey);

    if (userMap != null) {
      final safeMap = Map<String, dynamic>.from(userMap as Map);
      return User.fromMap(safeMap);
    }
    return null;
  }
  // -----------------------

  Future<void> clearUser() async {
    await _userBox.delete(_userKey);
  }

  Future<void> clearAll() async {
    await _userBox.clear(); // Deletes User AND First Launch Flag
  }
}