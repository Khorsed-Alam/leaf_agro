import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

/// Screen 23 – Historical Record Banner
/// Restrained, prominent banner immediately informing the farmer that this is
/// an authentic past saved record, NOT a live analysis.
class HistoricalRecordBanner extends StatelessWidget {
  final bool isBn;

  const HistoricalRecordBanner({
    super.key,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: AppColors.freshGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.freshGreen.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.history_edu_rounded,
              size: 18,
              color: AppColors.forestGreen,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBn ? 'পূর্ববর্তী এআই ফলাফল' : 'Previous Prediction',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.forestGreen,
                  ),
                ),
                Text(
                  isBn
                      ? 'এই ফলাফলটি আপনার সংরক্ষিত ইতিহাস থেকে প্রদর্শিত হচ্ছে।'
                      : 'This result is from your saved scan history.',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.primaryText,
                    height: 1.3,
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
