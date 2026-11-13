import 'package:flutter/material.dart';
import 'package:leaf_agro/core/theme/app_colors.dart';
import 'package:leaf_agro/data/models/disease_model.dart';
import 'package:leaf_agro/data/models/recommendation_model.dart';

/// Screen 19 – Disease-Specific Prevention Section
/// Renders targeted prevention protocols when opened with an active disease context.
class DiseaseSpecificPreventionSection extends StatelessWidget {
  final DiseaseModel? disease;
  final List<RecommendationModel> recommendations;
  final bool isBn;

  const DiseaseSpecificPreventionSection({
    super.key,
    required this.disease,
    required this.recommendations,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    if (disease == null) return const SizedBox.shrink();

    final diseaseName = isBn ? disease!.diseaseNameBn : disease!.diseaseNameEn;
    final preventionItems = recommendations
        .where((r) =>
            r.recommendationType == 'prevention' ||
            r.recommendationType == 'care')
        .toList();

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
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  size: 20,
                  color: Color(0xFFD97706),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isBn
                      ? '$diseaseName প্রতিরোধে করণীয়'
                      : 'Prevention for $diseaseName',
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (preventionItems.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isBn
                    ? 'এই রোগের জন্য কোনো নির্দিষ্ট প্রতিরোধ প্রটোকল তালিকাভুক্ত নেই।'
                    : 'No disease-specific prevention protocol is currently listed for this pathogen.',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.secondaryText,
                ),
              ),
            )
          else
            Column(
              children: preventionItems.map((item) {
                final title = isBn ? item.titleBn : item.titleEn;
                final content = isBn ? item.contentBn : item.contentEn;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 16,
                            color: AppColors.forestGreen,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        content,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.primaryText,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
