class RecommendationModel {
  final int id;
  final int diseaseId;
  final String recommendationType; // 'treatment' | 'prevention' | 'care'
  final String titleEn;
  final String titleBn;
  final String contentEn;
  final String contentBn;
  final String? sourceName;
  final String? sourceUrl;
  final bool isVerified;

  const RecommendationModel({
    required this.id,
    required this.diseaseId,
    required this.recommendationType,
    required this.titleEn,
    required this.titleBn,
    required this.contentEn,
    required this.contentBn,
    this.sourceName,
    this.sourceUrl,
    this.isVerified = false,
  });

  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    return RecommendationModel(
      id: json['id'] as int,
      diseaseId: json['disease_id'] as int,
      recommendationType: json['recommendation_type'] as String,
      titleEn: json['title_en'] as String,
      titleBn: json['title_bn'] as String,
      contentEn: json['content_en'] as String,
      contentBn: json['content_bn'] as String,
      sourceName: json['source_name'] as String?,
      sourceUrl: json['source_url'] as String?,
      isVerified: (json['is_verified'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'disease_id': diseaseId,
      'recommendation_type': recommendationType,
      'title_en': titleEn,
      'title_bn': titleBn,
      'content_en': contentEn,
      'content_bn': contentBn,
      'source_name': sourceName,
      'source_url': sourceUrl,
      'is_verified': isVerified,
    };
  }

  RecommendationModel copyWith({
    int? id,
    int? diseaseId,
    String? recommendationType,
    String? titleEn,
    String? titleBn,
    String? contentEn,
    String? contentBn,
    String? sourceName,
    String? sourceUrl,
    bool? isVerified,
  }) {
    return RecommendationModel(
      id: id ?? this.id,
      diseaseId: diseaseId ?? this.diseaseId,
      recommendationType: recommendationType ?? this.recommendationType,
      titleEn: titleEn ?? this.titleEn,
      titleBn: titleBn ?? this.titleBn,
      contentEn: contentEn ?? this.contentEn,
      contentBn: contentBn ?? this.contentBn,
      sourceName: sourceName ?? this.sourceName,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  @override
  String toString() =>
      'RecommendationModel(id: $id, diseaseId: $diseaseId, '
      'type: $recommendationType, titleEn: $titleEn)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecommendationModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
