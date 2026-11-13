import '../../../../core/errors/ai_model_exception.dart';
import 'disease_label.dart';

/// Represents a ranked class prediction with associated probability and localized metadata.
class TopClassPrediction {
  final int classIndex;
  final String className;
  final String cropName;
  final String diseaseNameEn;
  final String diseaseNameBn;
  final double probability;
  final bool isHealthy;

  const TopClassPrediction({
    required this.classIndex,
    required this.className,
    required this.cropName,
    required this.diseaseNameEn,
    required this.diseaseNameBn,
    required this.probability,
    required this.isHealthy,
  });

  /// Probability formatted as a percentage in [0.0, 100.0].
  double get probabilityPercentage => probability * 100.0;

  Map<String, dynamic> toJson() => {
        'class_index': classIndex,
        'class_name': className,
        'crop_name': cropName,
        'disease_name_en': diseaseNameEn,
        'disease_name_bn': diseaseNameBn,
        'probability': probability,
        'is_healthy': isHealthy,
      };

  factory TopClassPrediction.fromJson(Map<String, dynamic> json) {
    return TopClassPrediction(
      classIndex: json['class_index'] as int,
      className: json['class_name'] as String,
      cropName: json['crop_name'] as String,
      diseaseNameEn: json['disease_name_en'] as String,
      diseaseNameBn: json['disease_name_bn'] as String,
      probability: (json['probability'] as num).toDouble(),
      isHealthy: json['is_healthy'] as bool? ?? false,
    );
  }
}

/// Immutable, null-safe data model representing an authentic plant disease prediction.
/// Produced strictly from on-device MobileNetV2 TensorFlow Lite inference.
class PlantDiseasePrediction {
  /// Zero-based index corresponding to the winning model output neuron (0..18).
  final int predictedClassIndex;

  /// Verified raw class name from labels.json (e.g. "Potato___Early_blight").
  final String predictedClassName;

  /// Confidence score of the top prediction, bounded in [0.0, 1.0].
  final double confidence;

  /// Full 19-element probability vector from model Softmax output, in original class order.
  final List<double> classProbabilities;

  /// Time spent executing TFLite native interpreter run.
  final Duration inferenceDuration;

  /// Identifier of the model version used for inference.
  final String modelVersion;

  /// Path to the validated image file that was analyzed.
  final String imagePath;

  /// Timestamp when prediction was executed.
  final DateTime predictionTimestamp;

  /// Sorted list of top predictions by descending probability.
  final List<TopClassPrediction> topPredictions;

  /// Time spent in image decoding.
  final Duration imageDecodingDuration;

  /// Time spent in resizing, RGB conversion, and tensor construction.
  final Duration preprocessingDuration;

  /// Total end-to-end duration from image loading to prediction completion.
  final Duration totalPredictionDuration;

  /// Crop name parsed from verified class label (e.g. "Potato").
  final String cropName;

  /// English disease title (e.g. "Early Blight").
  final String diseaseNameEn;

  /// Bengali disease title (e.g. "আর্লি ব্লাইট (আগাম ধসা)").
  final String diseaseNameBn;

  /// Whether the leaf was diagnosed as healthy.
  final bool isHealthy;

  const PlantDiseasePrediction({
    required this.predictedClassIndex,
    required this.predictedClassName,
    required this.confidence,
    required this.classProbabilities,
    required this.inferenceDuration,
    required this.modelVersion,
    required this.imagePath,
    required this.predictionTimestamp,
    required this.topPredictions,
    required this.imageDecodingDuration,
    required this.preprocessingDuration,
    required this.totalPredictionDuration,
    required this.cropName,
    required this.diseaseNameEn,
    required this.diseaseNameBn,
    required this.isHealthy,
  });

  /// Confidence score formatted as a percentage in [0.0, 100.0].
  double get confidencePercentage => confidence * 100.0;

  /// Factory constructor to create and validate a prediction result from raw model outputs.
  factory PlantDiseasePrediction.fromInference({
    required int predictedClassIndex,
    required List<double> classProbabilities,
    required DiseaseLabels labels,
    required String modelVersion,
    required String imagePath,
    required Duration imageDecodingDuration,
    required Duration preprocessingDuration,
    required Duration inferenceDuration,
    required Duration totalPredictionDuration,
    DateTime? timestamp,
  }) {
    // 1. Validate class count
    if (classProbabilities.length != labels.numClasses) {
      throw InferenceException(
        'Probability vector length (${classProbabilities.length}) does not match model class count (${labels.numClasses}).',
      );
    }

    // 2. Validate winning index
    if (predictedClassIndex < 0 || predictedClassIndex >= labels.numClasses) {
      throw InvalidLabelIndexException(
        queriedIndex: predictedClassIndex,
        totalClasses: labels.numClasses,
      );
    }

    // 3. Validate probability values
    for (int i = 0; i < classProbabilities.length; i++) {
      final p = classProbabilities[i];
      if (p.isNaN || p.isInfinite) {
        throw InferenceException('Probability vector contains NaN or Infinity at index $i.');
      }
      if (p < 0.0 || p > 1.05) {
        // slight numerical tolerance for floating point rounding
        throw InferenceException('Probability out of [0.0, 1.0] bounds at index $i: $p');
      }
    }

    final winningLabel = labels.getLabelByIndex(predictedClassIndex);
    final confidence = classProbabilities[predictedClassIndex].clamp(0.0, 1.0);

    // 4. Build sorted top predictions list
    final indexed = List.generate(classProbabilities.length, (i) => i);
    indexed.sort((a, b) => classProbabilities[b].compareTo(classProbabilities[a]));

    final topPredictions = indexed.map((idx) {
      final label = labels.getLabelByIndex(idx);
      final prob = classProbabilities[idx].clamp(0.0, 1.0);
      return TopClassPrediction(
        classIndex: idx,
        className: label.rawClassName,
        cropName: label.cropName,
        diseaseNameEn: label.diseaseName,
        diseaseNameBn: label.getDisplayName(true),
        probability: prob,
        isHealthy: label.isHealthy,
      );
    }).toList();

    return PlantDiseasePrediction(
      predictedClassIndex: predictedClassIndex,
      predictedClassName: winningLabel.rawClassName,
      confidence: confidence,
      classProbabilities: List.unmodifiable(classProbabilities),
      inferenceDuration: inferenceDuration,
      modelVersion: modelVersion,
      imagePath: imagePath,
      predictionTimestamp: timestamp ?? DateTime.now(),
      topPredictions: List.unmodifiable(topPredictions),
      imageDecodingDuration: imageDecodingDuration,
      preprocessingDuration: preprocessingDuration,
      totalPredictionDuration: totalPredictionDuration,
      cropName: winningLabel.cropName,
      diseaseNameEn: winningLabel.diseaseName,
      diseaseNameBn: winningLabel.getDisplayName(true),
      isHealthy: winningLabel.isHealthy,
    );
  }

  Map<String, dynamic> toJson() => {
        'predicted_class_index': predictedClassIndex,
        'predicted_class_name': predictedClassName,
        'confidence': confidence,
        'confidence_percentage': confidencePercentage,
        'class_probabilities': classProbabilities,
        'inference_duration_ms': inferenceDuration.inMilliseconds,
        'image_decoding_duration_ms': imageDecodingDuration.inMilliseconds,
        'preprocessing_duration_ms': preprocessingDuration.inMilliseconds,
        'total_prediction_duration_ms': totalPredictionDuration.inMilliseconds,
        'model_version': modelVersion,
        'image_path': imagePath,
        'prediction_timestamp': predictionTimestamp.toIso8601String(),
        'crop_name': cropName,
        'disease_name_en': diseaseNameEn,
        'disease_name_bn': diseaseNameBn,
        'is_healthy': isHealthy,
        'top_predictions': topPredictions.map((t) => t.toJson()).toList(),
      };

  factory PlantDiseasePrediction.fromJson(Map<String, dynamic> json) {
    return PlantDiseasePrediction(
      predictedClassIndex: json['predicted_class_index'] as int,
      predictedClassName: json['predicted_class_name'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      classProbabilities: (json['class_probabilities'] as List)
          .map((e) => (e as num).toDouble())
          .toList(),
      inferenceDuration: Duration(milliseconds: json['inference_duration_ms'] as int),
      imageDecodingDuration: Duration(
          milliseconds: json['image_decoding_duration_ms'] as int? ?? 0),
      preprocessingDuration: Duration(
          milliseconds: json['preprocessing_duration_ms'] as int? ?? 0),
      totalPredictionDuration: Duration(
          milliseconds: json['total_prediction_duration_ms'] as int? ?? 0),
      modelVersion: json['model_version'] as String,
      imagePath: json['image_path'] as String,
      predictionTimestamp: DateTime.parse(json['prediction_timestamp'] as String),
      topPredictions: (json['top_predictions'] as List? ?? [])
          .map((e) => TopClassPrediction.fromJson(e as Map<String, dynamic>))
          .toList(),
      cropName: json['crop_name'] as String,
      diseaseNameEn: json['disease_name_en'] as String,
      diseaseNameBn: json['disease_name_bn'] as String,
      isHealthy: json['is_healthy'] as bool? ?? false,
    );
  }
}
