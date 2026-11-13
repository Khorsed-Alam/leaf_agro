import 'selected_plant_image.dart';

/// Distinct outcome categories for camera and gallery image picker operations.
enum PickerResultType {
  /// User successfully selected a valid leaf image.
  success,

  /// User dismissed or cancelled the camera/gallery without selecting.
  cancelled,

  /// An error occurred (permission denied, corrupted file, validation failure).
  failure,
}

/// Typed result structure distinguishing success, user cancellation, and failure.
class PickerResult {
  final PickerResultType type;
  final SelectedPlantImage? image;
  final String? errorMessageEn;
  final String? errorMessageBn;
  final String? errorCode;
  final dynamic exception;

  const PickerResult._({
    required this.type,
    this.image,
    this.errorMessageEn,
    this.errorMessageBn,
    this.errorCode,
    this.exception,
  });

  /// Factory for successful image selection.
  factory PickerResult.success(SelectedPlantImage image) {
    return PickerResult._(
      type: PickerResultType.success,
      image: image,
    );
  }

  /// Factory for user cancellation (not treated as an error).
  factory PickerResult.cancelled() {
    return const PickerResult._(
      type: PickerResultType.cancelled,
    );
  }

  /// Factory for failed picker or validation operations.
  factory PickerResult.failure({
    required String messageEn,
    required String messageBn,
    String? errorCode,
    dynamic exception,
  }) {
    return PickerResult._(
      type: PickerResultType.failure,
      errorMessageEn: messageEn,
      errorMessageBn: messageBn,
      errorCode: errorCode,
      exception: exception,
    );
  }

  /// True when a valid image was acquired and validated.
  bool get isSuccess => type == PickerResultType.success && image != null;

  /// True when the user deliberately dismissed the picker.
  bool get isCancelled => type == PickerResultType.cancelled;

  /// True when an error occurred.
  bool get isFailure => type == PickerResultType.failure;

  /// Convenience getter for localized error message.
  String? getErrorMessage(bool isBn) => isBn ? errorMessageBn : errorMessageEn;

  @override
  String toString() {
    switch (type) {
      case PickerResultType.success:
        return 'PickerResult.success($image)';
      case PickerResultType.cancelled:
        return 'PickerResult.cancelled()';
      case PickerResultType.failure:
        return 'PickerResult.failure(code: $errorCode, message: $errorMessageEn)';
    }
  }
}
