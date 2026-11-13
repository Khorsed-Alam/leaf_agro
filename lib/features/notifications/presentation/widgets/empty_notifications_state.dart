import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Screen 27 – Empty Notifications State
/// Friendly empty state illustration and message for zero notifications or empty filter results.
class EmptyNotificationsState extends StatelessWidget {
  final String activeFilter;
  final bool isBn;

  const EmptyNotificationsState({
    super.key,
    required this.activeFilter,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    String heading;
    String description;
    IconData icon;

    if (activeFilter == 'unread') {
      heading = isBn ? 'কোনো অপঠিত নোটিফিকেশন নেই' : 'No Unread Notifications';
      description = isBn
          ? 'আপনার সকল নোটিফিকেশন পড়া সম্পন্ন হয়েছে।'
          : 'You have read all your notifications.';
      icon = Icons.mark_chat_read_outlined;
    } else if (activeFilter != 'all') {
      heading = isBn ? 'কোনো নোটিফিকেশন পাওয়া যায়নি' : 'No Notifications Found';
      description = isBn
          ? 'এই ক্যাটাগরিতে এই মুহূর্তে কোনো নোটিফিকেশন নেই।'
          : 'There are no notifications in this category right now.';
      icon = Icons.filter_list_off_rounded;
    } else {
      heading = isBn ? 'সব নোটিফিকেশন দেখা হয়েছে!' : "You're All Caught Up!";
      description = isBn
          ? 'এই মুহূর্তে কোনো নতুন নোটিফিকেশন নেই।'
          : 'There are no notifications to show right now.';
      icon = Icons.notifications_none_rounded;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer.withValues(alpha: 0.5),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderGreen, width: 1.2),
              ),
              child: Icon(
                icon,
                size: 36,
                color: AppColors.forestGreen,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              heading,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryText,
                letterSpacing: -0.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.secondaryText,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

