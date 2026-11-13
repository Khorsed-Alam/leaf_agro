import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

/// Instruction box advising the farmer to ensure the lesion is clear
class ImageReviewInstruction extends StatelessWidget {
  final bool isBn;

  const ImageReviewInstruction({
    super.key,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderGreen,
          width: 1.1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2.0),
            child: Icon(
              Icons.info_outline_rounded,
              color: AppColors.forestGreen,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBn
                      ? 'পাতার অংশটি স্পষ্টভাবে দেখা যাচ্ছে কিনা নিশ্চিত করুন।'
                      : 'Make sure the leaf is clearly visible.',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isBn
                      ? 'রোগ নির্ণয় শুরু করার পূর্বে আক্রান্ত ও ক্ষতিগ্রস্ত অংশটি দৃশ্যমান কিনা তা দেখে নিন।'
                      : 'Check that the affected part of the leaf is visible before starting the analysis.',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.secondaryText,
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
