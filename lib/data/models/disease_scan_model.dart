class DiseaseScanModel {
  final String id;
  final String userId;
  final String? cropId;
  final String imageUrl;
  final String cropName;
  final String detectedDisease;
  final double confidenceScore;
  final String severity;
  final Map<String, dynamic>? detectionResult;
  final DateTime createdAt;

  const DiseaseScanModel({
    required this.id,
    required this.userId,
    this.cropId,
    required this.imageUrl,
    required this.cropName,
    required this.detectedDisease,
    required this.confidenceScore,
    required this.severity,
    this.detectionResult,
    required this.createdAt,
  });

  factory DiseaseScanModel.fromJson(Map<String, dynamic> json) {
    return DiseaseScanModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      cropId: json['crop_id'] as String?,
      imageUrl: json['image_url'] as String,
      cropName: json['crop_name'] as String,
      detectedDisease: json['detected_disease'] as String,
      confidenceScore: (json['confidence_score'] as num).toDouble(),
      severity: json['severity'] as String? ?? 'moderate',
      detectionResult: json['detection_result'] != null
          ? Map<String, dynamic>.from(json['detection_result'] as Map)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      if (cropId != null) 'crop_id': cropId,
      'image_url': imageUrl,
      'crop_name': cropName,
      'detected_disease': detectedDisease,
      'confidence_score': confidenceScore,
      'severity': severity,
      if (detectionResult != null) 'detection_result': detectionResult,
      'created_at': createdAt.toIso8601String(),
    };
  }

  DiseaseScanModel copyWith({
    String? id,
    String? userId,
    String? cropId,
    String? imageUrl,
    String? cropName,
    String? detectedDisease,
    double? confidenceScore,
    String? severity,
    Map<String, dynamic>? detectionResult,
    DateTime? createdAt,
  }) {
    return DiseaseScanModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      cropId: cropId ?? this.cropId,
      imageUrl: imageUrl ?? this.imageUrl,
      cropName: cropName ?? this.cropName,
      detectedDisease: detectedDisease ?? this.detectedDisease,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      severity: severity ?? this.severity,
      detectionResult: detectionResult ?? this.detectionResult,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

