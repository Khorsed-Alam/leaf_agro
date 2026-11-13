import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../data/models/disease_model.dart';

/// Screen 17 – Disease Severity Card
/// Displays documented pathogen risk characteristics only when supported.
/// Explicitly informs the farmer that this represents general agronomic risk,
/// NOT an assessment of their individual field plant.
class DiseaseSeverityCard extends StatelessWidget {
  final DiseaseModel disease;
  final bool isBn;
  final String? severityLevel; // 'low', 'moderate', 'high', 'critical'

  const DiseaseSeverityCard({
    super.key,
    required this.disease,
    required this.isBn,
    this.severityLevel,
  });

  @override
  Widget build(BuildContext context) {
    // If not healthy and no explicit severity is documented, omit section as required
    if (!disease.isHealthy &&
        (severityLevel == null || severityLevel!.isEmpty)) {
      return const SizedBox.shrink();
    }

    final (badgeColor, badgeBg, label, description) = _getSeverityData();

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
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  disease.isHealthy
                      ? Icons.verified_user_outlined
                      : Icons.speed_rounded,
                  size: 20,
                  color: badgeColor,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                isBn ? 'রোগের সাধারণ তীব্রতা' : 'Disease Severity',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 10),

          // Explicit Distinction Disclaimer
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 15,
                  color: AppColors.secondaryText,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isBn
                        ? 'এটি ফসলের সাধারণ জীবতাত্ত্বিক ঝুঁকি নির্দেশ করে, আপনার গাছের নির্দিষ্ট পরীক্ষা নয়।'
                        : 'Represents general botanical risk from literature, not an assessment of your individual plant.',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.secondaryText,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color, String, String) _getSeverityData() {
    if (disease.isHealthy) {
      return (
        AppColors.forestGreen,
        AppColors.softNaturalGreen,
        isBn ? 'স্বাভাবিক / সুস্থ' : 'Low / Healthy',
        isBn
            ? 'সুস্থ উদ্ভিদের জন্য কোনো রোগজনিত তীব্রতা বা ঝুঁকির কারণ নেই।'
            : 'Healthy foliage presents negligible botanical risk.',
      );
    }

    final level = severityLevel?.toLowerCase() ?? '';
    if (level == 'critical' || level == 'severe') {
      return (
        const Color(0xFFDC2626),
        const Color(0xFFFEE2E2),
        isBn ? 'মারাত্মক ঝুঁকি' : 'High Severity',
        isBn
            ? 'এই রোগটি দ্রুত বিস্তার লাভ করে ব্যাপক পাতা ও ফলন ধ্বংস করার ক্ষমতা রাখে।'
            : 'This pathogen has a high capacity for rapid foliar destruction and field transmission.',
      );
    }
    if (level == 'high') {
      return (
        const Color(0xFFEA580C),
        const Color(0xFFFFEDD5),
        isBn ? 'উচ্চ ঝুঁকি' : 'High Severity',
        isBn
            ? 'সময়মতো দমন ব্যবস্থা না নিলে গাছের বিকাশ স্থায়ীভাবে ব্যাহত হতে পারে।'
            : 'Foliar symptoms may cause significant yield loss if left unmanaged.',
      );
    }
    return (
      const Color(0xFFD97706),
      const Color(0xFFFEF3C7),
      isBn ? 'মাঝারি ঝুঁকি' : 'Moderate Severity',
      isBn
          ? 'সাধারণত নিয়ন্ত্রিত পর্যায়ে থাকে, তবে প্রতিকূল আবহাওয়ায় তীব্র হতে পারে।'
          : 'Pathogen damage is typically manageable under standard agricultural practices.',
    );
  }
}
