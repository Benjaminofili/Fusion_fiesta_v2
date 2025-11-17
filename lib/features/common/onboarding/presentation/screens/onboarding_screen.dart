import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageView(
      children: const [
        Center(child: Text('Discover events.')),
        Center(child: Text('Register seamlessly.')),
        Center(child: Text('Collaborate across roles.')),
      ],
    );
  }
}

