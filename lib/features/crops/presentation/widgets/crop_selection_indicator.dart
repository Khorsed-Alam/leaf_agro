import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CropSelectionIndicator extends StatelessWidget {
  final bool isSelected;

  const CropSelectionIndicator({
    super.key,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.freshGreen : Colors.white.withOpacity(0.85),
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? Colors.white : AppColors.borderGreen,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? AppColors.freshGreen.withOpacity(0.4)
                : Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: isSelected
            ? const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 16,
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
