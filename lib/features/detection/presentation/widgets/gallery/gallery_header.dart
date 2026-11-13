import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';

/// Top header for Screen 13 – Gallery Upload Screen
/// Displays title, subtitle, back navigation, and optional crop badge.
class GalleryHeader extends StatelessWidget {
  final bool isBn;
  final String? selectedCropName;
  final VoidCallback? onBack;

  const GalleryHeader({
    super.key,
    required this.isBn,
    this.selectedCropName,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar with Back Button & Crop Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back Button
              Semantics(
                button: true,
                label: isBn ? 'ফিরে যান' : 'Go back',
                child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 1,
                  shadowColor: Colors.black12,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      if (onBack != null) {
                        onBack!();
                      } else {
                        try {
                          context.pop();
                        } catch (_) {
                          Navigator.of(context).maybePop();
                        }
                      }
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.borderGreen,
                          width: 1.2,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.primaryText,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),

              // Active Crop Context Badge (if crop was selected)
              if (selectedCropName != null && selectedCropName!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.freshGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.freshGreen.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.eco_rounded,
                        color: AppColors.forestGreen,
                        size: 15,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        selectedCropName!,
                        style: const TextStyle(
                          color: AppColors.forestGreen,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                )
              else
                const SizedBox.shrink(),
            ],
          ),

          const SizedBox(height: 18),

          // Heading & Subtitle
          Text(
            isBn ? 'গাছের ছবি নির্বাচন করুন' : 'Choose a Plant Image',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryText,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isBn
                ? 'আপনার ডিভাইস থেকে পাতার স্পষ্ট ছবি নির্বাচন করুন।'
                : 'Select a clear leaf image from your device.',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.secondaryText,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
