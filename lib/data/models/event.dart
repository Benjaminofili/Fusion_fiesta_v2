import 'package:equatable/equatable.dart';
import '../../core/utils/formatters.dart';

enum EventStatus { pending, approved, rejected, cancelled }

class Event extends Equatable {
  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.organizer,
    required this.organizerId,
    this.bannerUrl,
    this.guidelinesUrl,
    this.registrationLimit,
    this.registeredCount = 0,
    this.approvalStatus = EventStatus.pending, // Default to Pending
    this.coOrganizers = const [], // Team Management
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String organizer;
  final String organizerId;
  final String? bannerUrl;
  final String? guidelinesUrl;
  final int? registrationLimit;
  final int registeredCount;
  final EventStatus approvalStatus;
  final List<String> coOrganizers;

  String get scheduleLabel =>
      '${Formatters.formatDateTime(startTime)} - ${Formatters.formatDateTime(endTime)}';

  Event copyWith({
    String? title,
    String? description,
    String? category,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    String? organizer,
    String? organizerId,
    String? bannerUrl,
    String? guidelinesUrl,
    int? registrationLimit,
    int? registeredCount,
    EventStatus? approvalStatus,
    List<String>? coOrganizers,
  }) {
    return Event(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      organizer: organizer ?? this.organizer,
      organizerId: organizerId ?? this.organizerId,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      guidelinesUrl: guidelinesUrl ?? this.guidelinesUrl,
      registrationLimit: registrationLimit ?? this.registrationLimit,
      registeredCount: registeredCount ?? this.registeredCount,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      coOrganizers: coOrganizers ?? this.coOrganizers,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        category,
        startTime,
        endTime,
        location,
        organizer,
        organizerId,
        bannerUrl,
        guidelinesUrl,
        registrationLimit,
        registeredCount,
        approvalStatus,
        coOrganizers,
      ];
}
