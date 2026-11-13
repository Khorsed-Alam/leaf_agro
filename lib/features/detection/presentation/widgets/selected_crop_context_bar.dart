import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/crop_model.dart';

/// Context pill / banner displaying the currently selected crop (if any)
/// with a quick action to change or select crop.
class SelectedCropContextBar extends StatelessWidget {
  final CropModel? selectedCrop;
  final bool isBn;

  const SelectedCropContextBar({
    super.key,
    required this.selectedCrop,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedCrop != null) {
      final crop = selectedCrop!;
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.freshGreen.withValues(alpha: 0.45),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.forestGreen.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Crop Thumbnail or Icon
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 38,
                height: 38,
                color: AppColors.softNaturalGreen,
                child: crop.imageUrl != null && crop.imageUrl!.isNotEmpty
                    ? Image.network(
                        crop.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.eco_rounded,
                          color: AppColors.forestGreen,
                          size: 20,
                        ),
                      )
                    : const Icon(
                        Icons.eco_rounded,
                        color: AppColors.forestGreen,
                        size: 20,
                      ),
              ),
            ),
            const SizedBox(width: 10),

            // Crop Name & AI Badge
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          isBn ? crop.nameBn : crop.nameEn,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isBn ? 'AI মডেল প্রস্তুত' : 'AI Ready',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.forestGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isBn
                        ? '${crop.supportedDiseaseCount}টি রোগ শনাক্তকরণ সমর্থিত'
                        : '${crop.supportedDiseaseCount} diseases supported by AI model',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.secondaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Change button
            TextButton(
              onPressed: () => context.push('/crop-select'),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: AppColors.forestGreen,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: Text(
                isBn ? 'পরিবর্তন' : 'Change',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // No Crop Selected – Optional Recommendation
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.eco_outlined,
            size: 20,
            color: AppColors.forestGreen,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isBn
                  ? 'সকল শস্য সমর্থিত • নির্দিষ্ট ফসলের জন্য বাছাই করুন'
                  : 'All crops supported • Select crop for higher accuracy',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryText,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: () => context.push('/crop-select'),
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              foregroundColor: AppColors.forestGreen,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: Text(
              isBn ? 'বাছাই' : 'Select',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
