import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class DiseaseSearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool isBn;

  const DiseaseSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: AppColors.forestGreen.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.primaryText,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: isBn ? 'রোগের নাম বা লক্ষণ দিয়ে খুঁজুন...' : 'Search diseases or symptoms...',
            hintStyle: const TextStyle(
              fontSize: 13,
              color: AppColors.secondaryText,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.forestGreen,
              size: 22,
            ),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.secondaryText),
                    onPressed: onClear,
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }
}
