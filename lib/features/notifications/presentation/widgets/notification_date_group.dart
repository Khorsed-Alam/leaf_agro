import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/notification_model.dart';
import 'notification_card.dart';

/// Screen 27 – Notification Date Group
/// Groups notifications into clean chronological sections: Today, Yesterday, and Earlier.
class NotificationDateGroup extends StatelessWidget {
  final String groupTitle;
  final List<NotificationModel> notifications;
  final bool isBn;
  final ValueChanged<NotificationModel> onNotificationTap;

  const NotificationDateGroup({
    super.key,
    required this.groupTitle,
    required this.notifications,
    required this.isBn,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
          child: Text(
            groupTitle,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.forestGreen,
              letterSpacing: 0.2,
            ),
          ),
        ),
        ...notifications.map(
          (notif) => NotificationCard(
            notification: notif,
            isBn: isBn,
            onTap: () => onNotificationTap(notif),
          ),
        ),
      ],
    );
  }
}

