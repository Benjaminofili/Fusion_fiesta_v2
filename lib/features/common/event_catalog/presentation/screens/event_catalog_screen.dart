import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_routes.dart';
import '../../../../../core/constants/app_sizes.dart';
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

enum SortOption { newest, popular }

class _EventCatalogScreenState extends State<EventCatalogScreen> {
  final EventRepository _eventRepository = serviceLocator<EventRepository>();

  String _activeCategoryFilter = 'All';
  String _searchQuery = '';
  bool _showPastEvents = false;
  SortOption _currentSort = SortOption.newest;

  @override
  Widget build(BuildContext context) {
    // Check if we can go back (meaning we were PUSHED here, not on the main tab)
    final canGoBack = context.canPop();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // --- 1. HEADER SECTION ---
            SliverPadding(
              padding: const EdgeInsets.all(AppSizes.lg),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- NEW: CONDITIONAL BACK BUTTON ---
                      if (canGoBack) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0, right: 12.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: AppColors.textPrimary),
                              onPressed: () => context.pop(),
                            ),
                          ),
                        ),
                      ],
                      // ------------------------------------

                      // Search Bar
                      Expanded(
                        child: GlobalSearchBar(
                          hintText: 'Search events...',
                          onSearch: (query) async {
                            if (query.isEmpty) return [];
                            final events =
                                await _eventRepository.getEventsStream().first;
                            return events
                                .where((e) => e.title
                                    .toLowerCase()
                                    .contains(query.toLowerCase()))
                                .map((e) => e.title)
                                .take(5)
                                .toList();
                          },
                          onSubmit: (query) =>
                              setState(() => _searchQuery = query),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // History Button
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _showPastEvents
                                ? AppColors.primary
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.history,
                              color:
                                  _showPastEvents ? Colors.white : Colors.grey,
                            ),
                            tooltip: _showPastEvents
                                ? 'Showing Past Events'
                                : 'Show History',
                            onPressed: () => setState(
                                () => _showPastEvents = !_showPastEvents),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Active Search Indicator
                  if (_searchQuery.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Chip(
                          label: Text('Search: "$_searchQuery"'),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () => setState(() => _searchQuery = ''),
                          backgroundColor: AppColors.primary.withValues(alpha:0.1),
                        ),
                      ),
                    ),

                  const SizedBox(height: AppSizes.md),

                  // Filters & Sort Row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChipGroup(
                          filters: const [
                            'All',
                            'Technical',
                            'Cultural',
                            'Sports'
                          ],
                          activeFilter: _activeCategoryFilter,
                          onSelected: (value) =>
                              setState(() => _activeCategoryFilter = value),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: PopupMenuButton<SortOption>(
                            icon: const Icon(Icons.sort,
                                size: 20, color: AppColors.textSecondary),
                            tooltip: 'Sort Events',
                            onSelected: (value) =>
                                setState(() => _currentSort = value),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                  value: SortOption.newest,
                                  child: Text('Newest')),
                              const PopupMenuItem(
                                  value: SortOption.popular,
                                  child: Text('Popular')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSizes.md),

                  // Dynamic Section Title
                  Text(
                    _showPastEvents ? "Event History" : "Upcoming Events",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                ]),
              ),
            ),

            // --- 2. EVENT LIST STREAM ---
            // --- 2. EVENT LIST STREAM ---
            StreamBuilder<List<Event>>(
              stream: _eventRepository.getEventsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SliverFillRemaining(
                      child: Center(child: Text("No events available.")));
                }

                // Filtering Logic
                final now = DateTime.now();
                final filteredEvents = snapshot.data!.where((event) {
                  // --- FIX: SECURITY FILTER ---
                  // Only show Approved events.
                  // (Optional: You might want to allow cancelled events to show in history)
                  if (event.approvalStatus != EventStatus.approved) {
                    return false;
                  }
                  // ----------------------------

                  // Category
                  if (_activeCategoryFilter != 'All' &&
                      event.category != _activeCategoryFilter) {
                    return false;
                  }

                  // Search
                  if (_searchQuery.isNotEmpty) {
                    final q = _searchQuery.toLowerCase();
                    if (!event.title.toLowerCase().contains(q) &&
                        !event.description.toLowerCase().contains(q)) {
                      return false;
                    }
                  }

                  // Time (History vs Upcoming)
                  return _showPastEvents
                      ? event.endTime.isBefore(now)
                      : event.endTime.isAfter(now);
                }).toList();

                // Sorting Logic
                if (_currentSort == SortOption.newest) {
                  filteredEvents.sort((a, b) => _showPastEvents
                      ? b.startTime.compareTo(a.startTime)
                      : a.startTime.compareTo(b.startTime));
                } else {
                  filteredEvents.sort(
                      (a, b) => b.registeredCount.compareTo(a.registeredCount));
                }

                if (filteredEvents.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                              _showPastEvents
                                  ? Icons.history
                                  : Icons.event_busy,
                              size: 60,
                              color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            _showPastEvents
                                ? "No past events found."
                                : "No upcoming events match your filters.",
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: EventCard(
                          event: filteredEvents[index],
                          onTap: () => context.push(
                              '${AppRoutes.events}/details',
                              extra: filteredEvents[index]),
                        ),
                      ),
                      childCount: filteredEvents.length,
                    ),
                  ),
                );
              },
            ),

            // Bottom Padding
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }
}
