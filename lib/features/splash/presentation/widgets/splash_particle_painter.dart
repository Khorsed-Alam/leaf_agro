import 'dart:math' as math;
import 'package:flutter/material.dart';

class ParticleModel {
  final double x;
  final double y;
  final double radius;
  final double speed;
  final double opacity;
  final double swayAmplitude;
  final double phase;
  final bool isLeaf;

  const ParticleModel({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.opacity,
    required this.swayAmplitude,
    required this.phase,
    this.isLeaf = false,
  });
}

class SplashParticlePainter extends CustomPainter {
  final double progress;
  final double overallOpacity;
  final List<ParticleModel> particles;

  SplashParticlePainter({
    required this.progress,
    required this.overallOpacity,
    required this.particles,
  });

  static List<ParticleModel> generateParticles(int count) {
    final random = math.Random(42); // deterministic seed for consistent beauty
    return List.generate(count, (index) {
      return ParticleModel(
        x: random.nextDouble(),
        y: random.nextDouble(),
        radius: 1.5 + random.nextDouble() * 3.5,
        speed: 0.2 + random.nextDouble() * 0.4,
        opacity: 0.25 + random.nextDouble() * 0.55,
        swayAmplitude: 8.0 + random.nextDouble() * 16.0,
        phase: random.nextDouble() * 2 * math.pi,
        isLeaf: index % 4 == 0,
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (overallOpacity <= 0) return;

    for (final p in particles) {
      // Calculate dynamic position
      final currentY = (p.y - (progress * p.speed)) % 1.0;
      final dy = currentY * size.height;
      final dx = (p.x * size.width) + math.sin(p.phase + (progress * 2 * math.pi)) * p.swayAmplitude;

      // Skip if offscreen
      if (dx < -20 || dx > size.width + 20 || dy < -20 || dy > size.height + 20) continue;

      final alpha = (p.opacity * overallOpacity).clamp(0.0, 1.0);

      if (p.isLeaf) {
        // Draw tiny micro-leaf
        final paint = Paint()
          ..color = const Color(0xFF62E990).withOpacity(alpha * 0.8)
          ..style = PaintingStyle.fill;

        canvas.save();
        canvas.translate(dx, dy);
        canvas.rotate(p.phase + progress * math.pi);

        final path = Path();
        path.moveTo(0, -p.radius * 2);
        path.quadraticBezierTo(p.radius * 1.5, 0, 0, p.radius * 2);
        path.quadraticBezierTo(-p.radius * 1.5, 0, 0, -p.radius * 2);
        canvas.drawPath(path, paint);

        canvas.restore();
      } else {
        // Glowing bio-luminescent particle
        final glowPaint = Paint()
          ..color = const Color(0xFF38EF7D).withOpacity(alpha * 0.35)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.radius * 1.8);

        canvas.drawCircle(Offset(dx, dy), p.radius * 2, glowPaint);

        final corePaint = Paint()
          ..color = const Color(0xFFB9FFCE).withOpacity(alpha)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(Offset(dx, dy), p.radius, corePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant SplashParticlePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.overallOpacity != overallOpacity;
  }
}

