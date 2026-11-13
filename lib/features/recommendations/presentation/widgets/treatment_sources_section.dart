import 'package:flutter/material.dart';
import 'package:leaf_agro/core/theme/app_colors.dart';
import 'package:leaf_agro/data/models/recommendation_model.dart';

/// Screen 18 – Treatment Sources & Verification Section
/// Displays authoritative agricultural research organizations and verification credentials.
class TreatmentSourcesSection extends StatelessWidget {
  final List<RecommendationModel> recommendations;
  final bool isBn;

  const TreatmentSourcesSection({
    super.key,
    required this.recommendations,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    // Extract unique source names
    final sources = recommendations
        .map((r) => r.sourceName)
        .where((s) => s != null && s.isNotEmpty)
        .toSet()
        .toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.verified_user_outlined,
                size: 16,
                color: AppColors.forestGreen,
              ),
              const SizedBox(width: 8),
              Text(
                isBn
                    ? 'তথ্যের সত্যতা ও কৃষি উৎস'
                    : 'Source & Agronomic Verification',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isBn
                ? 'এই পৃষ্ঠার সমস্ত কৃষি ব্যবস্থাপনা নির্দেশিকা বাংলাদেশ ধান গবেষণা ইনস্টিটিউট (BRRI), বাংলাদেশ কৃষি গবেষণা ইনস্টিটিউট (BARI) এবং কৃষি সম্প্রসারণ অধিদপ্তর (DAE)-এর অনুমোদিত প্রকাশনা হতে সংগৃহীত।'
                : 'All agricultural management guidance on this screen is compiled from verified publications of Bangladesh Rice Research Institute (BRRI), Bangladesh Agricultural Research Institute (BARI), and Department of Agricultural Extension (DAE).',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.secondaryText,
              height: 1.45,
            ),
          ),
          if (sources.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: sources.map((source) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    source!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.forestGreen,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
