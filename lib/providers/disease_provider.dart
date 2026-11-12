import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/datasources/ai_crop_catalog.dart';
import '../data/models/disease_model.dart';
import '../data/models/recommendation_model.dart';

final diseasesByCropProvider =
    FutureProvider.family<List<DiseaseModel>, int>((ref, cropId) async {
  try {
    final client = Supabase.instance.client;
    final response = await client
        .from('disease_catalog')
        .select()
        .eq('crop_id', cropId)
        .order('disease_name_en');

    final list =
        (response as List).map((row) => DiseaseModel.fromJson(row)).toList();
    if (list.isNotEmpty) return list;
    return AiCropCatalog.getVerifiedDiseasesForCrop(cropId);
  } catch (_) {
    return AiCropCatalog.getVerifiedDiseasesForCrop(cropId);
  }
});

final diseaseByIdProvider =
    FutureProvider.family<DiseaseModel?, int>((ref, diseaseId) async {
  try {
    final client = Supabase.instance.client;
    final response = await client
        .from('disease_catalog')
        .select()
        .eq('id', diseaseId)
        .maybeSingle();

    if (response != null) return DiseaseModel.fromJson(response);
    return AiCropCatalog.getDiseaseById(diseaseId);
  } catch (_) {
    return AiCropCatalog.getDiseaseById(diseaseId);
  }
});

final recommendationsByDiseaseProvider =
    FutureProvider.family<List<RecommendationModel>, int>((ref, diseaseId) async {
  try {
    final client = Supabase.instance.client;
    final response = await client
        .from('recommendations')
        .select()
        .eq('disease_id', diseaseId);

    return (response as List)
        .map((row) => RecommendationModel.fromJson(row))
        .toList();
  } catch (_) {
    return [];
  }
});

final careTipsByCropProvider =
    Provider.family<List<CropCareTip>, int>((ref, cropId) {
  return AiCropCatalog.getCareTips(cropId);
});

final cropProfileProvider =
    Provider.family<CropProfile?, int>((ref, cropId) {
  return AiCropCatalog.getCropProfile(cropId);
});

final allDiseasesProvider = FutureProvider<List<DiseaseModel>>((ref) async {
  try {
    final client = Supabase.instance.client;
    final response = await client
        .from('disease_catalog')
        .select()
        .order('crop_id')
        .order('disease_name_en');

    final list =
        (response as List).map((row) => DiseaseModel.fromJson(row)).toList();
    if (list.isNotEmpty) return list;
    return AiCropCatalog.verifiedDiseases;
  } catch (_) {
    return AiCropCatalog.verifiedDiseases;
  }
});
