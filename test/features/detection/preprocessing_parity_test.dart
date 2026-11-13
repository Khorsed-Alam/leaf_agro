import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:leaf_agro/features/detection/data/services/plant_image_preprocessor.dart';

void main() {
  group('Phase 43 — Python vs Flutter Preprocessing Parity Verification', () {
    late PlantImagePreprocessor preprocessor;
    late File referenceImageFile;
    late File pythonTensorBinFile;
    late File manifestFile;

    setUp(() {
      preprocessor = PlantImagePreprocessor();
      referenceImageFile = File('test/fixtures/reference_leaf.jpg');
      pythonTensorBinFile = File('test/fixtures/python_tensor_150528_f32.bin');
      manifestFile = File('test/fixtures/reference_preprocessing_manifest.json');
    });

    test('verifies test fixtures exist from Phase 34 Python export', () {
      expect(referenceImageFile.existsSync(), isTrue,
          reason: 'Missing test/fixtures/reference_leaf.jpg');
      expect(pythonTensorBinFile.existsSync(), isTrue,
          reason: 'Missing test/fixtures/python_tensor_150528_f32.bin');
      expect(manifestFile.existsSync(), isTrue,
          reason: 'Missing test/fixtures/reference_preprocessing_manifest.json');
    });

    test('numerically audits Python vs Dart preprocessing tensor parity', () async {
      // 1. Read Python reference manifest
      final manifestJson = json.decode(manifestFile.readAsStringSync()) as Map<String, dynamic>;
      final int expectedLength = manifestJson['tensor_length'] as int;
      final int pyTopClassIdx = manifestJson['top_class_index'] as int;
      final String pyTopClassName = manifestJson['top_class_name'] as String;

      // 2. Read Python reference tensor bytes (150,528 floats = 602,112 bytes)
      final pyBytes = pythonTensorBinFile.readAsBytesSync();
      expect(pyBytes.length, expectedLength * 4,
          reason: 'Python binary tensor size mismatch');
      final pyFloats = pyBytes.buffer.asFloat32List();

      // 3. Run Dart/Flutter PlantImagePreprocessor on the exact same image
      final dartResult = await preprocessor.preprocessFile(referenceImageFile.path);

      expect(dartResult.width, 224);
      expect(dartResult.height, 224);
      expect(dartResult.channels, 3);
      expect(dartResult.tensor.length, expectedLength);

      final dartFloats = dartResult.tensor;

      // 4. Calculate numerical difference metrics
      double maxAbsDiff = 0.0;
      double sumAbsDiff = 0.0;
      int diffWithin2 = 0;
      int diffWithin5 = 0;
      int diffWithin10 = 0;

      for (int i = 0; i < expectedLength; i++) {
        final pyVal = pyFloats[i];
        final dartVal = dartFloats[i];
        final diff = (pyVal - dartVal).abs();

        if (diff > maxAbsDiff) {
          maxAbsDiff = diff;
        }
        sumAbsDiff += diff;

        if (diff <= 2.0) diffWithin2++;
        if (diff <= 5.0) diffWithin5++;
        if (diff <= 10.0) diffWithin10++;
      }

      final double meanAbsDiff = sumAbsDiff / expectedLength;
      final double pctWithin2 = (diffWithin2 / expectedLength) * 100.0;
      final double pctWithin5 = (diffWithin5 / expectedLength) * 100.0;
      final double pctWithin10 = (diffWithin10 / expectedLength) * 100.0;

      // Print comprehensive verification report
      // ignore: avoid_print
      print('\n============================================================');
      // ignore: avoid_print
      print('PHASE 43 PREPROCESSING PARITY VERIFICATION REPORT');
      // ignore: avoid_print
      print('============================================================');
      // ignore: avoid_print
      print('Reference Image: ${manifestJson['source_image']}');
      // ignore: avoid_print
      print('Target Dimensions: 224 x 224 x 3 ($expectedLength elements)');
      // ignore: avoid_print
      print('Python Reference Top Class: #$pyTopClassIdx ($pyTopClassName)');
      // ignore: avoid_print
      print('Dart Decoding Duration: ${dartResult.decodingDuration.inMilliseconds} ms');
      // ignore: avoid_print
      print('Dart Preprocessing Duration: ${dartResult.preprocessingDuration.inMilliseconds} ms');
      // ignore: avoid_print
      print('Maximum Absolute Difference: ${maxAbsDiff.toStringAsFixed(4)} / 255.0');
      // ignore: avoid_print
      print('Mean Absolute Difference: ${meanAbsDiff.toStringAsFixed(4)} / 255.0');
      // ignore: avoid_print
      print('Elements within +/-2.0 levels: $diffWithin2 / $expectedLength (${pctWithin2.toStringAsFixed(2)}%)');
      // ignore: avoid_print
      print('Elements within +/-5.0 levels: $diffWithin5 / $expectedLength (${pctWithin5.toStringAsFixed(2)}%)');
      // ignore: avoid_print
      print('Elements within +/-10.0 levels: $diffWithin10 / $expectedLength (${pctWithin10.toStringAsFixed(2)}%)');
      // ignore: avoid_print
      print('============================================================\n');

      // Assertions:
      // In digital image processing, bilinear resamplers between different libraries (PIL C backend vs Dart package:image)
      // differ by subpixel coordinate offsets and float rounding, but the mean absolute error is minimal (< 4.0 out of 255)
      expect(meanAbsDiff, lessThan(4.0),
          reason: 'Mean absolute difference between Python and Flutter preprocessing must be under 4.0 / 255.0');
      expect(pctWithin5, greaterThan(80.0),
          reason: 'At least 80% of pixel channels should be within 5.0 intensity levels');
    });
  });
}
