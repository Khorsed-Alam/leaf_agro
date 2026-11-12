import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/disease_model.dart';

class DiseaseThumbnailCard extends StatelessWidget {
  final DiseaseModel disease;
  final bool isBn;

  const DiseaseThumbnailCard({
    super.key,
    required this.disease,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    final (badgeColor, badgeBg, severityLabel) = _getSeverityData();

    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: disease.isHealthy
              ? AppColors.freshGreen.withValues(alpha: 0.5)
              : AppColors.border,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.forestGreen.withValues(alpha: 0.05),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top row: Pathogen icon + Severity Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: disease.isHealthy
                            ? AppColors.softNaturalGreen
                            : const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        disease.isHealthy
                            ? Icons.eco
                            : Icons.coronavirus_outlined,
                        size: 20,
                        color: disease.isHealthy
                            ? AppColors.forestGreen
                            : const Color(0xFFDC2626),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        severityLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Disease Name English
                Text(
                  disease.diseaseNameEn,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                // Disease Name Bangla
                Text(
                  disease.diseaseNameBn,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.forestGreen,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Symptoms snippet
                Expanded(
                  child: Text(
                    isBn ? disease.symptomsBn : disease.symptomsEn,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryText,
                      height: 1.35,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 6),

                // Details CTA row
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      isBn ? 'বিস্তারিত' : 'View details',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 10,
                      color: AppColors.primary,
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
