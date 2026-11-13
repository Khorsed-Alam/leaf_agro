import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';

/// Top header for Screen 14 – Image Preview Screen
/// Displays title, subtitle, and accessible back button.
class ImagePreviewHeader extends StatelessWidget {
  final bool isBn;
  final VoidCallback? onBack;

  const ImagePreviewHeader({
    super.key,
    required this.isBn,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar with Back Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.freshGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.freshGreen.withValues(alpha: 0.35),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.preview_rounded,
                      color: AppColors.forestGreen,
                      size: 15,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isBn ? 'নমুনা প্রিভিউ' : 'Sample Preview',
                      style: const TextStyle(
                        color: AppColors.forestGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Title & Subtitle
          Text(
            isBn ? 'আপনার ছবি পর্যালোচনা করুন' : 'Review Your Image',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryText,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            isBn
                ? 'AI রোগ নির্ণয় শুরু করার পূর্বে নিশ্চিত করুন যে পাতার নমুনাটি স্পষ্ট।'
                : 'Ensure the leaf sample is clear and well-lit before AI diagnosis.',
            style: const TextStyle(
              fontSize: 13,
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
