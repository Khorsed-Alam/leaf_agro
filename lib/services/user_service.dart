import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';
import '../data/models/user_profile_model.dart';

class UserService {
  final SupabaseClient _client;

  UserService([SupabaseClient? client])
      : _client = client ?? SupabaseConfig.client;

  /// Fetch user profile by ID
  Future<UserProfileModel?> getProfile(String userId) async {
    try {
      final response = await _client
          .from(SupabaseConfig.tableProfiles)
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;
      return UserProfileModel.fromJson(response);
    } catch (e) {
      debugPrint('Error getting profile: $e');
      return null;
    }
  }

  /// Upsert profile
  Future<UserProfileModel> createProfile(UserProfileModel profile) async {
    final data = profile.toJson();
    final response = await _client
        .from(SupabaseConfig.tableProfiles)
        .upsert(data)
        .select()
        .single();

    return UserProfileModel.fromJson(response);
  }

  /// Update an existing user profile
  Future<UserProfileModel> updateProfile(UserProfileModel profile) async {
    final data = profile.toJson();
    // Disallow altering security-sensitive role directly from client
    data.remove('role');
    data['updated_at'] = DateTime.now().toIso8601String();

    final response = await _client
        .from(SupabaseConfig.tableProfiles)
        .update(data)
        .eq('id', profile.id)
        .select()
        .single();

    return UserProfileModel.fromJson(response);
  }

  /// Upload avatar image bytes to storage
  Future<String> uploadProfileImage({
    required String userId,
    required Uint8List bytes,
    String fileExtension = 'jpg',
  }) async {
    final fileName = '$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
    await _client.storage
        .from(SupabaseConfig.bucketProfileImages)
        .uploadBinary(
          fileName,
          bytes,
          fileOptions: FileOptions(
            contentType: 'image/$fileExtension',
            upsert: true,
          ),
        );

    final publicUrl = _client.storage
        .from(SupabaseConfig.bucketProfileImages)
        .getPublicUrl(fileName);

    // Update profile with avatar url
    await _client
        .from(SupabaseConfig.tableProfiles)
        .update({'avatar_url': publicUrl})
        .eq('id', userId);

    return publicUrl;
  }

  /// Request account deletion via backend
  Future<void> deleteAccount(String userId) async {
    // Note: auth.admin.deleteUser is restricted to service_role / Edge Functions.
    // Client initiates deletion record or calls edge function
    await _client
        .from(SupabaseConfig.tableProfiles)
        .delete()
        .eq('id', userId);
    await _client.auth.signOut();
  }
}

