import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

enum DiseaseEmptyType {
  noDiseasesForCrop,
  noSearchResults,
  catalogEmpty,
}

class DiseaseEmptyState extends StatelessWidget {
  final DiseaseEmptyType type;
  final VoidCallback? onAction;
  final bool isBn;

  const DiseaseEmptyState({
    super.key,
    required this.type,
    this.onAction,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, heading, description, actionText) = _getStateContent();

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Styled Circular Icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.softNaturalGreen,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppColors.forestGreen,
              ),
            ),
            const SizedBox(height: 20),

            // Heading
            Text(
              heading,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryText,
                letterSpacing: -0.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              description,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.secondaryText,
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),

            // Action Button
            if (onAction != null && actionText.isNotEmpty)
              OutlinedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: Text(actionText),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.forestGreen,
                  side: const BorderSide(color: AppColors.freshGreen, width: 1.2),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
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

  (IconData, String, String, String) _getStateContent() {
    switch (type) {
      case DiseaseEmptyType.noDiseasesForCrop:
        return (
          Icons.grass_rounded,
          isBn ? 'রোগ পাওয়া যায়নি' : 'No Diseases Found',
          isBn
              ? 'এই ফসলের জন্য কোনো রোগ তথ্য বর্তমানে উপলব্ধ নেই।'
              : 'No disease information is currently available for this crop.',
          isBn ? 'সকল ফসল দেখুন' : 'View All Crops',
        );
      case DiseaseEmptyType.noSearchResults:
        return (
          Icons.search_off_rounded,
          isBn ? 'কোনো রোগ মেলেনি' : 'No Matching Diseases',
          isBn
              ? 'অন্য কোনো রোগের নাম লিখুন বা অন্য ফসল নির্বাচন করুন।'
              : 'Try another disease name or select a different crop.',
          isBn ? 'অনুসন্ধান মুছুন' : 'Clear Search',
        );
      case DiseaseEmptyType.catalogEmpty:
        return (
          Icons.library_books_outlined,
          isBn ? 'রোগের তথ্য পাওয়া যায়নি' : 'Disease Information Unavailable',
          isBn
              ? 'রোগের তথ্য ডাটাবেজে যুক্ত হলে এখানে প্রদর্শিত হবে।'
              : 'Disease information will appear here when available.',
          '',
        );
    }
  }
}
