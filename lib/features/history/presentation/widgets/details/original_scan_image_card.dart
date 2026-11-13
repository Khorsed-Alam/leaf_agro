import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/leaf_image_view.dart';

/// Screen 23 – Original Scan Image Card
/// Displays the actual leaf photograph saved with the historical detection.
class OriginalScanImageCard extends StatelessWidget {
  final String? imagePath;
  final bool isHealthy;
  final bool isBn;

  const OriginalScanImageCard({
    super.key,
    required this.imagePath,
    required this.isHealthy,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null && imagePath!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.borderGreen,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image or Placeholder
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
            child: SizedBox(
              width: double.infinity,
              height: 220,
              child: hasImage
                  ? LeafImageView(
                      imagePath: imagePath!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: AppColors.surfaceContainerLow,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isHealthy
                                  ? Icons.eco_rounded
                                  : Icons.image_not_supported_outlined,
                              size: 48,
                              color: isHealthy
                                  ? AppColors.forestGreen
                                  : AppColors.secondaryText,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isBn
                                  ? 'মূল ছবি উপলব্ধ নেই'
                                  : 'Original Image Unavailable',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),

          // Caption Bar
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
            child: Row(
              children: [
                const Icon(
                  Icons.camera_alt_rounded,
                  size: 15,
                  color: AppColors.forestGreen,
                ),
                const SizedBox(width: 6),
                Text(
                  isBn ? 'সংরক্ষিত মূল ছবি' : 'Original Scan Image',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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
