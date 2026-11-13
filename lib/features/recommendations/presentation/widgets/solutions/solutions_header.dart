import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';

/// Screen 20 – Solutions Header
/// Clean, accessible AppBar with title, subtitle, back navigation, and branding.
class SolutionsHeader extends StatelessWidget implements PreferredSizeWidget {
  final bool isBn;
  final VoidCallback? onBack;

  const SolutionsHeader({
    super.key,
    required this.isBn,
    this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(74);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      surfaceTintColor: Colors.transparent,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onBack ??
                  () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/home');
                    }
                  },
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.background,
                  border: Border.all(color: AppColors.borderGreen),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.forestGreen,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.science_outlined,
                color: AppColors.forestGreen,
                size: 19,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  isBn
                      ? 'পণ্য ও সমাধান সংক্রান্ত তথ্য'
                      : 'Product & Solution Information',
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.forestGreen,
                    letterSpacing: -0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            isBn
                ? 'নিরাপদে উদ্ভিদের রোগ ব্যবস্থাপনার সম্ভাব্য উপায়গুলো জানুন'
                : 'Explore possible approaches to managing plant diseases safely.',
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w400,
              color: AppColors.secondaryText,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.softNaturalGreen,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderGreen),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.spa_rounded,
                  color: AppColors.freshGreen,
                  size: 14,
                ),
                SizedBox(width: 4),
                Text(
                  'LeafAgro',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.forestGreen,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: AppColors.borderGreen.withValues(alpha: 0.5),
          height: 1,
        ),
      ),
    );
  }
}
