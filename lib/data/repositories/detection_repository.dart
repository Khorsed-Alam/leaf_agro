import '../datasources/local/tflite_datasource.dart';
import '../models/prediction_model.dart';

class DetectionRepository {
  final TfliteDataSource _tfliteDataSource;
  DetectionRepository(this._tfliteDataSource);

  Future<void> initializeModel() => _tfliteDataSource.initialize();

  Future<PredictionModel> detectPlantDisease(String imagePath) =>
      _tfliteDataSource.predictImage(imagePath);
}

