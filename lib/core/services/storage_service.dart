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

  // --- NEW: Notification Preferences ---
  bool get notifyEvents => _userBox.get('notify_events', defaultValue: true);
  Future<void> setNotifyEvents(bool value) async =>
      await _userBox.put('notify_events', value);

  bool get notifyReminders =>
      _userBox.get('notify_reminders', defaultValue: true);
  Future<void> setNotifyReminders(bool value) async =>
      await _userBox.put('notify_reminders', value);

  bool get notifyPromos => _userBox.get('notify_promos', defaultValue: false);
  Future<void> setNotifyPromos(bool value) async =>
      await _userBox.put('notify_promos', value);
}
