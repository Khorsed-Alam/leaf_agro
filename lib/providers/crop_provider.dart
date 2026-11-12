import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/datasources/ai_crop_catalog.dart';
import '../data/models/crop_model.dart';

// ── Notifier ──────────────────────────────────────────────────────────────────

class CropNotifier extends AsyncNotifier<List<CropModel>> {
  SupabaseClient? get _supabase {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<CropModel>> build() async {
    return loadCrops();
  }

  Future<List<CropModel>> loadCrops() async {
    try {
      final client = _supabase;
      if (client == null) {
        return AiCropCatalog.verifiedSupportedCrops;
      }
      final data = await client
          .from('crops')
          .select()
          .eq('is_active', true)
          .order('name_en');
      final list = (data as List)
          .map((e) => CropModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return list.isNotEmpty ? list : AiCropCatalog.verifiedSupportedCrops;
    } catch (_) {
      return AiCropCatalog.verifiedSupportedCrops;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(loadCrops);
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final cropProvider =
    AsyncNotifierProvider<CropNotifier, List<CropModel>>(CropNotifier.new);

/// Returns exclusively the crops verified to be supported by the trained AI model
final aiSupportedCropsProvider = FutureProvider<List<CropModel>>((ref) async {
  try {
    final crops = await ref.watch(cropProvider.future);
    final supported = crops.where((c) => c.isAiSupported).toList();
    return supported.isNotEmpty ? supported : AiCropCatalog.verifiedSupportedCrops;
  } catch (_) {
    return AiCropCatalog.verifiedSupportedCrops;
  }
});

final selectedCropProvider = StateProvider<CropModel?>((ref) => null);

final cropByIdProvider = FutureProvider.family<CropModel?, int>((ref, id) async {
  final crops = await ref.watch(cropProvider.future);
  try {
    return crops.firstWhere((c) => c.id == id);
  } catch (_) {
    // Not in cache — fetch directly
    final supabase = Supabase.instance.client;
    final data = await supabase
        .from('crops')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (data == null) return null;
    return CropModel.fromJson(data);
  }
});
