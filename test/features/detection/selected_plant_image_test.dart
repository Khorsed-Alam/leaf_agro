import 'package:flutter_test/flutter_test.dart';
import 'package:leaf_agro/features/detection/data/models/selected_plant_image.dart';

void main() {
  group('SelectedPlantImage Model Tests', () {
    test('Constructs model with correct fields and calculates aspect ratio', () {
      final now = DateTime.now();
      final image = SelectedPlantImage(
        imagePath: '/storage/emulated/0/DCIM/leaf_01.jpg',
        sourceType: ImageSourceType.camera,
        fileSizeBytes: 2 * 1024 * 1024, // 2MB
        width: 1920,
        height: 1080,
        mimeType: 'image/jpeg',
        selectedAt: now,
      );

      expect(image.imagePath, '/storage/emulated/0/DCIM/leaf_01.jpg');
      expect(image.sourceType, ImageSourceType.camera);
      expect(image.fileSizeBytes, 2097152);
      expect(image.width, 1920);
      expect(image.height, 1080);
      expect(image.mimeType, 'image/jpeg');
      expect(image.selectedAt, now);
      expect(image.isValid, isTrue);
      expect(image.aspectRatio, closeTo(1920 / 1080, 0.001));
      expect(image.formattedFileSize, '2.0 MB');
      expect(image.formattedResolution, '1920x1080');
      expect(image.fileName, 'leaf_01.jpg');
    });

    test('Handles Gallery source type and smaller file sizes correctly', () {
      final image = SelectedPlantImage(
        imagePath: '/downloads/tomato_leaf.png',
        sourceType: ImageSourceType.gallery,
        fileSizeBytes: 450 * 1024, // 450 KB
        width: 800,
        height: 800,
        selectedAt: DateTime.now(),
      );

      expect(image.sourceType, ImageSourceType.gallery);
      expect(image.formattedFileSize, '450.0 KB');
      expect(image.aspectRatio, 1.0);
      expect(image.mimeType, isNull);
      expect(image.isValid, isTrue);
    });

    test('isValid is false when dimensions or size are invalid', () {
      final invalidSize = SelectedPlantImage(
        imagePath: '/path/leaf.jpg',
        sourceType: ImageSourceType.camera,
        fileSizeBytes: 0,
        width: 100,
        height: 100,
        selectedAt: DateTime.now(),
      );
      expect(invalidSize.isValid, isFalse);

      final invalidDims = SelectedPlantImage(
        imagePath: '/path/leaf.jpg',
        sourceType: ImageSourceType.gallery,
        fileSizeBytes: 1000,
        width: 0,
        height: 100,
        selectedAt: DateTime.now(),
      );
      expect(invalidDims.isValid, isFalse);

      final emptyPath = SelectedPlantImage(
        imagePath: '',
        sourceType: ImageSourceType.camera,
        fileSizeBytes: 1000,
        width: 100,
        height: 100,
        selectedAt: DateTime.now(),
      );
      expect(emptyPath.isValid, isFalse);
    });

    test('toJson and fromJson serialize and deserialize symmetrically', () {
      final now = DateTime(2026, 11, 13, 20, 0, 0);
      final original = SelectedPlantImage(
        imagePath: '/test/image.webp',
        sourceType: ImageSourceType.gallery,
        fileSizeBytes: 150000,
        width: 1200,
        height: 900,
        mimeType: 'image/webp',
        selectedAt: now,
      );

      final jsonMap = original.toJson();
      final recreated = SelectedPlantImage.fromJson(jsonMap);

      expect(recreated.imagePath, original.imagePath);
      expect(recreated.sourceType, original.sourceType);
      expect(recreated.fileSizeBytes, original.fileSizeBytes);
      expect(recreated.width, original.width);
      expect(recreated.height, original.height);
      expect(recreated.mimeType, original.mimeType);
      expect(recreated.selectedAt, original.selectedAt);
    });

    test('copyWith updates specified fields only', () {
      final image = SelectedPlantImage(
        imagePath: '/old/path.jpg',
        sourceType: ImageSourceType.camera,
        fileSizeBytes: 1000,
        width: 640,
        height: 480,
        selectedAt: DateTime.now(),
      );

      final updated = image.copyWith(imagePath: '/new/path.jpg', width: 1280);
      expect(updated.imagePath, '/new/path.jpg');
      expect(updated.width, 1280);
      expect(updated.height, 480);
      expect(updated.sourceType, ImageSourceType.camera);
    });
  });
}
