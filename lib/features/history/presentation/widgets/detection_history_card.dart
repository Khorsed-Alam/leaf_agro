import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../data/models/prediction_history_model.dart';
import '../../../../shared/widgets/leaf_image_view.dart';
import '../../../../shared/widgets/status_badge.dart';

/// Screen 22 – Detection History Card
/// Displays an individual historical plant scan with authentic thumbnail,
/// crop name, predicted disease/healthy state, confidence %, date, and chevron.
class DetectionHistoryCard extends StatelessWidget {
  final PredictionHistoryModel scan;
  final bool isBn;
  final VoidCallback onTap;

  const DetectionHistoryCard({
    super.key,
    required this.scan,
    required this.isBn,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final parts = scan.predictedClass.split('___');
    final crop = parts[0];
    final disease = parts.length > 1 ? parts[1].replaceAll('_', ' ') : 'Healthy';
    final isHealthy = disease.toLowerCase().contains('healthy') ||
        scan.predictedClass.toLowerCase().contains('healthy');

    final hasConfidence = scan.confidence > 0;
    final confidencePercent = (scan.confidence * 100).toStringAsFixed(1);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderGreen,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Left Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: scan.imagePath != null && scan.imagePath!.isNotEmpty
                        ? LeafImageView(
                            imagePath: scan.imagePath!,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: AppColors.surfaceContainerLow,
                            child: Icon(
                              isHealthy ? Icons.eco_rounded : Icons.bug_report_rounded,
                              size: 32,
                              color: isHealthy
                                  ? AppColors.forestGreen
                                  : AppColors.error,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),

                // 2. Center Information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Crop Name
                      Text(
                        crop,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.forestGreen,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 2),

                      // Disease Name or Healthy
                      Text(
                        isHealthy
                            ? (isBn ? 'সুস্থ উদ্ভিদ' : 'Healthy Plant')
                            : disease,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryText,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Date and Time
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            size: 12,
                            color: AppColors.secondaryText,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              DateFormatter.formatTimestamp(scan.createdAt),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.secondaryText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),

                      // Confidence Percentage
                      Text(
                        hasConfidence
                            ? (isBn
                                ? 'নিশ্চিততা: $confidencePercent%'
                                : 'Confidence: $confidencePercent%')
                            : (isBn
                                ? 'নিশ্চিততা উপলব্ধ নেই'
                                : 'Confidence unavailable'),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // 3. Right Status Badge & Chevron
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StatusBadge(
                      label: isHealthy
                          ? (isBn ? 'সুস্থ' : 'Healthy')
                          : (isBn ? 'রোগাক্রান্ত' : 'Diseased'),
                      isHealthy: isHealthy,
                    ),
                    const SizedBox(height: 12),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: AppColors.secondaryText,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
