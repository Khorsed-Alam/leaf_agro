import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

/// Top branding header for Screen 15 – AI Analysis Screen
/// Uncluttered layout displaying the AgriCare AI branding without disruptive navigation.
class AnalyzingHeader extends StatelessWidget {
  final bool isBn;

  const AnalyzingHeader({
    super.key,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.freshGreen.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.eco_rounded,
              color: AppColors.forestGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'AgriCare AI',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.forestGreen,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}
