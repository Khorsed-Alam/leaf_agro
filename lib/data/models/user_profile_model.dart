class UserProfileModel {
  final String id;
  final String fullName;
  final String? email;
  final String? phoneNumber;
  final String? avatarUrl;
  final String preferredLanguage;
  final String role;
  final DateTime? termsAcceptedAt;
  final String? district;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserProfileModel({
    required this.id,
    required this.fullName,
    this.email,
    this.phoneNumber,
    this.avatarUrl,
    this.preferredLanguage = 'en',
    this.role = 'farmer',
    this.termsAcceptedAt,
    this.district,
    required this.createdAt,
    this.updatedAt,
  });

  // Getter alias for backwards compatibility
  String? get phone => phoneNumber;

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? 'Farmer',
      email: json['email'] as String?,
      phoneNumber: (json['phone_number'] ?? json['phone']) as String?,
      avatarUrl: json['avatar_url'] as String?,
      preferredLanguage: (json['preferred_language'] as String?) ?? 'en',
      role: (json['role'] as String?) ?? 'farmer',
      termsAcceptedAt: json['terms_accepted_at'] != null
          ? DateTime.tryParse(json['terms_accepted_at'] as String)
          : null,
      district: json['district'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      if (email != null) 'email': email,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      'preferred_language': preferredLanguage,
      'role': role,
      if (termsAcceptedAt != null)
        'terms_accepted_at': termsAcceptedAt!.toIso8601String(),
      if (district != null) 'district': district,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  UserProfileModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
    String? preferredLanguage,
    String? role,
    DateTime? termsAcceptedAt,
    String? district,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      role: role ?? this.role,
      termsAcceptedAt: termsAcceptedAt ?? this.termsAcceptedAt,
      district: district ?? this.district,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'UserProfileModel(id: $id, fullName: $fullName, email: $email, '
      'phone: $phoneNumber, role: $role, language: $preferredLanguage)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
