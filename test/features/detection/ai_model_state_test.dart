import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:leaf_agro/features/detection/data/models/ai_model_metadata.dart';
import 'package:leaf_agro/features/detection/data/models/disease_label.dart';
import 'package:leaf_agro/features/detection/presentation/providers/ai_model_state.dart';

void main() {
  group('AiModelState Tests', () {
    late AiModelMetadata testMetadata;
    late DiseaseLabels testLabels;

    setUp(() {
      final metaFile = File('assets/models/model_metadata.json');
      testMetadata = AiModelMetadata.fromJson(
        json.decode(metaFile.readAsStringSync()) as Map<String, dynamic>,
      );

      final labelsFile = File('assets/models/labels.json');
      testLabels = DiseaseLabels.fromJson(
        json.decode(labelsFile.readAsStringSync()) as Map<String, dynamic>,
      );
    });

    test('Initial state properties are correct', () {
      final state = AiModelState.initial();
      expect(state.status, AiModelStatus.initial);
      expect(state.isReady, isFalse);
      expect(state.isLoading, isFalse);
      expect(state.hasError, isFalse);
      expect(state.classCount, 0);
      expect(state.metadata, isNull);
      expect(state.labels, isNull);
    });

    test('Loading state properties are correct', () {
      final state = AiModelState.loading();
      expect(state.status, AiModelStatus.loading);
      expect(state.isReady, isFalse);
      expect(state.isLoading, isTrue);
      expect(state.hasError, isFalse);
    });

    test('Ready state properties and getters reflect metadata and labels', () {
      final state = AiModelState.ready(
        metadata: testMetadata,
        labels: testLabels,
        inputShape: [1, 224, 224, 3],
        outputShape: [1, 19],
      );

      expect(state.status, AiModelStatus.ready);
      expect(state.isReady, isTrue);
      expect(state.isLoading, isFalse);
      expect(state.hasError, isFalse);
      expect(state.classCount, 19);
      expect(state.architecture, 'MobileNetV2');
      expect(state.modelName, 'AgriCare AI Leaf Disease Detector');
      expect(state.resolutionDescription, '224x224 RGB');
      expect(state.inputShape, [1, 224, 224, 3]);
      expect(state.outputShape, [1, 19]);
      expect(state.initializedAt, isNotNull);
    });

    test('Error state properties and diagnostics are preserved', () {
      final state = AiModelState.error(
        message: 'Failed to load model asset',
        technicalDetails: 'File not found: assets/models/plant_disease_model.tflite',
      );

      expect(state.status, AiModelStatus.error);
      expect(state.isReady, isFalse);
      expect(state.isLoading, isFalse);
      expect(state.hasError, isTrue);
      expect(state.errorMessage, 'Failed to load model asset');
      expect(state.technicalDetails, contains('assets/models/plant_disease_model.tflite'));
    });

    test('copyWith works accurately', () {
      final state = AiModelState.initial();
      final updated = state.copyWith(status: AiModelStatus.loading);
      expect(updated.status, AiModelStatus.loading);
      expect(updated.isReady, isFalse);
      expect(updated.isLoading, isTrue);
    });
  });
}
