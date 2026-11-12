import 'dart:math' as math;
import 'package:flutter/material.dart';

class FarmerHeroIllustration extends StatefulWidget {
  final int pageIndex;

  const FarmerHeroIllustration({super.key, required this.pageIndex});

  @override
  State<FarmerHeroIllustration> createState() => _FarmerHeroIllustrationState();
}

class _FarmerHeroIllustrationState extends State<FarmerHeroIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, _) {
        return CustomPaint(
          painter: _HeroIllustrationPainter(
            scanProgress: _animController.value,
            pageIndex: widget.pageIndex,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _HeroIllustrationPainter extends CustomPainter {
  final double scanProgress; // 0.0 to 1.0 (oscillating)
  final int pageIndex;

  _HeroIllustrationPainter({
    required this.scanProgress,
    required this.pageIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.52);
    final radius = math.min(size.width, size.height) * 0.44;

    // 1. Organic Soft Sun & Field Aura Backdrop
    _drawBackdropAura(canvas, center, radius);

    // 2. Rural Green Crop Field Hills & Rice Stalks
    _drawRuralFieldLandscape(canvas, center, radius);

    // 3. Bangladeshi Farmer & Caring Posture
    _drawFarmerFigure(canvas, center, radius);

    // 4. Plant Leaf Being Examined
    _drawCropLeaf(canvas, center, radius);

    // 5. Smartphone with AI Scanner
    _drawSmartphoneScanner(canvas, center, radius);

    // 6. Holographic AI Laser Scanning Beam & Particle Field
    _drawAiScanningRay(canvas, center, radius);
  }

  void _drawBackdropAura(Canvas canvas, Offset center, double radius) {
    // Soft outer circular aura
    final auraPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFDCFCE7).withOpacity(0.9),
          const Color(0xFFE8F5E9).withOpacity(0.6),
          const Color(0xFFF4F9F1).withOpacity(0.0),
        ],
        stops: const [0.0, 0.65, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.35));

    canvas.drawCircle(center, radius * 1.35, auraPaint);

    // Organic Sun / Bio-sphere in upper right
    final sunOffset = Offset(center.dx + radius * 0.45, center.dy - radius * 0.45);
    final sunPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFA3E635).withOpacity(0.35),
          const Color(0xFF22C55E).withOpacity(0.15),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: sunOffset, radius: radius * 0.65));
    canvas.drawCircle(sunOffset, radius * 0.65, sunPaint);

    // Soft dashed orbital rings
    final orbitPaint = Paint()
      ..color = const Color(0xFF22C55E).withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawCircle(center, radius * 1.05, orbitPaint);
  }

  void _drawRuralFieldLandscape(Canvas canvas, Offset center, double radius) {
    // Rolling green ridges representing Bangladesh rural agricultural paddies
    final ridgePaint1 = Paint()
      ..color = const Color(0xFF86EFAC).withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final ridge1 = Path();
    ridge1.moveTo(center.dx - radius * 1.2, center.dy + radius * 0.8);
    ridge1.quadraticBezierTo(
      center.dx - radius * 0.4,
      center.dy + radius * 0.25,
      center.dx + radius * 1.2,
      center.dy + radius * 0.65,
    );
    ridge1.lineTo(center.dx + radius * 1.2, center.dy + radius * 1.2);
    ridge1.lineTo(center.dx - radius * 1.2, center.dy + radius * 1.2);
    ridge1.close();
    canvas.drawPath(ridge1, ridgePaint1);

    final ridgePaint2 = Paint()
      ..color = const Color(0xFF4ADE80).withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final ridge2 = Path();
    ridge2.moveTo(center.dx - radius * 1.2, center.dy + radius * 0.55);
    ridge2.quadraticBezierTo(
      center.dx + radius * 0.2,
      center.dy + radius * 0.35,
      center.dx + radius * 1.2,
      center.dy + radius * 0.85,
    );
    ridge2.lineTo(center.dx + radius * 1.2, center.dy + radius * 1.2);
    ridge2.lineTo(center.dx - radius * 1.2, center.dy + radius * 1.2);
    ridge2.close();
    canvas.drawPath(ridge2, ridgePaint2);

    // Lush rice / crop stalks on the left and right borders
    final stalkPaint = Paint()
      ..color = const Color(0xFF15803D).withOpacity(0.55)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final stalkOffsets = [
      Offset(center.dx - radius * 0.85, center.dy + radius * 0.35),
      Offset(center.dx - radius * 0.70, center.dy + radius * 0.42),
      Offset(center.dx - radius * 0.55, center.dy + radius * 0.50),
      Offset(center.dx + radius * 0.65, center.dy + radius * 0.45),
      Offset(center.dx + radius * 0.80, center.dy + radius * 0.38),
    ];

    for (final s in stalkOffsets) {
      final stalk = Path();
      stalk.moveTo(s.dx, s.dy + 45);
      stalk.quadraticBezierTo(s.dx - 8, s.dy + 20, s.dx, s.dy);
      stalk.quadraticBezierTo(s.dx + 12, s.dy - 10, s.dx + 18, s.dy - 16);
      canvas.drawPath(stalk, stalkPaint);

      // Grain head / leaf blades
      canvas.drawCircle(Offset(s.dx + 18, s.dy - 16), 3.5, Paint()..color = const Color(0xFF22C55E));
      canvas.drawCircle(Offset(s.dx + 12, s.dy - 10), 3.0, Paint()..color = const Color(0xFFA3E635));
    }
  }

  void _drawFarmerFigure(Canvas canvas, Offset center, double radius) {
    // Stylized friendly farmer situated on the left, leaning in attentively
    final farmerOrigin = Offset(center.dx - radius * 0.45, center.dy + radius * 0.15);

    // 1. Farmer Torso (Green rural kurta/vest)
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF166534), Color(0xFF14532D)],
      ).createShader(Rect.fromCircle(center: farmerOrigin, radius: 45));

    final bodyPath = Path();
    bodyPath.moveTo(farmerOrigin.dx - 30, farmerOrigin.dy + 70);
    bodyPath.quadraticBezierTo(farmerOrigin.dx - 25, farmerOrigin.dy + 15, farmerOrigin.dx, farmerOrigin.dy + 5);
    bodyPath.quadraticBezierTo(farmerOrigin.dx + 25, farmerOrigin.dy + 10, farmerOrigin.dx + 30, farmerOrigin.dy + 70);
    bodyPath.close();
    canvas.drawPath(bodyPath, bodyPaint);

    // 2. Traditional Gamcha (red/orange checked scarf draped gracefully over shoulder)
    final gamchaPaint = Paint()
      ..color = const Color(0xFFEA580C)
      ..style = PaintingStyle.fill;

    final gamcha = Path();
    gamcha.moveTo(farmerOrigin.dx - 18, farmerOrigin.dy + 6);
    gamcha.quadraticBezierTo(farmerOrigin.dx - 24, farmerOrigin.dy + 35, farmerOrigin.dx - 20, farmerOrigin.dy + 65);
    gamcha.lineTo(farmerOrigin.dx - 10, farmerOrigin.dy + 65);
    gamcha.quadraticBezierTo(farmerOrigin.dx - 12, farmerOrigin.dy + 35, farmerOrigin.dx - 8, farmerOrigin.dy + 8);
    gamcha.close();
    canvas.drawPath(gamcha, gamchaPaint);

    // 3. Farmer Head / Caring Face Profile
    final skinPaint = Paint()..color = const Color(0xFFD97706).withOpacity(0.85);
    final headCenter = Offset(farmerOrigin.dx, farmerOrigin.dy - 22);
    canvas.drawCircle(headCenter, 18, skinPaint);

    // Traditional rural headcloth / Mathal / Cap silhouette
    final hatPaint = Paint()
      ..color = const Color(0xFF15803D)
      ..style = PaintingStyle.fill;
    final hat = Path();
    hat.moveTo(headCenter.dx - 22, headCenter.dy - 6);
    hat.quadraticBezierTo(headCenter.dx, headCenter.dy - 28, headCenter.dx + 22, headCenter.dy - 6);
    hat.quadraticBezierTo(headCenter.dx, headCenter.dy - 14, headCenter.dx - 22, headCenter.dy - 6);
    canvas.drawPath(hat, hatPaint);

    // Farmer Arm reaching forward to support the plant stem
    final armPaint = Paint()
      ..color = const Color(0xFFD97706).withOpacity(0.9)
      ..strokeWidth = 9.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final armPath = Path();
    armPath.moveTo(farmerOrigin.dx + 12, farmerOrigin.dy + 22);
    armPath.quadraticBezierTo(farmerOrigin.dx + 32, farmerOrigin.dy + 28, center.dx - 8, center.dy + 28);
    canvas.drawPath(armPath, armPaint);

    // Hand gently cupping the leaf
    canvas.drawCircle(Offset(center.dx - 8, center.dy + 28), 6.5, Paint()..color = const Color(0xFFD97706));
  }

  void _drawCropLeaf(Canvas canvas, Offset center, double radius) {
    // The central plant leaf being diagnosed
    final leafOrigin = Offset(center.dx + radius * 0.05, center.dy + 15);
    const leafW = 32.0;
    const leafH = 68.0;

    canvas.save();
    canvas.translate(leafOrigin.dx, leafOrigin.dy);
    canvas.rotate(-0.25); // natural gentle tilt towards farmer

    // Stem
    final stemPaint = Paint()
      ..color = const Color(0xFF166534)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(0, leafH * 0.45), const Offset(-12, leafH * 0.75), stemPaint);

    // Leaf Body
    final leafPath = Path();
    leafPath.moveTo(0, leafH * 0.45);
    leafPath.cubicTo(-leafW * 1.1, leafH * 0.1, -leafW * 0.9, -leafH * 0.35, 0, -leafH * 0.52);
    leafPath.cubicTo(leafW * 0.9, -leafH * 0.35, leafW * 1.1, leafH * 0.1, 0, leafH * 0.45);
    leafPath.close();

    // Leaf Fill Gradient
    final leafShader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF86EFAC), Color(0xFF22C55E), Color(0xFF14532D)],
      stops: [0.0, 0.45, 1.0],
    ).createShader(const Rect.fromLTWH(-leafW, -leafH * 0.55, leafW * 2, leafH));

    canvas.drawPath(leafPath, Paint()..shader = leafShader);

    // Leaf Outline
    canvas.drawPath(
      leafPath,
      Paint()
        ..color = const Color(0xFFA3E635)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    // Leaf Central Midrib
    final veinPaint = Paint()
      ..color = const Color(0xFFDCFCE7).withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawLine(const Offset(0, leafH * 0.40), const Offset(0, -leafH * 0.46), veinPaint);

    canvas.restore();
  }

  void _drawSmartphoneScanner(Canvas canvas, Offset center, double radius) {
    // Smartphone positioned on the right, aiming at the leaf
    final phoneCenter = Offset(center.dx + radius * 0.48, center.dy - radius * 0.05);
    const phoneW = 38.0;
    const phoneH = 68.0;

    canvas.save();
    canvas.translate(phoneCenter.dx, phoneCenter.dy);
    canvas.rotate(-0.18); // angled downwards towards the leaf

    // Phone Shadow
    final shadowRRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-phoneW / 2 + 3, -phoneH / 2 + 5, phoneW, phoneH),
      const Radius.circular(8),
    );
    canvas.drawRRect(shadowRRect, Paint()..color = Colors.black.withOpacity(0.12)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));

    // Phone Outer Body (Titanium / Forest Green)
    final bodyRRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-phoneW / 2, -phoneH / 2, phoneW, phoneH),
      const Radius.circular(8),
    );
    canvas.drawRRect(bodyRRect, Paint()..color = const Color(0xFF0F381E));
    canvas.drawRRect(bodyRRect, Paint()..color = const Color(0xFF22C55E)..style = PaintingStyle.stroke..strokeWidth = 1.2);

    // Phone Screen
    final screenRRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-phoneW / 2 + 2.5, -phoneH / 2 + 3.5, phoneW - 5, phoneH - 7),
      const Radius.circular(6),
    );
    canvas.drawRRect(screenRRect, Paint()..color = const Color(0xFF041A0C));

    // Screen HUD: Mini Reticle & Disease Detection Tag
    final hudReticlePaint = Paint()
      ..color = const Color(0xFFA3E635)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Small square bracket reticle on screen
    const boxSize = 12.0;
    canvas.drawRect(
      Rect.fromCenter(center: const Offset(0, -2), width: boxSize, height: boxSize),
      hudReticlePaint,
    );

    // Health pill metric on phone screen
    final tagRRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-10, 14, 20, 7),
      const Radius.circular(3),
    );
    canvas.drawRRect(tagRRect, Paint()..color = const Color(0xFF22C55E));

    canvas.restore();
  }

  void _drawAiScanningRay(Canvas canvas, Offset center, double radius) {
    // Holographic laser beam emitting from smartphone and sweeping across leaf
    final phoneTip = Offset(center.dx + radius * 0.36, center.dy - radius * 0.05);
    final leafTarget = Offset(center.dx + radius * 0.05, center.dy + 15);

    // Scan beam projection cone
    final rayPath = Path();
    rayPath.moveTo(phoneTip.dx, phoneTip.dy);
    rayPath.lineTo(leafTarget.dx - 25, leafTarget.dy - 35);
    rayPath.lineTo(leafTarget.dx + 25, leafTarget.dy + 35);
    rayPath.close();

    final rayShader = LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        const Color(0xFFA3E635).withOpacity(0.40),
        const Color(0xFF22C55E).withOpacity(0.18),
        Colors.transparent,
      ],
      stops: const [0.0, 0.45, 1.0],
    ).createShader(Rect.fromPoints(phoneTip, leafTarget));

    canvas.drawPath(rayPath, Paint()..shader = rayShader);

    // Laser Core Line moving vertically across leaf
    final scanYOffset = (scanProgress - 0.5) * 55.0;
    final laserStart = Offset(leafTarget.dx - 28, leafTarget.dy + scanYOffset);
    final laserEnd = Offset(leafTarget.dx + 28, leafTarget.dy + scanYOffset);

    // Laser Glow
    final laserGlowPaint = Paint()
      ..color = const Color(0xFFA3E635).withOpacity(0.75)
      ..strokeWidth = 3.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawLine(laserStart, laserEnd, laserGlowPaint);

    // Laser Core Line
    final laserCorePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.6;
    canvas.drawLine(laserStart, laserEnd, laserCorePaint);

    // Computer Vision Bounding Corner Brackets `[ ]` over leaf
    final bracketPaint = Paint()
      ..color = const Color(0xFF22C55E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    const bSize = 38.0;
    const cLen = 8.0;
    final bCenter = leafTarget;

    // Top-left
    canvas.drawLine(Offset(bCenter.dx - bSize, bCenter.dy - bSize + cLen), Offset(bCenter.dx - bSize, bCenter.dy - bSize), bracketPaint);
    canvas.drawLine(Offset(bCenter.dx - bSize, bCenter.dy - bSize), Offset(bCenter.dx - bSize + cLen, bCenter.dy - bSize), bracketPaint);
    // Top-right
    canvas.drawLine(Offset(bCenter.dx + bSize - cLen, bCenter.dy - bSize), Offset(bCenter.dx + bSize, bCenter.dy - bSize), bracketPaint);
    canvas.drawLine(Offset(bCenter.dx + bSize, bCenter.dy - bSize), Offset(bCenter.dx + bSize, bCenter.dy - bSize + cLen), bracketPaint);
    // Bottom-left
    canvas.drawLine(Offset(bCenter.dx - bSize, bCenter.dy + bSize - cLen), Offset(bCenter.dx - bSize, bCenter.dy + bSize), bracketPaint);
    canvas.drawLine(Offset(bCenter.dx - bSize, bCenter.dy + bSize), Offset(bCenter.dx - bSize + cLen, bCenter.dy + bSize), bracketPaint);
    // Bottom-right
    canvas.drawLine(Offset(bCenter.dx + bSize - cLen, bCenter.dy + bSize), Offset(bCenter.dx + bSize, bCenter.dy + bSize), bracketPaint);
    canvas.drawLine(Offset(bCenter.dx + bSize, bCenter.dy + bSize), Offset(bCenter.dx + bSize, bCenter.dy + bSize - cLen), bracketPaint);

    // Digital float particles
    final particlePaint = Paint()..color = const Color(0xFFA3E635);
    final randPoints = [
      Offset(bCenter.dx - 18, bCenter.dy - 12 + scanYOffset * 0.4),
      Offset(bCenter.dx + 16, bCenter.dy + 8 - scanYOffset * 0.3),
      Offset(bCenter.dx + 4, bCenter.dy - 22 + scanYOffset * 0.2),
      Offset(bCenter.dx - 8, bCenter.dy + 18 + scanYOffset * 0.5),
    ];
    for (final p in randPoints) {
      canvas.drawCircle(p, 1.8, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HeroIllustrationPainter oldDelegate) {
    return oldDelegate.scanProgress != scanProgress || oldDelegate.pageIndex != pageIndex;
  }
}

