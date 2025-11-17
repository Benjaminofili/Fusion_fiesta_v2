import 'package:equatable/equatable.dart';

import '../../core/utils/formatters.dart';

class Event extends Equatable {
  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.startTime,
    required this.endTime,
    required this.location,
    this.bannerUrl,
    this.guidelinesUrl,
    this.registrationLimit,
    this.registeredCount = 0,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String? bannerUrl;
  final String? guidelinesUrl;
  final int? registrationLimit;
  final int registeredCount;

  String get scheduleLabel =>
      '${Formatters.formatDateTime(startTime)} - ${Formatters.formatDateTime(endTime)}';

  Event copyWith({
    String? title,
    String? description,
    String? category,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    String? bannerUrl,
    String? guidelinesUrl,
    int? registrationLimit,
    int? registeredCount,
  }) {
    return Event(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      guidelinesUrl: guidelinesUrl ?? this.guidelinesUrl,
      registrationLimit: registrationLimit ?? this.registrationLimit,
      registeredCount: registeredCount ?? this.registeredCount,
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
        bannerUrl,
        guidelinesUrl,
        registrationLimit,
        registeredCount,
      ];
}

