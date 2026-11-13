import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../data/datasources/ai_crop_catalog.dart';
import '../../../../../data/models/crop_model.dart';

/// Screen 23 – Crop Information Card
/// Displays verified crop name and metadata associated with this historical detection.
class CropInformationCard extends StatelessWidget {
  final String? cropName;
  final bool isBn;

  const CropInformationCard({
    super.key,
    required this.cropName,
    required this.isBn,
  });

  CropModel? _resolveCrop(String? name) {
    if (name == null || name.isEmpty) return null;
    try {
      final normalized = name.toLowerCase().trim();
      return AiCropCatalog.verifiedSupportedCrops.firstWhere(
        (c) =>
            c.nameEn.toLowerCase() == normalized ||
            c.nameBn.toLowerCase() == normalized,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasCrop = cropName != null && cropName!.isNotEmpty;
    final resolvedCrop = _resolveCrop(cropName);

    String displayCropName = cropName ?? '';
    if (resolvedCrop != null) {
      displayCropName = isBn
          ? '${resolvedCrop.nameBn} (${resolvedCrop.nameEn})'
          : '${resolvedCrop.nameEn} (${resolvedCrop.nameBn})';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderGreen,
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.forestGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.spa_rounded,
              color: AppColors.forestGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBn ? 'ফসল' : 'Crop',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  hasCrop
                      ? displayCropName
                      : (isBn
                          ? 'ফসলের তথ্য উপলব্ধ নেই'
                          : 'Crop information unavailable'),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: hasCrop
                        ? AppColors.forestGreen
                        : AppColors.secondaryText,
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
