import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'image_quality_tip.dart';

/// Compact tips section helping farmers capture high-diagnostic-quality photos
class ImageQualityGuide extends StatelessWidget {
  final bool isBn;

  const ImageQualityGuide({
    super.key,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.borderGreen,
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.forestGreen.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Heading
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline_rounded,
                size: 18,
                color: AppColors.forestGreen,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  isBn ? 'উন্নত ফলাফলের পরামর্শ' : 'Tips for a Better Result',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 4 Compact Quality Guidelines
          ImageQualityTip(
            icon: Icons.wb_sunny_outlined,
            title: isBn ? 'পর্যাপ্ত আলো ব্যবহার করুন' : 'Use good lighting',
            subtitle: isBn
                ? 'প্রাকৃতিক বা পরিষ্কার দিনের আলোতে পাতার ছবি তুলুন।'
                : 'Capture the leaf in natural or sufficient light.',
          ),
          const SizedBox(height: 10),
          ImageQualityTip(
            icon: Icons.filter_center_focus_rounded,
            title: isBn ? 'পাতার ওপর ফোকাস রাখুন' : 'Keep the leaf in focus',
            subtitle: isBn
                ? 'নিশ্চিত করুন পাতার শিরা ও বিস্তার স্পষ্টভাবে দৃশ্যমান।'
                : 'Make sure the leaf details are clearly visible.',
          ),
          const SizedBox(height: 10),
          ImageQualityTip(
            icon: Icons.vibration_rounded,
            title: isBn ? 'ঝাপসা ছবি তোলা এড়িয়ে চলুন' : 'Avoid blurry images',
            subtitle: isBn
                ? 'ছবি তোলার সময় হাত ও ফোন স্থির রাখুন।'
                : 'Keep your phone steady while taking the photo.',
          ),
          const SizedBox(height: 10),
          ImageQualityTip(
            icon: Icons.center_focus_strong_rounded,
            title: isBn
                ? 'আক্রান্ত অংশ সুস্পষ্ট রাখুন'
                : 'Capture the affected area clearly',
            subtitle: isBn
                ? 'দাগ, বিবর্ণতা বা রোগাক্রান্ত অংশ যেন ছবিতে পরিষ্কার থাকে।'
                : 'Include visible spots, discoloration, or damaged areas.',
          ),
        ],
      ),
    );
  }
}
