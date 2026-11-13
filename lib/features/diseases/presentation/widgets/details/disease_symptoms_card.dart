import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../data/models/disease_model.dart';

/// Screen 17 – Disease Common Symptoms Card
/// Lists common clinical symptoms verified in the catalog in a structured,
/// easy-to-read checklist for farmers.
class DiseaseSymptomsCard extends StatelessWidget {
  final DiseaseModel disease;
  final bool isBn;

  const DiseaseSymptomsCard({
    super.key,
    required this.disease,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    final symptomText = isBn
        ? (disease.symptomsBn.isNotEmpty
            ? disease.symptomsBn
            : disease.symptomsEn)
        : (disease.symptomsEn.isNotEmpty
            ? disease.symptomsEn
            : disease.symptomsBn);

    final List<String> symptomItems = _parseSymptomItems(symptomText);

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
                  color: disease.isHealthy
                      ? AppColors.softNaturalGreen
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  disease.isHealthy
                      ? Icons.verified_rounded
                      : Icons.warning_amber_rounded,
                  size: 20,
                  color: disease.isHealthy
                      ? AppColors.forestGreen
                      : const Color(0xFFD97706),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                isBn ? 'সাধারণ লক্ষণসমূহ' : 'Common Symptoms',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Symptoms List or Unavailable State
          if (symptomItems.isEmpty)
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
                          ? 'এই রোগের জন্য কোনো নির্দিষ্ট লক্ষণ তথ্য লিপিবদ্ধ নেই।'
                          : 'No specific symptom information is recorded for this disease.',
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: symptomItems.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 3),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: disease.isHealthy
                              ? AppColors.softNaturalGreen
                              : const Color(0xFFFEF2F2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          disease.isHealthy
                              ? Icons.check_circle_outline_rounded
                              : Icons.fiber_manual_record_rounded,
                          size: disease.isHealthy ? 14 : 9,
                          color: disease.isHealthy
                              ? AppColors.forestGreen
                              : const Color(0xFFDC2626),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.trim(),
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: AppColors.primaryText,
                          ),
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

  List<String> _parseSymptomItems(String text) {
    if (text.trim().isEmpty) return [];

    List<String> rawItems;
    // Split on semicolon, bullet character, or newline
    if (text.contains(';') || text.contains('•') || text.contains('\n')) {
      rawItems = text
          .split(RegExp(r'[;•\n]'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    } else {
      // Split on full stop for longer text if multi-sentence
      final sentences = text
          .split(RegExp(r'(\. |\। )'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      rawItems = sentences.isNotEmpty ? sentences : [text];
    }

    // Clean trailing periods or punctuation from list items
    return rawItems
        .map((item) => item.replaceAll(RegExp(r'[\.\।]+$'), '').trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }
}
