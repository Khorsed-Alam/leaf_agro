import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../data/models/plant_observation_model.dart';
import '../../../../data/models/prediction_history_model.dart';

/// Screen 21 – Observation Timeline Section
/// Presents an authentic chronological timeline of events:
/// 1. Original AI Detection
/// 2. Farmer-Recorded Follow-up Observations
/// Strictly distinguishes AI scans from self-reported farmer notes.
class ObservationTimelineSection extends StatelessWidget {
  final PredictionHistoryModel? originalScan;
  final List<PlantObservationModel> observations;
  final bool isBn;

  const ObservationTimelineSection({
    super.key,
    required this.originalScan,
    required this.observations,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
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
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.forestGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.timeline_rounded,
                  size: 18,
                  color: AppColors.forestGreen,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isBn ? 'পর্যবেক্ষণ টাইমলাইন' : 'Observation Timeline',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.forestGreen,
                      ),
                    ),
                    Text(
                      isBn
                          ? 'রোগ শনাক্তকরণ ও ফলো-আপের সময়ানুক্রমিক রেকর্ড'
                          : 'Chronological events of AI scans and farmer notes',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Events List
          if (observations.isEmpty && originalScan == null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              child: Text(
                isBn
                    ? 'কোনো সময়ানুক্রমিক তথ্য উপলব্ধ নেই।'
                    : 'No chronological records available.',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.secondaryText,
                ),
              ),
            ),
          ] else ...[
            // 1. Follow-up observations (newest first)
            ...observations.map((obs) => _buildObservationTile(obs)),

            // 2. Original Detection Entry (the root event)
            if (originalScan != null) _buildOriginalScanTile(originalScan!),
          ],
        ],
      ),
    );
  }

  Widget _buildObservationTile(PlantObservationModel obs) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Marker & Line
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: obs.conditionLabel.backgroundColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: obs.conditionLabel.color,
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  obs.conditionLabel.icon,
                  size: 14,
                  color: obs.conditionLabel.color,
                ),
              ),
              Container(
                width: 2,
                height: 48,
                color: AppColors.borderGreen,
              ),
            ],
          ),
          const SizedBox(width: 12),

          // Event Content Card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isBn ? 'ফলো-আপ পর্যবেক্ষণ' : 'Farmer Follow-up',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ),
                      Text(
                        DateFormatter.formatTimestamp(obs.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        isBn ? 'লক্ষণীয় অবস্থা: ' : 'Condition: ',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      Text(
                        isBn
                            ? obs.conditionLabel.labelBn()
                            : obs.conditionLabel.labelEn(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: obs.conditionLabel.color,
                        ),
                      ),
                    ],
                  ),
                  if (obs.notes.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      obs.notes,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryText,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOriginalScanTile(PredictionHistoryModel scan) {
    final parts = scan.predictedClass.split('___');
    final crop = parts[0];
    final disease = parts.length > 1 ? parts[1].replaceAll('_', ' ') : 'Healthy';
    final isHealthy = disease.toLowerCase().contains('healthy') ||
        scan.predictedClass.toLowerCase().contains('healthy');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline Marker (Initial Event Root)
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.forestGreen,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.limeGreen,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.memory_rounded,
                size: 14,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),

        // Event Content Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.forestGreen.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.forestGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isBn ? 'মূল এআই নির্ণয়' : 'Initial AI Scan',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.forestGreen,
                        ),
                      ),
                    ),
                    Text(
                      DateFormatter.formatTimestamp(scan.createdAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '$crop · $disease',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isHealthy
                      ? (isBn
                          ? 'সুস্থ পাতার লক্ষণযুক্ত'
                          : 'Evaluated healthy foliage')
                      : (isBn
                          ? 'এআই মডেল রোগ শনাক্ত করেছে (${(scan.confidence * 100).toStringAsFixed(1)}% নিশ্চিততা)'
                          : 'AI detected pathology (${(scan.confidence * 100).toStringAsFixed(1)}% confidence)'),
                  style: TextStyle(
                    fontSize: 11,
                    color: isHealthy ? AppColors.forestGreen : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

