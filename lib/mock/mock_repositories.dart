import 'package:uuid/uuid.dart';

import '../core/constants/app_roles.dart';
import '../data/models/event.dart';
import '../data/models/gallery_item.dart';
import '../data/models/user.dart';
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

  final List<GalleryItem> _gallery = List.generate(
    5,
    (index) => GalleryItem(
      id: 'gallery-$index',
      eventId: 'event-${index % 3}',
      mediaType: 'image',
      url: 'https://picsum.photos/id/${index + 20}/400',
      favoriteCount: 10 * index,
    ),
  );

  @override
  Future<Event> getEvent(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return _events.firstWhere((event) => event.id == id);
  }

  @override
  Future<List<Event>> fetchEvents() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return _events;
  }

  @override
  Future<List<GalleryItem>> fetchGallery() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return _gallery;
  }
}

