import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/feedback_repository.dart';

final feedbackRepositoryProvider = Provider<FeedbackRepository>((ref) {
  return FeedbackRepository();
});
