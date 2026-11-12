import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class EmptyCropSearchState extends StatelessWidget {
  final String query;
  final bool isBn;
  final VoidCallback onClear;

  const EmptyCropSearchState({
    super.key,
    required this.query,
    required this.isBn,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.softNaturalGreen,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderGreen, width: 1.5),
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 44,
                color: AppColors.forestGreen,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isBn ? '"$query" খুঁজে পাওয়া যায়নি' : 'No crops matching "$query"',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isBn
                  ? 'AgriCare AI মডেল বর্তমানে শুধুমাত্র ধান, আলু, টমেটো, আম ও পাট সমর্থন করে।'
                  : 'AgriCare AI model currently supports Rice, Potato, Tomato, Mango, and Jute.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.secondaryText,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: Text(
                isBn ? 'অনুসন্ধান মুছুন' : 'Clear Search',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.forestGreen,
                side: const BorderSide(color: AppColors.forestGreen, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
