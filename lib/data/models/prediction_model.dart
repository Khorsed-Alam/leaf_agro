class PredictionModel {
  final String className;
  final String cropName;
  final String diseaseNameEn;
  final String diseaseNameBn;
  final double confidence;
  final DateTime predictedAt;
  final String modelVersion;

  const PredictionModel({
    required this.className,
    required this.cropName,
    required this.diseaseNameEn,
    required this.diseaseNameBn,
    required this.confidence,
    required this.predictedAt,
    required this.modelVersion,
  });

  /// Returns true when the predicted class indicates a healthy plant.
  bool get isHealthy =>
      className.toLowerCase().contains('healthy') ||
      diseaseNameEn.toLowerCase().contains('healthy');

  factory PredictionModel.fromJson(Map<String, dynamic> json) {
    return PredictionModel(
      className: json['class_name'] as String,
      cropName: json['crop_name'] as String,
      diseaseNameEn: json['disease_name_en'] as String,
      diseaseNameBn: json['disease_name_bn'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      predictedAt: DateTime.parse(json['predicted_at'] as String),
      modelVersion: json['model_version'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'class_name': className,
      'crop_name': cropName,
      'disease_name_en': diseaseNameEn,
      'disease_name_bn': diseaseNameBn,
      'confidence': confidence,
      'predicted_at': predictedAt.toIso8601String(),
      'model_version': modelVersion,
    };
  }

  PredictionModel copyWith({
    String? className,
    String? cropName,
    String? diseaseNameEn,
    String? diseaseNameBn,
    double? confidence,
    DateTime? predictedAt,
    String? modelVersion,
  }) {
    return PredictionModel(
      className: className ?? this.className,
      cropName: cropName ?? this.cropName,
      diseaseNameEn: diseaseNameEn ?? this.diseaseNameEn,
      diseaseNameBn: diseaseNameBn ?? this.diseaseNameBn,
      confidence: confidence ?? this.confidence,
      predictedAt: predictedAt ?? this.predictedAt,
      modelVersion: modelVersion ?? this.modelVersion,
    );
  }

  @override
  String toString() =>
      'PredictionModel(className: $className, cropName: $cropName, '
      'confidence: $confidence, isHealthy: $isHealthy)';
}
