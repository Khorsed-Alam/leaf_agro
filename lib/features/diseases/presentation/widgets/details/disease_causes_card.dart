import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../data/models/disease_model.dart';

/// Screen 17 – Disease Possible Causes Card
/// Explains the underlying pathogen biology and environmental conditions
/// favoring disease transmission in simple farmer language.
class DiseaseCausesCard extends StatelessWidget {
  final DiseaseModel disease;
  final bool isBn;

  const DiseaseCausesCard({
    super.key,
    required this.disease,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    final causeText = isBn
        ? (disease.causesBn.isNotEmpty ? disease.causesBn : disease.causesEn)
        : (disease.causesEn.isNotEmpty ? disease.causesEn : disease.causesBn);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.1),
        boxShadow: [
          BoxShadow(
            color: AppColors.forestGreen.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.softNaturalGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.biotech_outlined,
                  size: 20,
                  color: AppColors.forestGreen,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                isBn ? 'সম্ভাব্য কারণ ও জীবাণু' : 'Possible Causes',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (causeText.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: AppColors.secondaryText,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isBn
                          ? 'এই রোগের জন্য কোনো নির্দিষ্ট কারণ লিপিবদ্ধ নেই।'
                          : 'No specific causal agent information is recorded for this disease.',
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            // Main Cause Description
            Text(
              causeText,
              style: const TextStyle(
                fontSize: 14.5,
                height: 1.55,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 14),

            // Agronomic Environmental Factor Callout
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.cloud_outlined,
                    size: 18,
                    color: AppColors.forestGreen,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isBn
                          ? 'আর্দ্র আবহাওয়া, অতিরিক্ত বৃষ্টিপাত, কুয়াশা বা অনুপযুক্ত সেচ ব্যবস্থার কারণে জীবাণুর বিস্তার ত্বরান্বিত হয়।'
                          : 'High relative humidity, heavy dew/fog, and standing water accelerate spore germination and bacterial transmission.',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.secondaryText,
                        height: 1.4,
                      ),
                    ),
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
