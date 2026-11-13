import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:leaf_agro/core/errors/ai_model_exception.dart';
import 'package:leaf_agro/features/detection/data/models/ai_model_metadata.dart';

void main() {
  group('AiModelMetadata Tests', () {
    test('Correctly parses authentic model_metadata.json from assets', () {
      final file = File('assets/models/model_metadata.json');
      expect(file.existsSync(), isTrue, reason: 'assets/models/model_metadata.json must exist');

      final jsonContent = json.decode(file.readAsStringSync()) as Map<String, dynamic>;
      final metadata = AiModelMetadata.fromJson(jsonContent);

      expect(metadata.modelName, 'AgriCare AI Leaf Disease Detector');
      expect(metadata.modelVersion, '1.0.0');
      expect(metadata.architecture, 'MobileNetV2');
      expect(metadata.inputWidth, 224);
      expect(metadata.inputHeight, 224);
      expect(metadata.inputChannels, 3);
      expect(metadata.colorFormat, 'RGB');
      expect(metadata.inputDtype, 'float32');
      expect(metadata.inputPixelRange, [0.0, 255.0]);
      expect(metadata.inputNormalization, 'mobilenet_v2_internal_rescaling');
      expect(metadata.outputShape, [1, 19]);
      expect(metadata.outputDtype, 'float32');
      expect(metadata.outputActivation, 'softmax');
      expect(metadata.numClasses, 19);
      expect(metadata.primaryTfliteModel, 'plant_disease_model.tflite');
      expect(metadata.labelsFile, 'labels.json');
      expect(metadata.expectedInputElements, 150528);
      expect(metadata.bestValidationLoss, closeTo(0.8588, 0.0001));
      expect(metadata.bestValidationAccuracy, closeTo(0.8571, 0.0001));

      // Test validate passes
      expect(() => metadata.validate(), returnsNormally);
    });

    test('Throws InvalidMetadataException when model_name is missing or empty', () {
      final map = {
        'model_name': '',
        'model_version': '1.0.0',
        'architecture': 'MobileNetV2',
        'input_width': 224,
        'input_height': 224,
        'input_channels': 3,
        'num_classes': 19,
        'output_shape': [1, 19],
      };
      expect(() => AiModelMetadata.fromJson(map), throwsA(isA<InvalidMetadataException>()));
    });

    test('Throws InvalidMetadataException when input dimensions are non-positive', () {
      final map = {
        'model_name': 'Test Model',
        'model_version': '1.0.0',
        'architecture': 'MobileNetV2',
        'input_width': -1,
        'input_height': 224,
        'input_channels': 3,
        'num_classes': 19,
        'output_shape': [1, 19],
      };
      expect(() => AiModelMetadata.fromJson(map), throwsA(isA<InvalidMetadataException>()));
    });

    test('Throws InvalidMetadataException when num_classes does not match output_shape', () {
      final map = {
        'model_name': 'Test Model',
        'model_version': '1.0.0',
        'architecture': 'MobileNetV2',
        'input_width': 224,
        'input_height': 224,
        'input_channels': 3,
        'num_classes': 19,
        'output_shape': [1, 10], // mismatch with 19
      };
      final metadata = AiModelMetadata.fromJson(map);
      expect(() => metadata.validate(), throwsA(isA<InvalidMetadataException>()));
    });

    test('toJson produces valid map matching parsed fields', () {
      final file = File('assets/models/model_metadata.json');
      final jsonContent = json.decode(file.readAsStringSync()) as Map<String, dynamic>;
      final metadata = AiModelMetadata.fromJson(jsonContent);

      final outJson = metadata.toJson();
      expect(outJson['model_name'], metadata.modelName);
      expect(outJson['input_width'], 224);
      expect(outJson['num_classes'], 19);
      expect(outJson['output_shape'], [1, 19]);
    });
  });
}
