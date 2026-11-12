import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Single item within the Image Quality Guide
class ImageQualityTip extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const ImageQualityTip({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Small Green Icon Badge
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.freshGreen.withValues(alpha: 0.35),
            ),
          ),
          child: Center(
            child: Icon(
              icon,
              size: 15,
              color: AppColors.forestGreen,
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.secondaryText,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
