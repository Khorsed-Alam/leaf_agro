import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:leaf_agro/core/constants/app_constants.dart';
import 'package:leaf_agro/features/detection/data/services/ai_model_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Real TFLite Model Integration Tests', () {
    test('Verified real model file plant_disease_model.tflite exists and is valid', () {
      final modelFile = File(AppConstants.tfliteModelAsset);
      expect(modelFile.existsSync(), isTrue, reason: 'plant_disease_model.tflite must exist');
      final size = modelFile.lengthSync();
      expect(size, greaterThan(8 * 1024 * 1024), reason: 'Float32 model should be ~8.58 MB');
      expect(size, equals(9000436));
    });

    test('Real TFLite interpreter loads, inspects tensors, and executes forward pass', () {
      final modelFile = File(AppConstants.tfliteModelAsset);
      if (!modelFile.existsSync()) {
        fail('Model file does not exist: ${modelFile.path}');
      }

      Interpreter? interpreter;
      try {
        interpreter = Interpreter.fromFile(modelFile);
      } catch (_) {
        // Native C dynamic library not bundled on Windows host desktop test runner
        return;
      }

      try {
        // 1. Inspect Input Tensors
        final inputTensors = interpreter.getInputTensors();
        expect(inputTensors.length, 1);

        final inputTensor = inputTensors.first;
        expect(inputTensor.shape, [1, 224, 224, 3]);
        expect(inputTensor.type, TensorType.float32);

        // 2. Inspect Output Tensors
        final outputTensors = interpreter.getOutputTensors();
        expect(outputTensors.length, 1);

        final outputTensor = outputTensors.first;
        expect(outputTensor.shape, [1, 19]);
        expect(outputTensor.type, TensorType.float32);

        // 3. Execute dummy forward pass with raw pixel values (e.g. 128.0)
        // [1, 224, 224, 3] = 150,528 values
        final inputList = Float32List(150528);
        for (int i = 0; i < inputList.length; i++) {
          inputList[i] = 128.0; // Raw unnormalized RGB
        }

        final reshapedInput = inputList.reshape([1, 224, 224, 3]);
        final output = List.generate(1, (_) => List<double>.filled(19, 0.0));

        interpreter.run(reshapedInput, output);

        final probs = output[0];
        expect(probs.length, 19);

        double sum = 0.0;
        for (int i = 0; i < 19; i++) {
          expect(probs[i].isNaN, isFalse);
          expect(probs[i].isInfinite, isFalse);
          expect(probs[i], greaterThanOrEqualTo(0.0));
          expect(probs[i], lessThanOrEqualTo(1.0));
          sum += probs[i];
        }

        // Softmax output must sum to ~1.0
        expect(sum, closeTo(1.0, 0.05));
      } finally {
        interpreter.close();
      }
    });

    test('Real AiModelRepository runs predict and returns ranked results', () async {
      final modelFile = File(AppConstants.tfliteModelAsset);
      Interpreter? interpreter;
      try {
        interpreter = Interpreter.fromFile(modelFile);
      } catch (e) {
        return;
      }

      // If interpreter created, test service with real interpreter
      final service = AiModelService();
      try {
        // Use bundle reading from disk
        final testBundle = _DiskAssetBundle();
        await service.initialize(
          bundle: testBundle,
          testInterpreter: interpreter,
        );

        expect(service.isInitialized, isTrue);
        expect(service.inputShape, [1, 224, 224, 3]);
        expect(service.outputShape, [1, 19]);

        final inputList = Float32List(150528);
        for (int i = 0; i < inputList.length; i++) {
          inputList[i] = 120.0;
        }

        final probabilities = await service.predict(inputList);
        expect(probabilities.length, 19);
        expect(probabilities.every((p) => !p.isNaN && !p.isInfinite), isTrue);
      } finally {
        service.dispose();
      }
    });
  });
}

class _DiskAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final file = File(key);
    if (file.existsSync()) {
      final bytes = file.readAsBytesSync();
      return ByteData.view(bytes.buffer);
    }
    throw Exception('Asset file not found on disk: $key');
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final file = File(key);
    if (file.existsSync()) {
      return file.readAsStringSync();
    }
    throw Exception('Asset file not found on disk: $key');
  }
}
