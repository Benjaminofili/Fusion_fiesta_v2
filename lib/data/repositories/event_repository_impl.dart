// lib/data/repositories/event_repository_impl.dart

import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:uuid/uuid.dart';

import '../../core/errors/app_failure.dart';
import '../../core/utils/formatters.dart';
import '../models/certificate.dart';
import '../models/event.dart';
import '../models/registration.dart';
import '../models/feedback_entry.dart';
import 'event_repository.dart';

class EventRepositoryImpl implements EventRepository {
  final supabase.SupabaseClient _supabase = supabase.Supabase.instance.client;

  // --- EVENTS ---

  @override
  Stream<List<Event>> getEventsStream() {
    return _supabase
        .from('events')
        .stream(primaryKey: ['id'])
        .order('start_time', ascending: true)
        .map((data) => data.map((json) => _mapToEvent(json)).toList());
  }

  @override
  Future<Event> getEvent(String id) async {
    try {
      final data = await _supabase.from('events').select().eq('id', id).single();
      return _mapToEvent(data);
    } catch (e) {
      throw AppFailure('Failed to fetch event: $e');
    }
  }

  // --- REGISTRATIONS ---

  @override
  Stream<List<String>> getRegisteredEventIdsStream(String userId) {
    return _supabase
        .from('registrations')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((data) => data.map((json) => json['event_id'] as String).toList());
  }

  @override
  Future<void> registerForEvent(String eventId, String userId) async {
    try {
      // 1. Check if already registered
      final existing = await _supabase
          .from('registrations')
          .select()
          .eq('event_id', eventId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existing != null) return; // Already registered, do nothing

      // 2. Check Capacity
      final eventData = await _supabase
          .from('events')
          .select('registration_limit, registered_count')
          .eq('id', eventId)
          .single();

      final limit = eventData['registration_limit'] as int?;
      final count = eventData['registered_count'] as int? ?? 0;

      if (limit != null && count >= limit) {
        throw AppFailure('Event is fully booked');
      }

      // 3. Insert Registration
      await _supabase.from('registrations').insert({
        'event_id': eventId,
        'user_id': userId,
        'status': 'registered',
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw AppFailure('Registration failed: $e');
    }
  }

  @override
  Future<void> cancelRegistration(String eventId, String userId) async {
    try {
      await _supabase
          .from('registrations')
          .delete()
          .eq('event_id', eventId)
          .eq('user_id', userId);
    } catch (e) {
      throw AppFailure('Cancellation failed: $e');
    }
  }

  // --- FAVORITES ---

  @override
  Stream<List<String>> getFavoriteEventIdsStream(String userId) {
    return _supabase
        .from('favorites')
        .stream(primaryKey: ['user_id', 'event_id'])
        .eq('user_id', userId)
        .map((data) => data.map((json) => json['event_id'] as String).toList());
  }

  @override
  Future<void> toggleFavorite(String eventId, String userId) async {
    try {
      final exists = await _supabase
          .from('favorites')
          .select()
          .eq('user_id', userId)
          .eq('event_id', eventId)
          .maybeSingle();

      if (exists != null) {
        await _supabase.from('favorites').delete().eq('user_id', userId).eq('event_id', eventId);
      } else {
        await _supabase.from('favorites').insert({
          'user_id': userId,
          'event_id': eventId,
        });
      }
    } catch (e) {
      throw AppFailure('Failed to toggle favorite: $e');
    }
  }

  // --- ORGANIZER ACTIONS ---

  @override
  Future<void> createEvent(Event event) async {
    try {
      final eventData = _mapToEventJson(event);
      eventData.remove('id'); // Let DB generate ID
      await _supabase.from('events').insert(eventData);
    } catch (e) {
      throw AppFailure('Failed to create event: $e');
    }
  }

  @override
  Future<void> updateEvent(Event event) async {
    try {
      await _supabase
          .from('events')
          .update(_mapToEventJson(event))
          .eq('id', event.id);
    } catch (e) {
      throw AppFailure('Failed to update event: $e');
    }
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    try {
      await _supabase.from('events').delete().eq('id', eventId);
    } catch (e) {
      throw AppFailure('Failed to delete event: $e');
    }
  }

  @override
  Stream<List<Registration>> getEventRegistrationsStream(String eventId) {
    return _supabase
        .from('registrations')
        .stream(primaryKey: ['id'])
        .eq('event_id', eventId)
        .map((data) => data.map((json) => _mapToRegistration(json)).toList());
  }

  @override
  Future<void> updateRegistrationStatus(String registrationId, String newStatus) async {
    await _supabase.from('registrations').update({'status': newStatus}).eq('id', registrationId);
  }

  @override
  Future<void> markAttendance(String eventId, String userId) async {
    await _supabase
        .from('registrations')
        .update({'status': 'attended'})
        .eq('event_id', eventId)
        .eq('user_id', userId);
  }

  // --- COUNTERS ---

  @override
  Future<int> getCertificateCount(String userId) async {
    return await _supabase.from('certificates').count().eq('user_id', userId);
  }

  @override
  Future<int> getFeedbackCount(String userId) async {
    return await _supabase.from('feedback').count().eq('user_id', userId);
  }

  // --- PLACEHOLDERS (Future Enhancements) ---

  @override
  Future<void> broadcastAnnouncement(String eventId, String title, String message) async {}

  @override
  Future<List<Map<String, String>>> getCommunicationLogs() async => [];

  @override
  Future<void> submitFeedback(FeedbackEntry feedback) async {
    await _supabase.from('feedback').insert({
      'event_id': feedback.eventId,
      'user_id': feedback.userId,
      'rating_overall': feedback.ratingOverall,
      'comment': feedback.comment,
    });
  }

  @override
  Future<List<FeedbackEntry>> getFeedbackForEvent(String eventId) async => [];

  @override
  Future<void> generateCertificatesForEvent(String eventId, String fileUrl) async {}

  @override
  Future<List<Certificate>> getUserCertificates(String userId) async => [];

  // --- MAPPERS ---

  Event _mapToEvent(Map<String, dynamic> data) {
    return Event(
      id: data['id'],
      title: data['title'],
      description: data['description'] ?? '',
      category: data['category'] ?? 'General',
      startTime: DateTime.parse(data['start_time']),
      endTime: DateTime.parse(data['end_time']),
      location: data['location'] ?? 'TBD',
      organizer: data['organizer_id'] ?? '',
      bannerUrl: data['banner_url'],
      guidelinesUrl: data['guidelines_url'],
      registrationLimit: data['registration_limit'],
      registeredCount: data['registered_count'] ?? 0,
      approvalStatus: EventStatus.values.firstWhere(
            (e) => e.name == data['approval_status'],
        orElse: () => EventStatus.pending,
      ),
    );
  }

  Map<String, dynamic> _mapToEventJson(Event event) {
    return {
      'title': event.title,
      'description': event.description,
      'category': event.category,
      'start_time': event.startTime.toIso8601String(),
      'end_time': event.endTime.toIso8601String(),
      'location': event.location,
      'organizer_id': event.organizer,
      'banner_url': event.bannerUrl,
      'registration_limit': event.registrationLimit,
      'approval_status': event.approvalStatus.name,
    };
  }

  Registration _mapToRegistration(Map<String, dynamic> data) {
    return Registration(
      id: data['id'],
      eventId: data['event_id'],
      userId: data['user_id'],
      status: data['status'] ?? 'pending',
      createdAt: DateTime.parse(data['created_at']),
    );
  }
}