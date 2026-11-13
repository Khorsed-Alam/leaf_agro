import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Screen 22 – Empty History State View
/// Rendered when the farmer has zero saved diagnosis records in the system.
class EmptyHistoryView extends StatelessWidget {
  final bool isBn;
  final VoidCallback onScanFirstPlant;

  const EmptyHistoryView({
    super.key,
    required this.isBn,
    required this.onScanFirstPlant,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Emblem illustration
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.freshGreen.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.freshGreen.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.spa_rounded,
                size: 44,
                color: AppColors.forestGreen,
              ),
            ),
            const SizedBox(height: 20),

            // Heading
            Text(
              isBn
                  ? 'এখনও কোনো রোগ পরীক্ষার ইতিহাস নেই'
                  : 'No Detection History Yet',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.forestGreen,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              isBn
                  ? 'আপনার পূর্ববর্তী রোগ পরীক্ষার ফলাফল এখানে সংরক্ষিত থাকবে। আপনার ফসলের পাতার একটি ছবি তুলে শুরু করুন।'
                  : 'Your previous plant scans will appear here. Start by taking a photo of a plant leaf.',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.secondaryText,
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Primary Scan Button
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: onScanFirstPlant,
                icon: const Icon(Icons.camera_alt_outlined, size: 20),
                label: Text(
                  isBn ? 'প্রথম পরীক্ষা শুরু করুন' : 'Scan Your First Plant',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forestGreen,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
