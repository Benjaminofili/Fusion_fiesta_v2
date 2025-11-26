import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // 1. Import GoRouter

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/constants/app_routes.dart'; // 2. Import Routes
import '../../../../../core/widgets/event_card.dart';
import '../../../../../core/widgets/filter_chip_group.dart';
import '../../../../../core/widgets/global_search_bar.dart';
import '../../../../../data/models/event.dart';
import '../../../../../data/repositories/event_repository.dart';

class EventCatalogScreen extends StatefulWidget {
  const EventCatalogScreen({super.key});

  @override
  State<EventCatalogScreen> createState() => _EventCatalogScreenState();
}

class _EventCatalogScreenState extends State<EventCatalogScreen> {
  final EventRepository _eventRepository = serviceLocator<EventRepository>();
  String _activeFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlobalSearchBar(
            hintText: 'Search events, categories, organizers...',
            onSearch: (query) async {
              final events = await _eventRepository.getEventsStream().first;
              return events
                  .where((event) =>
                  event.title.toLowerCase().contains(query.toLowerCase()))
                  .take(5)
                  .map((e) => e.title)
                  .toList();
            },
            onSubmit: (_) {},
          ),
          const SizedBox(height: AppSizes.md),
          FilterChipGroup(
            filters: const ['All', 'Technical', 'Cultural', 'Sports'],
            activeFilter: _activeFilter,
            onSelected: (value) => setState(() => _activeFilter = value),
          ),
          const SizedBox(height: AppSizes.md),
          Expanded(
            child: StreamBuilder<List<Event>>( // Changed to StreamBuilder for real-time updates
              stream: _eventRepository.getEventsStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Filter Logic
                final events = snapshot.data!.where((event) {
                  if (_activeFilter == 'All') return true;
                  return event.category == _activeFilter;
                }).toList();

                if (events.isEmpty) {
                  return const Center(child: Text("No events found"));
                }

                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: EventCard(
                      event: events[index],
                      // 3. FIX: Navigate to Details
                      onTap: () {
                        context.push(
                          '${AppRoutes.events}/details',
                          extra: events[index],
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}