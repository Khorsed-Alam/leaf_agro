import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'widgets/ai_leaf_painter.dart';
import 'widgets/animated_loading_dots.dart';
import 'widgets/splash_particle_painter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  // Main orchestrating animation timeline (0 to 4.8s)
  late final AnimationController _timelineController;

  // Ambient continuous loop for background particles & subtle HUD rotation
  late final AnimationController _loopController;

  // Timeline Sub-animations
  late final Animation<double> _backgroundFade;
  late final Animation<double> _particlesFade;
  late final Animation<double> _leafGrowth;
  late final Animation<double> _leafRotation;
  late final Animation<double> _scanBeamProgress;
  late final Animation<double> _scanActiveOpacity;
  late final Animation<double> _brandFade;
  late final Animation<Offset> _brandSlide;
  late final Animation<double> _taglineFade;
  late final Animation<double> _loadingFade;
  late final Animation<double> _exitFade;

  // Particle models
  late final List<ParticleModel> _particles;

  bool _isNavigated = false;

  @override
  void initState() {
    super.initState();

    _particles = SplashParticlePainter.generateParticles(35);

    _loopController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _timelineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4600),
    );

    // ── Phase 1: 0.0s – 1.0s (0.00 – 0.22) ─────────────────────────────
    _backgroundFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _timelineController,
        curve: const Interval(0.00, 0.20, curve: Curves.easeIn),
      ),
    );

    _particlesFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _timelineController,
        curve: const Interval(0.05, 0.25, curve: Curves.easeOut),
      ),
    );

    // ── Phase 2: 1.0s – 2.0s (0.20 – 0.42) ─────────────────────────────
    _leafGrowth = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _timelineController,
        curve: const Interval(0.20, 0.42, curve: Curves.easeOutBack),
      ),
    );

    _leafRotation = Tween<double>(begin: -0.15, end: 0.0).animate(
      CurvedAnimation(
        parent: _timelineController,
        curve: const Interval(0.20, 0.40, curve: Curves.easeOutCubic),
      ),
    );

    // ── Phase 3: 2.0s – 3.2s (0.42 – 0.68) ─────────────────────────────
    _scanBeamProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _timelineController,
        curve: const Interval(0.44, 0.66, curve: Curves.easeInOutCubic),
      ),
    );

    _scanActiveOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 70),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 15),
    ]).animate(
      CurvedAnimation(
        parent: _timelineController,
        curve: const Interval(0.42, 0.68, curve: Curves.linear),
      ),
    );

    // ── Phase 4: 3.2s – 4.2s (0.68 – 0.88) ─────────────────────────────
    _brandFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _timelineController,
        curve: const Interval(0.68, 0.80, curve: Curves.easeOut),
      ),
    );

    _brandSlide = Tween<Offset>(begin: const Offset(0.0, 0.35), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _timelineController,
        curve: const Interval(0.68, 0.82, curve: Curves.easeOutCubic),
      ),
    );

    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _timelineController,
        curve: const Interval(0.74, 0.86, curve: Curves.easeOut),
      ),
    );

    _loadingFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _timelineController,
        curve: const Interval(0.78, 0.90, curve: Curves.easeIn),
      ),
    );

    // ── Phase 5: 4.4s – 4.6s (0.94 – 1.00) ─────────────────────────────
    _exitFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _timelineController,
        curve: const Interval(0.94, 1.00, curve: Curves.easeIn),
      ),
    );

    // Start playback & handle completion
    _timelineController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToHome();
      }
    });

    _timelineController.forward();
  }

  void _navigateToHome() {
    if (_isNavigated || !mounted) return;
    _isNavigated = true;
    context.go('/home');
  }

  @override
  void dispose() {
    _timelineController.dispose();
    _loopController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Respect reduced-motion preferences
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion && !_isNavigated) {
      Future.microtask(_navigateToHome);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF03140A),
      body: AnimatedBuilder(
        animation: Listenable.merge([_timelineController, _loopController]),
        builder: (context, _) {
          return Opacity(
            opacity: _exitFade.value,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Deep Forest Gradient Background
                _buildBackground(),

                // 2. Floating Bio-particles & Ambient Spores
                CustomPaint(
                  painter: SplashParticlePainter(
                    progress: _loopController.value,
                    overallOpacity: _particlesFade.value,
                    particles: _particles,
                  ),
                  size: Size.infinite,
                ),

                // 3. Central Interactive AI Leaf Logo with Scanning Ray
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 3),

                      // Center Animated Leaf & Scanner Visual
                      Transform.rotate(
                        angle: _leafRotation.value,
                        child: SizedBox(
                          width: 220,
                          height: 220,
                          child: CustomPaint(
                            painter: AiLeafPainter(
                              growthProgress: _leafGrowth.value,
                              scanProgress: _scanBeamProgress.value,
                              scanActiveOpacity: _scanActiveOpacity.value,
                              hudRotation: _loopController.value * 2 * math.pi,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 36),

                      // 4. Brand Typography & Badge
                      SlideTransition(
                        position: _brandSlide,
                        child: FadeTransition(
                          opacity: _brandFade,
                          child: Column(
                            children: [
                              // AI Tech Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F6D39).withOpacity(0.35),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFF38EF7D).withOpacity(0.45),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF00FF7F).withOpacity(0.12),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF00FFA2),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'AI-POWERED PLANT HEALTH',
                                      style: TextStyle(
                                        color: Color(0xFFB1FFCD),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Main Title: LeafAgro with Gradient Glow
                              ShaderMask(
                                shaderCallback: (bounds) {
                                  return const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white,
                                      Color(0xFFE5FFF0),
                                      Color(0xFF88F9B6),
                                      Color(0xFF38EF7D),
                                    ],
                                    stops: [0.0, 0.45, 0.8, 1.0],
                                  ).createShader(bounds);
                                },
                                child: const Text(
                                  'LeafAgro',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 42,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -1.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Tagline
                              FadeTransition(
                                opacity: _taglineFade,
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                                  child: Text(
                                    'Smart Farming. Healthier Crops. Better Tomorrow.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF98DDB2),
                                      letterSpacing: 0.3,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(flex: 3),

                      // 5. Bottom Loading Indicator & Status
                      FadeTransition(
                        opacity: _loadingFade,
                        child: Column(
                          children: [
                            AnimatedLoadingDots(
                              progress: _loopController.value * 2.5,
                              dotColor: const Color(0xFF38EF7D),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Growing a Healthier Future...',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF75BC8F),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 28),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0.0, -0.15),
          radius: 1.15,
          colors: [
            Color(0xFF093E20), // Rich forest emerald ambient heart
            Color(0xFF042110),
            Color(0xFF021208),
            Color(0xFF010A05), // Deep abyss black-green edges
          ],
          stops: [0.0, 0.45, 0.80, 1.0],
        ),
      ),
    );
  }
}
