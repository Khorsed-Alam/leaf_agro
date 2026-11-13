import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/ai_model_exception.dart';
import '../models/plant_disease_prediction.dart';
import '../models/selected_plant_image.dart';
import 'ai_model_service.dart';
import 'plant_image_preprocessor.dart';
import '../../presentation/providers/ai_model_provider.dart';

/// Application-level provider for [PlantImagePreprocessor].
final plantImagePreprocessorProvider = Provider<PlantImagePreprocessor>((ref) {
  return PlantImagePreprocessor();
});

/// Application-level provider for [PlantDiseaseInferenceService].
final plantDiseaseInferenceServiceProvider = Provider<PlantDiseaseInferenceService>((ref) {
  final aiModelService = ref.watch(aiModelServiceProvider);
  final preprocessor = ref.watch(plantImagePreprocessorProvider);
  return PlantDiseaseInferenceService(
    aiModelService: aiModelService,
    preprocessor: preprocessor,
  );
});

/// Production Inference Service executing offline plant disease classification.
///
/// Integrates:
/// 1. Phase 41 `AiModelService` (reusing the initialized TFLite MobileNetV2 interpreter)
/// 2. Phase 42 `SelectedPlantImage`
/// 3. Phase 43 `PlantImagePreprocessor`
///
/// Guarantees:
/// - Reuses existing interpreter instance (never reloads model per prediction)
/// - Strictly prevents unsafe concurrent execution across async turns
/// - Generates authentic `PlantDiseasePrediction` with verified labels and timings
class PlantDiseaseInferenceService {
  final AiModelService _aiModelService;
  final PlantImagePreprocessor _preprocessor;

  bool _isInferring = false;

  PlantDiseaseInferenceService({
    required AiModelService aiModelService,
    required PlantImagePreprocessor preprocessor,
  })  : _aiModelService = aiModelService,
        _preprocessor = preprocessor;

  /// Whether an inference execution is currently running.
  bool get isInferring => _isInferring;

  /// Executes complete end-to-end plant disease prediction for a [SelectedPlantImage].
  Future<PlantDiseasePrediction> predict(SelectedPlantImage selectedImage) async {
    return predictFromFile(selectedImage.imagePath);
  }

  /// Executes prediction directly from an image file path.
  Future<PlantDiseasePrediction> predictFromFile(String imagePath) async {
    if (_isInferring) {
      throw InferenceException(
        'Concurrent inference request blocked: another prediction is currently executing.',
      );
    }
    _isInferring = true;
    final totalStopwatch = Stopwatch()..start();

    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        throw ImagePreprocessingException('Image file not found: $imagePath');
      }
      // 1. Ensure AI Model Service is initialized
      if (!_aiModelService.isInitialized) {
        await _aiModelService.initialize();
      }

      final metadata = _aiModelService.metadata;
      final labels = _aiModelService.labels;

      if (metadata == null || labels == null) {
        throw InferenceException(
          'Model service is initialized but metadata or labels are missing.',
        );
      }

      // 2. Preprocess image into Float32 tensor [1, 224, 224, 3] in [0.0, 255.0]
      final preprocessed = await _preprocessor.preprocessFile(imagePath);

      // 3. Execute TFLite native inference with monotonic timing
      final inferenceStopwatch = Stopwatch()..start();
      final List<double> probabilities = await _aiModelService.predict(preprocessed.tensor);
      inferenceStopwatch.stop();

      // 4. Validate output probability vector and find top class (argmax)
      if (probabilities.length != labels.numClasses) {
        throw InferenceException(
          'Output vector size (${probabilities.length}) does not match verified class count (${labels.numClasses}).',
        );
      }

      int winningIndex = 0;
      double maxProbability = -1.0;

      for (int i = 0; i < probabilities.length; i++) {
        final prob = probabilities[i];
        if (prob > maxProbability) {
          maxProbability = prob;
          winningIndex = i;
        }
      }

      totalStopwatch.stop();

      // 5. Construct immutable PlantDiseasePrediction
      return PlantDiseasePrediction.fromInference(
        predictedClassIndex: winningIndex,
        classProbabilities: probabilities,
        labels: labels,
        modelVersion: metadata.modelVersion,
        imagePath: imagePath,
        imageDecodingDuration: preprocessed.decodingDuration,
        preprocessingDuration: preprocessed.preprocessingDuration,
        inferenceDuration: inferenceStopwatch.elapsed,
        totalPredictionDuration: totalStopwatch.elapsed,
      );
    } finally {
      _isInferring = false;
    }
  }
}
