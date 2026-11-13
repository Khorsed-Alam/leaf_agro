import 'dart:typed_data';
import '../../../../core/errors/ai_model_exception.dart';
import '../../../../data/models/prediction_model.dart';
import '../models/ai_model_metadata.dart';
import '../models/disease_label.dart';
import '../services/ai_model_service.dart';

/// Individual class prediction with its associated verified disease label and confidence score.
class RankedPrediction {
  final DiseaseLabel label;
  final double confidence;

  const RankedPrediction({
    required this.label,
    required this.confidence,
  });

  @override
  String toString() => '${label.rawClassName}: ${(confidence * 100).toStringAsFixed(1)}%';
}

/// Comprehensive inference result returned by [AiModelRepository].
class ModelInferenceResult {
  final DiseaseLabel topLabel;
  final double topConfidence;
  final List<RankedPrediction> allPredictions;
  final List<double> rawProbabilities;
  final String modelVersion;
  final DateTime executedAt;

  const ModelInferenceResult({
    required this.topLabel,
    required this.topConfidence,
    required this.allPredictions,
    required this.rawProbabilities,
    required this.modelVersion,
    required this.executedAt,
  });

  /// Converts to the application's legacy [PredictionModel] for backwards compatibility.
  PredictionModel toPredictionModel() {
    return PredictionModel(
      className: topLabel.rawClassName,
      cropName: topLabel.cropName,
      diseaseNameEn: topLabel.diseaseName,
      diseaseNameBn: topLabel.getDisplayName(true),
      confidence: topConfidence,
      predictedAt: executedAt,
      modelVersion: modelVersion,
    );
  }
}

/// Repository coordinating the AI Model service, label alignments, and domain-level inference output.
class AiModelRepository {
  final AiModelService _service;

  AiModelRepository(this._service);

  /// Whether the underlying AI service is initialized and ready.
  bool get isReady => _service.isInitialized;

  /// Verified metadata of the loaded model.
  AiModelMetadata? get metadata => _service.metadata;

  /// Verified 19-class label definitions.
  DiseaseLabels? get labels => _service.labels;

  /// Initializes the underlying model service.
  Future<void> initialize() => _service.initialize();

  /// Runs raw inference returning the raw 19-element softmax probability vector.
  Future<List<double>> getRawProbabilities(Float32List input) {
    return _service.predict(input);
  }

  /// Runs inference and maps output probabilities to typed [ModelInferenceResult].
  Future<ModelInferenceResult> predict(Float32List input) async {
    final probabilities = await _service.predict(input);
    final labels = _service.labels;
    final metadata = _service.metadata;

    if (labels == null) {
      throw const AiModelException('Labels are not loaded in AiModelService.');
    }

    // Rank all predictions by confidence descending
    final List<RankedPrediction> ranked = [];
    int bestIndex = 0;
    double bestConfidence = -1.0;

    for (int i = 0; i < probabilities.length; i++) {
      final p = probabilities[i];
      final label = labels.getLabelByIndex(i);
      ranked.add(RankedPrediction(label: label, confidence: p));

      if (p > bestConfidence) {
        bestConfidence = p;
        bestIndex = i;
      }
    }

    ranked.sort((a, b) => b.confidence.compareTo(a.confidence));

    return ModelInferenceResult(
      topLabel: labels.getLabelByIndex(bestIndex),
      topConfidence: bestConfidence,
      allPredictions: List.unmodifiable(ranked),
      rawProbabilities: probabilities,
      modelVersion: metadata?.modelVersion ?? '1.0.0',
      executedAt: DateTime.now(),
    );
  }

  /// Disposes the underlying AI model service.
  void dispose() {
    _service.dispose();
  }
}
