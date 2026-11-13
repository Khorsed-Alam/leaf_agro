import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Screen 27 – Notification Leading Category Icon
/// Displays an icon in a softly tinted container representing genuine application categories.
class NotificationIcon extends StatelessWidget {
  final String? type;

  const NotificationIcon({
    super.key,
    this.type,
  });

  @override
  Widget build(BuildContext context) {
    final cleanType = type?.toLowerCase().trim() ?? '';

    IconData icon;
    Color iconColor;
    Color bgColor;

    if (cleanType == 'activity' || cleanType == 'scan') {
      icon = Icons.eco_rounded;
      iconColor = AppColors.forestGreen;
      bgColor = AppColors.secondaryContainer.withValues(alpha: 0.6);
    } else if (cleanType == 'reminder' || cleanType == 'followup') {
      icon = Icons.calendar_today_rounded;
      iconColor = const Color(0xFFB45309);
      bgColor = const Color(0xFFFEF3C7);
    } else if (cleanType == 'update' || cleanType == 'disease') {
      icon = Icons.menu_book_rounded;
      iconColor = const Color(0xFF1D4ED8);
      bgColor = const Color(0xFFEFF6FF);
    } else {
      icon = Icons.notifications_none_rounded;
      iconColor = AppColors.forestGreen;
      bgColor = AppColors.softNaturalGreen;
    }

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.2),
          width: 0.8,
        ),
      ),
      child: Icon(
        icon,
        size: 20,
        color: iconColor,
      ),
    );
  }
}

