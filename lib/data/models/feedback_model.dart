class FeedbackModel {
  final String id;
  final String userId;
  final int rating;
  final String? category;
  final String message;
  final DateTime createdAt;

  const FeedbackModel({
    required this.id,
    required this.userId,
    required this.rating,
    this.category,
    required this.message,
    required this.createdAt,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      rating: json['rating'] as int,
      category: json['category'] as String?,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'rating': rating,
      'category': category,
      'message': message,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

