import '../datasources/ai_crop_catalog.dart';

class CropModel {
  final int id;
  final String nameEn;
  final String nameBn;
  final String descriptionEn;
  final String descriptionBn;
  final String? imageUrl;
  final bool isActive;

  const CropModel({
    required this.id,
    required this.nameEn,
    required this.nameBn,
    required this.descriptionEn,
    required this.descriptionBn,
    this.imageUrl,
    this.isActive = true,
  });

  /// True if this crop is supported by the on-device AI plant disease model
  bool get isAiSupported => AiCropCatalog.isSupported(nameEn);

  /// Number of detectable disease classes in labels.json for this crop
  int get supportedDiseaseCount => AiCropCatalog.getDiseaseCount(nameEn);

  factory CropModel.fromJson(Map<String, dynamic> json) {
    return CropModel(
      id: json['id'] as int,
      nameEn: json['name_en'] as String,
      nameBn: json['name_bn'] as String,
      descriptionEn: json['description_en'] as String,
      descriptionBn: json['description_bn'] as String,
      imageUrl: json['image_url'] as String?,
      isActive: (json['is_active'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_en': nameEn,
      'name_bn': nameBn,
      'description_en': descriptionEn,
      'description_bn': descriptionBn,
      'image_url': imageUrl,
      'is_active': isActive,
    };
  }

  CropModel copyWith({
    int? id,
    String? nameEn,
    String? nameBn,
    String? descriptionEn,
    String? descriptionBn,
    String? imageUrl,
    bool? isActive,
  }) {
    return CropModel(
      id: id ?? this.id,
      nameEn: nameEn ?? this.nameEn,
      nameBn: nameBn ?? this.nameBn,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionBn: descriptionBn ?? this.descriptionBn,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() =>
      'CropModel(id: $id, nameEn: $nameEn, nameBn: $nameBn, isActive: $isActive)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CropModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
