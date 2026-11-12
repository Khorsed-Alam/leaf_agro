import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedLoadingDots extends StatelessWidget {
  final double progress; // 0.0 to 1.0 continuously
  final Color dotColor;

  const AnimatedLoadingDots({
    super.key,
    required this.progress,
    this.dotColor = const Color(0xFF6BFF9D),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        // Offset each dot's bounce cycle
        final delay = index * 0.25;
        final cycle = (progress + delay) % 1.0;
        final bounce = math.sin(cycle * math.pi); // 0 -> 1 -> 0

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3.5),
          child: Transform.translate(
            offset: Offset(0, -bounce * 5.0),
            child: Container(
              width: 5.5,
              height: 5.5,
              decoration: BoxDecoration(
                color: dotColor.withOpacity(0.4 + (bounce * 0.6)),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: dotColor.withOpacity(bounce * 0.7),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

