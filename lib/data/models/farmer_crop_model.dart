class FarmerCropModel {
  final String id;
  final String userId;
  final String cropName;
  final String? cropVariety;
  final DateTime? plantingDate;
  final String? farmLocation;
  final DateTime createdAt;

  const FarmerCropModel({
    required this.id,
    required this.userId,
    required this.cropName,
    this.cropVariety,
    this.plantingDate,
    this.farmLocation,
    required this.createdAt,
  });

  factory FarmerCropModel.fromJson(Map<String, dynamic> json) {
    return FarmerCropModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      cropName: json['crop_name'] as String,
      cropVariety: json['crop_variety'] as String?,
      plantingDate: json['planting_date'] != null
          ? DateTime.tryParse(json['planting_date'] as String)
          : null,
      farmLocation: json['farm_location'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'crop_name': cropName,
      if (cropVariety != null) 'crop_variety': cropVariety,
      if (plantingDate != null)
        'planting_date': plantingDate!.toIso8601String().split('T').first,
      if (farmLocation != null) 'farm_location': farmLocation,
      'created_at': createdAt.toIso8601String(),
    };
  }

  FarmerCropModel copyWith({
    String? id,
    String? userId,
    String? cropName,
    String? cropVariety,
    DateTime? plantingDate,
    String? farmLocation,
    DateTime? createdAt,
  }) {
    return FarmerCropModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      cropName: cropName ?? this.cropName,
      cropVariety: cropVariety ?? this.cropVariety,
      plantingDate: plantingDate ?? this.plantingDate,
      farmLocation: farmLocation ?? this.farmLocation,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

