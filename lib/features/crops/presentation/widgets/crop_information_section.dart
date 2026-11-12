import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/datasources/ai_crop_catalog.dart';
import 'crop_information_card.dart';

class CropInformationSection extends StatelessWidget {
  final int cropId;
  final bool isBn;

  const CropInformationSection({
    super.key,
    required this.cropId,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    final profile = AiCropCatalog.getCropProfile(cropId);
    if (profile == null) return const SizedBox.shrink();

    // Prepare information items (only non-empty values)
    final items = <Map<String, dynamic>>[
      {
        'icon': Icons.category_outlined,
        'label': isBn ? 'ফসলের বিভাগ' : 'Category',
        'value': isBn ? profile.categoryBn : profile.categoryEn,
      },
      {
        'icon': Icons.calendar_month_outlined,
        'label': isBn ? 'চাষের মৌসুম' : 'Growing Season',
        'value': isBn ? profile.growingSeasonBn : profile.growingSeasonEn,
      },
      {
        'icon': Icons.water_drop_outlined,
        'label': isBn ? 'পানির চাহিদা' : 'Water Need',
        'value': isBn ? profile.waterRequirementBn : profile.waterRequirementEn,
      },
      {
        'icon': Icons.wb_sunny_outlined,
        'label': isBn ? 'সূর্যালোকের চাহিদা' : 'Sunlight',
        'value': isBn ? profile.sunlightRequirementBn : profile.sunlightRequirementEn,
      },
      {
        'icon': Icons.landscape_outlined,
        'label': isBn ? 'মাটির ধরন' : 'Soil Preference',
        'value': isBn ? profile.soilPreferenceBn : profile.soilPreferenceEn,
      },
      {
        'icon': Icons.timer_outlined,
        'label': isBn ? 'ফসল পাকার সময়' : 'Growth Duration',
        'value': isBn ? profile.growthDurationBn : profile.growthDurationEn,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                isBn ? 'ফসলের তথ্য' : 'Crop Information',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.85,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return CropInformationCard(
                icon: item['icon'] as IconData,
                label: item['label'] as String,
                value: item['value'] as String,
              );
            },
          ),
        ],
      ),
    );
  }
}

