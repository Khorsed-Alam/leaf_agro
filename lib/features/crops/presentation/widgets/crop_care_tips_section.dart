import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/datasources/ai_crop_catalog.dart';
import 'crop_care_tip_card.dart';

class CropCareTipsSection extends StatelessWidget {
  final int cropId;
  final bool isBn;

  const CropCareTipsSection({
    super.key,
    required this.cropId,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    final tips = AiCropCatalog.getCareTips(cropId);
    if (tips.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.freshGreen,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isBn ? 'ফসল পরিচর্যার পরামর্শ' : 'Crop Care Tips',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isBn
                ? 'মাঠপর্যায়ে পরীক্ষিত ও কৃষিবিদদের অনুমোদিত পরিচর্যা নির্দেশিকা।'
                : 'Agricultural best practices from verified field research.',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tips.length,
            itemBuilder: (context, index) {
              return CropCareTipCard(
                tip: tips[index],
                isBn: isBn,
              );
            },
          ),
        ],
      ),
    );
  }
}

