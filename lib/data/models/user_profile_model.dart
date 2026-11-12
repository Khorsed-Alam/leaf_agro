class UserProfileModel {
  final String id;
  final String fullName;
  final String? phone;
  final String? district;
  final String preferredLanguage;
  final DateTime createdAt;

  const UserProfileModel({
    required this.id,
    required this.fullName,
    this.phone,
    this.district,
    this.preferredLanguage = 'en',
    required this.createdAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String?,
      district: json['district'] as String?,
      preferredLanguage: (json['preferred_language'] as String?) ?? 'en',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'district': district,
      'preferred_language': preferredLanguage,
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserProfileModel copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? district,
    String? preferredLanguage,
    DateTime? createdAt,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      district: district ?? this.district,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'UserProfileModel(id: $id, fullName: $fullName, phone: $phone, '
      'district: $district, preferredLanguage: $preferredLanguage, createdAt: $createdAt)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
