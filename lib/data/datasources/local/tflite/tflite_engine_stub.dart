import '../../../models/prediction_model.dart';

abstract class TfliteEngine {
  Future<void> initialize();
  Future<PredictionModel> predictImage(String imagePath);
  void dispose();
}

TfliteEngine createTfliteEngine() => throw UnsupportedError('Platform not supported');
