import 'dart:async';
import '../data/models/event.dart';
import '../data/repositories/event_repository.dart';

class MockEventRepository implements EventRepository {
  final _eventController = StreamController<List<Event>>.broadcast();
  final _registrationController = StreamController<List<String>>.broadcast();
  final _favoriteController = StreamController<List<String>>.broadcast();

  // Initial Data
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
    // Simulate a new event appearing after 5 seconds
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
    yield* _registrationController.stream
        .map((_) => _registrations[userId]?.toList() ?? []);
  }

  @override
  Stream<List<String>> getFavoriteEventIdsStream(String userId) async* {
    yield _favorites[userId]?.toList() ?? [];
    yield* _favoriteController.stream
        .map((_) => _favorites[userId]?.toList() ?? []);
  }

  @override
  Future<Event> getEvent(String id) async =>
      _events.firstWhere((e) => e.id == id);

  // --- ACTIONS ---

  @override
  Future<void> registerForEvent(String eventId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _events.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      final event = _events[index];
      if (event.registrationLimit != null &&
          event.registeredCount >= event.registrationLimit!) {
        throw Exception("Event is full");
      }
    }

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

  // --- ORGANIZER ACTIONS ---

  @override
  Future<void> createEvent(Event event) async {
    await Future.delayed(const Duration(seconds: 1));
    _events.insert(0, event);
    _eventController.add(List.from(_events));
  }

  @override
  Future<void> updateEvent(Event event) async {
    await Future.delayed(const Duration(seconds: 1));
    final index = _events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      _events[index] = event;
      _eventController.add(List.from(_events));
    }
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _events.removeWhere((e) => e.id == eventId);
    _eventController.add(List.from(_events));
  }

  // --- HELPERS ---

  void _updateEventCount(String eventId, int delta) {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      _events[index] = _events[index].copyWith(
          registeredCount: _events[index].registeredCount + delta);
      _eventController.add(List.from(_events));
    }
  }

  @override
  Future<int> getCertificateCount(String userId) async => 3;

  @override
  Future<int> getFeedbackCount(String userId) async => 5;

  void dispose() {
    _eventController.close();
    _registrationController.close();
    _favoriteController.close();
  }
}