import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';

class StorageService {
  final SupabaseClient? _clientOverride;

  StorageService([SupabaseClient? client]) : _clientOverride = client;

  SupabaseClient get _client => _clientOverride ?? SupabaseConfig.client;

  /// Upload captured or selected plant leaf image for AI diagnosis
  /// Stored securely under authenticated user directory: <bucket>/<user_id>/<file>
  Future<String> uploadDiseaseImage({
    required String userId,
    required Uint8List bytes,
    String fileExtension = 'jpg',
  }) async {
    final fileName =
        '$userId/scan_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

    await _client.storage.from(SupabaseConfig.bucketDiseaseImages).uploadBinary(
          fileName,
          bytes,
          fileOptions: FileOptions(
            contentType: 'image/$fileExtension',
            upsert: false,
          ),
        );

    return fileName;
  }

  /// Upload optional feedback attachment
  Future<String> uploadFeedbackAttachment({
    required String userId,
    required Uint8List bytes,
    String fileExtension = 'jpg',
  }) async {
    final fileName =
        '$userId/feedback_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

    await _client.storage.from(SupabaseConfig.bucketDiseaseImages).uploadBinary(
          fileName,
          bytes,
          fileOptions: FileOptions(
            contentType: 'image/$fileExtension',
            upsert: false,
          ),
        );

    return fileName;
  }

  /// Upload user profile avatar
  Future<String> uploadProfileImage({
    required String userId,
    required Uint8List bytes,
    String fileExtension = 'jpg',
  }) async {
    final fileName =
        '$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

    await _client.storage.from(SupabaseConfig.bucketProfileImages).uploadBinary(
          fileName,
          bytes,
          fileOptions: FileOptions(
            contentType: 'image/$fileExtension',
            upsert: true,
          ),
        );

    return fileName;
  }

  /// Generate a secure signed URL for temporary access to a private bucket image
  Future<String> getSignedUrl({
    required String bucket,
    required String path,
    int expiresInSeconds = 3600,
  }) async {
    return await _client.storage
        .from(bucket)
        .createSignedUrl(path, expiresInSeconds);
  }

  /// Delete an image from storage
  Future<void> deleteImage({
    required String bucket,
    required String path,
  }) async {
    await _client.storage.from(bucket).remove([path]);
  }
}
