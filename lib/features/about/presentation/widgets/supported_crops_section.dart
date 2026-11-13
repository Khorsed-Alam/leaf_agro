import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SupportedCropItem {
  final String nameEn;
  final String nameBn;
  final int classCount;
  final IconData icon;

  const SupportedCropItem({
    required this.nameEn,
    required this.nameBn,
    required this.classCount,
    required this.icon,
  });

  String name(bool isBn) => isBn ? nameBn : nameEn;
  String classesText(bool isBn) =>
      isBn ? '$classCount টি অবস্থা/রোগ' : '$classCount conditions/classes';
}

/// Screen 30 – Verified Supported Crops Section
class SupportedCropsSection extends StatelessWidget {
  final bool isBn;

  const SupportedCropsSection({
    super.key,
    required this.isBn,
  });

  static const List<SupportedCropItem> supportedCrops = [
    SupportedCropItem(
      nameEn: 'Rice',
      nameBn: 'ধান',
      classCount: 4,
      icon: Icons.grain_rounded,
    ),
    SupportedCropItem(
      nameEn: 'Potato',
      nameBn: 'আলু',
      classCount: 3,
      icon: Icons.grass_rounded,
    ),
    SupportedCropItem(
      nameEn: 'Tomato',
      nameBn: 'টমেটো',
      classCount: 6,
      icon: Icons.spa_rounded,
    ),
    SupportedCropItem(
      nameEn: 'Mango',
      nameBn: 'আম',
      classCount: 3,
      icon: Icons.park_rounded,
    ),
    SupportedCropItem(
      nameEn: 'Jute',
      nameBn: 'পাট',
      classCount: 3,
      icon: Icons.eco_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderGreen, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.softNaturalGreen,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderGreen, width: 1),
                ),
                child: const Icon(
                  Icons.agriculture_rounded,
                  color: AppColors.forestGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isBn ? 'সমর্থিত ফসলসমূহ' : 'Supported Crops',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.forestGreen,
                      ),
                    ),
                    Text(
                      isBn
                          ? 'এআই মডেল দ্বারা সমর্থিত ৫টি প্রধান কৃষি ফসল'
                          : 'Explore the crops currently supported by the AI model.',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.softNaturalGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isBn ? '৫টি ফসল' : '5 Crops',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.forestGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Crops Grid / Wrap
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: supportedCrops.map((crop) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.softNaturalGreen,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderGreen, width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      crop.icon,
                      color: AppColors.forestGreen,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          crop.name(isBn),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.forestGreen,
                          ),
                        ),
                        Text(
                          crop.classesText(isBn),
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Note
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderGreen, width: 0.8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.secondaryText,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isBn
                        ? 'এআই মডেলটি উল্লেখিত ৫টি ফসলের মোট ১৯টি রোগ ও সুস্থ পাতার শ্রেণিভুক্ত।'
                        : 'AI predictions are limited to the 19 disease & healthy classes supported by the installed model.',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondaryText,
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
}
