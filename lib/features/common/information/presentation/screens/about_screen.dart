import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Text('FusionFiesta connects students, organizers, and admins.'),
    );
  }
}

