import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/leaf_image_view.dart';

/// Scanning Image View with Corner Reticles and Animated Laser Line
class ScanningImageView extends StatefulWidget {
  final String imagePath;
  final String? selectedCropName;
  final bool animate;
  final bool isBn;

  const ScanningImageView({
    super.key,
    required this.imagePath,
    this.selectedCropName,
    this.animate = true,
    required this.isBn,
  });

  @override
  State<ScanningImageView> createState() => _ScanningImageViewState();
}

class _ScanningImageViewState extends State<ScanningImageView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _scanAnimation = Tween<double>(begin: 0.05, end: 0.95).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutSine,
      ),
    );

    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant ScanningImageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate != oldWidget.animate) {
      if (widget.animate) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          height: 270,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.borderGreen,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.forestGreen.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Main Leaf Photograph (Preserving Aspect Ratio)
                LeafImageView(
                  imagePath: widget.imagePath,
                  fit: BoxFit.contain,
                ),

                // 2. Corner Brackets Reticle Painter
                Positioned.fill(
                  child: CustomPaint(
                    painter: _CornerBracketsPainter(
                      color: AppColors.freshGreen,
                      strokeWidth: 3.5,
                      cornerLength: 24.0,
                      radius: 20.0,
                    ),
                  ),
                ),

                // 3. Subtle Ambient Green Glow
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 0.85,
                        colors: [
                          AppColors.freshGreen.withValues(alpha: 0.04),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // 4. Animated Scanning Laser Line
                if (widget.animate)
                  AnimatedBuilder(
                    animation: _scanAnimation,
                    builder: (context, child) {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final topPos =
                              constraints.maxHeight * _scanAnimation.value;
                          return Positioned(
                            top: topPos,
                            left: 8,
                            right: 8,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Glowing trail
                                Container(
                                  height: 14,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        AppColors.freshGreen
                                            .withValues(alpha: 0.25),
                                      ],
                                    ),
                                  ),
                                ),
                                // Sharp scanning line
                                Container(
                                  height: 2.5,
                                  decoration: BoxDecoration(
                                    color: AppColors.limeGreen,
                                    borderRadius: BorderRadius.circular(2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.freshGreen
                                            .withValues(alpha: 0.8),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
        ),

        // Optional Selected Crop Context Pill
        if (widget.selectedCropName != null &&
            widget.selectedCropName!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.freshGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.freshGreen.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.eco_rounded,
                  color: AppColors.forestGreen,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  widget.isBn
                      ? 'ফসলের ধরন: ${widget.selectedCropName!}'
                      : 'Target Crop: ${widget.selectedCropName!}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.forestGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Custom painter for the 4 corner brackets
class _CornerBracketsPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double cornerLength;
  final double radius;

  _CornerBracketsPainter({
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
  bool shouldRepaint(covariant _CornerBracketsPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.cornerLength != cornerLength ||
        oldDelegate.radius != radius;
  }
}
