import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'dart:ui' as ui;

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_routes.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/services/storage_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool _isLastPage = false;

  Future<void> _finishOnboarding() async {
    final storage = serviceLocator<StorageService>();
    await storage.setFirstLaunchComplete();
    if (mounted) {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            PageView(
              controller: _controller,
              onPageChanged: (index) {
                setState(() => _isLastPage = index == 2);
              },
              children: const [
                _OnboardingPage(
                  title: 'Cultural Events',
                  description:
                  'Music, Dance, Drama. Experience the vibrant soul of our college.',
                  color: Colors.deepPurple,
                  scene: _CulturalScene(),
                ),
                _OnboardingPage(
                  title: 'Technical Fests',
                  description:
                  'Hackathons, Workshops, Coding. Showcase your innovation.',
                  color: Colors.blue,
                  scene: _TechScene(),
                ),
                _OnboardingPage(
                  title: 'Sports Meets',
                  description:
                  'Inter-college tournaments. Compete and conquer.',
                  color: Colors.orange,
                  scene: _SportsScene(),
                ),
              ],
            ),

            // Bottom Controls
            Container(
              alignment: const Alignment(0, 0.85),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Skip Button
                    TextButton(
                      onPressed: _finishOnboarding,
                      child: const Text('Skip',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),

                    // Dots
                    SmoothPageIndicator(
                      controller: _controller,
                      count: 3,
                      effect: const WormEffect(
                        spacing: 12,
                        dotColor: Colors.black12,
                        activeDotColor: Colors.black87,
                        dotHeight: 10,
                        dotWidth: 10,
                      ),
                    ),

                    // Next / Done Button
                    _isLastPage
                        ? FilledButton(
                      onPressed: _finishOnboarding,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Get Started'),
                    )
                        : FilledButton.icon(
                      onPressed: () => _controller.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeIn,
                      ),
                      icon: const Icon(Icons.arrow_forward, size: 18),
                      label: const Text('Next'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- REUSABLE PAGE LAYOUT ---
class _OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final Widget scene;
  final Color color;

  const _OnboardingPage({
    required this.title,
    required this.description,
    required this.scene,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Scene Container
          SizedBox(height: 320, width: 320, child: scene),
          const SizedBox(height: 40),

          // Typography
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.black87,
              letterSpacing: -0.5,
            ),
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),

          const SizedBox(height: 16),

          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
              height: 1.5,
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 600.ms),

          const SizedBox(height: 80), // Space for bottom controls
        ],
      ),
    );
  }
}

// --- HELPER: STYLED ICON ---
class _StyledIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  final Color? color2;

  const _StyledIcon(
      this.icon, {
        required this.size,
        required this.color,
        this.color2,
      });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 1.2,
      height: size * 1.2,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // 1. Blurred shadow base (softens edges)
          Transform.translate(
            offset: Offset(0, size * 0.08),
            child: ImageFiltered(
              imageFilter: ui.ImageFilter.blur(
                sigmaX: size * 0.15,
                sigmaY: size * 0.15,
                tileMode: TileMode.decal,
              ),
              child: Icon(
                icon,
                size: size,
                color: color.withOpacity(0.4),
              ),
            ),
          ),

          // 2. Main gradient icon
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color,
                color2 ?? color.withOpacity(0.6),
              ],
            ).createShader(bounds),
            child: Icon(
              icon,
              size: size,
              color: Colors.white,
            ),
          ),

          // 3. Soft glow overlay (reduces hard edges)
          ShaderMask(
            blendMode: BlendMode.plus,
            shaderCallback: (bounds) => RadialGradient(
              colors: [
                color.withOpacity(0.3),
                Colors.transparent,
              ],
              stops: const [0.4, 1.0],
            ).createShader(bounds),
            child: Icon(
              icon,
              size: size,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// --- SCENE 1: CULTURAL ---
class _CulturalScene extends StatelessWidget {
  const _CulturalScene();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.deepPurple.withOpacity(0.05),
          ),
        )
            .animate()
            .scale(
            duration: 2.seconds,
            begin: const Offset(0.95, 0.95),
            end: const Offset(1.05, 1.05))
            .animate(onPlay: (c) => c.repeat(reverse: true)),
        const _StyledIcon(FontAwesomeIcons.masksTheater,
            size: 120,
            color: Colors.deepPurple,
            color2: Colors.purpleAccent)
            .animate()
            .fadeIn(duration: 800.ms)
            .scale(curve: Curves.elasticOut, duration: 800.ms),
        Positioned(
          bottom: 60,
          left: 40,
          child: const _StyledIcon(FontAwesomeIcons.guitar,
              size: 60, color: Colors.pink, color2: Colors.deepOrange)
              .animate()
              .slide(
              begin: const Offset(-0.5, 0.5),
              duration: 600.ms,
              curve: Curves.easeOutBack)
              .rotate(begin: -0.1, end: 0.05)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .shake(hz: 1.5, rotation: 0.05),
        ),
        Positioned(
          top: 60,
          right: 50,
          child: const _StyledIcon(FontAwesomeIcons.music,
              size: 45, color: Colors.indigoAccent, color2: Colors.blue)
              .animate(onPlay: (c) => c.repeat())
              .moveY(
              begin: 0,
              end: -15,
              duration: 2.seconds,
              curve: Curves.easeInOut)
              .fadeIn(),
        ),
      ],
    );
  }
}

// --- SCENE 2: TECHNICAL ---
class _TechScene extends StatelessWidget {
  const _TechScene();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue.withOpacity(0.05),
          ),
        )
            .animate()
            .scale(
            duration: 3.seconds,
            begin: const Offset(1, 1),
            end: const Offset(1.1, 1.1))
            .animate(onPlay: (c) => c.repeat(reverse: true)),
        const Positioned(
          bottom: 80,
          child: _StyledIcon(FontAwesomeIcons.laptopCode,
              size: 110, color: Colors.blue, color2: Colors.cyanAccent),
        )
            .animate()
            .fadeIn()
            .slideY(
            begin: 0.5, end: 0, duration: 600.ms, curve: Curves.easeOutBack),
        Positioned(
          top: 40,
          right: 60,
          child: const _StyledIcon(FontAwesomeIcons.rocket,
              size: 70, color: Colors.orange, color2: Colors.redAccent)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(
              begin: 5, end: -5, duration: 2.seconds, curve: Curves.easeInOut),
        ),
        Positioned(
          left: 50,
          top: 100,
          child: const _StyledIcon(FontAwesomeIcons.code,
              size: 50, color: Colors.indigo, color2: Colors.purple)
              .animate()
              .scale(delay: 400.ms, duration: 400.ms, curve: Curves.elasticOut),
        ),
      ],
    );
  }
}

// --- SCENE 3: SPORTS ---
class _SportsScene extends StatelessWidget {
  const _SportsScene();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.orange.withOpacity(0.05),
          ),
        )
            .animate()
            .scale(duration: 2.seconds)
            .animate(onPlay: (c) => c.repeat(reverse: true)),
        const _StyledIcon(FontAwesomeIcons.trophy,
            size: 120, color: Colors.amber, color2: Colors.orange)
            .animate()
            .scale(
            begin: const Offset(0.5, 0.5),
            curve: Curves.elasticOut,
            duration: 1.seconds)
            .shimmer(delay: 1500.ms, duration: 2.seconds),
        Positioned(
          bottom: 60,
          left: 40,
          child: const _StyledIcon(FontAwesomeIcons.personRunning,
              size: 65, color: Colors.deepOrange, color2: Colors.red)
              .animate()
              .slideX(
              begin: -1, end: 0, duration: 600.ms, curve: Curves.easeOutBack),
        ),
        Positioned(
          top: 70,
          right: 50,
          child: const _StyledIcon(FontAwesomeIcons.basketball,
              size: 50,
              color: Colors.orangeAccent,
              color2: Colors.deepOrange)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(
              begin: -20, end: 0, duration: 500.ms, curve: Curves.bounceOut),
        ),
      ],
    );
  }
}