import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/notification_model.dart';
import '../../../providers/notification_provider.dart';
import '../../../providers/settings_provider.dart';
import 'widgets/empty_notifications_state.dart';
import 'widgets/notification_category_filter.dart';
import 'widgets/notification_date_group.dart';
import 'widgets/notification_detail_dialog.dart';

/// Screen 27 – Notifications Screen | AgriCare AI (LeafAgro)
/// A farmer-friendly Notification Center showing genuine detection activity,
/// plant care reminders, and crop pathology updates with unread filtering and Mark All as Read.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  String _activeFilter = 'all';
  bool _isMarkingAll = false;

  void _handleNotificationTap(NotificationModel notification, bool isBn) {
    // 1. Mark as read immediately
    if (!notification.isRead) {
      ref.read(notificationsProvider.notifier).markAsRead(notification.id);
    }

    // 2. Navigate if destination is present
    final route = notification.targetRoute;
    final relatedId = notification.relatedId;
    final type = notification.type?.toLowerCase();

    if (route != null && route.isNotEmpty) {
      try {
        context.push(route);
        return;
      } catch (_) {}
    }

    if (type == 'activity' && relatedId != null && relatedId.isNotEmpty) {
      try {
        context.push('/history/$relatedId');
        return;
      } catch (_) {}
    }

    if (type == 'reminder' && relatedId != null && relatedId.isNotEmpty) {
      try {
        context.push('/recovery?scanId=$relatedId');
        return;
      } catch (_) {}
    }

    if (type == 'update' && relatedId != null && relatedId.isNotEmpty) {
      try {
        context.push('/recommendations/$relatedId');
        return;
      } catch (_) {}
    }

    // 3. If no destination, display full detail dialog
    NotificationDetailDialog.show(
      context,
      notification: notification,
      isBn: isBn,
    );
  }

  Future<void> _handleMarkAllAsRead(bool isBn) async {
    if (_isMarkingAll) return;

    setState(() => _isMarkingAll = true);

    try {
      await ref.read(notificationsProvider.notifier).markAllAsRead();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isBn
                ? 'সকল নোটিফিকেশন পড়া হিসেবে চিহ্নিত করা হয়েছে।'
                : 'All notifications marked as read.',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isBn
                ? 'নোটিফিকেশন আপডেট করতে সমস্যা হয়েছে।'
                : 'Failed to update notifications.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isMarkingAll = false);
      }
    }
  }

  List<NotificationModel> _filterNotifications(
    List<NotificationModel> allNotifications,
  ) {
    switch (_activeFilter) {
      case 'unread':
        return allNotifications.where((n) => !n.isRead).toList();
      case 'activity':
        return allNotifications
            .where((n) => n.type?.toLowerCase() == 'activity' || n.type?.toLowerCase() == 'scan')
            .toList();
      case 'reminder':
        return allNotifications
            .where((n) => n.type?.toLowerCase() == 'reminder' || n.type?.toLowerCase() == 'followup')
            .toList();
      case 'update':
        return allNotifications
            .where((n) => n.type?.toLowerCase() == 'update' || n.type?.toLowerCase() == 'disease')
            .toList();
      default:
        return allNotifications;
    }
  }

  Map<String, List<NotificationModel>> _groupNotificationsByDate(
    List<NotificationModel> list,
    bool isBn,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final todayList = <NotificationModel>[];
    final yesterdayList = <NotificationModel>[];
    final earlierList = <NotificationModel>[];

    for (final notif in list) {
      final notifDate = DateTime(
        notif.createdAt.year,
        notif.createdAt.month,
        notif.createdAt.day,
      );

      if (notifDate == today) {
        todayList.add(notif);
      } else if (notifDate == yesterday) {
        yesterdayList.add(notif);
      } else {
        earlierList.add(notif);
      }
    }

    final groups = <String, List<NotificationModel>>{};
    if (todayList.isNotEmpty) {
      groups[isBn ? 'আজ' : 'Today'] = todayList;
    }
    if (yesterdayList.isNotEmpty) {
      groups[isBn ? 'গতকাল' : 'Yesterday'] = yesterdayList;
    }
    if (earlierList.isNotEmpty) {
      groups[isBn ? 'পূর্ববর্তী' : 'Earlier'] = earlierList;
    }

    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final isBn = settings.language == 'bn';

    final notificationsAsync = ref.watch(notificationsProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primaryText),
          tooltip: isBn ? 'ফিরে যান' : 'Back',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Text(
          isBn ? 'বিজ্ঞপ্তি ও সতর্কতা' : 'Notifications',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.forestGreen,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: (unreadCount > 0 && !_isMarkingAll)
                ? () => _handleMarkAllAsRead(isBn)
                : null,
            icon: _isMarkingAll
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.forestGreen,
                    ),
                  )
                : const Icon(Icons.done_all_rounded, size: 18),
            label: Text(
              isBn ? 'সব পড়া হয়েছে' : 'Mark All as Read',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: unreadCount > 0
                    ? AppColors.forestGreen
                    : AppColors.secondaryText.withValues(alpha: 0.5),
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Category Filter Chips
            NotificationCategoryFilter(
              activeFilter: _activeFilter,
              unreadCount: unreadCount,
              isBn: isBn,
              onFilterChanged: (filter) {
                setState(() => _activeFilter = filter);
              },
            ),

            // Main Notification Content Area
            Expanded(
              child: notificationsAsync.when(
                data: (allNotifications) {
                  final filteredList = _filterNotifications(allNotifications);

                  if (filteredList.isEmpty) {
                    return RefreshIndicator(
                      color: AppColors.forestGreen,
                      onRefresh: () async {
                        ref.read(notificationsProvider.notifier).refresh();
                      },
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          EmptyNotificationsState(
                            activeFilter: _activeFilter,
                            isBn: isBn,
                          ),
                        ],
                      ),
                    );
                  }

                  final groupedMap = _groupNotificationsByDate(filteredList, isBn);

                  return RefreshIndicator(
                    color: AppColors.forestGreen,
                    onRefresh: () async {
                      ref.read(notificationsProvider.notifier).refresh();
                    },
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.only(bottom: 24.0, top: 4.0),
                      itemCount: groupedMap.length,
                      itemBuilder: (context, index) {
                        final entry = groupedMap.entries.elementAt(index);
                        return NotificationDateGroup(
                          groupTitle: entry.key,
                          notifications: entry.value,
                          isBn: isBn,
                          onNotificationTap: (notif) => _handleNotificationTap(notif, isBn),
                        );
                      },
                    ),
                  );
                },
                loading: () => _buildLoadingSkeleton(),
                error: (error, stack) => _buildErrorView(isBn),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: 5,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderGreen.withValues(alpha: 0.6)),
        ),
      ),
    );
  }

  Widget _buildErrorView(bool isBn) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 12),
            Text(
              isBn
                  ? 'বিজ্ঞপ্তি লোড করতে সমস্যা হয়েছে'
                  : 'Failed to load notifications',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isBn
                  ? 'ইন্টারনেট সংযোগ পরীক্ষা করে পুনরায় চেষ্টা করুন।'
                  : 'Please check your connection and try again.',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(notificationsProvider.notifier).refresh();
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(isBn ? 'পুনরায় চেষ্টা করুন' : 'Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.forestGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
