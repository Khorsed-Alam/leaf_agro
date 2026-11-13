import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/leaf_image_view.dart';
import 'prediction_status_badge.dart';

/// Large image card displaying the exact leaf photo analyzed with crop and status badge
class ResultImageCard extends StatelessWidget {
  final String imagePath;
  final String? cropName;
  final bool isHealthy;
  final bool isBn;

  const ResultImageCard({
    super.key,
    required this.imagePath,
    this.cropName,
    required this.isHealthy,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isHealthy
              ? AppColors.freshGreen.withValues(alpha: 0.5)
              : Colors.amber.shade300,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isHealthy
                ? AppColors.forestGreen.withValues(alpha: 0.08)
                : Colors.amber.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Main Image Viewport
          Container(
            height: 230,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.04),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(22)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  LeafImageView(
                    imagePath: imagePath,
                    fit: BoxFit.contain,
                  ),

                  // Overlay Status Badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: PredictionStatusBadge(
                      isHealthy: isHealthy,
                      isBn: isBn,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Crop Information Banner (if provided)
          if (cropName != null && cropName!.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(22)),
                border: Border(
                  top: BorderSide(
                    color: AppColors.borderGreen.withValues(alpha: 0.7),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.eco_rounded,
                        color: AppColors.forestGreen,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isBn ? 'শস্য:' : 'Target Crop:',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        cropName!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.forestGreen,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.freshGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      isBn ? 'AI মডেল নিরীক্ষিত' : 'Model Verified',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
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
  }
}
