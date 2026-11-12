import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Custom vector hero illustration for Password Recovery & Email Confirmation states.
class RecoveryHeroIllustration extends StatelessWidget {
  final bool isConfirmed;
  final double size;

  const RecoveryHeroIllustration({
    super.key,
    this.isConfirmed = false,
    this.size = 170.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      child: CustomPaint(
        size: Size(size, size),
        painter: _RecoveryHeroPainter(isConfirmed: isConfirmed),
      ),
    );
  }
}

class _RecoveryHeroPainter extends CustomPainter {
  final bool isConfirmed;

  _RecoveryHeroPainter({required this.isConfirmed});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    // 1. Soft Circular Green Ambient Aura
    final auraShader = RadialGradient(
      colors: [
        (isConfirmed ? const Color(0xFF22C55E) : const Color(0xFF14532D))
            .withValues(alpha: 0.16),
        AppColors.limeGreen.withValues(alpha: 0.08),
        Colors.transparent,
      ],
      stops: const [0.0, 0.65, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: w * 0.48));

    final auraPaint = Paint()..shader = auraShader;
    canvas.drawCircle(center, w * 0.48, auraPaint);

    // Inner subtle concentric ring
    final ringPaint = Paint()
      ..color = (isConfirmed ? const Color(0xFF22C55E) : const Color(0xFF14532D))
          .withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, w * 0.38, ringPaint);

    // 2. Floating Bio-Particles and Micro-Sparks
    final particlePaint = Paint()..style = PaintingStyle.fill;
    final particles = [
      Offset(w * 0.16, h * 0.32),
      Offset(w * 0.84, h * 0.28),
      Offset(w * 0.22, h * 0.74),
      Offset(w * 0.82, h * 0.70),
      Offset(w * 0.50, h * 0.14),
    ];

    for (int i = 0; i < particles.length; i++) {
      particlePaint.color = i % 2 == 0
          ? AppColors.limeGreen.withValues(alpha: 0.7)
          : const Color(0xFF22C55E).withValues(alpha: 0.6);
      canvas.drawCircle(particles[i], (i % 2 == 0) ? 2.5 : 2.0, particlePaint);
    }

    // 3. Floating Envelope
    final envWidth = w * 0.58;
    final envHeight = h * 0.40;
    final envRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy + 4),
      width: envWidth,
      height: envHeight,
    );

    // Envelope Drop Shadow
    final shadowPaint = Paint()
      ..color = const Color(0xFF14532D).withValues(alpha: 0.14)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        envRect.shift(const Offset(0, 8)),
        const Radius.circular(14),
      ),
      shadowPaint,
    );

    // Envelope Body (Crisp Pure White surface)
    final envBodyPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final envBorderPaint = Paint()
      ..color = const Color(0xFFD1E7D2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    final envRRect = RRect.fromRectAndRadius(envRect, const Radius.circular(14));
    canvas.drawRRect(envRRect, envBodyPaint);

    // Envelope Fold Lines (Inner V-fold)
    final foldPaint = Paint()
      ..color = const Color(0xFFE2EDE4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    final leftBottom = Offset(envRect.left, envRect.bottom);
    final rightBottom = Offset(envRect.right, envRect.bottom);
    final foldCenter = Offset(envRect.center.dx, envRect.center.dy + 8);

    canvas.drawLine(leftBottom, foldCenter, foldPaint);
    canvas.drawLine(rightBottom, foldCenter, foldPaint);

    // Envelope Top Flap (Open / Folded peak)
    final flapPath = Path();
    flapPath.moveTo(envRect.left, envRect.top);
    flapPath.lineTo(envRect.center.dx, envRect.center.dy + 6);
    flapPath.lineTo(envRect.right, envRect.top);

    final flapFillPaint = Paint()
      ..color = const Color(0xFFF9FBF8)
      ..style = PaintingStyle.fill;
    canvas.drawPath(flapPath, flapFillPaint);
    canvas.drawPath(flapPath, envBorderPaint);
    canvas.drawRRect(envRRect, envBorderPaint);

    // 4. Fresh Green Agricultural Leaf Attached to Envelope Top-Right
    canvas.save();
    final leafOrigin = Offset(envRect.right - 8, envRect.top - 6);
    canvas.translate(leafOrigin.dx, leafOrigin.dy);
    canvas.rotate(0.35); // Gentle organic tilt

    final leafWidth = w * 0.18;
    final leafHeight = h * 0.24;
    final leafPath = Path();
    leafPath.moveTo(0, 0);
    leafPath.cubicTo(
      leafWidth * 0.6,
      -leafHeight * 0.3,
      leafWidth * 1.1,
      -leafHeight * 0.7,
      0,
      -leafHeight,
    );
    leafPath.cubicTo(
      -leafWidth * 1.1,
      -leafHeight * 0.7,
      -leafWidth * 0.6,
      -leafHeight * 0.3,
      0,
      0,
    );
    leafPath.close();

    final leafShader = const LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [
        Color(0xFF14532D),
        Color(0xFF22C55E),
        Color(0xFFA3E635),
      ],
    ).createShader(Rect.fromLTWH(-leafWidth, -leafHeight, leafWidth * 2, leafHeight));

    final leafFillPaint = Paint()
      ..shader = leafShader
      ..style = PaintingStyle.fill;
    canvas.drawPath(leafPath, leafFillPaint);

    // Leaf vein
    final veinPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.75)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(0, 0), Offset(0, -leafHeight * 0.85), veinPaint);
    canvas.restore();

    // 5. Center Badge: Security Lock Badge or Green Checkmark Badge
    final badgeCenter = Offset(envRect.center.dx, envRect.center.dy - 2);
    final badgeRadius = w * 0.13;

    final badgeBgPaint = Paint()
      ..color = isConfirmed ? const Color(0xFF16A34A) : AppColors.forestGreen
      ..style = PaintingStyle.fill;

    // Badge shadow
    final badgeShadowPaint = Paint()
      ..color = (isConfirmed ? const Color(0xFF16A34A) : AppColors.forestGreen)
          .withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(badgeCenter.translate(0, 3), badgeRadius, badgeShadowPaint);
    canvas.drawCircle(badgeCenter, badgeRadius, badgeBgPaint);

    // Outer badge accent border
    final badgeBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    canvas.drawCircle(badgeCenter, badgeRadius, badgeBorderPaint);

    if (isConfirmed) {
      // ── Green Checkmark ──
      final checkPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final checkPath = Path();
      checkPath.moveTo(badgeCenter.dx - badgeRadius * 0.45, badgeCenter.dy + 1);
      checkPath.lineTo(badgeCenter.dx - badgeRadius * 0.10, badgeCenter.dy + badgeRadius * 0.40);
      checkPath.lineTo(badgeCenter.dx + badgeRadius * 0.48, badgeCenter.dy - badgeRadius * 0.35);
      canvas.drawPath(checkPath, checkPaint);
    } else {
      // ── Security Lock Symbol ──
      final lockPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round;

      // Lock shackle (arc on top)
      final shackleRect = Rect.fromCenter(
        center: Offset(badgeCenter.dx, badgeCenter.dy - badgeRadius * 0.22),
        width: badgeRadius * 0.70,
        height: badgeRadius * 0.65,
      );
      canvas.drawArc(shackleRect, math.pi, math.pi, false, lockPaint);

      // Lock body (rounded rectangle)
      final lockBodyPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      final lockBodyRect = Rect.fromCenter(
        center: Offset(badgeCenter.dx, badgeCenter.dy + badgeRadius * 0.20),
        width: badgeRadius * 0.85,
        height: badgeRadius * 0.65,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(lockBodyRect, const Radius.circular(4)),
        lockBodyPaint,
      );

      // Lock keyhole dot
      final keyholePaint = Paint()
        ..color = AppColors.forestGreen
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(badgeCenter.dx, badgeCenter.dy + badgeRadius * 0.18),
        2.2,
        keyholePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RecoveryHeroPainter oldDelegate) =>
      oldDelegate.isConfirmed != isConfirmed;
}

