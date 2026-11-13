import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

/// Error or empty state displayed if no prediction is available on Screen 16
class ResultErrorView extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback onScanAnother;
  final VoidCallback onReturnHome;
  final bool isBn;

  const ResultErrorView({
    super.key,
    this.errorMessage,
    required this.onScanAnother,
    required this.onReturnHome,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.amber.shade300,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.search_off_rounded,
                color: Colors.amber.shade800,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isBn ? 'ফলাফল পাওয়া যায়নি' : 'No Prediction Available',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ??
                  (isBn
                      ? 'মডেল থেকে কোনো ফলাফল পাওয়া যায়নি। অনুগ্রহ করে পুনরায় পাতার ছবি তুলে পরীক্ষা করুন।'
                      : "We couldn't interpret this result. Please try capturing another leaf photograph."),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.secondaryText,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: onScanAnother,
                icon: const Icon(Icons.document_scanner_rounded, size: 20),
                label: Text(
                  isBn ? 'আবার স্ক্যান করুন' : 'Scan Another Plant',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forestGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: onReturnHome,
                icon: const Icon(Icons.home_outlined, size: 18),
                label: Text(
                  isBn ? 'হোমে ফিরে যান' : 'Return Home',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.forestGreen,
                  side: const BorderSide(
                    color: AppColors.borderGreen,
                    width: 1.4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
