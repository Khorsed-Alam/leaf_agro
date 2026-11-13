import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../data/models/crop_model.dart';
import '../../../../../data/models/disease_model.dart';

/// Screen 17 – Disease Hero Section
/// Displays the disease headline, affected crop tag, health status badge,
/// verified disease photography, and sample content banner when applicable.
class DiseaseHeroSection extends StatelessWidget {
  final DiseaseModel disease;
  final CropModel? crop;
  final bool isBn;
  final bool isSample;

  const DiseaseHeroSection({
    super.key,
    required this.disease,
    required this.crop,
    required this.isBn,
    this.isSample = false,
  });

  @override
  Widget build(BuildContext context) {
    final showSampleBanner = disease.isSample || isSample;
    final primaryName = isBn ? disease.diseaseNameBn : disease.diseaseNameEn;
    final secondaryName = isBn ? disease.diseaseNameEn : disease.diseaseNameBn;
    final cropName = crop != null
        ? (isBn ? crop!.nameBn : crop!.nameEn)
        : (isBn ? 'শস্য' : 'Crop');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.forestGreen.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Sample Content Banner (Only shown if explicitly flagged as sample/demo content)
          if (showSampleBanner)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: const BoxDecoration(
                color: Color(0xFFFEF3C7),
                borderRadius: BorderRadius.vertical(top: Radius.circular(23)),
                border: Border(
                  bottom: BorderSide(color: Color(0xFFF59E0B), width: 1),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFFB45309),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isBn
                          ? 'নমুনা তথ্য – শুধুমাত্র প্রদর্শনের জন্য'
                          : 'Sample Information – For Demonstration Only',
                      style: const TextStyle(
                        color: Color(0xFF92400E),
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // 2. Rounded Disease Image / Visual Container
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(showSampleBanner ? 0 : 23),
                ),
                child: disease.imageUrl != null && disease.imageUrl!.isNotEmpty
                    ? Image.network(
                        disease.imageUrl!,
                        width: double.infinity,
                        height: 220,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 220,
                            color: AppColors.softNaturalGreen,
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => _buildFallbackVisual(),
                      )
                    : _buildFallbackVisual(),
              ),

              // Bottom gradient on the photograph
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 60,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.45),
                      ],
                    ),
                  ),
                ),
              ),

              // Affected Crop Pill (Floating on top-left of photo)
              Positioned(
                top: 14,
                left: 14,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.forestGreen.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.limeGreen.withValues(alpha: 0.6),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.grass_rounded,
                        color: AppColors.limeGreen,
                        size: 14,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        cropName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Healthy or Infected Status Badge (Floating on top-right of photo)
              Positioned(
                top: 14,
                right: 14,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: disease.isHealthy
                        ? const Color(0xFFDCFCE7).withValues(alpha: 0.95)
                        : const Color(0xFFFEF2F2).withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: disease.isHealthy
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFEF4444),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        disease.isHealthy
                            ? Icons.check_circle_rounded
                            : Icons.coronavirus_outlined,
                        size: 14,
                        color: disease.isHealthy
                            ? const Color(0xFF15803D)
                            : const Color(0xFFDC2626),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        disease.isHealthy
                            ? (isBn ? 'সুস্থ উদ্ভিদ' : 'Healthy Plant')
                            : (isBn ? 'রোগাক্রান্ত' : 'Infected'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: disease.isHealthy
                              ? const Color(0xFF15803D)
                              : const Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 3. Disease Name & Title Section
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  primaryName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryText,
                    height: 1.25,
                  ),
                ),
                if (secondaryName.isNotEmpty &&
                    secondaryName != primaryName) ...[
                  const SizedBox(height: 4),
                  Text(
                    secondaryName,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackVisual() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: disease.isHealthy
            ? AppColors.softNaturalGreen
            : const Color(0xFFFEF2F2),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              disease.isHealthy
                  ? Icons.eco_rounded
                  : Icons.coronavirus_outlined,
              size: 56,
              color: disease.isHealthy
                  ? AppColors.forestGreen
                  : const Color(0xFFDC2626).withValues(alpha: 0.8),
            ),
            const SizedBox(height: 8),
            Text(
              disease.isHealthy
                  ? (isBn ? 'সতেজ ও সুস্থ পাতা' : 'Healthy Foliage')
                  : (isBn
                      ? 'রোগের প্রতীকী ভিজ্যুয়াল'
                      : 'Plant Pathology Visual'),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: disease.isHealthy
                    ? AppColors.forestGreen
                    : const Color(0xFF991B1B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
