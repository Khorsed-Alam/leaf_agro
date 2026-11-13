import 'dart:io';
import 'package:flutter/material.dart';
import 'package:leaf_agro/core/theme/app_colors.dart';
import 'package:leaf_agro/data/models/crop_model.dart';
import 'package:leaf_agro/data/models/disease_model.dart';
import 'package:leaf_agro/data/models/prediction_model.dart';

/// Screen 18 – Detected Disease Summary Card
/// Displays detected disease headline, host crop, prediction certainty disclaimer,
/// optional image thumbnail, and model confidence score.
class DetectedDiseaseSummaryCard extends StatelessWidget {
  final DiseaseModel disease;
  final CropModel? crop;
  final PredictionModel? prediction;
  final String? imagePath;
  final bool isBn;
  final bool isSample;

  const DetectedDiseaseSummaryCard({
    super.key,
    required this.disease,
    required this.crop,
    this.prediction,
    this.imagePath,
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

    final double? confidence = prediction?.confidence;
    final String? confidenceText =
        confidence != null ? '${(confidence * 100).toStringAsFixed(1)}%' : null;

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
          // 1. Sample Content Banner (when demo or sample fixture is active)
          if (showSampleBanner)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFFFEF3C7),
                borderRadius: BorderRadius.vertical(top: Radius.circular(21)),
                border: Border(
                  bottom: BorderSide(color: Color(0xFFF59E0B), width: 1),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFFB45309),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isBn
                          ? 'নমুনা নির্দেশিকা – শুধুমাত্র প্রদর্শনের জন্য'
                          : 'Sample Guidance – For Demonstration Only',
                      style: const TextStyle(
                        color: Color(0xFF92400E),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Thumbnail + Disease Title + Crop Tag
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Leaf Thumbnail or Pathogen Icon
                    _buildImageThumbnail(),
                    const SizedBox(width: 14),

                    // Titles & Crop Tag
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status Pill & Crop Row
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.softNaturalGreen,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  cropName,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.forestGreen,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: disease.isHealthy
                                      ? const Color(0xFFDCFCE7)
                                      : const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  disease.isHealthy
                                      ? (isBn ? 'সুস্থ' : 'Healthy')
                                      : (isBn ? 'রোগাক্রান্ত' : 'Detected'),
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: disease.isHealthy
                                        ? const Color(0xFF15803D)
                                        : const Color(0xFFB45309),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Primary Disease Name
                          Text(
                            primaryName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryText,
                              height: 1.25,
                            ),
                          ),
                          if (secondaryName.isNotEmpty &&
                              secondaryName != primaryName) ...[
                            const SizedBox(height: 2),
                            Text(
                              secondaryName,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 12),

                // Confidence Score (Only shown if genuinely supplied by AI inference)
                if (confidenceText != null) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.analytics_outlined,
                        size: 16,
                        color: AppColors.forestGreen,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isBn
                            ? 'AI প্যাটার্ন মিল: $confidenceText'
                            : 'AI Pattern Match: $confidenceText',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.forestGreen,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        isBn ? 'মডেল স্কোর' : 'Model Score',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],

                // Non-laboratory estimate disclaimer
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 14,
                        color: AppColors.secondaryText,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isBn
                              ? 'AI ফলাফলটি একটি আনুমানিক চিত্র বিশ্লেষণ, নিশ্চিত ল্যাবরেটরি রোগ নির্ণয় নয়।'
                              : 'AI detection reflects visual pattern matching, not an absolute laboratory diagnosis.',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.secondaryText,
                            fontStyle: FontStyle.italic,
                            height: 1.35,
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

  Widget _buildImageThumbnail() {
    if (imagePath != null && imagePath!.isNotEmpty) {
      final file = File(imagePath!);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(
            file,
            width: 68,
            height: 68,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildFallbackThumbnail(),
          ),
        );
      }
    }

    if (disease.imageUrl != null && disease.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          disease.imageUrl!,
          width: 68,
          height: 68,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallbackThumbnail(),
        ),
      );
    }

    return _buildFallbackThumbnail();
  }

  Widget _buildFallbackThumbnail() {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: disease.isHealthy
            ? AppColors.softNaturalGreen
            : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: disease.isHealthy
              ? AppColors.freshGreen.withValues(alpha: 0.3)
              : const Color(0xFFFCA5A5).withValues(alpha: 0.5),
        ),
      ),
      child: Center(
        child: Icon(
          disease.isHealthy ? Icons.eco_rounded : Icons.coronavirus_outlined,
          size: 32,
          color: disease.isHealthy
              ? AppColors.forestGreen
              : const Color(0xFFDC2626),
        ),
      ),
    );
  }
}
