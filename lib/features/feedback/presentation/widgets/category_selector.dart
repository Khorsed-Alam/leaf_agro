import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class FeedbackCategoryItem {
  final String id;
  final String labelEn;
  final String labelBn;
  final IconData icon;

  const FeedbackCategoryItem({
    required this.id,
    required this.labelEn,
    required this.labelBn,
    required this.icon,
  });

  String label(bool isBn) => isBn ? labelBn : labelEn;
}

/// Screen 29 – Category Selector
class CategorySelector extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<String> onCategoryChanged;
  final String? errorText;
  final bool isBn;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
    this.errorText,
    required this.isBn,
  });

  static const List<FeedbackCategoryItem> categories = [
    FeedbackCategoryItem(
      id: 'AI prediction accuracy',
      labelEn: 'AI prediction accuracy',
      labelBn: 'এআই রোগ নির্ণয়ের নির্ভুলতা',
      icon: Icons.analytics_outlined,
    ),
    FeedbackCategoryItem(
      id: 'App usability',
      labelEn: 'App usability',
      labelBn: 'অ্যাপ ব্যবহারের সুবিধা',
      icon: Icons.touch_app_outlined,
    ),
    FeedbackCategoryItem(
      id: 'Disease information',
      labelEn: 'Disease information',
      labelBn: 'রোগের তথ্য ও বিবরণ',
      icon: Icons.menu_book_rounded,
    ),
    FeedbackCategoryItem(
      id: 'Treatment recommendations',
      labelEn: 'Treatment recommendations',
      labelBn: 'প্রতিকার ও চিকিৎসা পরামর্শ',
      icon: Icons.healing_outlined,
    ),
    FeedbackCategoryItem(
      id: 'Other',
      labelEn: 'Other',
      labelBn: 'অন্যান্য',
      icon: Icons.more_horiz_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: errorText != null ? AppColors.error : AppColors.borderGreen,
          width: errorText != null ? 1.4 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isBn ? 'মতামতের বিষয় কী?' : 'What is your feedback about?',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.forestGreen,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            isBn
                ? 'যে বিষয়ে জানাতে চান তা নির্বাচন করুন।'
                : 'Choose the area you would like to tell us about.',
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 12),

          // Categories wrap
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((cat) {
              final isSelected = selectedCategory == cat.id;

              return ChoiceChip(
                avatar: Icon(
                  cat.icon,
                  size: 16,
                  color: isSelected ? Colors.white : AppColors.forestGreen,
                ),
                label: Text(cat.label(isBn)),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    onCategoryChanged(cat.id);
                  }
                },
                selectedColor: AppColors.forestGreen,
                backgroundColor: AppColors.softNaturalGreen,
                labelStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.primaryText,
                ),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.forestGreen
                      : AppColors.borderGreen,
                  width: isSelected ? 1.4 : 1.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              );
            }).toList(),
          ),

          // Error Text
          if (errorText != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    size: 14, color: AppColors.error),
                const SizedBox(width: 4),
                Text(
                  errorText!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
