import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Screen 22 – Detection History Search Bar
/// Provides interactive search filtering by crop name, disease name, or healthy state.
class HistorySearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isBn;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const HistorySearchBar({
    super.key,
    required this.controller,
    required this.isBn,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasText = controller.text.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.borderGreen,
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
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryText,
          ),
          decoration: InputDecoration(
            hintText:
                isBn ? 'ফসল বা রোগের নাম খুঁজুন...' : 'Search crop or disease...',
            hintStyle: const TextStyle(
              fontSize: 13,
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
                      Icons.clear_rounded,
                      size: 18,
                      color: AppColors.secondaryText,
                    ),
                    onPressed: onClear,
                  )
                : null,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
      ),
    );
  }
}

