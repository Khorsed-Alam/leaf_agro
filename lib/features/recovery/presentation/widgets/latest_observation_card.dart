import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../data/models/plant_observation_model.dart';

/// Screen 21 – Latest Farmer Observation Summary
/// Highlights the most recent self-reported observation recorded by the farmer.
/// Explicitly indicates that condition labels are farmer-reported, NOT AI verdicts.
class LatestObservationCard extends StatelessWidget {
  final PlantObservationModel? observation;
  final bool isBn;

  const LatestObservationCard({
    super.key,
    required this.observation,
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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.freshGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.rate_review_outlined,
                      size: 18,
                      color: AppColors.forestGreen,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isBn
                        ? 'আপনার সাম্প্রতিক পর্যবেক্ষণ'
                        : 'Your Latest Observation',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.forestGreen,
                    ),
                  ),
                ],
              ),
              // Self-reported tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Text(
                  isBn ? 'কৃষকের নিজস্ব পর্যবেক্ষণ' : 'Farmer Self-Reported',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (observation != null) ...[
            // Condition Badge & Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Condition Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: observation!.conditionLabel.backgroundColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: observation!.conditionLabel.color
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        observation!.conditionLabel.icon,
                        size: 15,
                        color: observation!.conditionLabel.color,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isBn
                            ? observation!.conditionLabel.labelBn()
                            : observation!.conditionLabel.labelEn(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: observation!.conditionLabel.color,
                        ),
                      ),
                    ],
                  ),
                ),

                // Observation Date
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 13,
                      color: AppColors.secondaryText,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormatter.formatTimestamp(observation!.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Note Content
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                observation!.notes.isNotEmpty
                    ? observation!.notes
                    : (isBn
                        ? '(কোনো বিবরণী নোট নেই)'
                        : '(No written notes recorded)'),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.primaryText,
                  height: 1.4,
                ),
              ),
            ),

            if (observation!.nextInspectionDate != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.event_available_rounded,
                    size: 15,
                    color: AppColors.forestGreen,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isBn
                        ? 'পরবর্তী লক্ষ্যমাত্রা: ${DateFormatter.formatShortDate(observation!.nextInspectionDate!)}'
                        : 'Target Follow-up: ${DateFormatter.formatShortDate(observation!.nextInspectionDate!)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.forestGreen,
                    ),
                  ),
                ],
              ),
            ],
          ] else ...[
            // Empty state
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.border,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.edit_note_rounded,
                    size: 32,
                    color: AppColors.secondaryText.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isBn
                        ? 'আপনি এখনও কোনো ফলো-আপ পর্যবেক্ষণ রেকর্ড করেননি।'
                        : "You haven't recorded a follow-up observation yet.",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isBn
                        ? 'গাছের পরিবর্তন লিখে রাখতে নিচের ফর্মটি ব্যবহার করুন।'
                        : 'Use the observation journal below to write down changes you notice.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

