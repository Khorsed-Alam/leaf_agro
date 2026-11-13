import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';

/// Screen 17 – Disease Not Found State
/// Displayed when an invalid or unmapped disease ID is queried.
class DiseaseNotFoundView extends StatelessWidget {
  final bool isBn;
  final VoidCallback? onBack;

  const DiseaseNotFoundView({
    super.key,
    required this.isBn,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFFCA5A5).withValues(alpha: 0.5),
                ),
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 52,
                color: Color(0xFFDC2626),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isBn
                  ? 'রোগের কোনো তথ্য পাওয়া যায়নি'
                  : 'Disease Information Unavailable',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isBn
                  ? 'অনুরোধকৃত রোগটি ডাটাবেজে নেই অথবা যাচাইকৃত তালিকার সাথে মেলানো সম্ভব হয়নি।'
                  : 'The requested disease record could not be found or mapped in our verified catalogue.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.secondaryText,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.forestGreen,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: Text(
                isBn ? 'রোগ তালিকায় ফিরে যান' : 'Back to Disease Catalogue',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                if (onBack != null) {
                  onBack!();
                } else if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/diseases');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
