import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Screen 22 – No Matching Filter Results View
/// Rendered when records exist in database, but active search/filters returned zero matches.
class NoMatchingResultsView extends StatelessWidget {
  final bool isBn;
  final VoidCallback onClearFilters;

  const NoMatchingResultsView({
    super.key,
    required this.isBn,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Search off icon
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 36,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 16),

            // Heading
            Text(
              isBn ? 'কোনো মিল পাওয়া যায়নি' : 'No Matching Results',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),

            // Description
            Text(
              isBn
                  ? 'অন্য কোনো ফসলের নাম, রোগ বা তারিখ নির্বাচন করে আবার চেষ্টা করুন।'
                  : 'Try another crop name, disease, or date range.',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.secondaryText,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Clear Filters Action Button
            OutlinedButton.icon(
              onPressed: onClearFilters,
              icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
              label: Text(
                isBn ? 'ফিল্টার মুছুন' : 'Clear Filters',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.forestGreen,
                side: const BorderSide(
                  color: AppColors.forestGreen,
                  width: 1.2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
