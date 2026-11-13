import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../data/models/prediction_history_model.dart';
import '../../../../shared/widgets/leaf_image_view.dart';
import '../../../../shared/widgets/status_badge.dart';

/// Screen 21 – Original Detection Summary Card
/// Summarizes the authentic initial AI detection record for comparison.
/// Strictly transparent: Never fabricates sample data as real records.
class OriginalDetectionCard extends StatelessWidget {
  final PredictionHistoryModel? scan;
  final bool isBn;
  final VoidCallback? onStartScan;

  const OriginalDetectionCard({
    super.key,
    required this.scan,
    required this.isBn,
    this.onStartScan,
  });

  @override
  Widget build(BuildContext context) {
    if (scan == null) {
      return _buildEmptyState(context);
    }

    final parts = scan!.predictedClass.split('___');
    final crop = parts[0];
    final disease = parts.length > 1 ? parts[1].replaceAll('_', ' ') : 'Healthy';
    final isHealthy = disease.toLowerCase().contains('healthy') ||
        scan!.predictedClass.toLowerCase().contains('healthy');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.borderGreen,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Heading & Original AI Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.forestGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.history_edu_rounded,
                      size: 18,
                      color: AppColors.forestGreen,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isBn ? 'মূল রোগ শনাক্তকরণ' : 'Original Detection',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.forestGreen,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.forestGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.forestGreen.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  isBn ? 'মূল এআই পূর্বাভাস' : 'Original AI Record',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.forestGreen,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Scan Thumbnail & Metadata
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 90,
                  height: 90,
                  child: scan!.imagePath != null && scan!.imagePath!.isNotEmpty
                      ? LeafImageView(
                          imagePath: scan!.imagePath!,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: AppColors.surfaceContainer,
                          child: const Icon(
                            Icons.eco_rounded,
                            size: 36,
                            color: AppColors.forestGreen,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 14),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Crop Name
                    Text(
                      crop,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.forestGreen,
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Disease Name
                    Text(
                      isHealthy
                          ? (isBn ? 'সুস্থ উদ্ভিদ' : 'Healthy Plant')
                          : disease,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Date
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 13,
                          color: AppColors.secondaryText,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            DateFormatter.formatTimestamp(scan!.createdAt),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.secondaryText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 10),

          // Confidence & Status Badge Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // AI Confidence
              Row(
                children: [
                  Text(
                    isBn ? 'এআই নিশ্চিততা: ' : 'Confidence: ',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  Text(
                    '${(scan!.confidence * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryText,
                    ),
                  ),
                ],
              ),

              // Health Status Badge
              StatusBadge(
                label: isHealthy
                    ? (isBn ? 'সুস্থ' : 'Healthy')
                    : (isBn ? 'রোগ শনাক্ত' : 'Disease Detected'),
                isHealthy: isHealthy,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.borderGreen,
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.forestGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 32,
              color: AppColors.forestGreen,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isBn
                ? 'কোনো পূর্ববর্তী শনাক্তকরণ পাওয়া যায়নি'
                : 'No Previous Scan Found',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isBn
                ? 'ফলো-আপ শুরু করার জন্য প্রথমে আপনার ফসলের পাতার একটি ছবি স্ক্যান করুন।'
                : 'To begin follow-up monitoring, scan a leaf photograph of your crop first.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.secondaryText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              if (onStartScan != null) {
                onStartScan!();
              } else {
                try {
                  context.push('/detect');
                } catch (_) {}
              }
            },
            icon: const Icon(Icons.camera_alt_outlined, size: 18),
            label: Text(
              isBn ? 'নতুন স্ক্যান শুরু করুন' : 'Start a New Scan',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.forestGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

