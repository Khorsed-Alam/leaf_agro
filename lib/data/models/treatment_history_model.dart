class TreatmentHistoryModel {
  final String id;
  final String userId;
  final String scanId;
  final String treatmentName;
  final String treatmentDescription;
  final List<dynamic> preventionTips;
  final DateTime createdAt;

  const TreatmentHistoryModel({
    required this.id,
    required this.userId,
    required this.scanId,
    required this.treatmentName,
    required this.treatmentDescription,
    this.preventionTips = const [],
    required this.createdAt,
  });

  factory TreatmentHistoryModel.fromJson(Map<String, dynamic> json) {
    return TreatmentHistoryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      scanId: json['scan_id'] as String,
      treatmentName: json['treatment_name'] as String,
      treatmentDescription: json['treatment_description'] as String,
      preventionTips: json['prevention_tips'] is List
          ? List<dynamic>.from(json['prevention_tips'] as List)
          : [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'scan_id': scanId,
      'treatment_name': treatmentName,
      'treatment_description': treatmentDescription,
      'prevention_tips': preventionTips,
      'created_at': createdAt.toIso8601String(),
    };
  }

  TreatmentHistoryModel copyWith({
    String? id,
    String? userId,
    String? scanId,
    String? treatmentName,
    String? treatmentDescription,
    List<dynamic>? preventionTips,
    DateTime? createdAt,
  }) {
    return TreatmentHistoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      scanId: scanId ?? this.scanId,
      treatmentName: treatmentName ?? this.treatmentName,
      treatmentDescription:
          treatmentDescription ?? this.treatmentDescription,
      preventionTips: preventionTips ?? this.preventionTips,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

