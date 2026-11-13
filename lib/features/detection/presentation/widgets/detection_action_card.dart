import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Interactive Action Card for Camera or Gallery capture on Screen 11
class DetectionActionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isPrimary;
  final bool isLoading;
  final VoidCallback? onTap;
  final bool isBn;

  const DetectionActionCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.isPrimary = false,
    this.isLoading = false,
    required this.onTap,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null && !isLoading;

    final cardBorder = isPrimary
        ? Border.all(color: AppColors.freshGreen, width: 1.5)
        : Border.all(
            color: AppColors.freshGreen.withValues(alpha: 0.35),
            width: 1.2,
          );

    final iconBgColor =
        isPrimary ? AppColors.forestGreen : const Color(0xFFDCFCE7);

    final iconColor = isPrimary ? Colors.white : AppColors.forestGreen;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: cardBorder,
        boxShadow: [
          BoxShadow(
            color: isPrimary
                ? AppColors.forestGreen.withValues(alpha: 0.08)
                : AppColors.forestGreen.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: enabled ? onTap : null,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            child: Row(
              children: [
                // Action Icon in Glowing Rounded Circle
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                    boxShadow: isPrimary
                        ? [
                            BoxShadow(
                              color:
                                  AppColors.freshGreen.withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Text Information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryText,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryText,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Trailing Action Indicator or Spinner
                if (isLoading)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.forestGreen,
                    ),
                  )
                else
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.softNaturalGreen,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.freshGreen.withValues(alpha: 0.25),
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: AppColors.forestGreen,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
