import 'package:flutter/material.dart';
import 'package:leaf_agro/core/theme/app_colors.dart';
import 'package:leaf_agro/data/datasources/ai_crop_catalog.dart';
import 'package:leaf_agro/data/models/crop_model.dart';

/// Screen 19 – Crop-Specific Advice Section
/// Displays tailored agricultural prevention recommendations for the active crop.
class CropSpecificAdviceSection extends StatelessWidget {
  final CropModel? crop;
  final bool isBn;

  const CropSpecificAdviceSection({
    super.key,
    required this.crop,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    final cropName = crop != null
        ? (isBn ? crop!.nameBn : crop!.nameEn)
        : (isBn ? 'ফসল' : 'Crop');

    final careTips =
        crop != null ? AiCropCatalog.getCareTips(crop!.id) : <CropCareTip>[];

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
                  Icons.tips_and_updates_outlined,
                  size: 20,
                  color: AppColors.forestGreen,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                isBn ? '$cropName-এর বিশেষ যত্ন' : 'Advice for $cropName',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (careTips.isEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: AppColors.secondaryText,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isBn
                          ? 'এই ফসলের জন্য নির্দিষ্ট প্রতিরোধ নির্দেশিকা এখনো অন্তর্ভুক্ত করা হয়নি। অনুগ্রহ করে স্থানীয় উপজেলা কৃষি কর্মকর্তার পরামর্শ নিন।'
                          : 'Crop-specific prevention guidance is not available yet. Please consult your local agricultural extension officer for advice.',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.secondaryText,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: careTips.map((tip) {
                final title = isBn ? tip.titleBn : tip.titleEn;
                final description =
                    isBn ? tip.descriptionBn : tip.descriptionEn;
                final category = isBn ? tip.categoryBn : tip.categoryEn;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.softNaturalGreen,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          tip.icon,
                          size: 18,
                          color: AppColors.forestGreen,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Text(
                                    category,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.forestGreen,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryText,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              description,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.primaryText,
                                height: 1.45,
                              ),
                            ),
                          ],
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
