/// Source origin of the selected plant leaf image.
enum ImageSourceType {
  /// Captured using device camera.
  camera,

  /// Selected from device gallery / photo picker.
  gallery,
}

/// Immutable null-safe representation of an authentic plant leaf image
/// selected by the farmer, validated for resolution, size, and format.
///
/// Stores no personal EXIF or GPS coordinates and preserves the original file reference.
class SelectedPlantImage {
  final String imagePath;
  final ImageSourceType sourceType;
  final int fileSizeBytes;
  final int width;
  final int height;
  final String? mimeType;
  final DateTime selectedAt;

  const SelectedPlantImage({
    required this.imagePath,
    required this.sourceType,
    required this.fileSizeBytes,
    required this.width,
    required this.height,
    this.mimeType,
    required this.selectedAt,
  });

  /// True if the image has non-empty path, positive dimensions, and positive file size.
  bool get isValid =>
      imagePath.isNotEmpty &&
      fileSizeBytes > 0 &&
      width > 0 &&
      height > 0;

  /// Aspect ratio of the original image (width / height).
  double get aspectRatio => height > 0 ? width / height : 1.0;

  /// Human-readable file name extracted from [imagePath].
  String get fileName {
    if (imagePath.isEmpty) return '';
    final normalized = imagePath.replaceAll('\\', '/');
    return normalized.split('/').last;
  }

  /// Formatted file size string (e.g. "2.4 MB" or "350 KB").
  String get formattedFileSize {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Formatted resolution string (e.g. "1920x1080").
  String get formattedResolution => '${width}x$height';

  /// Serializes model to standard JSON map.
  Map<String, dynamic> toJson() {
    return {
      'image_path': imagePath,
      'source_type': sourceType.name,
      'file_size_bytes': fileSizeBytes,
      'width': width,
      'height': height,
      if (mimeType != null) 'mime_type': mimeType,
      'selected_at': selectedAt.toIso8601String(),
    };
  }

  /// Deserializes model from JSON map.
  factory SelectedPlantImage.fromJson(Map<String, dynamic> json) {
    return SelectedPlantImage(
      imagePath: json['image_path'] as String,
      sourceType: ImageSourceType.values.byName(
        json['source_type'] as String? ?? 'gallery',
      ),
      fileSizeBytes: (json['file_size_bytes'] as num).toInt(),
      width: (json['width'] as num).toInt(),
      height: (json['height'] as num).toInt(),
      mimeType: json['mime_type'] as String?,
      selectedAt: DateTime.parse(json['selected_at'] as String),
    );
  }

  SelectedPlantImage copyWith({
    String? imagePath,
    ImageSourceType? sourceType,
    int? fileSizeBytes,
    int? width,
    int? height,
    String? mimeType,
    DateTime? selectedAt,
  }) {
    return SelectedPlantImage(
      imagePath: imagePath ?? this.imagePath,
      sourceType: sourceType ?? this.sourceType,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      width: width ?? this.width,
      height: height ?? this.height,
      mimeType: mimeType ?? this.mimeType,
      selectedAt: selectedAt ?? this.selectedAt,
    );
  }

  @override
  String toString() =>
      'SelectedPlantImage(${sourceType.name}, $formattedResolution, $formattedFileSize, path: $imagePath)';
}
