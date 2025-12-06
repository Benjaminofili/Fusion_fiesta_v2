import 'dart:async';
import 'package:uuid/uuid.dart';
import '../data/models/event.dart';
import '../data/models/registration.dart';
import '../data/repositories/event_repository.dart';
import '../app/di/service_locator.dart'; // To access NotificationService
import '../../core/services/notification_service.dart';

class MockEventRepository implements EventRepository {
  final _eventController = StreamController<List<Event>>.broadcast();
  final _registrationController = StreamController<List<String>>.broadcast(); // For Student IDs
  final _favoriteController = StreamController<List<String>>.broadcast();

  // NEW: Stream specifically for Organizer's Participant List
  final _organizerRegistrationsController = StreamController<List<Registration>>.broadcast();

  // --- 1. MOCK EVENTS DATA ---
  final List<Event> _events = [
    Event(
      id: 'event-0',
      title: 'TechViz 2025',
      description: 'Annual tech fest showcasing AI and Robotics innovations.',
      category: 'Technical',
      startTime: DateTime.now().add(const Duration(days: 2)),
      endTime: DateTime.now().add(const Duration(days: 2, hours: 4)),
      location: 'Main Auditorium',
      organizer: 'Tech Club', // In real app: organizer@fusionfiesta.dev
      registrationLimit: 100,
      registeredCount: 1,
      bannerUrl: null,
      guidelinesUrl: null,
    ),
    Event(
      id: 'event-1',
      title: 'Cultural Night',
      description: 'A night of music, dance, and drama performances.',
      category: 'Cultural',
      startTime: DateTime.now().add(const Duration(days: 5)),
      endTime: DateTime.now().add(const Duration(days: 5, hours: 5)),
      location: 'Open Air Theatre',
      organizer: 'Cultural Committee',
      registrationLimit: 200,
      registeredCount: 45,
    ),
    Event(
      id: 'event-2',
      title: 'Inter-College Football',
      description: 'The biggest football tournament of the year.',
      category: 'Sports',
      startTime: DateTime.now().add(const Duration(days: 10)),
      endTime: DateTime.now().add(const Duration(days: 10, hours: 2)),
      location: 'Sports Complex',
      organizer: 'Sports Department',
      registrationLimit: 50,
      registeredCount: 12,
    ),
  ];

  // --- 2. MOCK REGISTRATIONS (Objects instead of Map) ---
  final List<Registration> _allRegistrations = [
    // Seed one sample registration
    Registration(
      id: 'reg-1',
      eventId: 'event-0',
      userId: 'student-1', // Matches mock student
      status: 'pending',   // Initial status
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  final Map<String, Set<String>> _favorites = {};

  MockEventRepository() {
    // Simulate a new event appearing after 10 seconds (Dashboard Real-time Test)
    Future.delayed(const Duration(seconds: 10), () {
      final newEvent = Event(
        id: 'event-new',
        title: '🔥 Pop-up Workshop',
        description: 'Surprise workshop on Flutter!',
        category: 'Technical',
        startTime: DateTime.now().add(const Duration(days: 1)),
        endTime: DateTime.now().add(const Duration(days: 1, hours: 4)),
        location: 'Lab 3',
        organizer: 'Tech Club',
        registrationLimit: 30,
        registeredCount: 0,
      );
      _events.insert(0, newEvent);
      _eventController.add(List.from(_events));
    });
  }

  // --- STREAMS ---

  @override
  Stream<List<Event>> getEventsStream() async* {
    yield List.from(_events);
    yield* _eventController.stream;
  }

  @override
  Stream<List<String>> getRegisteredEventIdsStream(String userId) async* {
    // Initial emit
    yield _getIdsForUser(userId);
    // Listen for updates
    yield* _registrationController.stream.map((_) => _getIdsForUser(userId));
  }

  List<String> _getIdsForUser(String userId) {
    return _allRegistrations
        .where((r) => r.userId == userId && r.status != 'cancelled')
        .map((r) => r.eventId)
        .toList();
  }

  @override
  Stream<List<Registration>> getEventRegistrationsStream(String eventId) async* {
    yield _getRegistrationsForEvent(eventId);
    yield* _organizerRegistrationsController.stream.map((_) => _getRegistrationsForEvent(eventId));
  }

  List<Registration> _getRegistrationsForEvent(String eventId) {
    return _allRegistrations.where((r) => r.eventId == eventId).toList();
  }

  @override
  Stream<List<String>> getFavoriteEventIdsStream(String userId) async* {
    yield _favorites[userId]?.toList() ?? [];
    yield* _favoriteController.stream.map((_) => _favorites[userId]?.toList() ?? []);
  }

  @override
  Future<Event> getEvent(String id) async => _events.firstWhere((e) => e.id == id);

  // --- STUDENT ACTIONS ---

  @override
  Future<void> registerForEvent(String eventId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // 1. Check constraints
    final eventIndex = _events.indexWhere((e) => e.id == eventId);
    if (eventIndex != -1) {
      final event = _events[eventIndex];
      if (event.registrationLimit != null && event.registeredCount >= event.registrationLimit!) {
        throw Exception("Event is full");
      }

      // 2. Update Event Count
      _events[eventIndex] = event.copyWith(registeredCount: event.registeredCount + 1);
      _eventController.add(List.from(_events));
    }

    // 3. Create Registration Entry
    final newReg = Registration(
      id: const Uuid().v4(),
      eventId: eventId,
      userId: userId,
      status: 'pending', // Default status is pending approval
      createdAt: DateTime.now(),
    );
    _allRegistrations.add(newReg);

    _notifyRegistrationUpdates();
  }

  @override
  Future<void> cancelRegistration(String eventId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // 1. Remove Registration
    _allRegistrations.removeWhere((r) => r.eventId == eventId && r.userId == userId);

    // 2. Update Event Count
    final eventIndex = _events.indexWhere((e) => e.id == eventId);
    if (eventIndex != -1) {
      final event = _events[eventIndex];
      if (event.registeredCount > 0) {
        _events[eventIndex] = event.copyWith(registeredCount: event.registeredCount - 1);
        _eventController.add(List.from(_events));
      }
    }

    _notifyRegistrationUpdates();
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
    _events.insert(0, event); // Add to top
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

  @override
  Future<void> updateRegistrationStatus(String registrationId, String newStatus) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _allRegistrations.indexWhere((r) => r.id == registrationId);
    if (index != -1) {
      _allRegistrations[index] = _allRegistrations[index].copyWith(status: newStatus);
      _notifyRegistrationUpdates();
    }
  }

  @override
  Future<void> markAttendance(String eventId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Find the specific registration
    final index = _allRegistrations.indexWhere(
            (r) => r.eventId == eventId && r.userId == userId
    );

    if (index == -1) {
      throw Exception("Student not registered for this event.");
    }

    // Update status to 'attended'
    _allRegistrations[index] = _allRegistrations[index].copyWith(status: 'attended');
    _notifyRegistrationUpdates();
  }

  @override
  Future<void> broadcastAnnouncement(String eventId, String title, String message) async {
    await Future.delayed(const Duration(seconds: 1));

    // 1. Find the event name for context
    final event = _events.firstWhere((e) => e.id == eventId);

    // 2. Find all registered students
    final recipients = _allRegistrations
        .where((r) => r.eventId == eventId && r.status != 'rejected')
        .map((r) => r.userId)
        .toList();

    // 3. Send Notification to each (Simulated via NotificationService)
    final notifService = serviceLocator<NotificationService>();

    // In a real backend, you'd loop through FCM tokens.
    // Here we just trigger a local notification to simulate the Organizer "seeing" it works.
    await notifService.showNotification(
      title: '📢 Announcement: ${event.title}',
      body: message,
    );

    // Note: In a real app, this would also add to a persistent "Announcements" collection.
  }

  // --- HELPERS ---

  void _notifyRegistrationUpdates() {
    _registrationController.add([]); // Updates Student "My Schedule"
    _organizerRegistrationsController.add([]); // Updates Organizer "Participants List"
  }

  @override
  Future<int> getCertificateCount(String userId) async => 3;

  @override
  Future<int> getFeedbackCount(String userId) async => 5;

  void dispose() {
    _eventController.close();
    _registrationController.close();
    _favoriteController.close();
    _organizerRegistrationsController.close();
  }
}