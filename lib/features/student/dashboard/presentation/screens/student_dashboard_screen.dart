import 'package:flutter/material.dart';

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/widgets/event_card.dart';
import '../../../../../core/widgets/stat_tile.dart';
import '../../../../../data/models/event.dart';
import '../../../../../data/repositories/event_repository.dart';

class StudentDashboardScreen extends StatelessWidget {
  StudentDashboardScreen({super.key});

  final EventRepository _eventRepository = serviceLocator<EventRepository>();

  Future<List<Event>> _loadEvents() => _eventRepository.fetchEvents();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome back!',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSizes.md),
          const Row(
            children: [
              Expanded(
                child: StatTile(
                  label: 'Upcoming',
                  value: '04',
                  icon: Icons.event,
                  color: Colors.deepPurple,
                ),
              ),
              SizedBox(width: AppSizes.md),
              Expanded(
                child: StatTile(
                  label: 'Registered',
                  value: '12',
                  icon: Icons.badge,
                  color: Colors.teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          Text('Recommended for you',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSizes.sm),
          FutureBuilder(
            future: _loadEvents(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return Column(
                children: snapshot.data!
                    .map((event) => EventCard(event: event, onTap: () {}))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

