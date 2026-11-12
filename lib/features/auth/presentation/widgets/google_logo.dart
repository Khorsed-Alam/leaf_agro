import 'package:flutter/material.dart';

class GoogleLogo extends StatelessWidget {
  final double size;

  const GoogleLogo({super.key, this.size = 20.0});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w / 2;

    // Google 4-Color Palette
    const blue = Color(0xFF4285F4);
    const red = Color(0xFFEA4335);
    const yellow = Color(0xFFFBBC05);
    const green = Color(0xFF34A853);

    final strokeWidth = w * 0.22;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final arcRect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    // 1. Red Top Arc
    paint.color = red;
    canvas.drawArc(arcRect, -0.75 * 3.14159, 0.75 * 3.14159, false, paint);

    // 2. Yellow Left Arc
    paint.color = yellow;
    canvas.drawArc(arcRect, 0.75 * 3.14159, 0.5 * 3.14159, false, paint);

    // 3. Green Bottom Arc
    paint.color = green;
    canvas.drawArc(arcRect, 0.25 * 3.14159, 0.5 * 3.14159, false, paint);

    // 4. Blue Right Arc & Horizontal Bar
    paint.color = blue;
    canvas.drawArc(arcRect, -0.05 * 3.14159, 0.30 * 3.14159, false, paint);

    // Blue Center Bar
    final barPaint = Paint()
      ..color = blue
      ..style = PaintingStyle.fill;
    final barRect = Rect.fromLTWH(center.dx - strokeWidth * 0.1, center.dy - strokeWidth / 2, radius * 0.95, strokeWidth);
    canvas.drawRRect(RRect.fromRectAndRadius(barRect, Radius.circular(strokeWidth * 0.15)), barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

