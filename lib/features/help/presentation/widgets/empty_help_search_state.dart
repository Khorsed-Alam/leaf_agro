import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Screen 28 – Empty Search State
class EmptyHelpSearchState extends StatelessWidget {
  final bool isBn;
  final VoidCallback onClear;

  const EmptyHelpSearchState({
    super.key,
    required this.isBn,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGreen, width: 1.2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.softNaturalGreen,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderGreen, width: 1),
            ),
            child: const Icon(
              Icons.search_off_rounded,
              color: AppColors.forestGreen,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            isBn ? 'কোনো সহায়তার বিষয় পাওয়া যায়নি' : 'No help topics found',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.forestGreen,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            isBn
                ? 'অন্য কোনো শব্দ দিয়ে খুঁজুন অথবা নিচের নির্দেশিকাগুলো দেখুন।'
                : 'Try a different word or browse the guides below.',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.secondaryText,
              height: 1.35,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: Text(
              isBn ? 'অনুসন্ধান মুছুন' : 'Clear search',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.forestGreen,
              side: const BorderSide(color: AppColors.forestGreen, width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
