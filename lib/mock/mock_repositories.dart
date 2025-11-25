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

class MockEventRepository implements EventRepository {
  // 1. Internal State
  final _controller = StreamController<List<Event>>.broadcast();
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
      registrationLimit: 100,
      registeredCount: 42 + index,
    ),
  );

  MockEventRepository() {
    // 2. SIMULATE REAL-TIME UPDATE
    // After 5 seconds, a new "Surprise Event" will appear automatically
    Future.delayed(const Duration(seconds: 5), () {
      final newEvent = Event(
        id: 'event-new',
        title: '🔥 Flash Photography Contest',
        description: 'Pop-up event starting soon!',
        category: 'Cultural',
        startTime: DateTime.now().add(const Duration(days: 1)),
        endTime: DateTime.now().add(const Duration(days: 1, hours: 4)),
        location: 'Campus Lawn',
        registrationLimit: 50,
        registeredCount: 0,
      );

      _events.insert(0, newEvent); // Add to top
      _controller.add(List.from(_events)); // Emit new list to active listeners
    });
  }

  // --- CHANGED TO ASYNC* TO FIX LOADING ISSUE ---
  @override
  Stream<List<Event>> getEventsStream() async* {
    // 1. Immediately yield the current list to the new listener
    yield List.from(_events);

    // 2. Then connect to the broadcast stream for future updates
    yield* _controller.stream;
  }

  @override
  Future<Event> getEvent(String id) async {
    // In a real app, this would also be a stream or fetch fresh data
    return _events.firstWhere((event) => event.id == id);
  }

  @override
  Future<List<GalleryItem>> fetchGallery() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return []; // Empty for now
  }

  void dispose() {
    _controller.close();
  }
}

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