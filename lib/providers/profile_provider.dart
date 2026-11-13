import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/user_profile_model.dart';
import '../services/user_service.dart';
import 'auth_provider.dart';
import 'history_provider.dart';

/// Provider for the UserService instance
final userServiceProvider = Provider<UserService>((ref) {
  try {
    return UserService(Supabase.instance.client);
  } catch (_) {
    return UserService();
  }
});

/// Fetches the authenticated user's profile from Supabase with fallback to auth state
final profileProvider = FutureProvider<UserProfileModel?>((ref) async {
  try {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user != null) {
      final response = await client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response != null) {
        return UserProfileModel.fromJson(response);
      }
    }
  } catch (_) {}

  return ref.watch(currentUserProvider);
});

/// Calculates the authenticated user's total saved disease detection scans
final userDetectionCountProvider = FutureProvider<int>((ref) async {
  try {
    final history = await ref.watch(historyProvider.future);
    return history.length;
  } catch (_) {
    return 0;
  }
});
