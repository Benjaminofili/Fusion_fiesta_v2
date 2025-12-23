import 'package:flutter/material.dart';

import '../constants/app_sizes.dart';

class FilterChipGroup extends StatelessWidget {
  const FilterChipGroup({
    super.key,
    required this.filters,
    required this.activeFilter,
    required this.onSelected,
  });

  final List<String> filters;
  final String activeFilter;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSizes.sm,
      children: filters
          .map(
            (filter) => ChoiceChip(
              label: Text(filter),
              selected: filter == activeFilter,
              onSelected: (_) => onSelected(filter),
            ),
          )
          .toList(),
    );
  }
}
