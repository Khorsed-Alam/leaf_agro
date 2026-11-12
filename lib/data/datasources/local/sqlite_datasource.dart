import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../../models/prediction_history_model.dart';

class SqliteDataSource {
  Database? _db;
  final List<PredictionHistoryModel> _inMemoryWebCache = [];

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
        version: 1,
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
}
