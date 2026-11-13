import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:leaf_agro/features/detection/data/services/image_validation_service.dart';

void main() {
  group('ImageValidationService Unit Tests', () {
    late ImageValidationService validator;
    late Directory tempDir;

    setUp(() {
      validator = const ImageValidationService(
        maxFileSizeBytes: 5 * 1024 * 1024, // 5MB for tests
        minFileSizeBytes: 50,
        minDimension: 64,
        maxDimension: 4096,
      );
      tempDir = Directory.systemTemp.createTempSync('image_val_test_');
    });

    tearDown(() {
      try {
        tempDir.deleteSync(recursive: true);
      } catch (_) {}
    });

    test('Validates a genuine decoded PNG image successfully', () async {
      // Create a valid 200x200 PNG image
      final testImage = img.Image(width: 200, height: 200);
      img.fill(testImage, color: img.ColorRgb8(35, 122, 69)); // Forest green
      final pngBytes = Uint8List.fromList(img.encodePng(testImage));

      final testFile = File('${tempDir.path}/valid_leaf.png');
      testFile.writeAsBytesSync(pngBytes);

      final result = await validator.validate(testFile.path);

      expect(result.isValid, isTrue);
      expect(result.width, 200);
      expect(result.height, 200);
      expect(result.fileSizeBytes, greaterThan(0));
      expect(result.mimeType, 'image/png');
      expect(result.errorCode, isNull);
    });

    test('Rejects non-existent image file with FILE_NOT_FOUND', () async {
      final result = await validator.validate('${tempDir.path}/does_not_exist.jpg');

      expect(result.isValid, isFalse);
      expect(result.errorCode, 'FILE_NOT_FOUND');
      expect(result.errorMessageEn, contains('does not exist'));
      expect(result.errorMessageBn, contains('খুঁজে পাওয়া যায়নি'));
    });

    test('Rejects empty path with EMPTY_PATH', () async {
      final result = await validator.validate('   ');

      expect(result.isValid, isFalse);
      expect(result.errorCode, 'EMPTY_PATH');
    });

    test('Rejects unsupported file format with UNSUPPORTED_FORMAT', () async {
      final testFile = File('${tempDir.path}/document.pdf');
      testFile.writeAsBytesSync([1, 2, 3, 4]);

      final result = await validator.validate(testFile.path);

      expect(result.isValid, isFalse);
      expect(result.errorCode, 'UNSUPPORTED_FORMAT');
      expect(result.errorMessageEn, contains('Unsupported image format'));
    });

    test('Rejects 0-byte empty file with EMPTY_FILE', () async {
      final testFile = File('${tempDir.path}/empty_leaf.jpg');
      testFile.writeAsBytesSync([]);

      final result = await validator.validate(testFile.path);

      expect(result.isValid, isFalse);
      expect(result.errorCode, 'EMPTY_FILE');
    });

    test('Rejects file smaller than minFileSizeBytes with FILE_TOO_SMALL', () async {
      final testFile = File('${tempDir.path}/tiny.jpg');
      testFile.writeAsBytesSync(List.filled(20, 0)); // 20 bytes < 50 min

      final result = await validator.validate(testFile.path);

      expect(result.isValid, isFalse);
      expect(result.errorCode, 'FILE_TOO_SMALL');
    });

    test('Rejects file exceeding maxFileSizeBytes with FILE_TOO_LARGE', () async {
      const smallValidator = ImageValidationService(maxFileSizeBytes: 1024);
      final testFile = File('${tempDir.path}/large.jpg');
      testFile.writeAsBytesSync(List.filled(2048, 1)); // 2KB > 1KB limit

      final result = await smallValidator.validate(testFile.path);

      expect(result.isValid, isFalse);
      expect(result.errorCode, 'FILE_TOO_LARGE');
    });

    test('Rejects corrupted bytes that fail decoding with DECODE_FAILURE', () async {
      final testFile = File('${tempDir.path}/corrupted.jpg');
      // Valid extension, valid size, but random bytes that do not decode
      testFile.writeAsBytesSync(List.generate(500, (i) => (i * 37) % 256));

      final result = await validator.validate(testFile.path);

      expect(result.isValid, isFalse);
      expect(result.errorCode, 'DECODE_FAILURE');
      expect(result.errorMessageEn, contains('could not be decoded'));
    });

    test('Rejects image with dimensions below minDimension with DIMENSIONS_TOO_SMALL', () async {
      // 32x32 image is below minDimension of 64
      final tinyImg = img.Image(width: 32, height: 32);
      final pngBytes = Uint8List.fromList(img.encodePng(tinyImg));

      final testFile = File('${tempDir.path}/too_small.png');
      testFile.writeAsBytesSync(pngBytes);

      final result = await validator.validate(testFile.path);

      expect(result.isValid, isFalse);
      expect(result.errorCode, 'DIMENSIONS_TOO_SMALL');
      expect(result.errorMessageEn, contains('32x32'));
    });
  });
}
