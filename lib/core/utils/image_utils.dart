import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

class ImageUtils {
  /// Decodes and resizes an image file to the target 224x224 RGB format required by MobileNetV2
  static Future<img.Image?> prepareLeafImage(String filePath, {int targetSize = 224}) async {
    if (kIsWeb) return null;
    try {
      final bytes = await File(filePath).readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return null;

      final resized = img.copyResize(image, width: targetSize, height: targetSize);
      return resized;
    } catch (_) {
      return null;
    }
  }
}
