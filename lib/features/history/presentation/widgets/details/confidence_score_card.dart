import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

/// Screen 23 – Confidence Score Card
/// Displays original model confidence with progress indicator and honest disclaimer.
class ConfidenceScoreCard extends StatelessWidget {
  final double confidence;
  final bool isHealthy;
  final bool isBn;

  const ConfidenceScoreCard({
    super.key,
    required this.confidence,
    required this.isHealthy,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    final hasConfidence = confidence > 0;
    final percentage = (confidence * 100).clamp(0.0, 100.0);
    final formattedPercent = percentage.toStringAsFixed(1);
    final barValue = (confidence).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.borderGreen,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.speed_rounded,
                    size: 18,
                    color: AppColors.forestGreen,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isBn ? 'এআই নিশ্চিততা' : 'AI Confidence',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryText,
                    ),
                  ),
                ],
              ),
              Text(
                hasConfidence
                    ? '$formattedPercent%'
                    : (isBn ? 'উপলব্ধ নেই' : 'Unavailable'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.forestGreen,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Progress Indicator
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: hasConfidence ? barValue : 0.0,
              minHeight: 8,
              backgroundColor: AppColors.surfaceContainerLow,
              valueColor: AlwaysStoppedAnimation<Color>(
                isHealthy ? AppColors.freshGreen : AppColors.forestGreen,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Explanatory note
          Text(
            isBn
                ? 'এই ঐতিহাসিক পূর্বাভাসের জন্য এআই মডেলের নিশ্চিততার মাত্রা। এটি কোনো নিখুঁত নিশ্চয়তা নয়।'
                : 'Model confidence for this historical prediction. Not a diagnostic guarantee.',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.secondaryText,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
