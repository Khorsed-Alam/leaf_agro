import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../data/models/crop_model.dart';

/// Small information card displaying the active crop context if selected
class SelectedCropInfo extends StatelessWidget {
  final CropModel? selectedCrop;
  final bool isBn;

  const SelectedCropInfo({
    super.key,
    required this.selectedCrop,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedCrop == null) {
      return const SizedBox.shrink();
    }

    final cropName = isBn ? selectedCrop!.nameBn : selectedCrop!.nameEn;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderGreen,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.forestGreen.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.freshGreen.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.eco_rounded,
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
                  isBn ? 'নির্বাচিত ফসল' : 'Selected Crop',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  cropName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.forestGreen,
                  ),
                ),
              ],
            ),
          ),
          if (selectedCrop!.isAiSupported)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.freshGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isBn ? 'AI মডেল প্রস্তুত' : 'AI Ready',
                style: const TextStyle(
                  color: AppColors.forestGreen,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
