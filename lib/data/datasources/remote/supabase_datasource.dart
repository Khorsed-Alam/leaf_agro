import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/api_constants.dart';
import '../../models/crop_model.dart';
import '../../models/disease_model.dart';
import '../../models/recommendation_model.dart';
import '../../models/prediction_history_model.dart';
import '../../models/user_profile_model.dart';

class SupabaseDataSource {
  final SupabaseClient _client;
  SupabaseDataSource(this._client);

  // Authentication
  User? get currentUser => _client.auth.currentUser;

  Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUp(String email, String password, {String? fullName}) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: fullName != null ? {'full_name': fullName} : null,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Profile
  Future<UserProfileModel?> getProfile(String userId) async {
    final response = await _client
        .from(ApiConstants.tableProfiles)
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;
    return UserProfileModel.fromJson(response);
  }

  // Crops & Catalog
  Future<List<CropModel>> getCrops() async {
    final response = await _client
        .from(ApiConstants.tableCrops)
        .select()
        .eq('is_active', true)
        .order('name_en');

    return (response as List).map((row) => CropModel.fromJson(row)).toList();
  }

  Future<List<DiseaseModel>> getDiseasesForCrop(int cropId) async {
    final response = await _client
        .from(ApiConstants.tableDiseaseCatalog)
        .select()
        .eq('crop_id', cropId);

    return (response as List).map((row) => DiseaseModel.fromJson(row)).toList();
  }

  Future<DiseaseModel?> getDiseaseByClassName(String className) async {
    final response = await _client
        .from(ApiConstants.tableDiseaseCatalog)
        .select()
        .eq('class_name', className)
        .maybeSingle();

    if (response == null) return null;
    return DiseaseModel.fromJson(response);
  }

  Future<List<RecommendationModel>> getRecommendations(int diseaseId) async {
    final response = await _client
        .from(ApiConstants.tableRecommendations)
        .select()
        .eq('disease_id', diseaseId)
        .eq('is_verified', true);

    return (response as List).map((row) => RecommendationModel.fromJson(row)).toList();
  }

  // History & Storage
  Future<void> syncPredictionHistory(PredictionHistoryModel model) async {
    await _client.from(ApiConstants.tablePredictionHistory).insert(model.toJson());
  }

  Future<List<PredictionHistoryModel>> getUserHistory(String userId) async {
    final response = await _client
        .from(ApiConstants.tablePredictionHistory)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((row) => PredictionHistoryModel.fromJson(row)).toList();
  }

  Future<String?> uploadLeafImage(String userId, String scanId, File imageFile) async {
    final path = '$userId/$scanId.jpg';
    await _client.storage.from(ApiConstants.bucketPlantImages).upload(
          path,
          imageFile,
          fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
        );
    return _client.storage.from(ApiConstants.bucketPlantImages).getPublicUrl(path);
  }
}

