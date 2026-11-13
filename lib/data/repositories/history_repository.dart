import '../datasources/local/sqlite_datasource.dart';
import '../datasources/remote/supabase_datasource.dart';
import '../models/prediction_history_model.dart';

class HistoryRepository {
  final SqliteDataSource _localDataSource;
  final SupabaseDataSource _remoteDataSource;

  HistoryRepository(this._localDataSource, this._remoteDataSource);

  Future<void> savePrediction(PredictionHistoryModel model) async {
    // 1. Always write locally first for offline resilience
    await _localDataSource.saveLocalPrediction(model);

    // 2. Attempt cloud synchronization if user is authenticated
    try {
      if (model.userId != 'guest') {
        await _remoteDataSource.syncPredictionHistory(model);
        await _localDataSource.markAsSynced(model.id);
      }
    } catch (_) {
      // Retained in SQLite as pending
    }
  }

  Future<List<PredictionHistoryModel>> getAllPredictions(String userId) async {
    try {
      if (userId != 'guest') {
        final remote = await _remoteDataSource.getUserHistory(userId);
        if (remote.isNotEmpty) return remote;
      }
    } catch (_) {}

    return await _localDataSource.getLocalPredictions();
  }

  Future<void> deletePrediction(String id, String userId) async {
    // 1. Delete locally from SQLite
    await _localDataSource.deleteLocalPrediction(id);

    // 2. Delete remotely from Supabase if authenticated
    try {
      if (userId != 'guest') {
        await _remoteDataSource.deletePredictionHistory(id);
      }
    } catch (_) {}
  }
}

