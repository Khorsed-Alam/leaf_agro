import '../../../models/prediction_model.dart';
import '../../../../core/constants/app_constants.dart';
import 'tflite_engine_interface.dart';

class WebTfliteEngine implements TfliteEngine {
  @override
  Future<void> initialize() async {}

  @override
  Future<PredictionModel> predictImage(String imagePath) async {
    // Simulated prediction for Web testing
    await Future.delayed(const Duration(milliseconds: 600));
    return PredictionModel(
      className: 'Rice___Bacterial_leaf_blight',
      cropName: 'Rice',
      diseaseNameEn: 'Bacterial leaf blight',
      diseaseNameBn: 'ব্যাকটেরিয়াল লিফ ব্লাইট',
      confidence: 0.94,
      predictedAt: DateTime.now(),
      modelVersion: AppConstants.appVersion,
    );
  }

  @override
  void dispose() {}
}

TfliteEngine createTfliteEngine() => WebTfliteEngine();
