import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/crop_model.dart';

// ── Notifier ──────────────────────────────────────────────────────────────────

class CropNotifier extends AsyncNotifier<List<CropModel>> {
  SupabaseClient get _supabase => Supabase.instance.client;

  @override
  Future<List<CropModel>> build() async {
    return loadCrops();
  }

  Future<List<CropModel>> loadCrops() async {
    final data = await _supabase
        .from('crops')
        .select()
        .eq('is_active', true)
        .order('name_en');
    return (data as List)
        .map((e) => CropModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(loadCrops);
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final cropProvider =
    AsyncNotifierProvider<CropNotifier, List<CropModel>>(CropNotifier.new);

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
    return CropModel.fromJson(data as Map<String, dynamic>);
  }
});
