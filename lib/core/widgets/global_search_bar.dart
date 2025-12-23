import 'dart:async';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

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
  final _focusNode = FocusNode();
  final _layerLink = LayerLink(); // Anchor for the floating list

  Timer? _debounce;
  OverlayEntry? _overlayEntry;
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    // Close overlay when user taps outside (unfocuses)
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        // Small delay to allow "onTap" on the list item to register first
        Future.delayed(const Duration(milliseconds: 100), _removeOverlay);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    _removeOverlay();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    if (value.isEmpty) {
      _removeOverlay();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final results = await widget.onSearch(value);
      if (mounted) {
        setState(() => _suggestions = results);
        if (_suggestions.isNotEmpty) {
          _showOverlay();
        } else {
          _removeOverlay();
        }
      }
    });
  }

  // --- OVERLAY LOGIC (The "Overlap" Magic) ---
  void _showOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
      return;
    }

    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 8.0), // 8px gap below input
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            shadowColor: Colors.black.withValues(alpha:0.1),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220), // Limit height
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _suggestions.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final suggestion = _suggestions[index];
                  return ListTile(
                    leading:
                        const Icon(Icons.search, size: 20, color: Colors.grey),
                    title: Text(suggestion),
                    onTap: () {
                      _controller.text = suggestion;
                      _removeOverlay();
                      _focusNode.unfocus();
                      widget.onSubmit(suggestion);
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: widget.hintText,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _controller.clear();
                    _removeOverlay();
                    widget.onSubmit('');
                  },
                )
              : null,
        ),
        onChanged: _onChanged,
        onSubmitted: (val) {
          _removeOverlay();
          widget.onSubmit(val);
        },
      ),
    );
  }
}
