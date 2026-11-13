import 'package:flutter_test/flutter_test.dart';
import 'package:leaf_agro/core/errors/ai_model_exception.dart';
import 'package:leaf_agro/features/detection/data/models/disease_label.dart';
import 'package:leaf_agro/features/detection/data/models/plant_disease_prediction.dart';

void main() {
  group('PlantDiseasePrediction & TopClassPrediction Tests', () {
    late DiseaseLabels mockLabels;

    setUp(() {
      final json = {
        'num_classes': 4,
        'class_names': [
          'Potato___Early_blight',
          'Potato___Late_blight',
          'Potato___healthy',
          'Tomato___healthy',
        ],
        'class_indices': {
          'Potato___Early_blight': 0,
          'Potato___Late_blight': 1,
          'Potato___healthy': 2,
          'Tomato___healthy': 3,
        },
        'supported_crops': ['Potato', 'Tomato'],
      };
      mockLabels = DiseaseLabels.fromJson(json);
    });

    test('successfully builds valid PlantDiseasePrediction from inference', () {
      final probabilities = [0.85, 0.10, 0.03, 0.02];
      final prediction = PlantDiseasePrediction.fromInference(
        predictedClassIndex: 0,
        classProbabilities: probabilities,
        labels: mockLabels,
        modelVersion: '1.0.0',
        imagePath: '/test/leaf.jpg',
        imageDecodingDuration: const Duration(milliseconds: 15),
        preprocessingDuration: const Duration(milliseconds: 25),
        inferenceDuration: const Duration(milliseconds: 40),
        totalPredictionDuration: const Duration(milliseconds: 80),
      );

      expect(prediction.predictedClassIndex, 0);
      expect(prediction.predictedClassName, 'Potato___Early_blight');
      expect(prediction.confidence, 0.85);
      expect(prediction.confidencePercentage, 85.0);
      expect(prediction.cropName, 'Potato');
      expect(prediction.diseaseNameEn, 'Early blight');
      expect(prediction.isHealthy, isFalse);
      expect(prediction.modelVersion, '1.0.0');
      expect(prediction.imagePath, '/test/leaf.jpg');

      // Top predictions are sorted descending by probability
      expect(prediction.topPredictions.length, 4);
      expect(prediction.topPredictions.first.classIndex, 0);
      expect(prediction.topPredictions.first.probability, 0.85);
      expect(prediction.topPredictions[1].classIndex, 1);
      expect(prediction.topPredictions[1].probability, 0.10);
      expect(prediction.topPredictions.last.classIndex, 3);
      expect(prediction.topPredictions.last.probability, 0.02);
    });

    test('properly detects healthy class status', () {
      final probabilities = [0.05, 0.05, 0.80, 0.10];
      final prediction = PlantDiseasePrediction.fromInference(
        predictedClassIndex: 2,
        classProbabilities: probabilities,
        labels: mockLabels,
        modelVersion: '1.0.0',
        imagePath: '/test/healthy_leaf.jpg',
        imageDecodingDuration: const Duration(milliseconds: 10),
        preprocessingDuration: const Duration(milliseconds: 20),
        inferenceDuration: const Duration(milliseconds: 30),
        totalPredictionDuration: const Duration(milliseconds: 60),
      );

      expect(prediction.predictedClassIndex, 2);
      expect(prediction.predictedClassName, 'Potato___healthy');
      expect(prediction.isHealthy, isTrue);
      expect(prediction.diseaseNameEn, 'Healthy');
    });

    test('throws InferenceException when probability length does not match class count', () {
      expect(
        () => PlantDiseasePrediction.fromInference(
          predictedClassIndex: 0,
          classProbabilities: [0.9, 0.1], // Only 2 instead of 4
          labels: mockLabels,
          modelVersion: '1.0.0',
          imagePath: '/test/leaf.jpg',
          imageDecodingDuration: Duration.zero,
          preprocessingDuration: Duration.zero,
          inferenceDuration: Duration.zero,
          totalPredictionDuration: Duration.zero,
        ),
        throwsA(isA<InferenceException>()),
      );
    });

    test('throws InvalidLabelIndexException when predicted class index is out of bounds', () {
      expect(
        () => PlantDiseasePrediction.fromInference(
          predictedClassIndex: 99,
          classProbabilities: [0.25, 0.25, 0.25, 0.25],
          labels: mockLabels,
          modelVersion: '1.0.0',
          imagePath: '/test/leaf.jpg',
          imageDecodingDuration: Duration.zero,
          preprocessingDuration: Duration.zero,
          inferenceDuration: Duration.zero,
          totalPredictionDuration: Duration.zero,
        ),
        throwsA(isA<InvalidLabelIndexException>()),
      );
    });

    test('throws InferenceException on NaN or Infinity in probabilities', () {
      expect(
        () => PlantDiseasePrediction.fromInference(
          predictedClassIndex: 0,
          classProbabilities: [double.nan, 0.1, 0.0, 0.0],
          labels: mockLabels,
          modelVersion: '1.0.0',
          imagePath: '/test/leaf.jpg',
          imageDecodingDuration: Duration.zero,
          preprocessingDuration: Duration.zero,
          inferenceDuration: Duration.zero,
          totalPredictionDuration: Duration.zero,
        ),
        throwsA(isA<InferenceException>()),
      );
    });

    test('serializes to and from JSON faithfully', () {
      final prediction = PlantDiseasePrediction.fromInference(
        predictedClassIndex: 0,
        classProbabilities: [0.70, 0.20, 0.05, 0.05],
        labels: mockLabels,
        modelVersion: '1.0.0',
        imagePath: '/test/leaf.jpg',
        imageDecodingDuration: const Duration(milliseconds: 12),
        preprocessingDuration: const Duration(milliseconds: 18),
        inferenceDuration: const Duration(milliseconds: 35),
        totalPredictionDuration: const Duration(milliseconds: 65),
      );

      final jsonMap = prediction.toJson();
      final reconstituted = PlantDiseasePrediction.fromJson(jsonMap);

      expect(reconstituted.predictedClassIndex, prediction.predictedClassIndex);
      expect(reconstituted.predictedClassName, prediction.predictedClassName);
      expect(reconstituted.confidence, closeTo(prediction.confidence, 1e-5));
      expect(reconstituted.cropName, prediction.cropName);
      expect(reconstituted.diseaseNameEn, prediction.diseaseNameEn);
      expect(reconstituted.isHealthy, prediction.isHealthy);
      expect(reconstituted.classProbabilities.length, 4);
      expect(reconstituted.topPredictions.length, 4);
    });
  });
}
