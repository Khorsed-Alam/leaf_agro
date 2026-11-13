import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

/// Leaf Positioning Guide Overlay
/// Provides a clear viewfinder reticle with corner brackets and instructional text for farmers.
class LeafPositioningGuide extends StatelessWidget {
  final bool isBn;

  const LeafPositioningGuide({
    super.key,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final size = media.size;

    // Viewfinder dimensions: ~72% width, max 340px, aspect ratio 1:1.15
    final boxWidth = (size.width * 0.72).clamp(240.0, 340.0);
    final boxHeight = boxWidth * 1.15;

    return IgnorePointer(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Viewfinder Rect Box with corner accents
            Container(
              width: boxWidth,
              height: boxHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                  width: 1.5,
                ),
              ),
              child: Stack(
                children: [
                  // Corner accent painters
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _CornerAccentsPainter(
                        color: AppColors.freshGreen,
                        strokeWidth: 4.0,
                        cornerLength: 28.0,
                        radius: 24.0,
                      ),
                    ),
                  ),

                  // Center subtle leaf watermark
                  Center(
                    child: Icon(
                      Icons.eco_outlined,
                      size: 54,
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Instruction Pill
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white12,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isBn
                        ? 'পাতার অংশটি ফ্রেমের ভেতরে রাখুন'
                        : 'Place the leaf inside the frame',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isBn
                        ? 'হাত স্থির রাখুন এবং ঝাপসা বা আলো এড়ান'
                        : 'Hold steady & avoid glare / heavy shadow',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for the 4 corner brackets of the viewfinder reticle
class _CornerAccentsPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double cornerLength;
  final double radius;

  _CornerAccentsPainter({
    required this.color,
    required this.strokeWidth,
    required this.cornerLength,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    // Top-Left
    final pathTL = Path()
      ..moveTo(0, cornerLength)
      ..lineTo(0, radius)
      ..arcToPoint(Offset(radius, 0), radius: Radius.circular(radius))
      ..lineTo(cornerLength, 0);
    canvas.drawPath(pathTL, paint);

    // Top-Right
    final pathTR = Path()
      ..moveTo(w - cornerLength, 0)
      ..lineTo(w - radius, 0)
      ..arcToPoint(Offset(w, radius), radius: Radius.circular(radius))
      ..lineTo(w, cornerLength);
    canvas.drawPath(pathTR, paint);

    // Bottom-Left
    final pathBL = Path()
      ..moveTo(0, h - cornerLength)
      ..lineTo(0, h - radius)
      ..arcToPoint(Offset(radius, h), radius: Radius.circular(radius))
      ..lineTo(cornerLength, h);
    canvas.drawPath(pathBL, paint);

    // Bottom-Right
    final pathBR = Path()
      ..moveTo(w - cornerLength, h)
      ..lineTo(w - radius, h)
      ..arcToPoint(Offset(w, h - radius), radius: Radius.circular(radius))
      ..lineTo(w, h - cornerLength);
    canvas.drawPath(pathBR, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerAccentsPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.cornerLength != cornerLength ||
        oldDelegate.radius != radius;
  }
}
