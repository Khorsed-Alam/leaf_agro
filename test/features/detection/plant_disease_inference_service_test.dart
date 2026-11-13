import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:leaf_agro/core/errors/ai_model_exception.dart';
import 'package:leaf_agro/features/detection/data/models/ai_model_metadata.dart';
import 'package:leaf_agro/features/detection/data/models/disease_label.dart';
import 'package:leaf_agro/features/detection/data/models/selected_plant_image.dart';
import 'package:leaf_agro/features/detection/data/services/ai_model_service.dart';
import 'package:leaf_agro/features/detection/data/services/plant_disease_inference_service.dart';
import 'package:leaf_agro/features/detection/data/services/plant_image_preprocessor.dart';

class MockAiModelService extends AiModelService {
  bool _mockIsInitialized = false;
  DiseaseLabels? _mockLabels;
  AiModelMetadata? _mockMetadata;
  List<double>? customProbabilities;
  Duration simulatedDelay = Duration.zero;

  @override
  bool get isInitialized => _mockIsInitialized;

  @override
  DiseaseLabels? get labels => _mockLabels;

  @override
  AiModelMetadata? get metadata => _mockMetadata;

  void setup({
    required DiseaseLabels labels,
    required AiModelMetadata metadata,
  }) {
    _mockLabels = labels;
    _mockMetadata = metadata;
    _mockIsInitialized = true;
  }

  @override
  Future<void> initialize({
    String? modelAsset,
    String? labelsAsset,
    String? metadataAsset,
    dynamic bundle,
    dynamic testInterpreter,
  }) async {
    _mockIsInitialized = true;
  }

  @override
  Future<List<double>> predict(Float32List input) async {
    if (simulatedDelay > Duration.zero) {
      await Future.delayed(simulatedDelay);
    }
    return customProbabilities ??
        [
          0.05, 0.05, 0.80, 0.10, // Class 2 wins
        ];
  }
}

void main() {
  group('PlantDiseaseInferenceService Tests', () {
    late MockAiModelService mockAiService;
    late PlantImagePreprocessor preprocessor;
    late PlantDiseaseInferenceService inferenceService;
    late String tempImagePath;

    setUp(() async {
      mockAiService = MockAiModelService();
      preprocessor = PlantImagePreprocessor();
      inferenceService = PlantDiseaseInferenceService(
        aiModelService: mockAiService,
        preprocessor: preprocessor,
      );

      final labelsJson = {
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

      final metadataJson = {
        'model_name': 'AgriCare AI MobileNetV2',
        'model_version': '1.0.0',
        'architecture': 'MobileNetV2',
        'input_width': 224,
        'input_height': 224,
        'input_channels': 3,
        'input_dtype': 'float32',
        'num_classes': 4,
        'output_shape': [1, 4],
      };

      mockAiService.setup(
        labels: DiseaseLabels.fromJson(labelsJson),
        metadata: AiModelMetadata.fromJson(metadataJson),
      );

      // Create a temporary valid image file
      final testImage = img.Image(width: 120, height: 120);
      for (int y = 0; y < 120; y++) {
        for (int x = 0; x < 120; x++) {
          testImage.setPixelRgb(x, y, 60, 140, 70);
        }
      }
      final tempFile = File('${Directory.systemTemp.path}/test_leaf_${DateTime.now().microsecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(img.encodeJpg(testImage));
      tempImagePath = tempFile.path;
    });

    tearDown(() async {
      try {
        final f = File(tempImagePath);
        if (await f.exists()) await f.delete();
      } catch (_) {}
    });

    test('executes end-to-end inference and returns structured PlantDiseasePrediction', () async {
      final selectedImage = SelectedPlantImage(
        imagePath: tempImagePath,
        sourceType: ImageSourceType.camera,
        fileSizeBytes: 1024,
        width: 120,
        height: 120,
        selectedAt: DateTime.now(),
      );

      final prediction = await inferenceService.predict(selectedImage);

      expect(prediction.predictedClassIndex, 2);
      expect(prediction.predictedClassName, 'Potato___healthy');
      expect(prediction.confidence, 0.80);
      expect(prediction.isHealthy, isTrue);
      expect(prediction.classProbabilities.length, 4);
      expect(prediction.modelVersion, '1.0.0');
      expect(prediction.imagePath, tempImagePath);
      expect(prediction.inferenceDuration.inMicroseconds, greaterThanOrEqualTo(0));
      expect(prediction.preprocessingDuration.inMicroseconds, greaterThanOrEqualTo(0));
      expect(prediction.totalPredictionDuration.inMicroseconds, greaterThanOrEqualTo(0));
    });

    test('throws ImagePreprocessingException if image file does not exist', () async {
      expect(
        () => inferenceService.predictFromFile('/invalid/path/leaf.jpg'),
        throwsA(isA<ImagePreprocessingException>()),
      );
    });

    test('blocks concurrent inference execution with InferenceException', () async {
      mockAiService.simulatedDelay = const Duration(milliseconds: 100);

      final future1 = inferenceService.predictFromFile(tempImagePath);
      await expectLater(
        inferenceService.predictFromFile(tempImagePath),
        throwsA(isA<InferenceException>()),
      );

      await future1;
    });
  });
}
