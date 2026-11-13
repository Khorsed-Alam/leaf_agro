import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/plant_observation_model.dart';
import '../data/repositories/observation_repository.dart';
import 'history_provider.dart';

final observationRepositoryProvider = Provider<ObservationRepository>((ref) {
  return ObservationRepository(
    ref.watch(sqliteDataSourceProvider),
    ref.watch(supabaseDataSourceProvider),
  );
});

/// Fetches all observations for a specific scan record
final observationsByScanProvider =
    FutureProvider.family<List<PlantObservationModel>, String>((ref, scanId) async {
  final repo = ref.watch(observationRepositoryProvider);
  String userId = 'guest';
  try {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) userId = user.id;
  } catch (_) {}

  return await repo.getObservationsForScan(scanId, userId);
});

/// Manages observation state and provides mutation actions
class ObservationNotifier
    extends StateNotifier<AsyncValue<List<PlantObservationModel>>> {
  final Ref _ref;
  final String _scanId;

  ObservationNotifier(this._ref, this._scanId)
      : super(const AsyncValue.loading()) {
    loadObservations();
  }

  Future<void> loadObservations() async {
    state = const AsyncValue.loading();
    try {
      final repo = _ref.read(observationRepositoryProvider);
      String userId = 'guest';
      try {
        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) userId = user.id;
      } catch (_) {}

      final list = await repo.getObservationsForScan(_scanId, userId);
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addObservation({
    required String notes,
    required FarmerConditionLabel condition,
    String? cropName,
    DateTime? nextInspectionDate,
  }) async {
    final repo = _ref.read(observationRepositoryProvider);
    String userId = 'guest';
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) userId = user.id;
    } catch (_) {}

    final newObservation = PlantObservationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      scanId: _scanId,
      userId: userId,
      cropName: cropName,
      conditionLabel: condition,
      notes: notes,
      nextInspectionDate: nextInspectionDate,
      createdAt: DateTime.now(),
      syncStatus: 'pending',
    );

    await repo.saveObservation(newObservation);

    // If next inspection date was provided, update stored preference as well
    if (nextInspectionDate != null) {
      await saveInspectionReminder(_scanId, nextInspectionDate);
    }

    await loadObservations();
  }

  static Future<void> saveInspectionReminder(
      String scanId, DateTime date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'inspection_reminder_$scanId', date.toIso8601String());
    } catch (_) {}
  }

  static Future<DateTime?> getInspectionReminder(String scanId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateStr = prefs.getString('inspection_reminder_$scanId');
      if (dateStr != null) {
        return DateTime.tryParse(dateStr);
      }
    } catch (_) {}
    return null;
  }

  static Future<void> clearInspectionReminder(String scanId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('inspection_reminder_$scanId');
    } catch (_) {}
  }
}

final observationNotifierProvider = StateNotifierProvider.family<
    ObservationNotifier,
    AsyncValue<List<PlantObservationModel>>,
    String>((ref, scanId) {
  return ObservationNotifier(ref, scanId);
});

