class PredictionHistoryModel {
  final String id;
  final String userId;
  final int? diseaseId;
  final String predictedClass;
  final double confidence;
  final String? imagePath;
  final String modelVersion;
  final DateTime createdAt;
  final String syncStatus; // 'synced', 'pending', 'local_only'

  const PredictionHistoryModel({
    required this.id,
    required this.userId,
    this.diseaseId,
    required this.predictedClass,
    required this.confidence,
    this.imagePath,
    this.modelVersion = '1.0.0',
    required this.createdAt,
    this.syncStatus = 'synced',
  });

  factory PredictionHistoryModel.fromJson(Map<String, dynamic> json) {
    return PredictionHistoryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      diseaseId: json['disease_id'] as int?,
      predictedClass: json['predicted_class'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      imagePath: json['image_path'] as String?,
      modelVersion: (json['model_version'] as String?) ?? '1.0.0',
      createdAt: DateTime.parse(json['created_at'] as String),
      syncStatus: (json['sync_status'] as String?) ?? 'synced',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'disease_id': diseaseId,
      'predicted_class': predictedClass,
      'confidence': confidence,
      'image_path': imagePath,
      'model_version': modelVersion,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

