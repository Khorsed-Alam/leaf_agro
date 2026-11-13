import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Screen 24 – Profile Action Tile
/// Reusable interactive list row for navigation items (Edit Profile, Settings, Language).
class ProfileActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color? iconBgColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const ProfileActionTile({
    super.key,
    required this.icon,
    this.iconColor = AppColors.forestGreen,
    this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = iconBgColor ?? AppColors.softNaturalGreen;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.borderGreen.withValues(alpha: 0.8),
                    width: 0.8,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 14),

              // Title and Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),

              // Trailing widget or right arrow
              trailing ??
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.secondaryText,
                    size: 22,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

