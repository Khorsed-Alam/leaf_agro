import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../models/picker_result.dart';
import '../models/selected_plant_image.dart';
import 'image_validation_service.dart';

/// Centralized service orchestrating native Android camera capture and gallery selection.
///
/// Dispatches strongly typed results distinguishing success, user cancellation,
/// and failure without throwing unhandled exceptions into the UI.
class PlantImagePickerService {
  final ImagePicker _picker;
  final ImageValidationService _validator;

  PlantImagePickerService({
    ImagePicker? picker,
    ImageValidationService? validator,
  })  : _picker = picker ?? ImagePicker(),
        _validator = validator ?? const ImageValidationService();

  /// Captures a plant leaf photo using the native Android camera.
  Future<PickerResult> captureFromCamera({
    CameraDevice preferredCamera = CameraDevice.rear,
    int imageQuality = 95,
  }) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: preferredCamera,
        imageQuality: imageQuality,
      );

      if (file == null) {
        // User deliberately cancelled or pressed back
        return PickerResult.cancelled();
      }

      return await _validateAndPackageResult(file.path, ImageSourceType.camera);
    } on PlatformException catch (e) {
      return _mapPlatformException(e, ImageSourceType.camera);
    } catch (e) {
      return PickerResult.failure(
        messageEn: 'Unexpected error while opening camera: $e',
        messageBn: 'ক্যামেরা চালু করার সময় অপ্রত্যাশিত ত্রুটি ঘটেছে।',
        errorCode: 'CAMERA_UNEXPECTED_ERROR',
        exception: e,
      );
    }
  }

  /// Selects an existing leaf image using the Android photo picker / gallery.
  Future<PickerResult> pickFromGallery({
    int imageQuality = 95,
  }) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: imageQuality,
      );

      if (file == null) {
        // User backed out of gallery
        return PickerResult.cancelled();
      }

      return await _validateAndPackageResult(file.path, ImageSourceType.gallery);
    } on PlatformException catch (e) {
      return _mapPlatformException(e, ImageSourceType.gallery);
    } catch (e) {
      return PickerResult.failure(
        messageEn: 'Unexpected error while opening gallery: $e',
        messageBn: 'গ্যালারি চালু করার সময় অপ্রত্যাশিত ত্রুটি ঘটেছে।',
        errorCode: 'GALLERY_UNEXPECTED_ERROR',
        exception: e,
      );
    }
  }

  /// Checks for any image captured before an Android Activity was killed due to low memory.
  Future<PickerResult?> retrieveLostData() async {
    try {
      final LostDataResponse response = await _picker.retrieveLostData();
      if (response.isEmpty) return null;

      final file = response.file;
      if (file != null) {
        return await _validateAndPackageResult(file.path, ImageSourceType.camera);
      }

      final exception = response.exception;
      if (exception != null) {
        return _mapPlatformException(exception, ImageSourceType.camera);
      }
    } catch (_) {
      // In web or platforms where retrieveLostData is unsupported
    }
    return null;
  }

  /// Validates the picked file and transforms it into a [SelectedPlantImage].
  Future<PickerResult> _validateAndPackageResult(
    String path,
    ImageSourceType sourceType,
  ) async {
    final validation = await _validator.validate(path);

    if (!validation.isValid) {
      return PickerResult.failure(
        messageEn: validation.errorMessageEn ?? 'Image validation failed.',
        messageBn: validation.errorMessageBn ?? 'ছবি যাচাইকরণ ব্যর্থ হয়েছে।',
        errorCode: validation.errorCode ?? 'VALIDATION_FAILED',
      );
    }

    final selectedImage = SelectedPlantImage(
      imagePath: path,
      sourceType: sourceType,
      fileSizeBytes: validation.fileSizeBytes ?? 0,
      width: validation.width ?? 0,
      height: validation.height ?? 0,
      mimeType: validation.mimeType,
      selectedAt: DateTime.now(),
    );

    return PickerResult.success(selectedImage);
  }

  /// Maps native Android platform exceptions into clear, localized error responses.
  PickerResult _mapPlatformException(PlatformException e, ImageSourceType source) {
    if (e.code == 'camera_access_denied' || e.code == 'CameraAccessDenied') {
      return PickerResult.failure(
        messageEn: 'Camera permission was denied. Please allow camera access in Settings.',
        messageBn: 'ক্যামেরা ব্যবহারের অনুমতি দেওয়া হয়নি। সেটিংসে গিয়ে অনুমতি দিন।',
        errorCode: 'CAMERA_PERMISSION_DENIED',
        exception: e,
      );
    }

    if (e.code == 'photo_access_denied') {
      return PickerResult.failure(
        messageEn: 'Gallery access permission was denied. Please allow photo access in Settings.',
        messageBn: 'গ্যালারি ব্যবহারের অনুমতি দেওয়া হয়নি। সেটিংসে গিয়ে অনুমতি দিন।',
        errorCode: 'GALLERY_PERMISSION_DENIED',
        exception: e,
      );
    }

    final isCamera = source == ImageSourceType.camera;
    return PickerResult.failure(
      messageEn: isCamera
          ? 'Failed to capture photo: ${e.message ?? e.code}'
          : 'Failed to pick image: ${e.message ?? e.code}',
      messageBn: isCamera
          ? 'ছবি ধারণ করতে সমস্যা হয়েছে: ${e.message ?? "আবার চেষ্টা করুন"}'
          : 'ছবি নির্বাচন করতে সমস্যা হয়েছে: ${e.message ?? "আবার চেষ্টা করুন"}',
      errorCode: e.code,
      exception: e,
    );
  }
}
