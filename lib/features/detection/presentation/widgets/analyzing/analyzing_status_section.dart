import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

/// Central Status Section of Screen 15
/// Shows the main heading, subtitle, indeterminate progress bar, processing status, and on-device badge.
class AnalyzingStatusSection extends StatelessWidget {
  final bool isBn;

  const AnalyzingStatusSection({
    super.key,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Exact Main Heading
          Text(
            isBn ? 'আপনার গাছ বিশ্লেষণ করা হচ্ছে' : 'Analyzing Your Plant',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryText,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),

          // 2. Exact Subtitle
          Text(
            isBn
                ? 'আমাদের AI মডেল পাতার ছবিটি পর্যবেক্ষণ করছে।'
                : 'Our AI model is examining the leaf image.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 22),

          // 3. Indeterminate Progress Indicator (Truthful, non-fabricated)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 220,
              height: 6,
              child: LinearProgressIndicator(
                backgroundColor: AppColors.freshGreen.withValues(alpha: 0.15),
                color: AppColors.freshGreen,
              ),
            ),
          ),
          const SizedBox(height: 18),

          // 4. Status Text with Pulsing Green Dot
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.freshGreen,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.freshGreen,
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isBn
                    ? 'আপনার ডিভাইসেই ছবিটি প্রক্রিয়া করা হচ্ছে'
                    : 'Processing image on your device',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.forestGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 5. Genuine Offline AI Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.borderGreen,
                width: 1.1,
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
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.wifi_off_rounded,
                  color: AppColors.forestGreen,
                  size: 15,
                ),
                const SizedBox(width: 6),
                Text(
                  isBn ? 'অন-ডিভাইস AI • অফলাইন' : 'On-device AI • Offline',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.forestGreen,
                    letterSpacing: 0.1,
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
