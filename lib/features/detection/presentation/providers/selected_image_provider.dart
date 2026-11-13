import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../providers/detection_provider.dart';
import '../../data/models/picker_result.dart';
import '../../data/models/selected_plant_image.dart';
import '../../data/services/image_validation_service.dart';
import '../../data/services/plant_image_picker_service.dart';

/// Status lifecycle for plant image selection.
enum SelectedImageStatus {
  /// No image currently selected.
  initial,

  /// Camera viewfinder is currently active.
  openingCamera,

  /// Gallery / Photo picker is currently active.
  openingGallery,

  /// Validating file integrity, size, and dimensions.
  validating,

  /// An authentic, validated leaf image is ready for preview and Phase 43 preprocessing.
  selected,

  /// Image selection, capture, or validation failed.
  error,
}

/// Immutable state containing the current image selection and diagnostics.
class SelectedImageState {
  final SelectedImageStatus status;
  final SelectedPlantImage? selectedImage;
  final String? errorMessageEn;
  final String? errorMessageBn;
  final String? errorCode;

  const SelectedImageState({
    this.status = SelectedImageStatus.initial,
    this.selectedImage,
    this.errorMessageEn,
    this.errorMessageBn,
    this.errorCode,
  });

  factory SelectedImageState.initial() => const SelectedImageState(
        status: SelectedImageStatus.initial,
      );

  factory SelectedImageState.selected(SelectedPlantImage image) => SelectedImageState(
        status: SelectedImageStatus.selected,
        selectedImage: image,
      );

  factory SelectedImageState.error({
    required String messageEn,
    required String messageBn,
    String? errorCode,
    SelectedPlantImage? preservedImage,
  }) =>
      SelectedImageState(
        status: SelectedImageStatus.error,
        selectedImage: preservedImage,
        errorMessageEn: messageEn,
        errorMessageBn: messageBn,
        errorCode: errorCode,
      );

  /// True when a valid image is selected and available.
  bool get hasImage => selectedImage != null && selectedImage!.isValid;

  /// True when a picker operation or validation is currently underway.
  bool get isLoading =>
      status == SelectedImageStatus.openingCamera ||
      status == SelectedImageStatus.openingGallery ||
      status == SelectedImageStatus.validating;

  /// True if an error occurred during selection or validation.
  bool get hasError => status == SelectedImageStatus.error;

  /// Convenience helper for localized error message.
  String? getErrorMessage(bool isBn) => isBn ? errorMessageBn : errorMessageEn;

  SelectedImageState copyWith({
    SelectedImageStatus? status,
    SelectedPlantImage? selectedImage,
    String? errorMessageEn,
    String? errorMessageBn,
    String? errorCode,
  }) {
    return SelectedImageState(
      status: status ?? this.status,
      selectedImage: selectedImage ?? this.selectedImage,
      errorMessageEn: errorMessageEn ?? this.errorMessageEn,
      errorMessageBn: errorMessageBn ?? this.errorMessageBn,
      errorCode: errorCode ?? this.errorCode,
    );
  }

  @override
  String toString() =>
      'SelectedImageState(status: ${status.name}, hasImage: $hasImage, file: ${selectedImage?.fileName})';
}

/// StateNotifier orchestrating camera capture, gallery selection, validation, and lifecycle.
class SelectedImageNotifier extends StateNotifier<SelectedImageState> {
  final PlantImagePickerService _pickerService;
  final Ref _ref;

  SelectedImageNotifier(this._pickerService, this._ref)
      : super(SelectedImageState.initial());

  /// Captures an image from the native camera.
  Future<void> captureImage() async {
    if (state.isLoading) return; // Prevent duplicate requests

    final previousImage = state.selectedImage;
    state = state.copyWith(status: SelectedImageStatus.openingCamera);

    final result = await _pickerService.captureFromCamera();
    _handlePickerResult(result, previousImage);
  }

  /// Selects an image from the native Android photo picker / gallery.
  Future<void> selectFromGallery() async {
    if (state.isLoading) return; // Prevent duplicate requests

    final previousImage = state.selectedImage;
    state = state.copyWith(status: SelectedImageStatus.openingGallery);

    final result = await _pickerService.pickFromGallery();
    _handlePickerResult(result, previousImage);
  }

  /// Replaces the current selection with a new image from the specified source.
  Future<void> replaceSelection(ImageSourceType source) async {
    if (source == ImageSourceType.camera) {
      await captureImage();
    } else {
      await selectFromGallery();
    }
  }

  /// Clears the currently selected image and resets state to initial.
  void clearSelection() {
    state = SelectedImageState.initial();
    // Also reset the detection provider state image path if it matches
    _ref.read(detectionProvider.notifier).selectImage('');
  }

  /// Explicitly sets a validated image (useful for testing or direct navigation).
  void setExplicitImage(SelectedPlantImage image) {
    state = SelectedImageState.selected(image);
    _ref.read(detectionProvider.notifier).selectImage(image.imagePath);
  }

  /// Recovers lost camera image after an Android process recreation.
  Future<void> checkLostData() async {
    final result = await _pickerService.retrieveLostData();
    if (result != null && result.isSuccess) {
      _handlePickerResult(result, state.selectedImage);
    }
  }

  void _handlePickerResult(PickerResult result, SelectedPlantImage? previousImage) {
    switch (result.type) {
      case PickerResultType.success:
        final newImage = result.image!;
        state = SelectedImageState.selected(newImage);
        // Synchronize with existing detection provider for backwards compatibility
        _ref.read(detectionProvider.notifier).selectImage(newImage.imagePath);
        break;

      case PickerResultType.cancelled:
        // Cancellation is NOT an error. Preserve any previously selected valid image.
        if (previousImage != null) {
          state = SelectedImageState.selected(previousImage);
        } else {
          state = SelectedImageState.initial();
        }
        break;

      case PickerResultType.failure:
        // Report error while preserving previous image if one was valid
        state = SelectedImageState.error(
          messageEn: result.errorMessageEn ?? 'Image selection failed.',
          messageBn: result.errorMessageBn ?? 'ছবি নির্বাচন ব্যর্থ হয়েছে।',
          errorCode: result.errorCode,
          preservedImage: previousImage,
        );
        break;
    }
  }
}

// ---------------------------------------------------------------------------
// Application Providers
// ---------------------------------------------------------------------------

final imageValidationServiceProvider = Provider<ImageValidationService>((ref) {
  return const ImageValidationService();
});

final imagePickerInstanceProvider = Provider<ImagePicker>((ref) {
  return ImagePicker();
});

final plantImagePickerServiceProvider = Provider<PlantImagePickerService>((ref) {
  final picker = ref.watch(imagePickerInstanceProvider);
  final validator = ref.watch(imageValidationServiceProvider);
  return PlantImagePickerService(picker: picker, validator: validator);
});

final selectedImageProvider =
    StateNotifierProvider<SelectedImageNotifier, SelectedImageState>((ref) {
  final pickerService = ref.watch(plantImagePickerServiceProvider);
  return SelectedImageNotifier(pickerService, ref);
});
