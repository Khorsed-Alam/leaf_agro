import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CropSelectionHeader extends StatelessWidget {
  final bool isBn;
  final VoidCallback onBack;

  const CropSelectionHeader({
    super.key,
    required this.isBn,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back Button Row
        Row(
          children: [
            Material(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.borderGreen, width: 1.2),
              ),
              child: InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(12),
                child: const SizedBox(
                  width: 42,
                  height: 42,
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.primaryText,
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.freshGreen.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.forestGreen,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isBn ? 'ধাপ ০১ • ফসল নির্বাচন' : 'Step 01 • Crop Selection',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.forestGreen,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Heading & Subtitle
        Text(
          isBn ? 'ফসল নির্বাচন করুন' : 'Select Your Crop',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryText,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isBn
              ? 'যে ফসলের রোগ পরীক্ষা করতে চান তা তালিকা থেকে বেছে নিন।'
              : 'Choose the plant you want to examine with AI vision.',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.secondaryText,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
