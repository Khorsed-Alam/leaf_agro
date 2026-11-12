import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final bool isHealthy;

  const StatusBadge({
    super.key,
    required this.label,
    required this.isHealthy,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isHealthy ? AppColors.secondaryContainer : AppColors.errorContainer;
    final textColor = isHealthy ? AppColors.onSecondaryContainer : AppColors.onErrorContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isHealthy ? Icons.check_circle_outline : Icons.warning_amber_rounded,
            size: 14,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

