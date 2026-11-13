import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../data/datasources/ai_crop_catalog.dart';
import '../../../../../data/models/crop_model.dart';
import '../../../../../data/models/disease_model.dart';
import '../../../../../data/models/prediction_model.dart';

/// Screen 20 – Selected Disease and Crop Summary Card
/// Compact card summarizing target crop, disease, management context,
/// and genuine AI confidence pattern match if available from detection session.
class SolutionsDiseaseSummaryCard extends StatelessWidget {
  final DiseaseModel? disease;
  final CropModel? crop;
  final PredictionModel? prediction;
  final String? imagePath;
  final bool isBn;
  final ValueChanged<CropModel>? onCropChanged;

  const SolutionsDiseaseSummaryCard({
    super.key,
    this.disease,
    this.crop,
    this.prediction,
    this.imagePath,
    required this.isBn,
    this.onCropChanged,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveCropName = crop != null
        ? (isBn ? crop!.nameBn : crop!.nameEn)
        : (isBn ? 'ধান' : 'Rice');

    final effectiveDiseaseName = disease != null
        ? (isBn ? disease!.diseaseNameBn : disease!.diseaseNameEn)
        : (isBn ? 'সাধারণ ফসল পরিচর্যা' : 'General Crop Management');

    final hasConfidence = prediction != null && prediction!.confidence > 0;
    final confidenceScore =
        hasConfidence ? (prediction!.confidence * 100) : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderGreen),
        boxShadow: [
          BoxShadow(
            color: AppColors.forestGreen.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Crop and Disease Identity with Avatar/Thumbnail
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.softNaturalGreen,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderGreen),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: disease?.imageUrl != null &&
                          disease!.imageUrl!.startsWith('http')
                      ? Image.network(
                          disease!.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.agriculture_rounded,
                            color: AppColors.forestGreen,
                            size: 28,
                          ),
                        )
                      : crop?.imageUrl != null &&
                              crop!.imageUrl!.startsWith('http')
                          ? Image.network(
                              crop!.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.agriculture_rounded,
                                color: AppColors.forestGreen,
                                size: 28,
                              ),
                            )
                          : const Icon(
                              Icons.agriculture_rounded,
                              color: AppColors.forestGreen,
                              size: 28,
                            ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Affected Crop Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.softNaturalGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isBn
                            ? 'আক্রান্ত ফসল: $effectiveCropName'
                            : 'Affected Crop: $effectiveCropName',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.forestGreen,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),

                    // Selected Disease Headline
                    Text(
                      effectiveDiseaseName,
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(color: Color(0xFFE5E7EB), height: 1),
          const SizedBox(height: 12),

          // Management Overview
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: AppColors.secondary,
                size: 17,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isBn
                      ? 'ব্যবস্থাপনা পরিচিতি: এই ফসলের রোগটি নিরাপদে ও কার্যকরভাবে পরিচালনার সম্ভাব্য বিভিন্ন সমাধান সম্পর্কে জানুন।'
                      : 'Management Overview: Learn about possible approaches that may help manage this crop disease.',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.secondaryText,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),

          // AI Confidence indicator (ONLY when coming from actual detection record)
          if (hasConfidence) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    color: Color(0xFF16A34A),
                    size: 15,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isBn
                        ? 'AI প্যাটার্ন মিল: ${confidenceScore.toStringAsFixed(1)}%'
                        : 'AI Pattern Match: ${confidenceScore.toStringAsFixed(1)}% Confidence',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF15803D),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    isBn ? '(দৃশ্যমান নমুনা)' : '(Visual Pattern)',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Crop Switcher Chips (when user wants to explore other supported crops)
          if (onCropChanged != null) ...[
            const SizedBox(height: 14),
            Text(
              isBn ? 'অন্যান্য ফসল নির্বাচন করুন:' : 'Switch Supported Crop:',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: AiCropCatalog.verifiedSupportedCrops.map((c) {
                  final isSelected = crop?.id == c.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        isBn ? c.nameBn : c.nameEn,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color:
                              isSelected ? Colors.white : AppColors.primaryText,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.forestGreen,
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.forestGreen
                            : AppColors.borderGreen,
                      ),
                      onSelected: (val) {
                        if (val) onCropChanged!(c);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
