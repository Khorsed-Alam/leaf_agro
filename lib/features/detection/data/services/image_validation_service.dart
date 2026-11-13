import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Structured result of an image validation check.
class ImageValidationResult {
  final bool isValid;
  final int? width;
  final int? height;
  final int? fileSizeBytes;
  final String? mimeType;
  final String? errorMessageEn;
  final String? errorMessageBn;
  final String? errorCode;

  const ImageValidationResult._({
    required this.isValid,
    this.width,
    this.height,
    this.fileSizeBytes,
    this.mimeType,
    this.errorMessageEn,
    this.errorMessageBn,
    this.errorCode,
  });

  factory ImageValidationResult.valid({
    required int width,
    required int height,
    required int fileSizeBytes,
    String? mimeType,
  }) {
    return ImageValidationResult._(
      isValid: true,
      width: width,
      height: height,
      fileSizeBytes: fileSizeBytes,
      mimeType: mimeType,
    );
  }

  factory ImageValidationResult.invalid({
    required String messageEn,
    required String messageBn,
    required String errorCode,
  }) {
    return ImageValidationResult._(
      isValid: false,
      errorMessageEn: messageEn,
      errorMessageBn: messageBn,
      errorCode: errorCode,
    );
  }

  String? getErrorMessage(bool isBn) => isBn ? errorMessageBn : errorMessageEn;

  @override
  String toString() => isValid
      ? 'ImageValidationResult.valid(${width}x$height, $fileSizeBytes bytes)'
      : 'ImageValidationResult.invalid($errorCode: $errorMessageEn)';
}

/// Centralized service verifying file accessibility, size, format, and decodability.
///
/// Ensures corrupted, empty, or unsupported files are rejected before downstream processing.
/// Preserves the original image file without modifying, cropping, or resizing it.
class ImageValidationService {
  /// Maximum permitted file size in bytes (default: 20 MB).
  final int maxFileSizeBytes;

  /// Minimum permitted file size in bytes (default: 100 bytes).
  final int minFileSizeBytes;

  /// Maximum permitted width or height in pixels (default: 8192 px).
  final int maxDimension;

  /// Minimum permitted width or height in pixels (default: 64 px).
  final int minDimension;

  /// Supported file extensions (lowercase).
  final List<String> supportedExtensions;

  const ImageValidationService({
    this.maxFileSizeBytes = 20 * 1024 * 1024, // 20 MB
    this.minFileSizeBytes = 100,
    this.maxDimension = 8192,
    this.minDimension = 64,
    this.supportedExtensions = const ['.jpg', '.jpeg', '.png', '.webp'],
  });

  /// Validates an image file by path, optionally using pre-read bytes.
  Future<ImageValidationResult> validate(String filePath, {Uint8List? preloadedBytes}) async {
    if (filePath.trim().isEmpty) {
      return ImageValidationResult.invalid(
        messageEn: 'The image file path is empty.',
        messageBn: 'ছবির ফাইলের পাথ খালি।',
        errorCode: 'EMPTY_PATH',
      );
    }

    // 1. File existence and access check
    final file = File(filePath);
    bool fileExists = false;
    try {
      fileExists = await file.exists();
    } catch (_) {
      // Platform or sandbox limitation
      fileExists = preloadedBytes != null && preloadedBytes.isNotEmpty;
    }

    if (!fileExists && (preloadedBytes == null || preloadedBytes.isEmpty)) {
      return ImageValidationResult.invalid(
        messageEn: 'The selected image file does not exist or cannot be accessed.',
        messageBn: 'নির্বাচিত ফাইলটি খুঁজে পাওয়া যায়নি বা পড়া সম্ভব নয়।',
        errorCode: 'FILE_NOT_FOUND',
      );
    }

    // 2. Extension check
    final lower = filePath.toLowerCase();
    final hasValidExt = supportedExtensions.any((ext) => lower.endsWith(ext));
    if (!hasValidExt) {
      return ImageValidationResult.invalid(
        messageEn: 'Unsupported image format. Please use JPG, PNG, or WebP.',
        messageBn: 'অসমর্থিত ছবির ফরম্যাট। শুধুমাত্র JPG, PNG বা WebP সমর্থিত।',
        errorCode: 'UNSUPPORTED_FORMAT',
      );
    }

    // 3. File size check
    int fileSize = 0;
    try {
      fileSize = preloadedBytes?.length ?? await file.length();
    } catch (_) {
      fileSize = preloadedBytes?.length ?? 0;
    }

    if (fileSize == 0) {
      return ImageValidationResult.invalid(
        messageEn: 'The image file is empty or corrupted (0 bytes).',
        messageBn: 'ছবির ফাইলটি খালি বা ত্রুটিপূর্ণ (০ বাইট)।',
        errorCode: 'EMPTY_FILE',
      );
    }

    if (fileSize < minFileSizeBytes) {
      return ImageValidationResult.invalid(
        messageEn: 'The file size is too small to contain valid image data.',
        messageBn: 'ফাইলের আকার খুব ছোট, সঠিক ছবি হতে পারে না।',
        errorCode: 'FILE_TOO_SMALL',
      );
    }

    if (fileSize > maxFileSizeBytes) {
      final maxMb = (maxFileSizeBytes / (1024 * 1024)).toStringAsFixed(0);
      return ImageValidationResult.invalid(
        messageEn: 'Image size exceeds the ${maxMb}MB limit. Please choose a smaller photo.',
        messageBn: 'ছবির আকার ${maxMb}MB এর বেশি। অনুগ্রহ করে ছোট ছবি নির্বাচন করুন।',
        errorCode: 'FILE_TOO_LARGE',
      );
    }

    // 4. Image decoding & dimension safety check
    Uint8List bytes;
    try {
      bytes = preloadedBytes ?? await file.readAsBytes();
    } catch (e) {
      return ImageValidationResult.invalid(
        messageEn: 'Unable to read image bytes: $e',
        messageBn: 'ছবির তথ্য পড়তে ব্যর্থ হয়েছে।',
        errorCode: 'READ_FAILURE',
      );
    }

    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      return ImageValidationResult.invalid(
        messageEn: 'The image file could not be decoded. It may be damaged or not a valid image.',
        messageBn: 'ছবিটি ডিকোড করা সম্ভব হয়নি। ফাইলটি ক্ষতিগ্রস্ত হতে পারে।',
        errorCode: 'DECODE_FAILURE',
      );
    }

    final width = decoded.width;
    final height = decoded.height;

    if (width < minDimension || height < minDimension) {
      return ImageValidationResult.invalid(
        messageEn: 'Image resolution is too low (${width}x$height). Minimum required is ${minDimension}x$minDimension.',
        messageBn: 'ছবির রেজোলিউশন খুব কম (${width}x$height)। নূন্যতম ${minDimension}x$minDimension প্রয়োজন।',
        errorCode: 'DIMENSIONS_TOO_SMALL',
      );
    }

    if (width > maxDimension || height > maxDimension) {
      return ImageValidationResult.invalid(
        messageEn: 'Image resolution is excessively high (${width}x$height). Maximum allowed is ${maxDimension}x$maxDimension.',
        messageBn: 'ছবির রেজোলিউশন অতিরিক্ত বেশি (${width}x$height)। সর্বোচ্চ সীমা ${maxDimension}x$maxDimension।',
        errorCode: 'DIMENSIONS_TOO_LARGE',
      );
    }

    // 5. Determine MIME type from extension
    String mimeType = 'image/jpeg';
    if (lower.endsWith('.png')) {
      mimeType = 'image/png';
    } else if (lower.endsWith('.webp')) {
      mimeType = 'image/webp';
    }

    return ImageValidationResult.valid(
      width: width,
      height: height,
      fileSizeBytes: fileSize,
      mimeType: mimeType,
    );
  }
}
