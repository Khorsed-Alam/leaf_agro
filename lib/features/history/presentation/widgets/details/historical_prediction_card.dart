import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/status_badge.dart';

/// Screen 23 – Historical Prediction Card
/// Displays the genuine historical AI prediction: Disease Detected, Healthy, or Uncertain.
class HistoricalPredictionCard extends StatelessWidget {
  final String predictedClass;
  final String diseaseName;
  final bool isHealthy;
  final bool isBn;

  const HistoricalPredictionCard({
    super.key,
    required this.predictedClass,
    required this.diseaseName,
    required this.isHealthy,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    final statusBg = isHealthy
        ? AppColors.secondaryContainer
        : AppColors.errorContainer.withValues(alpha: 0.6);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isHealthy
              ? AppColors.borderGreen
              : const Color(0xFFFCA5A5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Status Badge Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: statusBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isHealthy
                          ? Icons.check_circle_rounded
                          : Icons.warning_amber_rounded,
                      size: 16,
                      color: isHealthy
                          ? AppColors.forestGreen
                          : AppColors.error,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isHealthy
                        ? (isBn ? 'সুস্থ উদ্ভিদ' : 'Healthy Prediction')
                        : (isBn ? 'রোগ শনাক্ত হয়েছে' : 'Disease Detected'),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isHealthy
                          ? AppColors.forestGreen
                          : AppColors.error,
                    ),
                  ),
                ],
              ),
              StatusBadge(
                label: isHealthy
                    ? (isBn ? 'সুস্থ' : 'Healthy')
                    : (isBn ? 'রোগাক্রান্ত' : 'Diseased'),
                isHealthy: isHealthy,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Main Prediction Headline
          Text(
            isHealthy
                ? (isBn
                    ? 'গাছের পাতা সম্পূর্ণ সুস্থ দেখাচ্ছে'
                    : 'Foliage appears healthy')
                : diseaseName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryText,
              letterSpacing: -0.3,
            ),
          ),

          const SizedBox(height: 6),

          // Supporting Diagnosis Narrative
          Text(
            isHealthy
                ? (isBn
                    ? 'এই সংরক্ষিত স্ক্যানে কোনো পরিচিত রোগের লক্ষণ পাওয়া যায়নি।'
                    : 'No disease pathology was identified in this historical scan.')
                : (isBn
                    ? 'এই সংরক্ষিত স্ক্যানে এআই মডেল উক্ত রোগটির উপস্থিতি চিহ্নিত করেছিল।'
                    : 'The AI model identified symptoms associated with this pathology.'),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.secondaryText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
