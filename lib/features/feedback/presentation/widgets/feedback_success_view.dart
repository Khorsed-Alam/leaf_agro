import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

/// Screen 29 – Feedback Success Confirmation View
class FeedbackSuccessView extends StatelessWidget {
  final bool isBn;
  final VoidCallback onReset;

  const FeedbackSuccessView({
    super.key,
    required this.isBn,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Success Animated/Check Icon
            Center(
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.softNaturalGreen,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderGreen, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.forestGreen.withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.forestGreen,
                    size: 52,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Heading
            Text(
              isBn
                  ? 'আপনার মতামতের জন্য ধন্যবাদ!'
                  : 'Thank You for Your Feedback!',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.forestGreen,
                letterSpacing: -0.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              isBn
                  ? 'আপনার মতামত সফলভাবে জমা হয়েছে। এটি কৃষক ভাইদের জন্য এগ্রিকেয়ার এআই-কে আরও উন্নত ও নির্ভুল করতে সাহায্য করবে।'
                  : 'Your feedback has been submitted successfully. It helps us make AgriCare AI better and more accurate for farmers.',
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
                color: AppColors.secondaryText,
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),

            // Primary Return Button
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/settings');
                  }
                },
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: Text(
                  isBn ? 'ফিরে যান' : 'Back',
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
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Secondary Submit Another Feedback Button
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(
                  isBn ? 'আরেকটি মতামত পাঠান' : 'Submit Another Feedback',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.forestGreen,
                  side: const BorderSide(
                      color: AppColors.forestGreen, width: 1.4),
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
