import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/crop_model.dart';
import '../../../../data/models/disease_model.dart';
import 'crop_search_result_card.dart';
import 'disease_search_result_card.dart';

class SearchResultsSection extends StatelessWidget {
  final List<CropModel> matchedCrops;
  final List<DiseaseModel> matchedDiseases;
  final List<CropModel> allCrops;
  final bool isBn;

  const SearchResultsSection({
    super.key,
    required this.matchedCrops,
    required this.matchedDiseases,
    required this.allCrops,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section A: Crops ──────────────────────────────────────────────────
        if (matchedCrops.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.freshGreen,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isBn ? 'ফসলসমূহ' : 'Crops',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.softNaturalGreen,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${matchedCrops.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.forestGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...matchedCrops.map((crop) => CropSearchResultCard(crop: crop, isBn: isBn)),
          const SizedBox(height: 12),
        ],

        // ── Section B: Diseases ───────────────────────────────────────────────
        if (matchedDiseases.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.freshGreen,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isBn ? 'রোগসমূহ' : 'Diseases',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.softNaturalGreen,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${matchedDiseases.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.forestGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...matchedDiseases.map((disease) {
            final crop = allCrops.cast<CropModel?>().firstWhere(
                  (c) => c?.id == disease.cropId,
                  orElse: () => null,
                );
            return DiseaseSearchResultCard(
              disease: disease,
              crop: crop,
              isBn: isBn,
            );
          }),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}
