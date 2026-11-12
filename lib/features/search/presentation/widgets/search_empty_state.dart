import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SearchEmptyState extends StatelessWidget {
  final VoidCallback onClear;
  final bool isBn;

  const SearchEmptyState({
    super.key,
    required this.onClear,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Agriculture-themed Search Icon Container
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.softNaturalGreen,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 52,
                color: AppColors.forestGreen,
              ),
            ),
            const SizedBox(height: 20),

            // Heading
            Text(
              isBn ? 'কোনো ফলাফল পাওয়া যায়নি' : 'No Results Found',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryText,
                letterSpacing: -0.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Message
            Text(
              isBn
                  ? 'আপনার অনুসন্ধানের সাথে মেলে এমন কোনো ফসল বা রোগ পাওয়া যায়নি।'
                  : "We couldn't find any crops or diseases matching your search.",
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.secondaryText,
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),

            // Helpful suggestion
            Text(
              isBn
                  ? 'ভিন্ন কোনো শব্দ লিখে চেষ্টা করুন বা বানান পরীক্ষা করুন।'
                  : 'Try another keyword or check your spelling.',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.forestGreen,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),

            // Clear Search Action Button
            ElevatedButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: Text(isBn ? 'অনুসন্ধান মুছুন' : 'Clear Search'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.forestGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
