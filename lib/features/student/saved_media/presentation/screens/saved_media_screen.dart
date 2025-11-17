import 'package:flutter/material.dart';

class SavedMediaScreen extends StatelessWidget {
  const SavedMediaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16),
      itemBuilder: (context, index) => Container(
        color: Colors.grey.shade200,
        child: Center(child: Text('Saved Item ${index + 1}')),
      ),
      itemCount: 4,
    );
  }
}

