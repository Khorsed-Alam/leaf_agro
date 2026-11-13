import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final SupabaseClient? _clientOverride;

  NotificationRepository([SupabaseClient? client])
      : _clientOverride = client;

  SupabaseClient get _client => _clientOverride ?? SupabaseConfig.client;

  /// Fetch notifications for authenticated user, sorted newest first
  Future<List<NotificationModel>> getNotifications(String userId) async {
    try {
      final response = await _client
          .from(SupabaseConfig.tableNotifications)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final list = (response as List)
          .map((row) => NotificationModel.fromJson(row))
          .toList();
      return list;
    } catch (_) {
      return [];
    }
  }

  /// Mark an individual notification as read
  Future<void> markAsRead(String notificationId) async {
    final now = DateTime.now().toIso8601String();
    await _client
        .from(SupabaseConfig.tableNotifications)
        .update({'read_at': now})
        .eq('id', notificationId);
  }

  /// Mark all unread notifications for a user as read
  Future<void> markAllAsRead(String userId) async {
    final now = DateTime.now().toIso8601String();
    await _client
        .from(SupabaseConfig.tableNotifications)
        .update({'read_at': now})
        .eq('user_id', userId)
        .isFilter('read_at', null);
  }
}

