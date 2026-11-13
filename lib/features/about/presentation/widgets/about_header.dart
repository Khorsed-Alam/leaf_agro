import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

/// Screen 30 – About Header
class AboutHeader extends StatelessWidget {
  final bool isBn;

  const AboutHeader({
    super.key,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/settings');
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderGreen, width: 1),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.forestGreen,
                size: 22,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isBn ? 'এগ্রিকেয়ার এআই পরিচিতি' : 'About AgriCare AI',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.forestGreen,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                isBn
                    ? 'আমাদের প্রকল্প ও প্রযুক্তি সম্পর্কে জানুন'
                    : 'Learn more about our project and technology.',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondaryText,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
