class NotificationModel {
  final String id;
  final String userId;
  final String titleEn;
  final String titleBn;
  final String? messageEn;
  final String? messageBn;
  final String? type; // 'activity', 'reminder', 'update', etc.
  final String? relatedId; // associated scan ID, disease ID, etc.
  final String? targetRoute; // optional navigation route
  final DateTime? readAt;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.titleEn,
    required this.titleBn,
    this.messageEn,
    this.messageBn,
    this.type,
    this.relatedId,
    this.targetRoute,
    this.readAt,
    required this.createdAt,
  });

  bool get isRead => readAt != null;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      titleEn: json['title_en'] as String? ?? 'Notification',
      titleBn: json['title_bn'] as String? ?? 'বিজ্ঞপ্তি',
      messageEn: json['message_en'] as String? ?? json['message'] as String?,
      messageBn: json['message_bn'] as String? ?? json['message'] as String?,
      type: json['type'] as String? ?? json['category'] as String?,
      relatedId: json['related_id'] as String?,
      targetRoute: json['target_route'] as String?,
      readAt: json['read_at'] != null
          ? DateTime.tryParse(json['read_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title_en': titleEn,
      'title_bn': titleBn,
      if (messageEn != null) 'message_en': messageEn,
      if (messageBn != null) 'message_bn': messageBn,
      if (type != null) 'type': type,
      if (relatedId != null) 'related_id': relatedId,
      if (targetRoute != null) 'target_route': targetRoute,
      if (readAt != null) 'read_at': readAt!.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? titleEn,
    String? titleBn,
    String? messageEn,
    String? messageBn,
    String? type,
    String? relatedId,
    String? targetRoute,
    DateTime? readAt,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      titleEn: titleEn ?? this.titleEn,
      titleBn: titleBn ?? this.titleBn,
      messageEn: messageEn ?? this.messageEn,
      messageBn: messageBn ?? this.messageBn,
      type: type ?? this.type,
      relatedId: relatedId ?? this.relatedId,
      targetRoute: targetRoute ?? this.targetRoute,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
