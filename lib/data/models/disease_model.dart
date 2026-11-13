class DiseaseModel {
  final int id;
  final int cropId;
  final String className;
  final String diseaseNameEn;
  final String diseaseNameBn;
  final String symptomsEn;
  final String symptomsBn;
  final String causesEn;
  final String causesBn;
  final bool isHealthy;
  final String? imageUrl;
  final bool isSample;

  const DiseaseModel({
    required this.id,
    required this.cropId,
    required this.className,
    required this.diseaseNameEn,
    required this.diseaseNameBn,
    required this.symptomsEn,
    required this.symptomsBn,
    required this.causesEn,
    required this.causesBn,
    this.isHealthy = false,
    this.imageUrl,
    this.isSample = false,
  });

  factory DiseaseModel.fromJson(Map<String, dynamic> json) {
    return DiseaseModel(
      id: json['id'] as int,
      cropId: json['crop_id'] as int,
      className: json['class_name'] as String,
      diseaseNameEn: json['disease_name_en'] as String,
      diseaseNameBn: json['disease_name_bn'] as String,
      symptomsEn: (json['symptoms_en'] as String?) ?? '',
      symptomsBn: (json['symptoms_bn'] as String?) ?? '',
      causesEn: (json['causes_en'] as String?) ?? '',
      causesBn: (json['causes_bn'] as String?) ?? '',
      isHealthy: (json['is_healthy'] as bool?) ?? false,
      imageUrl: json['image_url'] as String?,
      isSample: (json['is_sample'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'crop_id': cropId,
      'class_name': className,
      'disease_name_en': diseaseNameEn,
      'disease_name_bn': diseaseNameBn,
      'symptoms_en': symptomsEn,
      'symptoms_bn': symptomsBn,
      'causes_en': causesEn,
      'causes_bn': causesBn,
      'is_healthy': isHealthy,
      'image_url': imageUrl,
      'is_sample': isSample,
    };
  }

  DiseaseModel copyWith({
    int? id,
    int? cropId,
    String? className,
    String? diseaseNameEn,
    String? diseaseNameBn,
    String? symptomsEn,
    String? symptomsBn,
    String? causesEn,
    String? causesBn,
    bool? isHealthy,
    String? imageUrl,
    bool? isSample,
  }) {
    return DiseaseModel(
      id: id ?? this.id,
      cropId: cropId ?? this.cropId,
      className: className ?? this.className,
      diseaseNameEn: diseaseNameEn ?? this.diseaseNameEn,
      diseaseNameBn: diseaseNameBn ?? this.diseaseNameBn,
      symptomsEn: symptomsEn ?? this.symptomsEn,
      symptomsBn: symptomsBn ?? this.symptomsBn,
      causesEn: causesEn ?? this.causesEn,
      causesBn: causesBn ?? this.causesBn,
      isHealthy: isHealthy ?? this.isHealthy,
      imageUrl: imageUrl ?? this.imageUrl,
      isSample: isSample ?? this.isSample,
    );
  }

  @override
  String toString() =>
      'DiseaseModel(id: $id, cropId: $cropId, className: $className, '
      'diseaseNameEn: $diseaseNameEn, isHealthy: $isHealthy)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiseaseModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
