import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Screen 25 – Settings List Tile
/// Material Design 3 list tile for settings rows with a rounded icon container,
/// title, subtitle, trailing chevron/widget, and optional bottom divider.
class SettingsListTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color? iconBgColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;
  final bool showDivider;

  const SettingsListTile({
    super.key,
    required this.icon,
    this.iconColor = AppColors.forestGreen,
    this.iconBgColor,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = iconBgColor ?? AppColors.softNaturalGreen;

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 13.0),
              child: Row(
                children: [
                  // Icon Container
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: AppColors.borderGreen.withValues(alpha: 0.8),
                        width: 0.8,
                      ),
                    ),
                    child: Icon(
                      icon,
                      size: 20,
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
                        if (subtitle != null && subtitle!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Trailing widget or default chevron
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
        ),
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 0.8,
            indent: 68,
            endIndent: 16,
            color: Color(0xFFF0F4EF),
          ),
      ],
    );
  }
}
