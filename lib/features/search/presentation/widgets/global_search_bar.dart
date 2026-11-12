import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class GlobalSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback onClear;
  final bool isLoading;
  final bool isBn;

  const GlobalSearchBar({
    super.key,
    required this.controller,
    this.focusNode,
    required this.onChanged,
    this.onSubmitted,
    required this.onClear,
    this.isLoading = false,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: focusNode?.hasFocus == true
                ? AppColors.freshGreen
                : AppColors.border,
            width: focusNode?.hasFocus == true ? 1.5 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.forestGreen.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          textInputAction: TextInputAction.search,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.primaryText,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: isBn
                ? 'ফসল বা রোগ অনুসন্ধান করুন...'
                : 'Search crops or diseases...',
            hintStyle: const TextStyle(
              fontSize: 14,
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.forestGreen,
              size: 22,
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.forestGreen,
                      ),
                    ),
                  ),
                if (controller.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(
                      Icons.cancel_rounded,
                      size: 20,
                      color: AppColors.secondaryText,
                    ),
                    onPressed: onClear,
                    tooltip: isBn ? 'মুছে ফেলুন' : 'Clear',
                  ),
              ],
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }
}
