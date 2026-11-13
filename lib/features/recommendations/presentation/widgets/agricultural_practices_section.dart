import 'package:flutter/material.dart';
import 'package:leaf_agro/core/theme/app_colors.dart';
import 'package:leaf_agro/data/models/crop_model.dart';
import 'package:leaf_agro/data/models/disease_model.dart';

/// Screen 18 – Agricultural Management Practices Section
/// Verified cultural and field sanitation practices to mitigate pathogen pressure.
class AgriculturalPracticesSection extends StatelessWidget {
  final DiseaseModel disease;
  final CropModel? crop;
  final bool isBn;

  const AgriculturalPracticesSection({
    super.key,
    required this.disease,
    required this.crop,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    final practices = _getPractices();

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
                  color: AppColors.softNaturalGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.agriculture_rounded,
                  size: 20,
                  color: AppColors.forestGreen,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                isBn
                    ? 'কৃষি ব্যবস্থাপনা ও পরিচর্যা'
                    : 'Agricultural Management Practices',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            isBn
                ? 'অনুমোদিত মাঠ গবেষণা অনুযায়ী নিম্নলিখিত কৃষি পদ্ধতিগুলো উদ্ভিদের রোগ প্রতিরোধে কার্যকর ভূমিকা রাখে:'
                : 'According to agronomic field research, these practical cultural measures reduce foliar disease severity:',
            style: const TextStyle(
              fontSize: 13.5,
              color: AppColors.secondaryText,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),

          // Practice Cards
          Column(
            children: practices.map((practice) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.softNaturalGreen,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        practice.icon,
                        size: 20,
                        color: AppColors.forestGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            practice.title,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            practice.description,
                            style: const TextStyle(
                              fontSize: 13.5,
                              color: AppColors.primaryText,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              practice.benefit,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.forestGreen,
                              ),
                            ),
                          ),
                        ],
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

  List<_PracticeItem> _getPractices() {
    return [
      _PracticeItem(
        icon: Icons.cleaning_services_rounded,
        title: isBn ? 'জমি ও আইল পরিচ্ছন্নতা' : 'Field & Bund Sanitation',
        description: isBn
            ? 'জমির চারপাশের আইল ও নালা থেকে আগাছা নিয়মিত পরিষ্কার রাখুন যাতে ক্ষতিকর পোকা ও জীবাণুর বিকল্প বাসস্থান নষ্ট হয়।'
            : 'Keep field bunds and perimeter channels free of volunteer weeds that harbor fungal spores and insect vectors.',
        benefit: isBn
            ? 'সুফল: জীবাণুর প্রাথমিক উৎস ধ্বংস হয়'
            : 'Benefit: Eliminates pathogen reservoirs',
      ),
      _PracticeItem(
        icon: Icons.water_drop_outlined,
        title: isBn ? 'সঠিক সেচ ও পানি নিষ্কাশন' : 'Regulated Water & Drainage',
        description: isBn
            ? 'ফসলের প্রয়োজন অনুযায়ী সেচ দিন। জমিতে অতিরিক্ত পানি জমতে না দিয়ে নিকাশ নালা সচল রাখুন।'
            : 'Provide timely irrigation without waterlogging. Maintain open surface ditches for rapid monsoon drainage.',
        benefit: isBn
            ? 'সুফল: পাতা ভেজা থাকার সময়কাল কমে'
            : 'Benefit: Shortens foliar wetness duration',
      ),
      _PracticeItem(
        icon: Icons.science_outlined,
        title: isBn
            ? 'সুষম সার ও ইউরিয়া নিয়ন্ত্রণ'
            : 'Balanced Fertilizer Application',
        description: isBn
            ? 'অতিরিক্ত ইউরিয়া প্রয়োগ করবেন না। নির্দেশিত মাত্রায় পটাশ ও জিংক সার ব্যবহার করে গাছের রোগ প্রতিরোধ শক্তি বাড়ান।'
            : 'Avoid excess nitrogen top-dressing. Maintain balanced potassium to reinforce epidermal cell strength.',
        benefit: isBn
            ? 'সুফল: উদ্ভিদের কোষপ্রাচীর দৃঢ় হয়'
            : 'Benefit: Fortifies plant cellular defense',
      ),
    ];
  }
}

class _PracticeItem {
  final IconData icon;
  final String title;
  final String description;
  final String benefit;

  const _PracticeItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.benefit,
  });
}
