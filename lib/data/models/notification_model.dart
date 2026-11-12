class NotificationModel {
  final String id;
  final String userId;
  final String titleEn;
  final String titleBn;
  final String? messageEn;
  final String? messageBn;
  final DateTime? readAt;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.titleEn,
    required this.titleBn,
    this.messageEn,
    this.messageBn,
    this.readAt,
    required this.createdAt,
  });

  bool get isRead => readAt != null;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      titleEn: json['title_en'] as String,
      titleBn: json['title_bn'] as String,
      messageEn: json['message_en'] as String?,
      messageBn: json['message_bn'] as String?,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

