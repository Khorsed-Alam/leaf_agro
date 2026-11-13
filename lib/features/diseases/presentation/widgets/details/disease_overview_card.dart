import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../data/models/crop_model.dart';
import '../../../../../data/models/disease_model.dart';

/// Screen 17 – Disease Overview Card
/// Provides a clear, farmer-friendly introduction to the disease,
/// its host crop impact, and agricultural context.
class DiseaseOverviewCard extends StatelessWidget {
  final DiseaseModel disease;
  final CropModel? crop;
  final bool isBn;

  const DiseaseOverviewCard({
    super.key,
    required this.disease,
    required this.crop,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    final cropName = crop != null
        ? (isBn ? crop!.nameBn : crop!.nameEn)
        : (isBn ? 'ফসল' : 'crop');

    final String overviewText;
    if (disease.isHealthy) {
      overviewText = isBn
          ? 'এই $cropName গাছটি সম্পূর্ণ সুস্থ ও সতেজ রয়েছে। পাতায় কোনো ছত্রাক বা ব্যাকটেরিয়াজনিত রোগজীবাণুর লক্ষণ বা ক্ষত নেই। ফলন ও রোগ প্রতিরোধ ক্ষমতা অটুট রাখতে নিয়মিত সুষম পরিচর্যা বজায় রাখুন।'
          : 'This $cropName plant appears healthy, vibrant, and free from observable fungal or bacterial lesions. Continue regular balanced crop management to maintain vigor and prevent seasonal pathogens.';
    } else {
      overviewText = isBn
          ? '${disease.diseaseNameBn} হলো $cropName ফসলের একটি ক্ষতিকর রোগ। এটি আক্রান্ত পাতার স্বাভাবিক সালোকসংশ্লেষণ ব্যাহত করে এবং সময়মতো দমন না করলে গাছের বৃদ্ধি কমে ফলন মারাত্মকভাবে হ্রাস পেতে পারে।'
          : '${disease.diseaseNameEn} is a known disease affecting $cropName plants. It impairs normal photosynthetic activity in affected leaves and can cause notable yield reduction if left unmanaged.';
    }

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
                  Icons.menu_book_rounded,
                  size: 20,
                  color: AppColors.forestGreen,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                isBn ? 'পরিচিতি ও বিবরণ' : 'Overview',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Overview Body
          Text(
            overviewText,
            style: const TextStyle(
              fontSize: 14.5,
              height: 1.55,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 12),

          // Host Plant Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.eco_outlined,
                  size: 16,
                  color: AppColors.forestGreen,
                ),
                const SizedBox(width: 6),
                Text(
                  isBn
                      ? 'আক্রান্ত হোস্ট ফসল: $cropName'
                      : 'Host Crop: $cropName',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.forestGreen,
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
