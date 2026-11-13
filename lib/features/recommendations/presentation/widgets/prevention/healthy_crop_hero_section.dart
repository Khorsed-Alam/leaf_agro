import 'package:flutter/material.dart';
import 'package:leaf_agro/core/theme/app_colors.dart';
import 'package:leaf_agro/data/models/crop_model.dart';

/// Screen 19 – Healthy Crop Hero Section
/// Visual card emphasizing proactive crop care and realistic risk-reduction expectations.
class HealthyCropHeroSection extends StatelessWidget {
  final CropModel? crop;
  final bool isBn;

  const HealthyCropHeroSection({
    super.key,
    required this.crop,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    final cropName = crop != null
        ? (isBn ? crop!.nameBn : crop!.nameEn)
        : (isBn ? 'ফসল' : 'Crops');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.forestGreen.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Image / Visual Banner
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(21)),
                child: crop?.imageUrl != null && crop!.imageUrl!.isNotEmpty
                    ? Image.network(
                        crop!.imageUrl!,
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 150,
                            color: AppColors.softNaturalGreen,
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.forestGreen,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => _buildFallbackBanner(),
                      )
                    : _buildFallbackBanner(),
              ),

              // Gradient Overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 50,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.4),
                      ],
                    ),
                  ),
                ),
              ),

              // Floating Shield Badge
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.forestGreen.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.limeGreen.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.shield_rounded,
                        color: AppColors.limeGreen,
                        size: 14,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isBn ? '$cropName সুরক্ষা' : '$cropName Protection',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Text Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBn
                      ? 'আপনার ফসল সুস্থ ও সতেজ রাখুন'
                      : 'Keep Your Crops Healthy',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryText,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isBn
                      ? 'সঠিক কৃষি পরিচর্যা ও নিয়মিত পর্যবেক্ষণের মাধ্যমে রোগবালাইয়ের ঝুঁকি অনেকাংশে কমিয়ে সুস্থ ও সবল ফসল উৎপাদন নিশ্চিত করা সম্ভব।'
                      : 'Good crop care and regular monitoring can help reduce disease risks and support healthy plant growth across seasonal flushes.',
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: AppColors.secondaryText,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 10),

                // Realistic expectation notice
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 14,
                        color: AppColors.forestGreen,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          isBn
                              ? 'প্রতিরোধমূলক ব্যবস্থা রোগের ঝুঁকি কমায়, তবে এটি কোনো শতভাগ গ্যারান্টি নয়।'
                              : 'Preventive practices mitigate pathogen pressure; they do not guarantee disease-free crops.',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.secondaryText,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackBanner() {
    return Container(
      width: double.infinity,
      height: 130,
      decoration: const BoxDecoration(
        color: AppColors.softNaturalGreen,
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.spa_rounded,
              size: 44,
              color: AppColors.forestGreen,
            ),
            SizedBox(height: 6),
            Text(
              'AgriCare AI Crop Health',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.forestGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
