import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';

/// Screen 17 – Disease Details Header
/// Provides back navigation, page heading, and optional bookmark/share actions.
class DiseaseDetailHeader extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final bool isBn;
  final VoidCallback? onBack;

  const DiseaseDetailHeader({
    super.key,
    required this.title,
    required this.isBn,
    this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: AppColors.primaryText,
          size: 24,
        ),
        tooltip: isBn ? 'ফিরে যান' : 'Back',
        onPressed: () {
          if (onBack != null) {
            onBack!();
          } else if (context.canPop()) {
            context.pop();
          } else {
            context.go('/diseases');
          }
        },
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.primaryText,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.softNaturalGreen,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.freshGreen.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.spa_rounded,
                      size: 14,
                      color: AppColors.forestGreen,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'AgriCare AI',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.forestGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
