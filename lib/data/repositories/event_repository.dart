import '../models/event.dart';
import '../models/registration.dart';
import '../models/feedback_entry.dart';

abstract class EventRepository {
  // Real-time stream of events
  Stream<List<Event>> getEventsStream();

  Future<Event> getEvent(String id);

  // --- USER INTERACTION STREAMS ---
  Stream<List<String>> getRegisteredEventIdsStream(String userId);
  Stream<List<String>> getFavoriteEventIdsStream(String userId);

  // For counters (Simulated for now, can be real streams later)
  Future<int> getCertificateCount(String userId);
  Future<int> getFeedbackCount(String userId);

  // Actions
  Future<void> registerForEvent(String eventId, String userId);
  Future<void> cancelRegistration(String eventId, String userId);
  Future<void> toggleFavorite(String eventId, String userId); // Added this

  // --- NEW: ORGANIZER ACTIONS ---
  Future<void> createEvent(Event event);
  Future<void> updateEvent(Event event);
  Future<void> deleteEvent(String eventId);
  Stream<List<Registration>> getEventRegistrationsStream(String eventId);
  Future<void> updateRegistrationStatus(String registrationId, String newStatus);
  Future<void> markAttendance(String eventId, String userId);
  Future<void> broadcastAnnouncement(String eventId, String title, String message);
  Future<List<Map<String, String>>> getCommunicationLogs();
  Future<void> submitFeedback(FeedbackEntry feedback);
  Future<List<FeedbackEntry>> getFeedbackForEvent(String eventId);

}