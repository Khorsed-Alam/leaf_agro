import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

/// Status badge indicating whether the plant is Healthy or Disease Detected
class PredictionStatusBadge extends StatelessWidget {
  final bool isHealthy;
  final bool isBn;

  const PredictionStatusBadge({
    super.key,
    required this.isHealthy,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isHealthy
        ? AppColors.freshGreen.withValues(alpha: 0.15)
        : Colors.amber.shade50;
    final borderColor =
        isHealthy ? AppColors.freshGreen : Colors.amber.shade400;
    final textColor = isHealthy ? AppColors.forestGreen : Colors.amber.shade900;
    final icon =
        isHealthy ? Icons.check_circle_rounded : Icons.warning_amber_rounded;
    final label = isHealthy
        ? (isBn ? 'সুস্থ উদ্ভিদ' : 'Healthy Plant')
        : (isBn ? 'রোগ শনাক্ত হয়েছে' : 'Disease Detected');

    return Semantics(
      label: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: borderColor.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: textColor,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: textColor,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
