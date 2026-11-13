import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources/local/sqlite_datasource.dart';
import '../data/datasources/remote/supabase_datasource.dart';
import '../data/models/prediction_history_model.dart';
import '../data/repositories/history_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final sqliteDataSourceProvider = Provider<SqliteDataSource>((ref) {
  return SqliteDataSource();
});

final supabaseDataSourceProvider = Provider<SupabaseDataSource>((ref) {
  return SupabaseDataSource(Supabase.instance.client);
});

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepository(
    ref.watch(sqliteDataSourceProvider),
    ref.watch(supabaseDataSourceProvider),
  );
});

class HistoryNotifier extends AsyncNotifier<List<PredictionHistoryModel>> {
  @override
  Future<List<PredictionHistoryModel>> build() async {
    return loadHistory();
  }

  Future<List<PredictionHistoryModel>> loadHistory() async {
    final repo = ref.read(historyRepositoryProvider);
    final user = Supabase.instance.client.auth.currentUser;
    final userId = user?.id ?? 'guest';
    return await repo.getAllPredictions(userId);
  }

  Future<void> addScanRecord(PredictionHistoryModel model) async {
    final repo = ref.read(historyRepositoryProvider);
    await repo.savePrediction(model);
    state = await AsyncValue.guard(loadHistory);
  }

  Future<void> deleteScanRecord(String id) async {
    final repo = ref.read(historyRepositoryProvider);
    final user = Supabase.instance.client.auth.currentUser;
    final userId = user?.id ?? 'guest';
    await repo.deletePrediction(id, userId);
    state = await AsyncValue.guard(loadHistory);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(loadHistory);
  }
}

final historyProvider =
    AsyncNotifierProvider<HistoryNotifier, List<PredictionHistoryModel>>(
  HistoryNotifier.new,
);

