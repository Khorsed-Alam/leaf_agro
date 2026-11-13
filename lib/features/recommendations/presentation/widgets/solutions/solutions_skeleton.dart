import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

/// Screen 20 – Solutions Skeleton
/// Shimmer loading layout for Screen 20 during network/cache retrieval.
class SolutionsSkeleton extends StatefulWidget {
  const SolutionsSkeleton({super.key});

  @override
  State<SolutionsSkeleton> createState() => _SolutionsSkeletonState();
}

class _SolutionsSkeletonState extends State<SolutionsSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.35, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _box({
    required double height,
    double? width,
    double radius = 12,
  }) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Disease Summary Card skeleton
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderGreen),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _box(height: 52, width: 52, radius: 14),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _box(height: 14, width: 110, radius: 6),
                          const SizedBox(height: 8),
                          _box(height: 18, width: 180, radius: 6),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _box(height: 12, width: double.infinity, radius: 4),
                const SizedBox(height: 6),
                _box(height: 12, width: 220, radius: 4),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 2. Biological Management Card skeleton
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderGreen),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _box(height: 36, width: 36, radius: 10),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _box(height: 16, width: 160, radius: 6),
                          const SizedBox(height: 6),
                          _box(height: 12, width: 220, radius: 4),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _box(height: 70, radius: 12),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 3. Cultural Management Card skeleton
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderGreen),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _box(height: 36, width: 36, radius: 10),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _box(height: 16, width: 150, radius: 6),
                          const SizedBox(height: 6),
                          _box(height: 12, width: 200, radius: 4),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _box(height: 54, radius: 10),
                const SizedBox(height: 8),
                _box(height: 54, radius: 10),
                const SizedBox(height: 8),
                _box(height: 54, radius: 10),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 4. Safety skeleton
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFFED7AA)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _box(height: 20, width: 180, radius: 6),
                const SizedBox(height: 12),
                _box(height: 48, radius: 10),
                const SizedBox(height: 8),
                _box(height: 48, radius: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

