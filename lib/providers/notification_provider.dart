import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provides unread notification count for authenticated user from Supabase.
final unreadNotificationsCountProvider = FutureProvider<int>((ref) async {
  try {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) return 0;

    final response = await client
        .from('notifications')
        .select('id')
        .eq('user_id', user.id)
        .isFilter('read_at', null);

    return (response as List).length;
  } catch (_) {
    return 0;
  }
});

