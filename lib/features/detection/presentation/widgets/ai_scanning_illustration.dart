import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Central AI Scanning Illustration for Screen 11
/// Features a botanical plant leaf illustration, camera viewfinder corner reticles,
/// subtle AI tracking nodes, and an animated laser scanning beam sweeping vertically.
class AiScanningIllustration extends StatefulWidget {
  final bool isBn;
  final bool animate;

  const AiScanningIllustration({
    super.key,
    required this.isBn,
    this.animate = true,
  });

  @override
  State<AiScanningIllustration> createState() => _AiScanningIllustrationState();
}

class _AiScanningIllustrationState extends State<AiScanningIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    if (widget.animate) {
      _scanController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Container(
        height: 210,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border, width: 1.2),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFAFCF9),
              Color(0xFFF1F7EE),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.forestGreen.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. Subtle Radial Background Glow
              Positioned.fill(
                child: CustomPaint(
                  painter: _RadialGlowPainter(),
                ),
              ),

              // 2. Viewfinder Reticle Corner Brackets
              const Positioned.fill(
                child: _ReticleCornerBrackets(),
              ),

              // 3. Central Botanical Leaf with Veins & Tech Nodes
              SizedBox(
                width: 140,
                height: 140,
                child: CustomPaint(
                  painter: _BotanicalLeafPainter(),
                ),
              ),

              // 4. Subtle Animated AI Scanning Beam (Sweeps vertically across leaf)
              AnimatedBuilder(
                animation: _scanController,
                builder: (context, child) {
                  final progress =
                      disableAnimations ? 0.5 : _scanController.value;
                  final beamTop = 20.0 + (progress * 160.0);

                  return Positioned(
                    top: beamTop,
                    left: 28,
                    right: 28,
                    child: Container(
                      height: 2.2,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.freshGreen.withValues(alpha: 0.8),
                            blurRadius: 8,
                            spreadRadius: 2.5,
                          ),
                          BoxShadow(
                            color: AppColors.limeGreen.withValues(alpha: 0.5),
                            blurRadius: 14,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // 5. Tech Spec Pill (Bottom Center)
              Positioned(
                bottom: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.freshGreen.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 4,
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
                          shape: BoxShape.circle,
                          color: AppColors.freshGreen,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.isBn
                            ? 'AI পাতা স্ক্যানার • ২২৪x২২৪ এজ মডেল'
                            : 'AI Leaf Scanner • 224x224 Edge Model',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.forestGreen,
                          letterSpacing: 0.2,
                        ),
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

/// CustomPainter that renders a vibrant botanical leaf with main & side veins
class _BotanicalLeafPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final width = size.width * 0.46;
    final height = size.height * 0.76;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-math.pi / 16); // Gentle natural leaf tilt

    // Leaf Outline Path
    final leafPath = Path();
    leafPath.moveTo(0, -height / 2); // Leaf Tip
    // Right leaf lobe curve
    leafPath.cubicTo(
      width * 1.05, -height * 0.15,
      width * 0.85, height * 0.35,
      0, height / 2, // Leaf Base
    );
    // Left leaf lobe curve
    leafPath.cubicTo(
      -width * 0.85, height * 0.35,
      -width * 1.05, -height * 0.15,
      0, -height / 2, // Back to Leaf Tip
    );
    leafPath.close();

    // 1. Ambient Green Glow
    final glowPaint = Paint()
      ..color = AppColors.freshGreen.withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);
    canvas.drawPath(leafPath, glowPaint);

    // 2. Leaf Body Fill (Gradient from Fresh Green to Deep Forest Green)
    final leafShader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF4ADE80),
        Color(0xFF22C55E),
        Color(0xFF15803D),
        Color(0xFF14532D),
      ],
      stops: [0.0, 0.35, 0.75, 1.0],
    ).createShader(Rect.fromCenter(center: Offset.zero, width: width * 2, height: height));

    final leafFillPaint = Paint()
      ..shader = leafShader
      ..style = PaintingStyle.fill;
    canvas.drawPath(leafPath, leafFillPaint);

    // 3. Central Stem / Midrib Vein
    final midribPath = Path();
    midribPath.moveTo(0, height / 2 + 8); // Stem extending slightly below
    midribPath.quadraticBezierTo(1, 0, 0, -height / 2);

    final midribPaint = Paint()
      ..color = const Color(0xFFDCFCE7).withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(midribPath, midribPaint);

    // 4. Secondary Lateral Veins
    final veinPaint = Paint()
      ..color = const Color(0xFFDCFCE7).withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;

    final veinOffsets = [-height * 0.28, -height * 0.10, height * 0.08, height * 0.24];
    for (int i = 0; i < veinOffsets.length; i++) {
      final y = veinOffsets[i];
      // Right Vein
      canvas.drawLine(
        Offset(0, y),
        Offset(width * 0.52 * (1.0 - (y / height).abs()), y - (height * 0.10)),
        veinPaint,
      );
      // Left Vein
      canvas.drawLine(
        Offset(0, y),
        Offset(-width * 0.52 * (1.0 - (y / height).abs()), y - (height * 0.10)),
        veinPaint,
      );
    }

    // 5. AI Detection Point Reticles (Tracking nodes)
    _drawTrackingNode(canvas, Offset(width * 0.30, -height * 0.15));
    _drawTrackingNode(canvas, Offset(-width * 0.25, height * 0.08));
    _drawTrackingNode(canvas, Offset(width * 0.15, height * 0.22));

    canvas.restore();
  }

  void _drawTrackingNode(Canvas canvas, Offset offset) {
    // Outer Target Ring
    final ringPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(offset, 4.5, ringPaint);

    // Inner Glowing Core
    final corePaint = Paint()
      ..color = AppColors.limeGreen
      ..style = PaintingStyle.fill;
    canvas.drawCircle(offset, 2.0, corePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Subtle radial glow painter behind the leaf
class _RadialGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.freshGreen.withValues(alpha: 0.12),
          AppColors.freshGreen.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 90));
    canvas.drawCircle(center, 90, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Reticle Corner Brackets (agricultural camera viewfinder aesthetic)
class _ReticleCornerBrackets extends StatelessWidget {
  const _ReticleCornerBrackets();

  @override
  Widget build(BuildContext context) {
    const bracketSize = 22.0;
    const strokeWidth = 2.5;
    const color = AppColors.freshGreen;

    return Stack(
      children: [
        // Top-Left
        Positioned(
          top: 14,
          left: 14,
          child: CustomPaint(
            size: const Size(bracketSize, bracketSize),
            painter: _CornerPainter(
              color: color,
              strokeWidth: strokeWidth,
              isTop: true,
              isLeft: true,
            ),
          ),
        ),
        // Top-Right
        Positioned(
          top: 14,
          right: 14,
          child: CustomPaint(
            size: const Size(bracketSize, bracketSize),
            painter: _CornerPainter(
              color: color,
              strokeWidth: strokeWidth,
              isTop: true,
              isLeft: false,
            ),
          ),
        ),
        // Bottom-Left
        Positioned(
          bottom: 14,
          left: 14,
          child: CustomPaint(
            size: const Size(bracketSize, bracketSize),
            painter: _CornerPainter(
              color: color,
              strokeWidth: strokeWidth,
              isTop: false,
              isLeft: true,
            ),
          ),
        ),
        // Bottom-Right
        Positioned(
          bottom: 14,
          right: 14,
          child: CustomPaint(
            size: const Size(bracketSize, bracketSize),
            painter: _CornerPainter(
              color: color,
              strokeWidth: strokeWidth,
              isTop: false,
              isLeft: false,
            ),
          ),
        ),
      ],
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final bool isTop;
  final bool isLeft;

  _CornerPainter({
    required this.color,
    required this.strokeWidth,
    required this.isTop,
    required this.isLeft,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    if (isTop && isLeft) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (isTop && !isLeft) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (!isTop && isLeft) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
