import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/disease_model.dart';
import '../data/models/recommendation_model.dart';

final diseasesByCropProvider =
    FutureProvider.family<List<DiseaseModel>, int>((ref, cropId) async {
  final client = Supabase.instance.client;
  final response = await client
      .from('disease_catalog')
      .select()
      .eq('crop_id', cropId)
      .order('disease_name_en');

  return (response as List).map((row) => DiseaseModel.fromJson(row)).toList();
});

final diseaseByIdProvider =
    FutureProvider.family<DiseaseModel?, int>((ref, diseaseId) async {
  final client = Supabase.instance.client;
  final response = await client
      .from('disease_catalog')
      .select()
      .eq('id', diseaseId)
      .maybeSingle();

  if (response == null) return null;
  return DiseaseModel.fromJson(response);
});

final recommendationsByDiseaseProvider =
    FutureProvider.family<List<RecommendationModel>, int>((ref, diseaseId) async {
  final client = Supabase.instance.client;
  final response = await client
      .from('recommendations')
      .select()
      .eq('disease_id', diseaseId);

  return (response as List)
      .map((row) => RecommendationModel.fromJson(row))
      .toList();
});

