import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/feedback_provider.dart';
import '../../../providers/settings_provider.dart';
import 'widgets/attachment_card.dart';
import 'widgets/category_selector.dart';
import 'widgets/feedback_header.dart';
import 'widgets/feedback_success_view.dart';
import 'widgets/message_input_card.dart';
import 'widgets/rating_selector.dart';

/// Screen 29: Farmer Feedback Screen — AgriCare AI (LeafAgro)
class FeedbackScreen extends ConsumerStatefulWidget {
  final String? initialCategory;

  const FeedbackScreen({
    super.key,
    this.initialCategory,
  });

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  int _selectedRating = 0;
  String? _selectedCategory;
  final TextEditingController _messageController = TextEditingController();
  FeedbackAttachmentData? _selectedAttachment;

  bool _isSubmitting = false;
  bool _isSuccess = false;

  String? _ratingError;
  String? _categoryError;
  String? _messageError;
  String? _attachmentError;
  String? _submissionError;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _onRatingChanged(int rating) {
    setState(() {
      _selectedRating = rating;
      _ratingError = null;
      _submissionError = null;
    });
  }

  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
      _categoryError = null;
      _submissionError = null;
    });
  }

  void _onMessageChanged(String text) {
    if (_messageError != null && text.trim().isNotEmpty) {
      setState(() {
        _messageError = null;
        _submissionError = null;
      });
    }
  }

  void _onAttachmentChanged(FeedbackAttachmentData? data) {
    setState(() {
      _selectedAttachment = data;
      _attachmentError = null;
      _submissionError = null;
    });
  }

  void _resetForm() {
    setState(() {
      _selectedRating = 0;
      _selectedCategory = null;
      _messageController.clear();
      _selectedAttachment = null;
      _isSubmitting = false;
      _isSuccess = false;
      _ratingError = null;
      _categoryError = null;
      _messageError = null;
      _attachmentError = null;
      _submissionError = null;
    });
  }

  Future<void> _submitFeedback(bool isBn) async {
    // Prevent duplicate submissions while in progress
    if (_isSubmitting) return;

    // Validate fields
    bool hasError = false;

    if (_selectedRating <= 0) {
      _ratingError = isBn
          ? 'অনুগ্রহ করে একটি রেটিং নির্বাচন করুন।'
          : 'Please select a rating.';
      hasError = true;
    } else {
      _ratingError = null;
    }

    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      _categoryError = isBn
          ? 'অনুগ্রহ করে একটি বিষয় নির্বাচন করুন।'
          : 'Please select a feedback category.';
      hasError = true;
    } else {
      _categoryError = null;
    }

    final trimmedMessage = _messageController.text.trim();
    if (trimmedMessage.isEmpty) {
      _messageError = isBn
          ? 'অনুগ্রহ করে আপনার মতামত লিখুন।'
          : 'Please enter your feedback.';
      hasError = true;
    } else {
      _messageError = null;
    }

    if (hasError) {
      setState(() {});
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submissionError = null;
    });

    try {
      final repo = ref.read(feedbackRepositoryProvider);
      String userId = '00000000-0000-0000-0000-000000000000';
      try {
        final currentUser = Supabase.instance.client.auth.currentUser;
        if (currentUser != null) {
          userId = currentUser.id;
        }
      } catch (_) {}

      await repo.submitFeedback(
        userId: userId,
        rating: _selectedRating,
        category: _selectedCategory!,
        message: trimmedMessage,
        attachmentBytes: _selectedAttachment?.bytes,
        fileExtension: _selectedAttachment?.extension ?? 'jpg',
      );

      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _isSuccess = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _submissionError = isBn
              ? 'মতামত জমা দেওয়া সম্ভব হয়নি। অনুগ্রহ করে ইন্টারনেট সংযোগ পরীক্ষা করে আবার চেষ্টা করুন।'
              : "We couldn't submit your feedback. Please check your connection and try again.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final isBn = settings.language == 'bn';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _isSuccess
            ? FeedbackSuccessView(
                isBn: isBn,
                onReset: _resetForm,
              )
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Back button & Feedback Header
                    FeedbackHeader(isBn: isBn),
                    const SizedBox(height: 16),

                    // 2. Five-star rating selector
                    RatingSelector(
                      selectedRating: _selectedRating,
                      onRatingChanged: _onRatingChanged,
                      errorText: _ratingError,
                      isBn: isBn,
                    ),
                    const SizedBox(height: 16),

                    // 3. Feedback Category selector
                    CategorySelector(
                      selectedCategory: _selectedCategory,
                      onCategoryChanged: _onCategoryChanged,
                      errorText: _categoryError,
                      isBn: isBn,
                    ),
                    const SizedBox(height: 16),

                    // 4. Feedback Message text area
                    MessageInputCard(
                      controller: _messageController,
                      onChanged: _onMessageChanged,
                      errorText: _messageError,
                      isBn: isBn,
                    ),
                    const SizedBox(height: 16),

                    // 5. Optional Attachment section
                    AttachmentCard(
                      attachment: _selectedAttachment,
                      onAttachmentChanged: _onAttachmentChanged,
                      errorText: _attachmentError,
                      isBn: isBn,
                    ),
                    const SizedBox(height: 16),

                    // Submission error banner if failed
                    if (_submissionError != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              AppColors.errorContainer.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(14),
                          border:
                              Border.all(color: AppColors.error, width: 1.2),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: AppColors.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _submissionError!,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.error,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 6. Submit Feedback Button
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed:
                            _isSubmitting ? null : () => _submitFeedback(isBn),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.forestGreen,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.borderGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.send_rounded, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    isBn ? 'মতামত জমা দিন' : 'Submit Feedback',
                                    style: const TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }
}
