import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// A custom brand emblem displaying a leaf integrated with AI neural scan lines.
class AuthLogoBadge extends StatelessWidget {
  final double size;

  const AuthLogoBadge({super.key, this.size = 72.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF14532D), // Deep Forest Green
            Color(0xFF166534),
            Color(0xFF15803D), // Fresh Emerald Green
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.32),
        border: Border.all(
          color: AppColors.limeGreen.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.forestGreen.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.freshGreen.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.32),
        child: CustomPaint(
          size: Size(size, size),
          painter: _AuthLogoPainter(),
        ),
      ),
    );
  }
}

class _AuthLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    // 1. Subtle background grid / circuit lines
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, w * 0.4, gridPaint);
    canvas.drawCircle(center, w * 0.25, gridPaint);

    // 2. Leaf silhouette
    final leafPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFA3E635), // Lime accent
          Color(0xFF4ADE80), // Fresh leaf green
          Colors.white,
        ],
        stops: [0.0, 0.65, 1.0],
      ).createShader(Rect.fromCenter(center: center, width: w, height: h))
      ..style = PaintingStyle.fill;

    final leafPath = Path();
    final topPoint = Offset(w * 0.5, h * 0.22);
    final bottomPoint = Offset(w * 0.5, h * 0.78);

    // Right leaf curve
    leafPath.moveTo(topPoint.dx, topPoint.dy);
    leafPath.cubicTo(
      w * 0.78,
      h * 0.32,
      w * 0.78,
      h * 0.64,
      bottomPoint.dx,
      bottomPoint.dy,
    );

    // Left leaf curve
    leafPath.cubicTo(
      w * 0.22,
      h * 0.64,
      w * 0.22,
      h * 0.32,
      topPoint.dx,
      topPoint.dy,
    );
    leafPath.close();

    canvas.drawPath(leafPath, leafPaint);

    // 3. Central leaf stem / vein
    final stemPaint = Paint()
      ..color = AppColors.forestGreen.withValues(alpha: 0.8)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final stemPath = Path();
    stemPath.moveTo(topPoint.dx, topPoint.dy + 4);
    stemPath.quadraticBezierTo(
      w * 0.49,
      h * 0.5,
      bottomPoint.dx,
      bottomPoint.dy - 2,
    );
    canvas.drawPath(stemPath, stemPaint);

    // 4. AI Neural nodes & Scanning Beam
    final nodePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = AppColors.limeGreen
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final nodes = [
      Offset(w * 0.38, h * 0.45),
      Offset(w * 0.62, h * 0.42),
      Offset(w * 0.42, h * 0.58),
      Offset(w * 0.58, h * 0.56),
    ];

    final beamPaint = Paint()
      ..color = AppColors.limeGreen.withValues(alpha: 0.75)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Draw neural connection lines
    canvas.drawLine(nodes[0], Offset(w * 0.5, h * 0.44), beamPaint);
    canvas.drawLine(nodes[1], Offset(w * 0.5, h * 0.44), beamPaint);
    canvas.drawLine(nodes[2], Offset(w * 0.5, h * 0.57), beamPaint);
    canvas.drawLine(nodes[3], Offset(w * 0.5, h * 0.57), beamPaint);

    // Draw nodes with lime glow
    for (final node in nodes) {
      canvas.drawCircle(node, 2.8, glowPaint);
      canvas.drawCircle(node, 1.8, nodePaint);
    }

    // Top AI Scan Sparkle
    final sparklePaint = Paint()
      ..color = AppColors.limeGreen
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(topPoint.dx, topPoint.dy - 1), 2.2, sparklePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
