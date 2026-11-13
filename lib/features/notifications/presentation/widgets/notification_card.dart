import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/notification_model.dart';
import 'notification_icon.dart';
import 'unread_indicator.dart';

/// Screen 27 – Notification Card
/// Renders an individual notification with leading icon, title, message body,
/// formatted local timestamp, unread dot indicator, and interactive navigation cues.
class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final bool isBn;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.isBn,
    required this.onTap,
  });

  String _formatTimestamp(DateTime dt, bool isBn) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final itemDate = DateTime(dt.year, dt.month, dt.day);

    final timeStr = DateFormat('hh:mm a').format(dt);

    if (!isBn) {
      if (itemDate == today) {
        return 'Today · $timeStr';
      } else if (itemDate == yesterday) {
        return 'Yesterday · $timeStr';
      } else {
        final dateStr = DateFormat('d MMM yyyy').format(dt);
        return '$dateStr · $timeStr';
      }
    }

    // Bengali Date & Numerals mapping
    const enToBnDigits = {
      '0': '০',
      '1': '১',
      '2': '২',
      '3': '৩',
      '4': '৪',
      '5': '৫',
      '6': '৬',
      '7': '৭',
      '8': '৮',
      '9': '৯',
    };
    final bnTime = timeStr.split('').map((c) => enToBnDigits[c] ?? c).join('');

    if (itemDate == today) {
      return 'আজ · $bnTime';
    } else if (itemDate == yesterday) {
      return 'গতকাল · $bnTime';
    } else {
      const bnMonths = {
        1: 'জানু',
        2: 'ফেব্রু',
        3: 'মার্চ',
        4: 'এপ্রিল',
        5: 'মে',
        6: 'জুন',
        7: 'জুলাই',
        8: 'আগস্ট',
        9: 'সেপ্টে',
        10: 'অক্টো',
        11: 'নভে',
        12: 'ডিসে',
      };
      final bnDay = dt.day.toString().split('').map((c) => enToBnDigits[c] ?? c).join('');
      final bnYear = dt.year.toString().split('').map((c) => enToBnDigits[c] ?? c).join('');
      final bnMonth = bnMonths[dt.month] ?? '${dt.month}';
      return '$bnDay $bnMonth $bnYear · $bnTime';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;
    final title = isBn ? notification.titleBn : notification.titleEn;
    final message = isBn
        ? (notification.messageBn ?? notification.messageEn ?? '')
        : (notification.messageEn ?? notification.messageBn ?? '');

    final hasDestination = (notification.targetRoute != null &&
            notification.targetRoute!.isNotEmpty) ||
        (notification.relatedId != null &&
            notification.relatedId!.isNotEmpty);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: isUnread
            ? AppColors.surfaceContainerLowest
            : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isUnread ? AppColors.forestGreen.withValues(alpha: 0.35) : AppColors.borderGreen,
          width: isUnread ? 1.2 : 0.9,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isUnread ? 0.04 : 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Leading Category Icon
                NotificationIcon(type: notification.type),
                const SizedBox(width: 12),

                // Main Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600,
                                color: AppColors.primaryText,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          if (isUnread) ...[
                            const SizedBox(width: 6),
                            UnreadIndicator(isUnread: isUnread),
                          ],
                        ],
                      ),
                      if (message.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          message,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.secondaryText,
                            height: 1.35,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 6),
                      Text(
                        _formatTimestamp(notification.createdAt, isBn),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.secondaryText.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),

                // Trailing Navigation Chevron if applicable
                if (hasDestination) ...[
                  const SizedBox(width: 6),
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

