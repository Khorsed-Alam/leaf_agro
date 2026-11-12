import '../../models/prediction_model.dart';
import 'tflite/tflite_engine.dart';

class TfliteDataSource {
  final TfliteEngine _engine = createTfliteEngine();

  Future<void> initialize() => _engine.initialize();

  Future<PredictionModel> predictImage(String imagePath) =>
      _engine.predictImage(imagePath);

  void dispose() => _engine.dispose();
}
