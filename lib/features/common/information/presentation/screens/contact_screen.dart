import 'package:flutter/material.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Contact Us', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          TextField(decoration: const InputDecoration(labelText: 'Your Name')),
          const SizedBox(height: 16),
          TextField(decoration: const InputDecoration(labelText: 'Email')),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(labelText: 'Message'),
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: () {}, child: const Text('Submit')),
          const SizedBox(height: 24),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: Text('Google Maps placeholder')),
          ),
        ],
      ),
    );
  }
}

