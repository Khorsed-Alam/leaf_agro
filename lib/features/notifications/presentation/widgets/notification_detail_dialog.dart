import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/notification_model.dart';
import 'notification_icon.dart';

/// Screen 27 – Notification Detail Dialog
/// Displays the full details of a notification when no direct destination route is associated.
class NotificationDetailDialog extends StatelessWidget {
  final NotificationModel notification;
  final bool isBn;

  const NotificationDetailDialog({
    super.key,
    required this.notification,
    required this.isBn,
  });

  static Future<void> show(
    BuildContext context, {
    required NotificationModel notification,
    required bool isBn,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => NotificationDetailDialog(
        notification: notification,
        isBn: isBn,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = isBn ? notification.titleBn : notification.titleEn;
    final message = isBn
        ? (notification.messageBn ?? notification.messageEn ?? '')
        : (notification.messageEn ?? notification.messageBn ?? '');

    final dateStr = DateFormat('dd MMMM yyyy, hh:mm a').format(notification.createdAt);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      backgroundColor: AppColors.surfaceContainerLowest,
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NotificationIcon(type: notification.type),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateStr,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Text(
          message.isNotEmpty
              ? message
              : (isBn ? 'কোনো বিস্তারিত বিবরণ নেই।' : 'No additional details provided.'),
          style: const TextStyle(
            fontSize: 13.5,
            height: 1.45,
            color: AppColors.primaryText,
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.forestGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Text(
            isBn ? 'ঠিক আছে' : 'OK',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

