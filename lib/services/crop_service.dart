import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';
import '../data/models/farmer_crop_model.dart';

class CropService {
  final SupabaseClient _client;

  CropService([SupabaseClient? client])
      : _client = client ?? SupabaseConfig.client;

  /// Retrieve all field crops registered by a farmer
  Future<List<FarmerCropModel>> getUserCrops(String userId) async {
    final response = await _client
        .from(SupabaseConfig.tableCrops)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((row) => FarmerCropModel.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  /// Add a new crop to the farmer's field
  Future<FarmerCropModel> addCrop(FarmerCropModel crop) async {
    final data = crop.toJson();
    final response = await _client
        .from(SupabaseConfig.tableCrops)
        .insert(data)
        .select()
        .single();

    return FarmerCropModel.fromJson(response);
  }

  /// Update an existing crop record
  Future<FarmerCropModel> updateCrop(FarmerCropModel crop) async {
    final data = crop.toJson();
    final response = await _client
        .from(SupabaseConfig.tableCrops)
        .update(data)
        .eq('id', crop.id)
        .eq('user_id', crop.userId)
        .select()
        .single();

    return FarmerCropModel.fromJson(response);
  }

  /// Delete a crop record
  Future<void> deleteCrop(String cropId, String userId) async {
    await _client
        .from(SupabaseConfig.tableCrops)
        .delete()
        .eq('id', cropId)
        .eq('user_id', userId);
  }
}

