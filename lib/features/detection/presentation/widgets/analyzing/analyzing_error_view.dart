import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

/// Error state view when AI inference fails
class AnalyzingErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onReturnToPreview;
  final String? errorMessage;
  final bool isBn;

  const AnalyzingErrorView({
    super.key,
    required this.onRetry,
    required this.onReturnToPreview,
    this.errorMessage,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.red.shade300,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: Colors.red.shade700,
                size: 38,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              isBn
                  ? 'আমরা এই ছবিটি বিশ্লেষণ করতে পারিনি। অনুগ্রহ করে আবার চেষ্টা করুন।'
                  : "We couldn't analyze this image. Please try again.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
                height: 1.35,
              ),
            ),
            if (errorMessage != null && errorMessage!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
            const SizedBox(height: 24),
            // Primary Retry Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: Text(
                  isBn ? 'পুনরায় চেষ্টা করুন' : 'Retry Analysis',
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
                  elevation: 1,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Secondary Return to Review Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: onReturnToPreview,
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: Text(
                  isBn ? 'অন্য ছবি পছন্দ করুন' : 'Choose Another Image',
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
