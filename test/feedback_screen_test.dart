import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:leaf_agro/core/constants/app_constants.dart';
import 'package:leaf_agro/core/theme/app_colors.dart';
import 'package:leaf_agro/data/models/feedback_model.dart';
import 'package:leaf_agro/data/repositories/feedback_repository.dart';
import 'package:leaf_agro/features/feedback/presentation/feedback_screen.dart';
import 'package:leaf_agro/features/feedback/presentation/widgets/attachment_card.dart';
import 'package:leaf_agro/features/feedback/presentation/widgets/category_selector.dart';
import 'package:leaf_agro/features/feedback/presentation/widgets/feedback_header.dart';
import 'package:leaf_agro/features/feedback/presentation/widgets/feedback_success_view.dart';
import 'package:leaf_agro/features/feedback/presentation/widgets/rating_selector.dart';
import 'package:leaf_agro/providers/feedback_provider.dart';
import 'package:leaf_agro/providers/settings_provider.dart';

class _MockFeedbackRepository extends FeedbackRepository {
  final bool shouldFail;
  FeedbackModel? lastSubmitted;

  _MockFeedbackRepository({this.shouldFail = false});

  @override
  Future<FeedbackModel> submitFeedback({
    required String userId,
    required int rating,
    required String category,
    required String message,
    Uint8List? attachmentBytes,
    String fileExtension = 'jpg',
  }) async {
    if (shouldFail) {
      throw Exception('Network error');
    }

    final model = FeedbackModel(
      id: 'mock_feedback_123',
      userId: userId,
      rating: rating,
      category: category,
      message: message,
      attachmentPath: attachmentBytes != null ? '$userId/mock_photo.jpg' : null,
      createdAt: DateTime.now(),
    );
    lastSubmitted = model;
    return model;
  }
}

Future<Widget> createTestWidget({
  String language = 'en',
  FeedbackRepository? customRepo,
  String? initialCategory,
}) async {
  SharedPreferences.setMockInitialValues({
    AppConstants.keyLanguage: language,
    AppConstants.keyThemeMode: 'system',
    AppConstants.keyNotificationsEnabled: true,
  });

  final prefs = await SharedPreferences.getInstance();
  final repo = customRepo ?? _MockFeedbackRepository();

  final router = GoRouter(
    initialLocation: '/feedback',
    routes: [
      GoRoute(
        path: '/feedback',
        builder: (context, state) =>
            FeedbackScreen(initialCategory: initialCategory),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) =>
            const Scaffold(body: Text('Settings Screen')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      feedbackRepositoryProvider.overrideWithValue(repo),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Screen 29: Farmer Feedback Screen Tests', () {
    testWidgets('Header renders title, subtitle, back button, and banner',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(await createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(FeedbackHeader), findsOneWidget);
      expect(find.text('Share Your Feedback'), findsOneWidget);
      expect(find.text('Help us improve plant disease detection.'),
          findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });

    testWidgets('Interactive 5-star rating selector updates rating and labels',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(await createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(RatingSelector), findsOneWidget);
      expect(find.text('How would you rate your experience?'), findsOneWidget);

      // Tap 4th star
      await tester.tap(find.byIcon(Icons.star_outline_rounded).at(3));
      await tester.pumpAndSettle();

      expect(find.text('Very Good (4/5)'), findsOneWidget);

      // Tap 5th star
      await tester.tap(find.byIcon(Icons.star_outline_rounded).last);
      await tester.pumpAndSettle();

      expect(find.text('Excellent (5/5)'), findsOneWidget);
    });

    testWidgets(
        'Category selector displays all 5 exact categories and enforces single select',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(await createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(CategorySelector), findsOneWidget);
      expect(find.text('AI prediction accuracy'), findsOneWidget);
      expect(find.text('App usability'), findsOneWidget);
      expect(find.text('Disease information'), findsOneWidget);
      expect(find.text('Treatment recommendations'), findsOneWidget);
      expect(find.text('Other'), findsOneWidget);

      // Select category
      await tester.tap(find.text('App usability'));
      await tester.pumpAndSettle();

      final chip = tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'App usability'));
      expect(chip.selected, isTrue);

      // Select another category
      await tester.tap(find.text('Disease information'));
      await tester.pumpAndSettle();

      final chip2 = tester.widget<ChoiceChip>(
          find.widgetWithText(ChoiceChip, 'Disease information'));
      expect(chip2.selected, isTrue);

      final chipOld = tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'App usability'));
      expect(chipOld.selected, isFalse);
    });

    testWidgets(
        'Submitting empty form shows validation errors on rating, category, and message',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(await createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Submit Feedback'));
      await tester.pumpAndSettle();

      expect(find.text('Please select a rating.'), findsOneWidget);
      expect(find.text('Please select a feedback category.'), findsOneWidget);
      expect(find.text('Please enter your feedback.'), findsOneWidget);
      expect(find.byType(FeedbackSuccessView), findsNothing);
    });

    testWidgets('Correcting fields clears their respective validation errors',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(await createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Submit Feedback'));
      await tester.pumpAndSettle();

      expect(find.text('Please select a rating.'), findsOneWidget);

      // Select star
      await tester.tap(find.byIcon(Icons.star_outline_rounded).at(4));
      await tester.pumpAndSettle();

      expect(find.text('Please select a rating.'), findsNothing);
      expect(find.text('Please select a feedback category.'), findsOneWidget);

      // Select category
      await tester.tap(find.text('AI prediction accuracy'));
      await tester.pumpAndSettle();

      expect(find.text('Please select a feedback category.'), findsNothing);
      expect(find.text('Please enter your feedback.'), findsOneWidget);

      // Type message
      await tester.enterText(find.byType(TextField).first,
          'Model accurately identified tomato blight.');
      await tester.pumpAndSettle();

      expect(find.text('Please enter your feedback.'), findsNothing);
    });

    testWidgets('Attachment removal works correctly when attachment is loaded',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(await createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(AttachmentCard), findsOneWidget);
      expect(find.text('Add Image or Screenshot'), findsOneWidget);

      final validPngBytes = Uint8List.fromList([
        0x89,
        0x50,
        0x4E,
        0x47,
        0x0D,
        0x0A,
        0x1A,
        0x0A,
        0x00,
        0x00,
        0x00,
        0x0D,
        0x49,
        0x48,
        0x44,
        0x52,
        0x00,
        0x00,
        0x00,
        0x01,
        0x00,
        0x00,
        0x00,
        0x01,
        0x08,
        0x06,
        0x00,
        0x00,
        0x00,
        0x1F,
        0x15,
        0xC4,
        0x89,
        0x00,
        0x00,
        0x00,
        0x0A,
        0x49,
        0x44,
        0x41,
        0x54,
        0x78,
        0x9C,
        0x63,
        0x00,
        0x01,
        0x00,
        0x00,
        0x05,
        0x00,
        0x01,
        0x0D,
        0x0A,
        0x2D,
        0xB4,
        0x00,
        0x00,
        0x00,
        0x00,
        0x49,
        0x45,
        0x4E,
        0x44,
        0xAE,
        0x42,
        0x60,
        0x82
      ]);

      // Simulate attachment update
      final attachmentWidget =
          tester.widget<AttachmentCard>(find.byType(AttachmentCard));
      attachmentWidget.onAttachmentChanged(
        FeedbackAttachmentData(
          bytes: validPngBytes,
          name: 'leaf_sample.jpg',
          sizeInBytes: 2048,
          extension: 'jpg',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('leaf_sample.jpg'), findsOneWidget);
      expect(find.text('2.0 KB'), findsOneWidget);

      // Remove attachment
      await tester.tap(find.byIcon(Icons.cancel_rounded));
      await tester.pumpAndSettle();

      expect(find.text('leaf_sample.jpg'), findsNothing);
      expect(find.text('Add Image or Screenshot'), findsOneWidget);
    });

    testWidgets(
        'Successful feedback submission persists data and shows FeedbackSuccessView',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final mockRepo = _MockFeedbackRepository();
      await tester.pumpWidget(await createTestWidget(customRepo: mockRepo));
      await tester.pumpAndSettle();

      // Rate 5 stars
      await tester.tap(find.byIcon(Icons.star_outline_rounded).last);
      await tester.pumpAndSettle();

      // Category
      await tester.tap(find.text('AI prediction accuracy'));
      await tester.pumpAndSettle();

      // Message
      await tester.enterText(find.byType(TextField).first,
          'Detected potato late blight instantly in field.');
      await tester.pumpAndSettle();

      // Submit
      await tester.tap(find.text('Submit Feedback'));
      await tester.pumpAndSettle();

      expect(mockRepo.lastSubmitted, isNotNull);
      expect(mockRepo.lastSubmitted!.rating, equals(5));
      expect(
          mockRepo.lastSubmitted!.category, equals('AI prediction accuracy'));
      expect(mockRepo.lastSubmitted!.message,
          equals('Detected potato late blight instantly in field.'));

      // Verifies FeedbackSuccessView is displayed
      expect(find.byType(FeedbackSuccessView), findsOneWidget);
      expect(find.text('Thank You for Your Feedback!'), findsOneWidget);

      // Reset action resets form
      await tester.tap(find.text('Submit Another Feedback'));
      await tester.pumpAndSettle();

      expect(find.byType(FeedbackSuccessView), findsNothing);
      expect(find.text('Submit Feedback'), findsOneWidget);
    });

    testWidgets(
        'Submission failure preserves entered data and displays error banner without false success',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final failingRepo = _MockFeedbackRepository(shouldFail: true);
      await tester.pumpWidget(await createTestWidget(customRepo: failingRepo));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.star_outline_rounded).at(3));
      await tester.pumpAndSettle();

      await tester.tap(find.text('App usability'));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byType(TextField).first, 'App is fast and responsive.');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Submit Feedback'));
      await tester.pumpAndSettle();

      expect(find.byType(FeedbackSuccessView), findsNothing);
      expect(
          find.text(
              "We couldn't submit your feedback. Please check your connection and try again."),
          findsOneWidget);
      expect(find.text('App is fast and responsive.'), findsOneWidget);
    });

    testWidgets(
        'Bangla localization renders appropriate Bengali text throughout feedback form',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(await createTestWidget(language: 'bn'));
      await tester.pumpAndSettle();

      expect(find.text('আপনার মতামত জানান'), findsOneWidget);
      expect(find.text('আপনার অভিজ্ঞতা কেমন ছিল?'), findsOneWidget);
      expect(find.text('মতামতের বিষয় কী?'), findsOneWidget);
      expect(find.text('এআই রোগ নির্ণয়ের নির্ভুলতা'), findsOneWidget);
      expect(find.text('অ্যাপ ব্যবহারের সুবিধা'), findsOneWidget);
      expect(find.text('রোগের তথ্য ও বিবরণ'), findsOneWidget);
      expect(find.text('প্রতিকার ও চিকিৎসা পরামর্শ'), findsOneWidget);
      expect(find.text('অন্যান্য'), findsOneWidget);
      expect(find.text('বিস্তারিত লিখুন'), findsOneWidget);
      expect(find.text('ছবি যুক্ত করুন (ঐচ্ছিক)'), findsOneWidget);
      expect(find.text('মতামত জমা দিন'), findsOneWidget);
    });
  });
}
