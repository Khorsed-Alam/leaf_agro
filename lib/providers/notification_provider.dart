import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/notification_model.dart';
import '../data/repositories/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  try {
    return NotificationRepository(Supabase.instance.client);
  } catch (_) {
    return NotificationRepository();
  }
});

class NotificationsNotifier extends AsyncNotifier<List<NotificationModel>> {
  @override
  Future<List<NotificationModel>> build() async {
    return loadNotifications();
  }

  Future<List<NotificationModel>> loadNotifications() async {
    final repo = ref.read(notificationRepositoryProvider);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return [];
      return await repo.getNotifications(user.id);
    } catch (_) {
      return [];
    }
  }

  Future<void> markAsRead(String id) async {
    final repo = ref.read(notificationRepositoryProvider);
    try {
      await repo.markAsRead(id);
    } catch (_) {}

    // Update in-memory state immediately so UI updates reactively
    final current = state.value;
    if (current != null) {
      final now = DateTime.now();
      state = AsyncValue.data(
        current.map((n) => n.id == id ? n.copyWith(readAt: now) : n).toList(),
      );
    }
  }

  Future<void> markAllAsRead() async {
    final repo = ref.read(notificationRepositoryProvider);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await repo.markAllAsRead(user.id);
      }
    } catch (_) {}

    final current = state.value;
    if (current != null) {
      final now = DateTime.now();
      state = AsyncValue.data(
        current.map((n) => n.isRead ? n : n.copyWith(readAt: now)).toList(),
      );
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(loadNotifications);
  }
}

final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<NotificationModel>>(
  NotificationsNotifier.new,
);

/// Dynamic unread notifications count, synchronized with notificationsProvider
final unreadNotificationsCountProvider = FutureProvider<int>((ref) async {
  final notifsAsync = ref.watch(notificationsProvider);
  return notifsAsync.value?.where((n) => !n.isRead).length ?? 0;
});
