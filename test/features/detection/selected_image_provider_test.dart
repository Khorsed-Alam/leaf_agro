import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leaf_agro/features/detection/data/models/picker_result.dart';
import 'package:leaf_agro/features/detection/data/models/selected_plant_image.dart';
import 'package:leaf_agro/features/detection/data/services/plant_image_picker_service.dart';
import 'package:leaf_agro/features/detection/presentation/providers/selected_image_provider.dart';
import 'package:leaf_agro/providers/detection_provider.dart';

class StubPlantImagePickerService implements PlantImagePickerService {
  PickerResult cameraResult = PickerResult.cancelled();
  PickerResult galleryResult = PickerResult.cancelled();
  PickerResult? lostDataResult;

  int cameraCalls = 0;
  int galleryCalls = 0;

  @override
  Future<PickerResult> captureFromCamera({
    CameraDevice preferredCamera = CameraDevice.rear,
    int imageQuality = 95,
  }) async {
    cameraCalls++;
    return cameraResult;
  }

  @override
  Future<PickerResult> pickFromGallery({int imageQuality = 95}) async {
    galleryCalls++;
    return galleryResult;
  }

  @override
  Future<PickerResult?> retrieveLostData() async {
    return lostDataResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('SelectedImageNotifier & selectedImageProvider Tests', () {
    late StubPlantImagePickerService stubPicker;
    late ProviderContainer container;

    final sampleImage = SelectedPlantImage(
      imagePath: '/mock/valid_leaf.jpg',
      sourceType: ImageSourceType.camera,
      fileSizeBytes: 1048576,
      width: 1920,
      height: 1080,
      selectedAt: DateTime.now(),
    );

    setUp(() {
      stubPicker = StubPlantImagePickerService();
      container = ProviderContainer(
        overrides: [
          plantImagePickerServiceProvider.overrideWithValue(stubPicker),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial state is unselected and not loading', () {
      final state = container.read(selectedImageProvider);
      expect(state.status, SelectedImageStatus.initial);
      expect(state.hasImage, isFalse);
      expect(state.isLoading, isFalse);
      expect(state.hasError, isFalse);
      expect(state.selectedImage, isNull);
    });

    test('captureImage sets selected state and synchronizes detectionProvider on success', () async {
      stubPicker.cameraResult = PickerResult.success(sampleImage);

      final notifier = container.read(selectedImageProvider.notifier);
      await notifier.captureImage();

      final state = container.read(selectedImageProvider);
      expect(state.status, SelectedImageStatus.selected);
      expect(state.hasImage, isTrue);
      expect(state.selectedImage, sampleImage);
      expect(state.hasError, isFalse);

      // Verify sync with existing detectionProvider
      expect(container.read(detectionProvider).imagePath, sampleImage.imagePath);
    });

    test('selectFromGallery sets selected state on success', () async {
      final galleryImage = sampleImage.copyWith(
        imagePath: '/mock/gallery.png',
        sourceType: ImageSourceType.gallery,
      );
      stubPicker.galleryResult = PickerResult.success(galleryImage);

      final notifier = container.read(selectedImageProvider.notifier);
      await notifier.selectFromGallery();

      final state = container.read(selectedImageProvider);
      expect(state.status, SelectedImageStatus.selected);
      expect(state.selectedImage!.sourceType, ImageSourceType.gallery);
      expect(state.selectedImage!.imagePath, '/mock/gallery.png');
    });

    test('Cancellation preserves previously selected image', () async {
      // 1. Initial successful capture
      stubPicker.cameraResult = PickerResult.success(sampleImage);
      final notifier = container.read(selectedImageProvider.notifier);
      await notifier.captureImage();
      expect(container.read(selectedImageProvider).hasImage, isTrue);

      // 2. Subsequent cancelled gallery pick
      stubPicker.galleryResult = PickerResult.cancelled();
      await notifier.selectFromGallery();

      final state = container.read(selectedImageProvider);
      expect(state.hasImage, isTrue, reason: 'Previous image must be preserved');
      expect(state.status, SelectedImageStatus.selected);
      expect(state.selectedImage, sampleImage);
    });

    test('Failure preserves previously selected image and sets error details', () async {
      // 1. Initial success
      stubPicker.cameraResult = PickerResult.success(sampleImage);
      final notifier = container.read(selectedImageProvider.notifier);
      await notifier.captureImage();

      // 2. Subsequent failed pick
      stubPicker.galleryResult = PickerResult.failure(
        messageEn: 'Corrupted image file',
        messageBn: 'ক্ষতিগ্রস্ত ছবি',
        errorCode: 'DECODE_FAILURE',
      );
      await notifier.selectFromGallery();

      final state = container.read(selectedImageProvider);
      expect(state.hasError, isTrue);
      expect(state.errorCode, 'DECODE_FAILURE');
      expect(state.errorMessageEn, 'Corrupted image file');
      expect(state.selectedImage, sampleImage, reason: 'Previous image preserved during error');
    });

    test('clearSelection resets state to initial and clears detectionProvider', () async {
      stubPicker.cameraResult = PickerResult.success(sampleImage);
      final notifier = container.read(selectedImageProvider.notifier);
      await notifier.captureImage();
      expect(container.read(selectedImageProvider).hasImage, isTrue);

      notifier.clearSelection();

      final state = container.read(selectedImageProvider);
      expect(state.status, SelectedImageStatus.initial);
      expect(state.hasImage, isFalse);
      expect(state.selectedImage, isNull);
      expect(container.read(detectionProvider).imagePath, isEmpty);
    });

    test('checkLostData handles recovered image on startup', () async {
      stubPicker.lostDataResult = PickerResult.success(sampleImage);

      final notifier = container.read(selectedImageProvider.notifier);
      await notifier.checkLostData();

      final state = container.read(selectedImageProvider);
      expect(state.isSuccess, isTrue);
      expect(state.selectedImage, sampleImage);
    });
  });
}

extension on SelectedImageState {
  bool get isSuccess => status == SelectedImageStatus.selected && selectedImage != null;
}
