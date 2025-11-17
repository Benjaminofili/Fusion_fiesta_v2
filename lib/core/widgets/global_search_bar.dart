import 'dart:async';

import 'package:flutter/material.dart';

typedef SearchCallback = Future<List<String>> Function(String query);
typedef SearchSubmit = void Function(String query);

class GlobalSearchBar extends StatefulWidget {
  const GlobalSearchBar({
    super.key,
    required this.hintText,
    required this.onSearch,
    required this.onSubmit,
  });

  final String hintText;
  final SearchCallback onSearch;
  final SearchSubmit onSubmit;

  @override
  State<GlobalSearchBar> createState() => _GlobalSearchBarState();
}

class _GlobalSearchBarState extends State<GlobalSearchBar> {
  final _controller = TextEditingController();
  final _debounceDuration = const Duration(milliseconds: 300);
  Timer? _debounce;
  List<String> _suggestions = [];

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(_debounceDuration, () async {
      final results = await widget.onSearch(value);
      if (mounted) {
        setState(() => _suggestions = results);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: widget.hintText,
          ),
          onChanged: _onChanged,
          onSubmitted: widget.onSubmit,
        ),
        if (_suggestions.isNotEmpty)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index];
                return ListTile(
                  title: Text(suggestion),
                  onTap: () {
                    _controller.text = suggestion;
                    widget.onSubmit(suggestion);
                    setState(() => _suggestions = []);
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}

