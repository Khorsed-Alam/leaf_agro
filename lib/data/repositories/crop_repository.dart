import '../datasources/remote/supabase_datasource.dart';
import '../models/crop_model.dart';
import '../models/disease_model.dart';
import '../models/recommendation_model.dart';

class CropRepository {
  final SupabaseDataSource _remoteDataSource;
  CropRepository(this._remoteDataSource);

  Future<List<CropModel>> getActiveCrops() => _remoteDataSource.getCrops();

  Future<List<DiseaseModel>> getDiseasesForCrop(int cropId) =>
      _remoteDataSource.getDiseasesForCrop(cropId);

  Future<DiseaseModel?> getDiseaseByClass(String className) =>
      _remoteDataSource.getDiseaseByClassName(className);

  Future<List<RecommendationModel>> getRecommendations(int diseaseId) =>
      _remoteDataSource.getRecommendations(diseaseId);
}

