import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/crop_model.dart';
import 'popular_crop_card.dart';

class PopularCropsSection extends StatelessWidget {
  final List<CropModel> crops;
  final ValueChanged<CropModel> onCropTap;
  final bool isBn;

  const PopularCropsSection({
    super.key,
    required this.crops,
    required this.onCropTap,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    if (crops.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 0, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Icon(
                  Icons.eco_rounded,
                  size: 18,
                  color: AppColors.forestGreen,
                ),
                const SizedBox(width: 6),
                Text(
                  isBn ? 'জনপ্রিয় ফসলসমূহ' : 'Popular Crops',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: crops.length,
              itemBuilder: (context, index) {
                final crop = crops[index];
                return PopularCropCard(
                  crop: crop,
                  onTap: () => onCropTap(crop),
                  isBn: isBn,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
