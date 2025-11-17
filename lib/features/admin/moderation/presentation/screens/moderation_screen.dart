import 'package:flutter/material.dart';

class ModerationScreen extends StatelessWidget {
  const ModerationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Content Moderation'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Media'),
              Tab(text: 'Certificates'),
              Tab(text: 'Feedback'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Center(child: Text('Gallery moderation queue')),
            Center(child: Text('Certificates queue')),
            Center(child: Text('Feedback queue')),
          ],
        ),
      ),
    );
  }
}

