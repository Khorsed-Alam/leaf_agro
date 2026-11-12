import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Central Supabase configuration and client provider.
class SupabaseConfig {
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://placeholder-project.supabase.co',
  );

  static const String publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: 'placeholder-anon-key',
  );

  /// Table names in PostgreSQL
  static const String tableProfiles = 'profiles';
  static const String tableCrops = 'crops';
  static const String tableDiseaseScans = 'disease_scans';
  static const String tableTreatmentHistory = 'treatment_history';
  static const String tableNotifications = 'notifications';
  static const String tableFeedback = 'feedback';
  static const String tableDiseaseCatalog = 'disease_catalog';
  static const String tableRecommendations = 'recommendations';

  /// Storage bucket identifiers
  static const String bucketProfileImages = 'profile-images';
  static const String bucketDiseaseImages = 'disease-images';
  static const String bucketUserAvatars = 'user-avatars';
  static const String bucketPlantImages = 'plant-images';

  /// Initialize Supabase
  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: url,
        // ignore: deprecated_member_use
        anonKey: publishableKey,
      );
      debugPrint('Supabase initialized successfully');
    } catch (e) {
      debugPrint('Supabase initialization fallback: $e');
    }
  }

  /// Get the active Supabase client instance
  static SupabaseClient get client => Supabase.instance.client;
}
