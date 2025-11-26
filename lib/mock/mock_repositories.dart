import 'dart:async';
import 'package:uuid/uuid.dart';

import '../core/constants/app_roles.dart';
import '../data/models/event.dart';
import '../data/models/gallery_item.dart';
import '../data/models/user.dart';
import '../data/models/app_notification.dart';
import '../data/repositories/notification_repository.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/event_repository.dart';
import '../data/repositories/user_repository.dart';

// --- 1. MOCK AUTH REPOSITORY ---
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
  Future<User> signUp(User user, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _currentUser = user;
    return user;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
  }
}

// --- 2. MOCK USER REPOSITORY ---
class MockUserRepository implements UserRepository {
  final List<User> _users = [
    User(
      id: const Uuid().v4(),
      name: 'Student Demo',
      email: 'student@fusionfiesta.dev',
      role: AppRole.student,
      profileCompleted: true,
    ),
    User(
      id: const Uuid().v4(),
      name: 'Organizer Demo',
      email: 'organizer@fusionfiesta.dev',
      role: AppRole.organizer,
      profileCompleted: true,
    ),
  ];

  @override
  Future<List<User>> fetchUsers() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _users;
  }

  @override
  Future<User> updateUser(User user) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final index = _users.indexWhere((element) => element.id == user.id);
    if (index >= 0) {
      _users[index] = user;
    } else {
      _users.add(user);
    }
    return user;
  }
}

// --- 3. MOCK EVENT REPOSITORY (With Streams) ---
class MockEventRepository implements EventRepository {
  final _eventController = StreamController<List<Event>>.broadcast();
  final _registrationController = StreamController<List<String>>.broadcast();
  final _favoriteController = StreamController<List<String>>.broadcast();

  final List<Event> _events = List.generate(
    4,
        (index) => Event(
      id: 'event-$index',
      title: 'Sample Event ${index + 1}',
      description: 'Detailed description for event ${index + 1}',
      category: index.isEven ? 'Technical' : 'Cultural',
      startTime: DateTime.now().add(Duration(days: index)),
      endTime: DateTime.now().add(Duration(days: index, hours: 2)),
      location: 'Auditorium ${index + 1}',
      organizer: index.isEven ? 'Tech Club' : 'Cultural Committee',
      guidelinesUrl: index == 0 ? 'http://example.com/guide.pdf' : null,
      registrationLimit: 100,
      registeredCount: 42 + index,
    ),
  );

  final Map<String, Set<String>> _registrations = {};
  final Map<String, Set<String>> _favorites = {};

  MockEventRepository() {
    Future.delayed(const Duration(seconds: 5), () {
      final lastEvent = _events.last;
      final newEvent = Event(
        id: 'event-new',
        title: '🔥 Pop-up Event',
        description: lastEvent.description,
        category: 'Cultural',
        startTime: DateTime.now().add(const Duration(days: 1)),
        endTime: DateTime.now().add(const Duration(days: 1, hours: 4)),
        location: lastEvent.location,
        organizer: 'Student Council',
        registrationLimit: 50,
        registeredCount: 0,
      );
      _events.insert(0, newEvent);
      _eventController.add(List.from(_events));
    });
  }

  @override
  Stream<List<Event>> getEventsStream() async* {
    yield List.from(_events);
    yield* _eventController.stream;
  }

  @override
  Stream<List<String>> getRegisteredEventIdsStream(String userId) async* {
    yield _registrations[userId]?.toList() ?? [];
    yield* _registrationController.stream.map((_) => _registrations[userId]?.toList() ?? []);
  }

  @override
  Stream<List<String>> getFavoriteEventIdsStream(String userId) async* {
    yield _favorites[userId]?.toList() ?? [];
    yield* _favoriteController.stream.map((_) => _favorites[userId]?.toList() ?? []);
  }

  @override
  Future<void> registerForEvent(String eventId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // --- NEW: CAPACITY CHECK BACKEND LOGIC ---
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      final event = _events[index];
      if (event.registrationLimit != null && event.registeredCount >= event.registrationLimit!) {
        throw Exception("Event is full"); // This will be caught by UI and shown as SnackBar
      }
    }
    // -----------------------------------------

    if (!_registrations.containsKey(userId)) _registrations[userId] = {};
    _registrations[userId]!.add(eventId);

    _registrationController.add([]);
    _updateEventCount(eventId, 1);
  }

  @override
  Future<void> cancelRegistration(String eventId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_registrations.containsKey(userId)) {
      _registrations[userId]!.remove(eventId);
      _registrationController.add([]);
      _updateEventCount(eventId, -1);
    }
  }

  @override
  Future<void> toggleFavorite(String eventId, String userId) async {
    if (!_favorites.containsKey(userId)) _favorites[userId] = {};
    final favs = _favorites[userId]!;
    if (favs.contains(eventId)) {
      favs.remove(eventId);
    } else {
      favs.add(eventId);
    }
    _favoriteController.add([]);
  }

  void _updateEventCount(String eventId, int delta) {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      _events[index] = _events[index].copyWith(
          registeredCount: _events[index].registeredCount + delta
      );
      _eventController.add(List.from(_events));
    }
  }

  @override
  Future<Event> getEvent(String id) async => _events.firstWhere((e) => e.id == id);

  @override
  Future<List<GalleryItem>> fetchGallery() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return [];
  }

  @override
  Future<int> getCertificateCount(String userId) async => 3;

  @override
  Future<int> getFeedbackCount(String userId) async => 5;

  Future<List<String>> getRegisteredEventIds(String userId) async => _registrations[userId]?.toList() ?? [];

  void dispose() {
    _eventController.close();
    _registrationController.close();
    _favoriteController.close();
  }
}

// --- 4. MOCK NOTIFICATION REPOSITORY ---
class MockNotificationRepository implements NotificationRepository {
  final List<AppNotification> _notifications = [
    AppNotification(
      id: '1',
      title: 'Registration Confirmed',
      message: 'You have successfully registered for TechViz 2025.',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
    ),
    AppNotification(
      id: '2',
      title: 'Certificate Available',
      message: 'Your certificate for the Cultural Fest is ready to download.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: false,
    ),
    AppNotification(
      id: '3',
      title: 'Event Rescheduled',
      message: 'The Football Finals have been moved to Friday due to rain.',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      isRead: true,
    ),
  ];

  @override
  Future<List<AppNotification>> fetchNotifications() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _notifications;
  }

  @override
  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
  }
}