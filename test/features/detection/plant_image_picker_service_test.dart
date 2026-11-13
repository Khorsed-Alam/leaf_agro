import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leaf_agro/features/detection/data/models/selected_plant_image.dart';
import 'package:leaf_agro/features/detection/data/services/image_validation_service.dart';
import 'package:leaf_agro/features/detection/data/services/plant_image_picker_service.dart';

class FakeImagePicker implements ImagePicker {
  XFile? stubbedFile;
  PlatformException? stubbedException;
  LostDataResponse? stubbedLostData;

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    if (stubbedException != null) {
      throw stubbedException!;
    }
    return stubbedFile;
  }

  @override
  Future<LostDataResponse> retrieveLostData() async {
    return stubbedLostData ?? LostDataResponse.empty();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeImageValidationService extends ImageValidationService {
  final ImageValidationResult stubbedResult;

  FakeImageValidationService(this.stubbedResult);

  @override
  Future<ImageValidationResult> validate(String filePath, {Uint8List? preloadedBytes}) async {
    return stubbedResult;
  }
}

void main() {
  group('PlantImagePickerService Tests', () {
    late FakeImagePicker fakePicker;

    setUp(() {
      fakePicker = FakeImagePicker();
    });

    test('captureFromCamera returns success when valid file is captured', () async {
      fakePicker.stubbedFile = XFile('/mock/camera_leaf.jpg');
      final fakeValidator = FakeImageValidationService(
        ImageValidationResult.valid(
          width: 1920,
          height: 1080,
          fileSizeBytes: 2048576,
          mimeType: 'image/jpeg',
        ),
      );

      final service = PlantImagePickerService(
        picker: fakePicker,
        validator: fakeValidator,
      );

      final result = await service.captureFromCamera();

      expect(result.isSuccess, isTrue);
      expect(result.image, isNotNull);
      expect(result.image!.sourceType, ImageSourceType.camera);
      expect(result.image!.width, 1920);
      expect(result.image!.height, 1080);
      expect(result.image!.imagePath, '/mock/camera_leaf.jpg');
    });

    test('pickFromGallery returns success when valid image is chosen', () async {
      fakePicker.stubbedFile = XFile('/mock/gallery_leaf.png');
      final fakeValidator = FakeImageValidationService(
        ImageValidationResult.valid(
          width: 800,
          height: 800,
          fileSizeBytes: 512000,
          mimeType: 'image/png',
        ),
      );

      final service = PlantImagePickerService(
        picker: fakePicker,
        validator: fakeValidator,
      );

      final result = await service.pickFromGallery();

      expect(result.isSuccess, isTrue);
      expect(result.image!.sourceType, ImageSourceType.gallery);
      expect(result.image!.formattedResolution, '800x800');
    });

    test('captureFromCamera returns cancelled when user dismisses camera without capturing', () async {
      fakePicker.stubbedFile = null; // Dismissed
      final service = PlantImagePickerService(picker: fakePicker);

      final result = await service.captureFromCamera();

      expect(result.isCancelled, isTrue);
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isFalse);
      expect(result.image, isNull);
    });

    test('pickFromGallery returns cancelled when user backs out of gallery', () async {
      fakePicker.stubbedFile = null;
      final service = PlantImagePickerService(picker: fakePicker);

      final result = await service.pickFromGallery();

      expect(result.isCancelled, isTrue);
      expect(result.isSuccess, isFalse);
    });

    test('captureFromCamera handles camera_access_denied PlatformException gracefully', () async {
      fakePicker.stubbedException = PlatformException(
        code: 'camera_access_denied',
        message: 'Permission denied by user',
      );
      final service = PlantImagePickerService(picker: fakePicker);

      final result = await service.captureFromCamera();

      expect(result.isFailure, isTrue);
      expect(result.errorCode, 'CAMERA_PERMISSION_DENIED');
      expect(result.errorMessageEn, contains('permission was denied'));
      expect(result.errorMessageBn, contains('অনুমতি দেওয়া হয়নি'));
    });

    test('pickFromGallery handles photo_access_denied PlatformException gracefully', () async {
      fakePicker.stubbedException = PlatformException(
        code: 'photo_access_denied',
        message: 'Storage permission denied',
      );
      final service = PlantImagePickerService(picker: fakePicker);

      final result = await service.pickFromGallery();

      expect(result.isFailure, isTrue);
      expect(result.errorCode, 'GALLERY_PERMISSION_DENIED');
      expect(result.errorMessageEn, contains('Gallery access permission'));
    });

    test('returns failure when selected file fails validation', () async {
      fakePicker.stubbedFile = XFile('/mock/corrupt.jpg');
      final fakeValidator = FakeImageValidationService(
        ImageValidationResult.invalid(
          messageEn: 'Corrupted image file.',
          messageBn: 'ক্ষতিগ্রস্ত ফাইল।',
          errorCode: 'DECODE_FAILURE',
        ),
      );

      final service = PlantImagePickerService(
        picker: fakePicker,
        validator: fakeValidator,
      );

      final result = await service.captureFromCamera();

      expect(result.isFailure, isTrue);
      expect(result.errorCode, 'DECODE_FAILURE');
      expect(result.errorMessageEn, 'Corrupted image file.');
    });

    test('retrieveLostData recovers previously taken camera image', () async {
      fakePicker.stubbedLostData = LostDataResponse(
        file: XFile('/mock/recovered_leaf.jpg'),
      );
      final fakeValidator = FakeImageValidationService(
        ImageValidationResult.valid(
          width: 1024,
          height: 1024,
          fileSizeBytes: 100000,
        ),
      );

      final service = PlantImagePickerService(
        picker: fakePicker,
        validator: fakeValidator,
      );

      final result = await service.retrieveLostData();

      expect(result, isNotNull);
      expect(result!.isSuccess, isTrue);
      expect(result.image!.imagePath, '/mock/recovered_leaf.jpg');
    });
  });
}
