import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/crop_model.dart';
import '../../../../data/models/disease_model.dart';

class DiseaseCategoryCard extends StatelessWidget {
  final DiseaseModel disease;
  final CropModel? crop;
  final bool isBn;

  const DiseaseCategoryCard({
    super.key,
    required this.disease,
    required this.crop,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    final (badgeColor, badgeBg, severityLabel) = _getSeverityData();
    final cropName = crop != null
        ? (isBn ? crop!.nameBn : crop!.nameEn)
        : (isBn ? 'ফসল' : 'Crop');

    final symptomText = isBn
        ? (disease.symptomsBn.isNotEmpty ? disease.symptomsBn : disease.symptomsEn)
        : (disease.symptomsEn.isNotEmpty ? disease.symptomsEn : disease.symptomsBn);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: disease.isHealthy
              ? AppColors.freshGreen.withValues(alpha: 0.4)
              : AppColors.border,
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.forestGreen.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            context.push('/diseases/${disease.id}');
          },
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Left: Image / Pathogen Icon Container
                _buildLeadingVisual(),
                const SizedBox(width: 14),

                // 2. Center: Disease Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Crop Pill & Severity Badge Row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: AppColors.softNaturalGreen,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.freshGreen.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              cropName,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.forestGreen,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              severityLabel,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: badgeColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Disease English Name
                      Text(
                        disease.diseaseNameEn,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryText,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Disease Bangla Name
                      if (disease.diseaseNameBn.isNotEmpty) ...[
                        const SizedBox(height: 1),
                        Text(
                          disease.diseaseNameBn,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.forestGreen,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      // Symptom Snippet
                      if (symptomText.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          symptomText,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.secondaryText,
                            height: 1.35,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // 3. Right: Navigation Indicator
                Container(
                  padding: const EdgeInsets.all(6),
                  margin: const EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    color: AppColors.softNaturalGreen.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: AppColors.forestGreen,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingVisual() {
    if (disease.imageUrl != null && disease.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          disease.imageUrl!,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholderIcon(),
        ),
      );
    }
    return _buildPlaceholderIcon();
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: disease.isHealthy
            ? AppColors.softNaturalGreen
            : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: disease.isHealthy
              ? AppColors.freshGreen.withValues(alpha: 0.3)
              : const Color(0xFFFCA5A5).withValues(alpha: 0.5),
        ),
      ),
      child: Center(
        child: Icon(
          disease.isHealthy ? Icons.eco_rounded : Icons.coronavirus_outlined,
          size: 26,
          color: disease.isHealthy ? AppColors.forestGreen : const Color(0xFFDC2626),
        ),
      ),
    );
  }

  (Color, Color, String) _getSeverityData() {
    if (disease.isHealthy) {
      return (
        AppColors.forestGreen,
        AppColors.softNaturalGreen,
        isBn ? 'সুস্থ' : 'Healthy',
      );
    }
    final name = disease.className.toLowerCase();
    if (name.contains('late_blight') || name.contains('stem_rot')) {
      return (
        const Color(0xFFDC2626),
        const Color(0xFFFEE2E2),
        isBn ? 'মারাত্মক' : 'Critical',
      );
    }
    if (name.contains('bacterial') || name.contains('anthracnose')) {
      return (
        const Color(0xFFEA580C),
        const Color(0xFFFFEDD5),
        isBn ? 'উচ্চ' : 'High',
      );
    }
    return (
      const Color(0xFFD97706),
      const Color(0xFFFEF3C7),
      isBn ? 'মাঝারি' : 'Moderate',
    );
  }
}
