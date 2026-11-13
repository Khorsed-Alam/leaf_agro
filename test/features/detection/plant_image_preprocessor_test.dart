import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:leaf_agro/core/errors/ai_model_exception.dart';
import 'package:leaf_agro/features/detection/data/services/plant_image_preprocessor.dart';

void main() {
  group('PlantImagePreprocessor Tests', () {
    late PlantImagePreprocessor preprocessor;

    setUp(() {
      preprocessor = PlantImagePreprocessor();
    });

    test('preprocesses a valid RGB image to exact 224x224x3 Float32 tensor', () {
      final source = img.Image(width: 320, height: 240);
      // Fill with sample color RGB(100, 150, 200)
      for (int y = 0; y < source.height; y++) {
        for (int x = 0; x < source.width; x++) {
          source.setPixelRgb(x, y, 100, 150, 200);
        }
      }
      final bytes = Uint8List.fromList(img.encodeJpg(source));

      final result = preprocessor.preprocessBytes(bytes);

      expect(result.width, 224);
      expect(result.height, 224);
      expect(result.channels, 3);
      expect(result.originalWidth, 320);
      expect(result.originalHeight, 240);
      expect(result.tensor.length, 150528);

      // Verify pixel values match expectations (close to 100, 150, 200)
      for (int i = 0; i < 30; i += 3) {
        expect(result.tensor[i], closeTo(100.0, 10.0));
        expect(result.tensor[i + 1], closeTo(150.0, 10.0));
        expect(result.tensor[i + 2], closeTo(200.0, 10.0));
      }

      // Check tensor bounds
      for (int i = 0; i < result.tensor.length; i++) {
        final val = result.tensor[i];
        expect(val.isNaN, isFalse);
        expect(val.isInfinite, isFalse);
        expect(val >= 0.0 && val <= 255.0, isTrue);
      }
    });

    test('composites transparent RGBA pixels onto pure white background', () {
      final transparent = img.Image(width: 100, height: 100, numChannels: 4);
      // Half transparent black: R=0, G=0, B=0, A=128 (~50% alpha)
      for (int y = 0; y < 100; y++) {
        for (int x = 0; x < 100; x++) {
          transparent.setPixelRgba(x, y, 0, 0, 0, 128);
        }
      }
      final bytes = Uint8List.fromList(img.encodePng(transparent));

      final result = preprocessor.preprocessBytes(bytes);

      expect(result.tensor.length, 150528);
      // Over white, 50% black becomes ~127.5
      expect(result.tensor[0], closeTo(127.5, 5.0));
      expect(result.tensor[1], closeTo(127.5, 5.0));
      expect(result.tensor[2], closeTo(127.5, 5.0));
    });

    test('throws ImagePreprocessingException on empty bytes', () {
      expect(
        () => preprocessor.preprocessBytes(Uint8List(0)),
        throwsA(isA<ImagePreprocessingException>()),
      );
    });

    test('throws ImagePreprocessingException on corrupt image bytes', () {
      final garbage = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
      expect(
        () => preprocessor.preprocessBytes(garbage),
        throwsA(isA<ImagePreprocessingException>()),
      );
    });

    test('throws ImagePreprocessingException when file does not exist', () async {
      await expectLater(
        () => preprocessor.preprocessFile('/non/existent/path/image.jpg'),
        throwsA(isA<ImagePreprocessingException>()),
      );
    });

    test('faithfully records decoding and preprocessing durations', () {
      final testImg = img.Image(width: 150, height: 150);
      final bytes = Uint8List.fromList(img.encodeJpg(testImg));

      final result = preprocessor.preprocessBytes(bytes);

      expect(result.decodingDuration.inMicroseconds, greaterThanOrEqualTo(0));
      expect(result.preprocessingDuration.inMicroseconds, greaterThanOrEqualTo(0));
      expect(result.totalDuration.inMicroseconds, greaterThanOrEqualTo(0));
    });
  });
}
