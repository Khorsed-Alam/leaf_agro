import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:leaf_agro/core/errors/ai_model_exception.dart';
import 'package:leaf_agro/features/detection/data/models/ai_model_metadata.dart';
import 'package:leaf_agro/features/detection/data/models/disease_label.dart';
import 'package:leaf_agro/features/detection/data/models/selected_plant_image.dart';
import 'package:leaf_agro/features/detection/data/services/ai_model_service.dart';
import 'package:leaf_agro/features/detection/presentation/providers/ai_model_provider.dart';
import 'package:leaf_agro/features/detection/presentation/providers/plant_disease_prediction_provider.dart';
import 'package:leaf_agro/features/detection/presentation/providers/selected_image_provider.dart';
import 'package:leaf_agro/providers/detection_provider.dart';

class FakeAiModelService extends AiModelService {
  bool shouldFail = false;

  @override
  bool get isInitialized => true;

  @override
  DiseaseLabels? get labels => DiseaseLabels.fromJson({
        'num_classes': 2,
        'class_names': ['Potato___healthy', 'Tomato___healthy'],
        'class_indices': {'Potato___healthy': 0, 'Tomato___healthy': 1},
        'supported_crops': ['Potato', 'Tomato'],
      });

  @override
  AiModelMetadata? get metadata => AiModelMetadata.fromJson({
        'model_name': 'AgriCare MobileNetV2',
        'model_version': '1.0.0',
        'architecture': 'MobileNetV2',
        'input_width': 224,
        'input_height': 224,
        'input_channels': 3,
        'num_classes': 2,
        'output_shape': [1, 2],
      });

  @override
  Future<void> initialize({
    String? modelAsset,
    String? labelsAsset,
    String? metadataAsset,
    dynamic bundle,
    dynamic testInterpreter,
  }) async {}

  @override
  Future<List<double>> predict(dynamic input) async {
    if (shouldFail) {
      throw InferenceException('Simulated native interpreter crash');
    }
    return [0.92, 0.08];
  }
}

void main() {
  group('PlantDiseasePredictionProvider Tests', () {
    late FakeAiModelService fakeAiService;
    late ProviderContainer container;
    late String tempImagePath;

    setUp(() async {
      fakeAiService = FakeAiModelService();

      container = ProviderContainer(
        overrides: [
          aiModelServiceProvider.overrideWithValue(fakeAiService),
        ],
      );

      final testImage = img.Image(width: 80, height: 80);
      final tempFile = File('${Directory.systemTemp.path}/leaf_${DateTime.now().microsecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(img.encodeJpg(testImage));
      tempImagePath = tempFile.path;
    });

    tearDown(() async {
      container.dispose();
      try {
        final f = File(tempImagePath);
        if (await f.exists()) await f.delete();
      } catch (_) {}
    });

    test('initial state is idle', () {
      final state = container.read(plantDiseasePredictionProvider);
      expect(state.status, PlantDiseasePredictionStatus.idle);
      expect(state.prediction, isNull);
      expect(state.hasError, isFalse);
    });

    test('transitions through states to success on valid selected image', () async {
      final selectedImage = SelectedPlantImage(
        imagePath: tempImagePath,
        sourceType: ImageSourceType.camera,
        fileSizeBytes: 512,
        width: 80,
        height: 80,
        selectedAt: DateTime.now(),
      );

      container.read(selectedImageProvider.notifier).setExplicitImage(selectedImage);

      final notifier = container.read(plantDiseasePredictionProvider.notifier);
      await notifier.runInference();

      final finalState = container.read(plantDiseasePredictionProvider);
      expect(finalState.status, PlantDiseasePredictionStatus.success);
      expect(finalState.isSuccess, isTrue);
      expect(finalState.prediction, isNotNull);
      expect(finalState.prediction!.predictedClassIndex, 0);
      expect(finalState.prediction!.predictedClassName, 'Potato___healthy');
      expect(finalState.prediction!.confidence, 0.92);

      // Downstream detectionProvider is synced
      final legacyState = container.read(detectionProvider);
      expect(legacyState.status, DetectionStatus.success);
      expect(legacyState.prediction?.className, 'Potato___healthy');
    });

    test('sets error state when no image is selected', () async {
      final notifier = container.read(plantDiseasePredictionProvider.notifier);
      await notifier.runInference();

      final state = container.read(plantDiseasePredictionProvider);
      expect(state.status, PlantDiseasePredictionStatus.error);
      expect(state.hasError, isTrue);
      expect(state.errorMessageEn, contains('No leaf image found'));
    });

    test('sets error state when inference fails', () async {
      fakeAiService.shouldFail = true;

      final selectedImage = SelectedPlantImage(
        imagePath: tempImagePath,
        sourceType: ImageSourceType.gallery,
        fileSizeBytes: 512,
        width: 80,
        height: 80,
        selectedAt: DateTime.now(),
      );
      container.read(selectedImageProvider.notifier).setExplicitImage(selectedImage);

      final notifier = container.read(plantDiseasePredictionProvider.notifier);
      await notifier.runInference();

      final state = container.read(plantDiseasePredictionProvider);
      expect(state.status, PlantDiseasePredictionStatus.error);
      expect(state.hasError, isTrue);
      expect(state.errorMessageEn, contains('Inference failed'));
    });

    test('reset() restores idle state', () async {
      final selectedImage = SelectedPlantImage(
        imagePath: tempImagePath,
        sourceType: ImageSourceType.camera,
        fileSizeBytes: 512,
        width: 80,
        height: 80,
        selectedAt: DateTime.now(),
      );
      container.read(selectedImageProvider.notifier).setExplicitImage(selectedImage);
      await container.read(plantDiseasePredictionProvider.notifier).runInference();

      expect(container.read(plantDiseasePredictionProvider).isSuccess, isTrue);

      container.read(plantDiseasePredictionProvider.notifier).reset();
      expect(container.read(plantDiseasePredictionProvider).status, PlantDiseasePredictionStatus.idle);
      expect(container.read(plantDiseasePredictionProvider).prediction, isNull);
    });

    test('retry() executes inference again', () async {
      fakeAiService.shouldFail = true;
      final selectedImage = SelectedPlantImage(
        imagePath: tempImagePath,
        sourceType: ImageSourceType.camera,
        fileSizeBytes: 512,
        width: 80,
        height: 80,
        selectedAt: DateTime.now(),
      );
      container.read(selectedImageProvider.notifier).setExplicitImage(selectedImage);
      await container.read(plantDiseasePredictionProvider.notifier).runInference();
      expect(container.read(plantDiseasePredictionProvider).hasError, isTrue);

      // Now fix and retry
      fakeAiService.shouldFail = false;
      await container.read(plantDiseasePredictionProvider.notifier).retry();
      expect(container.read(plantDiseasePredictionProvider).isSuccess, isTrue);
    });
  });
}
