import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../../../../core/errors/ai_model_exception.dart';
import '../models/selected_plant_image.dart';

/// Container for the preprocessed input tensor and timing metrics.
class PreprocessedImageResult {
  /// Flat Float32List containing 150,528 values representing [1, 224, 224, 3] in NHWC format.
  /// Pixel values are in the raw unnormalized range [0.0, 255.0].
  final Float32List tensor;

  /// Target model input width (224).
  final int width;

  /// Target model input height (224).
  final int height;

  /// Number of channels (3 for RGB).
  final int channels;

  /// Time taken to read and decode image bytes into memory.
  final Duration decodingDuration;

  /// Time taken for EXIF orientation baking, RGB/alpha handling, resizing, and tensor formatting.
  final Duration preprocessingDuration;

  /// Original width of the raw image before resizing.
  final int originalWidth;

  /// Original height of the raw image before resizing.
  final int originalHeight;

  const PreprocessedImageResult({
    required this.tensor,
    required this.width,
    required this.height,
    required this.channels,
    required this.decodingDuration,
    required this.preprocessingDuration,
    required this.originalWidth,
    required this.originalHeight,
  });

  /// Total duration of decoding and preprocessing.
  Duration get totalDuration => decodingDuration + preprocessingDuration;
}

/// Image Preprocessing Service for AgriCare AI MobileNetV2.
///
/// CRITICAL CONTRACT AUDIT:
/// - Target dimensions: 224 x 224 x 3 (NHWC)
/// - Color format: RGB (Red, Green, Blue)
/// - Resampling: Bilinear interpolation matching Python PIL Image.Resampling.BILINEAR
/// - Normalization: Embedded inside the MobileNetV2 TFLite model graph (Rescaling scale=1/127.5, offset=-1.0).
/// - Tensor input range: [0.0, 255.0] Float32.
/// - NO DOUBLE NORMALIZATION: Do NOT map pixels to [-1.0, 1.0] before feeding the interpreter!
class PlantImagePreprocessor {
  static const int targetWidth = 224;
  static const int targetHeight = 224;
  static const int targetChannels = 3;
  static const int expectedTensorElements = targetWidth * targetHeight * targetChannels; // 150,528

  /// Preprocesses a [SelectedPlantImage] for TFLite MobileNetV2 inference.
  Future<PreprocessedImageResult> preprocessSelectedImage(
    SelectedPlantImage selectedImage,
  ) async {
    return preprocessFile(selectedImage.imagePath);
  }

  /// Preprocesses an image file on disk.
  Future<PreprocessedImageResult> preprocessFile(String imagePath) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      throw ImagePreprocessingException(
        'Image file does not exist at path: $imagePath',
      );
    }

    final Uint8List bytes;
    try {
      bytes = await file.readAsBytes();
    } catch (e) {
      throw ImagePreprocessingException(
        'Failed to read image file at $imagePath: $e',
        originalError: e,
      );
    }

    return preprocessBytes(bytes, sourcePath: imagePath);
  }

  /// Preprocesses raw image bytes into the exact MobileNetV2 input tensor contract.
  PreprocessedImageResult preprocessBytes(
    Uint8List bytes, {
    String? sourcePath,
  }) {
    if (bytes.isEmpty) {
      throw ImagePreprocessingException(
        'Cannot preprocess empty image bytes (0 bytes).',
      );
    }

    // 1. Measure image decoding
    final decodeStopwatch = Stopwatch()..start();
    img.Image? decoded;
    try {
      decoded = img.decodeImage(bytes);
    } catch (e) {
      throw ImagePreprocessingException(
        'Failed to decode image bytes: $e',
        originalError: e,
      );
    }
    decodeStopwatch.stop();

    if (decoded == null) {
      throw ImagePreprocessingException(
        'Unsupported image format or corrupt image data${sourcePath != null ? " ($sourcePath)" : ""}.',
      );
    }

    final originalWidth = decoded.width;
    final originalHeight = decoded.height;

    if (originalWidth <= 0 || originalHeight <= 0) {
      throw ImagePreprocessingException(
        'Invalid image dimensions ($originalWidth x $originalHeight).',
      );
    }

    // 2. Measure preprocessing operations
    final prepStopwatch = Stopwatch()..start();

    // 2a. Bake EXIF orientation exactly once to ensure visual correctness
    final oriented = img.bakeOrientation(decoded);

    // 2b. Resize to 224x224 using linear (bilinear) interpolation matching Python PIL
    final resized = img.copyResize(
      oriented,
      width: targetWidth,
      height: targetHeight,
      interpolation: img.Interpolation.linear,
    );

    // 2c. Build Float32 input tensor in NHWC format with [0.0, 255.0] range
    // Handles transparency compositing over pure white background (#FFFFFF)
    final tensor = Float32List(expectedTensorElements);
    int offset = 0;

    for (int y = 0; y < targetHeight; y++) {
      for (int x = 0; x < targetWidth; x++) {
        final pixel = resized.getPixel(x, y);

        double r = pixel.r.toDouble();
        double g = pixel.g.toDouble();
        double b = pixel.b.toDouble();

        // If pixel has an alpha channel, composite over white background (255.0)
        final num a = pixel.a;
        if (a < 255) {
          final alphaNorm = a / 255.0;
          r = (r * alphaNorm) + (255.0 * (1.0 - alphaNorm));
          g = (g * alphaNorm) + (255.0 * (1.0 - alphaNorm));
          b = (b * alphaNorm) + (255.0 * (1.0 - alphaNorm));
        }

        // Clamp to valid [0.0, 255.0] range and guard against NaN/Inf
        tensor[offset++] = r.clamp(0.0, 255.0);
        tensor[offset++] = g.clamp(0.0, 255.0);
        tensor[offset++] = b.clamp(0.0, 255.0);
      }
    }

    prepStopwatch.stop();

    // 3. Strict tensor validation
    _validateTensor(tensor);

    return PreprocessedImageResult(
      tensor: tensor,
      width: targetWidth,
      height: targetHeight,
      channels: targetChannels,
      decodingDuration: decodeStopwatch.elapsed,
      preprocessingDuration: prepStopwatch.elapsed,
      originalWidth: originalWidth,
      originalHeight: originalHeight,
    );
  }

  /// Verifies input tensor shape, length, and value bounds.
  void _validateTensor(Float32List tensor) {
    if (tensor.length != expectedTensorElements) {
      throw ImagePreprocessingException(
        'Tensor element count mismatch: expected $expectedTensorElements, got ${tensor.length}.',
      );
    }

    for (int i = 0; i < tensor.length; i++) {
      final val = tensor[i];
      if (val.isNaN || val.isInfinite) {
        throw ImagePreprocessingException(
          'Tensor contains NaN or Infinite value at offset $i.',
        );
      }
      if (val < 0.0 || val > 255.0) {
        throw ImagePreprocessingException(
          'Tensor value $val at offset $i is outside the required [0.0, 255.0] range.',
        );
      }
    }
  }
}
