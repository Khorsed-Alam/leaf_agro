import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../data/models/disease_model.dart';

/// Screen 23 – Disease Information Summary Section
/// Displays biological pathology information (symptoms, causes) for disease detections,
/// or a reassuring healthy maintenance guide for healthy plant records.
class DiseaseInformationSection extends StatelessWidget {
  final DiseaseModel? disease;
  final bool isHealthy;
  final bool isBn;

  const DiseaseInformationSection({
    super.key,
    required this.disease,
    required this.isHealthy,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    if (isHealthy) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.freshGreen.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.freshGreen.withValues(alpha: 0.3),
            width: 1.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.health_and_safety_rounded,
                color: AppColors.forestGreen,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBn
                        ? 'সুস্থ ফসলের পরিচর্যা'
                        : 'Healthy Foliage Maintenance',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.forestGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isBn
                        ? 'গাছটিতে কোনো রোগের সংক্রমণ দেখা যায়নি। সুষম সেচ, জৈব সার ও নিয়মিত পর্যবেক্ষণ বজায় রেখে গাছের স্বাস্থ্য অটুট রাখুন।'
                        : 'No signs of infection were found in this leaf photograph. Maintain regular watering, balanced soil nutrition, and continued field monitoring.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryText,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final symptoms =
        isBn ? disease?.symptomsBn : disease?.symptomsEn;
    final causes = isBn ? disease?.causesBn : disease?.causesEn;
    final hasInfo = (symptoms != null && symptoms.isNotEmpty) ||
        (causes != null && causes.isNotEmpty);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.borderGreen,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  Icons.menu_book_rounded,
                  size: 16,
                  color: AppColors.forestGreen,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isBn ? 'রোগ সম্পর্কিত তথ্য' : 'About This Disease',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.forestGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (hasInfo) ...[
            if (symptoms != null && symptoms.isNotEmpty) ...[
              Text(
                isBn ? 'সাধারণ লক্ষণসমূহ:' : 'Common Symptoms:',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                symptoms,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.secondaryText,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
            ],
            if (causes != null && causes.isNotEmpty) ...[
              Text(
                isBn ? 'রোগের কারণ ও উৎস:' : 'Causes & Pathogen:',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                causes,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.secondaryText,
                  height: 1.4,
                ),
              ),
            ],
          ] else ...[
            Text(
              isBn
                  ? 'এই রোগের বিস্তারিত তথ্য বর্তমানে ক্যাটালগে উপলব্ধ নেই।'
                  : 'Detailed disease information is currently unavailable.',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
