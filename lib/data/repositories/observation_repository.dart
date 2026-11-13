import '../datasources/local/sqlite_datasource.dart';
import '../datasources/remote/supabase_datasource.dart';
import '../models/plant_observation_model.dart';

class ObservationRepository {
  final SqliteDataSource _localDataSource;
  final SupabaseDataSource _remoteDataSource;

  ObservationRepository(this._localDataSource, this._remoteDataSource);

  /// Saves a farmer observation.
  /// Always persists to SQLite locally first to ensure offline-first reliability.
  /// Synchronizes to Supabase when the user has an active authenticated session.
  Future<void> saveObservation(PlantObservationModel model) async {
    // 1. Offline-first local write
    await _localDataSource.saveLocalObservation(model);

    // 2. Cloud synchronization for authenticated users
    try {
      if (model.userId != 'guest') {
        await _remoteDataSource.syncObservation(model);
        await _localDataSource.markObservationAsSynced(model.id);
      }
    } catch (_) {
      // Retained in SQLite with pending status for later sync
    }
  }

  /// Retrieves observations recorded for a specific plant scan.
  Future<List<PlantObservationModel>> getObservationsForScan(
      String scanId, String userId) async {
    try {
      if (userId != 'guest') {
        final remote = await _remoteDataSource.getObservationsForScan(scanId);
        if (remote.isNotEmpty) {
          // Cache each locally
          for (final obs in remote) {
            await _localDataSource.saveLocalObservation(obs);
          }
          return remote;
        }
      }
    } catch (_) {}

    return await _localDataSource.getLocalObservationsForScan(scanId);
  }

  /// Retrieves all observations recorded by a user.
  Future<List<PlantObservationModel>> getAllObservations(String userId) async {
    try {
      if (userId != 'guest') {
        final remote = await _remoteDataSource.getUserObservations(userId);
        if (remote.isNotEmpty) return remote;
      }
    } catch (_) {}

    return await _localDataSource.getAllLocalObservations(userId);
  }
}

