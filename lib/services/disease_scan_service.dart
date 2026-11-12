import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';
import '../data/models/disease_scan_model.dart';
import '../data/models/treatment_history_model.dart';

class DiseaseScanService {
  final SupabaseClient _client;

  DiseaseScanService([SupabaseClient? client])
      : _client = client ?? SupabaseConfig.client;

  /// Save an AI disease scan record
  Future<DiseaseScanModel> saveScan(DiseaseScanModel scan) async {
    final data = scan.toJson();
    final response = await _client
        .from(SupabaseConfig.tableDiseaseScans)
        .insert(data)
        .select()
        .single();

    return DiseaseScanModel.fromJson(response);
  }

  /// Get historical scans for a farmer
  Future<List<DiseaseScanModel>> getUserScans(String userId) async {
    final response = await _client
        .from(SupabaseConfig.tableDiseaseScans)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((row) => DiseaseScanModel.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  /// Get details for a single scan
  Future<DiseaseScanModel?> getScanDetails(String scanId) async {
    final response = await _client
        .from(SupabaseConfig.tableDiseaseScans)
        .select()
        .eq('id', scanId)
        .maybeSingle();

    if (response == null) return null;
    return DiseaseScanModel.fromJson(response);
  }

  /// Save verified treatment recommendation history for a scan
  Future<TreatmentHistoryModel> saveTreatmentHistory(
    TreatmentHistoryModel treatment,
  ) async {
    final data = treatment.toJson();
    final response = await _client
        .from(SupabaseConfig.tableTreatmentHistory)
        .insert(data)
        .select()
        .single();

    return TreatmentHistoryModel.fromJson(response);
  }

  /// Fetch treatment history for a scan
  Future<List<TreatmentHistoryModel>> getTreatmentsForScan(String scanId) async {
    final response = await _client
        .from(SupabaseConfig.tableTreatmentHistory)
        .select()
        .eq('scan_id', scanId);

    return (response as List)
        .map((row) => TreatmentHistoryModel.fromJson(row as Map<String, dynamic>))
        .toList();
  }
}

