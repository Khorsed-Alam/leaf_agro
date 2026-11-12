import 'dart:math' as math;
import 'package:flutter/material.dart';

class AiLeafPainter extends CustomPainter {
  final double growthProgress; // 0.0 to 1.0 (scales & forms leaf)
  final double scanProgress; // 0.0 to 1.0 (vertical beam sweep)
  final double scanActiveOpacity; // 0.0 to 1.0 (laser beam intensity)
  final double hudRotation; // continuous subtle rotation

  AiLeafPainter({
    required this.growthProgress,
    required this.scanProgress,
    required this.scanActiveOpacity,
    required this.hudRotation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (growthProgress <= 0.01) return;

    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = math.min(size.width, size.height) * 0.38;

    // 1. Draw Outer AI HUD Circular Halo & Target Brackets
    _drawHudElements(canvas, center, baseRadius);

    // 2. Draw Leaf
    canvas.save();
    canvas.translate(center.dx, center.dy);
    // Subtle scale & gentle tilt during growth
    final scale = growthProgress.clamp(0.0, 1.0);
    canvas.scale(scale);

    // Leaf bounds definition (relative to center)
    final leafWidth = baseRadius * 1.05;
    final leafHeight = baseRadius * 1.55;

    final leafPath = _createLeafPath(leafWidth, leafHeight);

    // Ambient Back Glow behind leaf
    final backGlowPaint = Paint()
      ..color = const Color(0xFF00FF77).withOpacity(0.18 * growthProgress)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);
    canvas.drawPath(leafPath, backGlowPaint);

    // Leaf Fill Gradient
    final leafShader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF2DE77A),
        Color(0xFF0E7A40),
        Color(0xFF074825),
      ],
      stops: [0.0, 0.55, 1.0],
    ).createShader(Rect.fromCenter(center: Offset.zero, width: leafWidth * 2, height: leafHeight * 2));

    final leafFillPaint = Paint()
      ..shader = leafShader
      ..style = PaintingStyle.fill;

    canvas.drawPath(leafPath, leafFillPaint);

    // Leaf Outline Stroke
    final leafStrokePaint = Paint()
      ..color = const Color(0xFF86F8B2).withOpacity(0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    canvas.drawPath(leafPath, leafStrokePaint);

    // Botanical & AI Circuit Veins
    _drawVeins(canvas, leafWidth, leafHeight);

    // 3. AI Vertical Scanning Laser Beam & Pulse
    if (scanActiveOpacity > 0.05) {
      _drawScanBeam(canvas, leafPath, leafWidth, leafHeight);
    }

    canvas.restore();
  }

  Path _createLeafPath(double w, double h) {
    final path = Path();
    // Start at bottom stem point
    path.moveTo(0, h * 0.48);

    // Left curved lobe to sharp tip
    path.cubicTo(
      -w * 0.85, h * 0.15,
      -w * 0.70, -h * 0.35,
      0, -h * 0.52,
    );

    // Right curved lobe back to bottom
    path.cubicTo(
      w * 0.70, -h * 0.35,
      w * 0.85, h * 0.15,
      0, h * 0.48,
    );

    path.close();
    return path;
  }

  void _drawVeins(Canvas canvas, double w, double h) {
    final veinPaint = Paint()
      ..color = const Color(0xFFD4FFE1).withOpacity(0.75 * growthProgress)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.0;

    // Central Midrib
    final midrib = Path();
    midrib.moveTo(0, h * 0.45);
    midrib.quadraticBezierTo(-w * 0.04, 0, 0, -h * 0.48);
    canvas.drawPath(midrib, veinPaint);

    // Lateral Veins (Branching circuits)
    final branches = [
      // Left branches
      {'start': Offset(0, h * 0.25), 'ctrl': Offset(-w * 0.25, h * 0.20), 'end': Offset(-w * 0.45, h * 0.05)},
      {'start': Offset(0, h * 0.05), 'ctrl': Offset(-w * 0.30, -h * 0.02), 'end': Offset(-w * 0.48, -h * 0.18)},
      {'start': Offset(0, -h * 0.15), 'ctrl': Offset(-w * 0.28, -h * 0.22), 'end': Offset(-w * 0.38, -h * 0.34)},
      // Right branches
      {'start': Offset(0, h * 0.25), 'ctrl': Offset(w * 0.25, h * 0.20), 'end': Offset(w * 0.45, h * 0.05)},
      {'start': Offset(0, h * 0.05), 'ctrl': Offset(w * 0.30, -h * 0.02), 'end': Offset(w * 0.48, -h * 0.18)},
      {'start': Offset(0, -h * 0.15), 'ctrl': Offset(w * 0.28, -h * 0.22), 'end': Offset(w * 0.38, -h * 0.34)},
    ];

    final branchPaint = Paint()
      ..color = const Color(0xFFB1FFCD).withOpacity(0.55 * growthProgress)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.4;

    final nodePaint = Paint()
      ..color = const Color(0xFFE2FFF0)
      ..style = PaintingStyle.fill;

    for (final b in branches) {
      final p = Path();
      p.moveTo(b['start']!.dx, b['start']!.dy);
      p.quadraticBezierTo(b['ctrl']!.dx, b['ctrl']!.dy, b['end']!.dx, b['end']!.dy);
      canvas.drawPath(p, branchPaint);

      // AI digital node circle at end of vein
      canvas.drawCircle(b['end']!, 2.2, nodePaint);
    }
  }

  void _drawScanBeam(Canvas canvas, Path leafClip, double w, double h) {
    canvas.save();
    canvas.clipPath(leafClip);

    // Calculate vertical scan line position from top (-h*0.52) to bottom (h*0.48)
    final topBound = -h * 0.52;
    final bottomBound = h * 0.48;
    final totalTravel = bottomBound - topBound;
    final currentScanY = topBound + (totalTravel * scanProgress);

    // 1. Digital Mesh Grid overlay when scanning
    final gridPaint = Paint()
      ..color = const Color(0xFF00FF88).withOpacity(0.12 * scanActiveOpacity)
      ..strokeWidth = 0.8;

    const gridStep = 14.0;
    for (double x = -w; x <= w; x += gridStep) {
      canvas.drawLine(Offset(x, topBound), Offset(x, bottomBound), gridPaint);
    }
    for (double y = topBound; y <= bottomBound; y += gridStep) {
      canvas.drawLine(Offset(-w, y), Offset(w, y), gridPaint);
    }

    // 2. Wide Laser Ambient Aura
    final auraHeight = 55.0;
    final auraRect = Rect.fromLTRB(-w * 1.2, currentScanY - auraHeight, w * 1.2, currentScanY + auraHeight);
    final auraShader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.transparent,
        const Color(0xFF00FF7F).withOpacity(0.28 * scanActiveOpacity),
        const Color(0xFF70FFB8).withOpacity(0.42 * scanActiveOpacity),
        const Color(0xFF00FF7F).withOpacity(0.28 * scanActiveOpacity),
        Colors.transparent,
      ],
      stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
    ).createShader(auraRect);

    final auraPaint = Paint()..shader = auraShader;
    canvas.drawRect(auraRect, auraPaint);

    // 3. Crisp Laser Core Beam Line
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(scanActiveOpacity)
      ..strokeWidth = 2.4
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 1.5);

    canvas.drawLine(Offset(-w * 1.1, currentScanY), Offset(w * 1.1, currentScanY), linePaint);

    final outerLinePaint = Paint()
      ..color = const Color(0xFF00FFA2).withOpacity(0.85 * scanActiveOpacity)
      ..strokeWidth = 4.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    canvas.drawLine(Offset(-w * 1.1, currentScanY), Offset(w * 1.1, currentScanY), outerLinePaint);

    canvas.restore();
  }

  void _drawHudElements(Canvas canvas, Offset center, double radius) {
    final hudOpacity = (growthProgress * 0.9).clamp(0.0, 1.0);
    if (hudOpacity <= 0.05) return;

    canvas.save();
    canvas.translate(center.dx, center.dy);

    // Subtle AI Orbit Ring with Dashes
    final ringRadius = radius * 1.18;
    canvas.rotate(hudRotation);

    final ringPaint = Paint()
      ..color = const Color(0xFF38EF7D).withOpacity(0.22 * hudOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const int segments = 36;
    for (int i = 0; i < segments; i++) {
      if (i % 3 == 0) continue; // dashed look
      final startAngle = (i * 2 * math.pi) / segments;
      final sweepAngle = (2 * math.pi) / segments * 0.65;
      canvas.drawArc(
        Rect.fromCircle(center: Offset.zero, radius: ringRadius),
        startAngle,
        sweepAngle,
        false,
        ringPaint,
      );
    }

    // Outer Target Reticle Brackets (Computer Vision Bounding Corners)
    canvas.rotate(-hudRotation); // Keep brackets fixed square
    final bracketRadius = radius * 1.15;
    final bracketPaint = Paint()
      ..color = const Color(0xFF8BFFBC).withOpacity(0.65 * hudOpacity)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square
      ..strokeWidth = 2.2;

    const cornerLength = 22.0;

    // Top-Left
    canvas.drawLine(Offset(-bracketRadius, -bracketRadius + cornerLength), Offset(-bracketRadius, -bracketRadius), bracketPaint);
    canvas.drawLine(Offset(-bracketRadius, -bracketRadius), Offset(-bracketRadius + cornerLength, -bracketRadius), bracketPaint);

    // Top-Right
    canvas.drawLine(Offset(bracketRadius - cornerLength, -bracketRadius), Offset(bracketRadius, -bracketRadius), bracketPaint);
    canvas.drawLine(Offset(bracketRadius, -bracketRadius), Offset(bracketRadius, -bracketRadius + cornerLength), bracketPaint);

    // Bottom-Left
    canvas.drawLine(Offset(-bracketRadius, bracketRadius - cornerLength), Offset(-bracketRadius, bracketRadius), bracketPaint);
    canvas.drawLine(Offset(-bracketRadius, bracketRadius), Offset(-bracketRadius + cornerLength, bracketRadius), bracketPaint);

    // Bottom-Right
    canvas.drawLine(Offset(bracketRadius - cornerLength, bracketRadius), Offset(bracketRadius, bracketRadius), bracketPaint);
    canvas.drawLine(Offset(bracketRadius, bracketRadius), Offset(bracketRadius, bracketRadius - cornerLength), bracketPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant AiLeafPainter oldDelegate) {
    return oldDelegate.growthProgress != growthProgress ||
        oldDelegate.scanProgress != scanProgress ||
        oldDelegate.scanActiveOpacity != scanActiveOpacity ||
        oldDelegate.hudRotation != hudRotation;
  }
}

