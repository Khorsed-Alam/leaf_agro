import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../../models/prediction_history_model.dart';
import '../../models/plant_observation_model.dart';

class SqliteDataSource {
  Database? _db;
  final List<PredictionHistoryModel> _inMemoryWebCache = [];
  final List<PlantObservationModel> _inMemoryObservationWebCache = [];

  Future<Database?> get database async {
    if (kIsWeb) return null;
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db;
  }

  Future<Database?> _initDatabase() async {
    if (kIsWeb) return null;
    try {
      final dbPath = await getDatabasesPath();
      final path = p.join(dbPath, 'agricare_local.db');

      return await openDatabase(
        path,
        version: 2,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE local_prediction_history (
              id TEXT PRIMARY KEY,
              user_id TEXT NOT NULL,
              disease_id INTEGER,
              predicted_class TEXT NOT NULL,
              confidence REAL NOT NULL,
              image_path TEXT,
              model_version TEXT NOT NULL,
              created_at TEXT NOT NULL,
              sync_status TEXT NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS local_plant_observations (
              id TEXT PRIMARY KEY,
              scan_id TEXT NOT NULL,
              user_id TEXT NOT NULL,
              crop_name TEXT,
              condition_label TEXT NOT NULL,
              notes TEXT NOT NULL,
              image_path TEXT,
              next_inspection_date TEXT,
              created_at TEXT NOT NULL,
              sync_status TEXT NOT NULL
            )
          ''');
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await db.execute('''
              CREATE TABLE IF NOT EXISTS local_plant_observations (
                id TEXT PRIMARY KEY,
                scan_id TEXT NOT NULL,
                user_id TEXT NOT NULL,
                crop_name TEXT,
                condition_label TEXT NOT NULL,
                notes TEXT NOT NULL,
                image_path TEXT,
                next_inspection_date TEXT,
                created_at TEXT NOT NULL,
                sync_status TEXT NOT NULL
              )
            ''');
          }
        },
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> saveLocalPrediction(PredictionHistoryModel model) async {
    if (kIsWeb) {
      _inMemoryWebCache.removeWhere((e) => e.id == model.id);
      _inMemoryWebCache.insert(0, model);
      return;
    }

    final db = await database;
    if (db == null) return;

    await db.insert(
      'local_prediction_history',
      {
        'id': model.id,
        'user_id': model.userId,
        'disease_id': model.diseaseId,
        'predicted_class': model.predictedClass,
        'confidence': model.confidence,
        'image_path': model.imagePath,
        'model_version': model.modelVersion,
        'created_at': model.createdAt.toIso8601String(),
        'sync_status': model.syncStatus,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<PredictionHistoryModel>> getLocalPredictions() async {
    if (kIsWeb) {
      return List.unmodifiable(_inMemoryWebCache);
    }

    final db = await database;
    if (db == null) return [];

    final results = await db.query(
      'local_prediction_history',
      orderBy: 'created_at DESC',
    );
    return results.map((row) => PredictionHistoryModel.fromJson(row)).toList();
  }

  Future<List<PredictionHistoryModel>> getPendingSyncList() async {
    if (kIsWeb) {
      return _inMemoryWebCache.where((e) => e.syncStatus == 'pending').toList();
    }

    final db = await database;
    if (db == null) return [];

    final results = await db.query(
      'local_prediction_history',
      where: 'sync_status = ?',
      whereArgs: ['pending'],
    );
    return results.map((row) => PredictionHistoryModel.fromJson(row)).toList();
  }

  Future<void> markAsSynced(String id) async {
    if (kIsWeb) {
      final index = _inMemoryWebCache.indexWhere((e) => e.id == id);
      if (index != -1) {
        final existing = _inMemoryWebCache[index];
        _inMemoryWebCache[index] = PredictionHistoryModel(
          id: existing.id,
          userId: existing.userId,
          diseaseId: existing.diseaseId,
          predictedClass: existing.predictedClass,
          confidence: existing.confidence,
          imagePath: existing.imagePath,
          modelVersion: existing.modelVersion,
          createdAt: existing.createdAt,
          syncStatus: 'synced',
        );
      }
      return;
    }

    final db = await database;
    if (db == null) return;

    await db.update(
      'local_prediction_history',
      {'sync_status': 'synced'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteLocalPrediction(String id) async {
    if (kIsWeb) {
      _inMemoryWebCache.removeWhere((e) => e.id == id);
      return;
    }

    final db = await database;
    if (db == null) return;

    await db.delete(
      'local_prediction_history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ── Plant Observation Methods ──────────────────────────────────────────────

  Future<void> saveLocalObservation(PlantObservationModel model) async {
    if (kIsWeb) {
      _inMemoryObservationWebCache.removeWhere((e) => e.id == model.id);
      _inMemoryObservationWebCache.insert(0, model);
      return;
    }

    final db = await database;
    if (db == null) return;

    await db.insert(
      'local_plant_observations',
      {
        'id': model.id,
        'scan_id': model.scanId,
        'user_id': model.userId,
        'crop_name': model.cropName,
        'condition_label': model.conditionLabel.key,
        'notes': model.notes,
        'image_path': model.imagePath,
        'next_inspection_date': model.nextInspectionDate?.toIso8601String(),
        'created_at': model.createdAt.toIso8601String(),
        'sync_status': model.syncStatus,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<PlantObservationModel>> getLocalObservationsForScan(
      String scanId) async {
    if (kIsWeb) {
      return _inMemoryObservationWebCache
          .where((e) => e.scanId == scanId)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    final db = await database;
    if (db == null) return [];

    final results = await db.query(
      'local_plant_observations',
      where: 'scan_id = ?',
      whereArgs: [scanId],
      orderBy: 'created_at DESC',
    );
    return results.map((row) => PlantObservationModel.fromJson(row)).toList();
  }

  Future<List<PlantObservationModel>> getAllLocalObservations(
      String userId) async {
    if (kIsWeb) {
      return _inMemoryObservationWebCache
          .where((e) => userId == 'guest' || e.userId == userId)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    final db = await database;
    if (db == null) return [];

    final results = userId == 'guest'
        ? await db.query(
            'local_plant_observations',
            orderBy: 'created_at DESC',
          )
        : await db.query(
            'local_plant_observations',
            where: 'user_id = ?',
            whereArgs: [userId],
            orderBy: 'created_at DESC',
          );
    return results.map((row) => PlantObservationModel.fromJson(row)).toList();
  }

  Future<void> markObservationAsSynced(String id) async {
    if (kIsWeb) {
      final index =
          _inMemoryObservationWebCache.indexWhere((e) => e.id == id);
      if (index != -1) {
        final existing = _inMemoryObservationWebCache[index];
        _inMemoryObservationWebCache[index] = existing.copyWith(
          syncStatus: 'synced',
        );
      }
      return;
    }

    final db = await database;
    if (db == null) return;

    await db.update(
      'local_plant_observations',
      {'sync_status': 'synced'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
