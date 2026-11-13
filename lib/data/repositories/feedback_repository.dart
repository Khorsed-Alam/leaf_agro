import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/supabase_config.dart';
import '../../services/storage_service.dart';
import '../models/feedback_model.dart';

class FeedbackRepository {
  final SupabaseClient? _clientOverride;
  final StorageService? _storageServiceOverride;

  FeedbackRepository({
    SupabaseClient? client,
    StorageService? storageService,
  })  : _clientOverride = client,
        _storageServiceOverride = storageService;

  SupabaseClient get _client => _clientOverride ?? SupabaseConfig.client;
  StorageService get _storageService =>
      _storageServiceOverride ?? StorageService(_clientOverride);

  /// Submits farmer feedback to Supabase 'feedback' table with optional secure attachment.
  /// If storage upload succeeds but table insert fails, orphaned attachment is cleaned up.
  Future<FeedbackModel> submitFeedback({
    required String userId,
    required int rating,
    required String category,
    required String message,
    Uint8List? attachmentBytes,
    String fileExtension = 'jpg',
  }) async {
    String? uploadedPath;

    try {
      // 1. Upload attachment if provided
      if (attachmentBytes != null && attachmentBytes.isNotEmpty) {
        uploadedPath = await _storageService.uploadFeedbackAttachment(
          userId: userId,
          bytes: attachmentBytes,
          fileExtension: fileExtension,
        );
      }

      // 2. Prepare message containing attachment reference if uploaded
      final finalMessage = (uploadedPath != null)
          ? '$message\n\n[Attachment: $uploadedPath]'
          : message;

      // 3. Insert record into public.feedback table
      final payload = {
        'user_id': userId,
        'rating': rating,
        'category': category,
        'message': finalMessage,
      };

      final response = await _client
          .from(SupabaseConfig.tableFeedback)
          .insert(payload)
          .select()
          .single();

      final result = FeedbackModel.fromJson(response);
      return result.copyWith(attachmentPath: uploadedPath);
    } catch (e) {
      // Safe cleanup: remove uploaded file if database insert failed
      if (uploadedPath != null) {
        try {
          await _storageService.deleteImage(
            bucket: SupabaseConfig.bucketDiseaseImages,
            path: uploadedPath,
          );
        } catch (_) {}
      }
      rethrow;
    }
  }

  /// Fetches feedback submitted by the authenticated user
  Future<List<FeedbackModel>> getUserFeedback(String userId) async {
    try {
      final response = await _client
          .from(SupabaseConfig.tableFeedback)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final list =
          (response as List).map((row) => FeedbackModel.fromJson(row)).toList();
      return list;
    } catch (_) {
      return [];
    }
  }
}
