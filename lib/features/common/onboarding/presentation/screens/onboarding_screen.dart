import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui' as ui;

import '../../../../../app/di/service_locator.dart';
import '../../../../../core/constants/app_routes.dart';
import '../../../../../core/services/storage_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  // Define the background colors for each page
  final List<Color> _pageColors = const [
    Color(0xFF4A148C), // Deep Purple (Cultural)
    Color(0xFF0D47A1), // Rich Blue (Technical)
    Color(0xFFE65100), // Deep Orange (Sports)
  ];

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
      // Removed static background color
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        color: _pageColors[_currentPage], // Dynamic Background
        child: SafeArea(
          child: Stack(
            children: [
              PageView(
                controller: _controller,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: const [
                  _OnboardingPage(
                    title: 'Cultural Events',
                    description:
                        'Music, Dance, Drama. Experience the vibrant soul of our college.',
                    // We keep the scene exactly as you wrote it
                    scene: _CulturalScene(),
                  ),
                  _OnboardingPage(
                    title: 'Technical Fests',
                    description:
                        'Hackathons, Workshops, Coding. Showcase your innovation.',
                    scene: _TechScene(),
                  ),
                  _OnboardingPage(
                    title: 'Sports Meets',
                    description:
                        'Inter-college tournaments. Compete and conquer.',
                    scene: _SportsScene(),
                  ),
                ],
              ),

              // Bottom Controls (Updated for High Contrast)
              Container(
                alignment: const Alignment(0, 0.85),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Skip Button - White
                      TextButton(
                        onPressed: _finishOnboarding,
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white70, // High contrast
                          ),
                        ),
                      ),

                      // Dots - White
                      SmoothPageIndicator(
                        controller: _controller,
                        count: 3,
                        effect: const WormEffect(
                          spacing: 12,
                          dotColor: Colors.white24,
                          activeDotColor: Colors.white,
                          dotHeight: 10,
                          dotWidth: 10,
                        ),
                      ),

                      // Next / Get Started - White Button
                      _currentPage == 2
                          ? FilledButton(
                              onPressed: _finishOnboarding,
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: _pageColors[_currentPage],
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                              ),
                              child: const Text(
                                'Get Started',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            )
                          : IconButton.filled(
                              onPressed: () => _controller.nextPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeIn,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: _pageColors[_currentPage],
                              ),
                              icon: const Icon(Icons.arrow_forward, size: 20),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- REUSABLE PAGE LAYOUT (Updated Text Colors) ---
class _OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final Widget scene;

  const _OnboardingPage({
    required this.title,
    required this.description,
    required this.scene,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(32.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Scene Container
          SizedBox(
            height: 320.w, // Scales with width to keep aspect ratio
            width: 320.w,
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: 320, // Internal logic keeps fixed coordinate system
                height: 320,
                child: scene,
              ),
            ),
          ),
          SizedBox(height: 40.h), // Responsive spacing

          // Typography - FORCED WHITE for contrast
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontSize: 24.sp, // Scalable font
                  letterSpacing: -0.5,
                ),
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),

          SizedBox(height: 16.h),

          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha:0.9),
                  fontSize: 16.sp, // Scalable font
                  height: 1.5,
                ),
          ).animate().fadeIn(delay: 200.ms, duration: 600.ms),

          SizedBox(height: 80.h), // Space for bottom controls
        ],
      ),
    );
  }
}

// --- YOUR PERFECTED HELPER: STYLED ICON ---
// (Unchanged from your snippet)
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
                color: color.withValues(alpha:0.4),
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
                color2 ?? color.withValues(alpha:0.6),
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
                color.withValues(alpha:0.3),
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

// --- YOUR SCENES (Unchanged from your snippet) ---

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
            color: Colors.deepPurple
                .withValues(alpha:0.2), // Slightly boosted opacity for visibility
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
                color: Colors.deepPurple, // Stays dark/saturated
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
            color: Colors.blue.withValues(alpha:0.2),
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
        ).animate().fadeIn().slideY(
            begin: 0.5, end: 0, duration: 600.ms, curve: Curves.easeOutBack),
        Positioned(
          top: 40,
          right: 60,
          child: const _StyledIcon(FontAwesomeIcons.rocket,
                  size: 70, color: Colors.orange, color2: Colors.redAccent)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(
                  begin: 5,
                  end: -5,
                  duration: 2.seconds,
                  curve: Curves.easeInOut),
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
            color: Colors.orange.withValues(alpha:0.2),
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
                  begin: -1,
                  end: 0,
                  duration: 600.ms,
                  curve: Curves.easeOutBack),
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
                  begin: -20,
                  end: 0,
                  duration: 500.ms,
                  curve: Curves.bounceOut),
        ),
      ],
    );
  }
}
