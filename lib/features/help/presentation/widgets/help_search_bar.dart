import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Screen 28 – Search Help Field
class HelpSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool isBn;

  const HelpSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    final hasText = controller.text.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasText ? AppColors.forestGreen : AppColors.borderGreen,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryText,
        ),
        decoration: InputDecoration(
          hintText: isBn ? 'সাহায্য খুঁজুন...' : 'Search for help...',
          hintStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.secondaryText,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.forestGreen,
            size: 22,
          ),
          suffixIcon: hasText
              ? IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.secondaryText,
                    size: 20,
                  ),
                  tooltip: isBn ? 'মুছে ফেলুন' : 'Clear search',
                  onPressed: onClear,
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
