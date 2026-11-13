import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leaf_agro/data/models/crop_model.dart';
import 'package:leaf_agro/data/models/prediction_model.dart';
import 'package:leaf_agro/data/repositories/detection_repository.dart';
import 'package:leaf_agro/features/detection/presentation/analyzing_screen.dart';
import 'package:leaf_agro/features/detection/presentation/widgets/analyzing/analyzing_error_view.dart';
import 'package:leaf_agro/features/detection/presentation/widgets/analyzing/analyzing_header.dart';
import 'package:leaf_agro/features/detection/presentation/widgets/analyzing/analyzing_status_section.dart';
import 'package:leaf_agro/features/detection/presentation/widgets/analyzing/scanning_image_view.dart';
import 'package:leaf_agro/providers/crop_provider.dart';
import 'package:leaf_agro/providers/detection_provider.dart';
import 'package:leaf_agro/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeDetectionRepository implements DetectionRepository {
  bool shouldThrow = false;
  int callCount = 0;

  @override
  Future<void> initializeModel() async {}

  @override
  Future<PredictionModel> detectPlantDisease(String imagePath) async {
    callCount++;
    if (shouldThrow) {
      throw Exception('Hardware acceleration failed');
    }
    return PredictionModel(
      className: 'rice_brown_spot',
      cropName: 'Rice',
      diseaseNameEn: 'Brown Spot',
      diseaseNameBn: 'বাদামী দাগ রোগ',
      confidence: 0.92,
      predictedAt: DateTime.now(),
      modelVersion: '1.0.0',
    );
  }
}

void main() {
  late SharedPreferences prefs;
  late File tempImageFile;

  setUpAll(() {
    final tempDir = Directory.systemTemp.createTempSync('leaf_analyzing_test');
    tempImageFile = File('${tempDir.path}/test_analyzing_sample.jpg');
    tempImageFile.writeAsBytesSync([
      0xFF,
      0xD8,
      0xFF,
      0xE0,
      0x00,
      0x10,
      0x4A,
      0x46,
      0x49,
      0x46,
      0x00,
      0x01,
      0x01,
      0x01,
      0x00,
      0x48,
      0x00,
      0x48,
      0x00,
      0x00,
      0xFF,
      0xDB,
      0x00,
      0x43,
      0x00,
      0xFF,
      0xD9
    ]);
  });

  tearDownAll(() {
    try {
      if (tempImageFile.existsSync()) {
        tempImageFile.parent.deleteSync(recursive: true);
      }
    } catch (_) {}
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({'preferred_language': 'en'});
    prefs = await SharedPreferences.getInstance();
  });

  group('Screen 15 – Analyzing Widgets Unit & Widget Tests', () {
    testWidgets('AnalyzingHeader displays branding logo and title',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnalyzingHeader(isBn: false),
          ),
        ),
      );

      expect(find.text('AgriCare AI'), findsOneWidget);
      expect(find.byIcon(Icons.eco_rounded), findsOneWidget);
    });

    testWidgets(
        'ScanningImageView displays photo, corner reticles, and crop context badge',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScanningImageView(
              imagePath: tempImageFile.path,
              selectedCropName: 'Rice',
              animate: false,
              isBn: false,
            ),
          ),
        ),
      );

      expect(find.text('Target Crop: Rice'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);

      // Bengali localization test
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScanningImageView(
              imagePath: tempImageFile.path,
              selectedCropName: 'ধান',
              animate: false,
              isBn: true,
            ),
          ),
        ),
      );

      expect(find.text('ফসলের ধরন: ধান'), findsOneWidget);
    });

    testWidgets(
        'AnalyzingStatusSection displays exact required headings, progress, and on-device badge',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnalyzingStatusSection(isBn: false),
          ),
        ),
      );

      expect(find.text('Analyzing Your Plant'), findsOneWidget);
      expect(find.text('Our AI model is examining the leaf image.'),
          findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('Processing image on your device'), findsOneWidget);
      expect(find.text('On-device AI • Offline'), findsOneWidget);

      // Bengali localization test
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnalyzingStatusSection(isBn: true),
          ),
        ),
      );

      expect(find.text('আপনার গাছ বিশ্লেষণ করা হচ্ছে'), findsOneWidget);
      expect(find.text('আমাদের AI মডেল পাতার ছবিটি পর্যবেক্ষণ করছে।'),
          findsOneWidget);
      expect(find.text('আপনার ডিভাইসেই ছবিটি প্রক্রিয়া করা হচ্ছে'),
          findsOneWidget);
      expect(find.text('অন-ডিভাইস AI • অফলাইন'), findsOneWidget);
    });

    testWidgets(
        'AnalyzingErrorView displays friendly message and handles retry and return',
        (WidgetTester tester) async {
      bool retryTapped = false;
      bool returnTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalyzingErrorView(
              onRetry: () => retryTapped = true,
              onReturnToPreview: () => returnTapped = true,
              errorMessage: 'Hardware error occurred',
              isBn: false,
            ),
          ),
        ),
      );

      expect(find.text("We couldn't analyze this image. Please try again."),
          findsOneWidget);
      expect(find.text('Hardware error occurred'), findsOneWidget);
      expect(find.text('Retry Analysis'), findsOneWidget);
      expect(find.text('Choose Another Image'), findsOneWidget);

      await tester.tap(find.text('Retry Analysis'));
      expect(retryTapped, isTrue);

      await tester.tap(find.text('Choose Another Image'));
      expect(returnTapped, isTrue);
    });
  });

  group('Screen 15 – AnalyzingScreen Full Flow & Inference Tests', () {
    testWidgets(
        'Renders all core analyzing elements with selected crop context',
        (WidgetTester tester) async {
      final fakeRepo = FakeDetectionRepository();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          detectionRepositoryProvider.overrideWithValue(fakeRepo),
          selectedCropProvider.overrideWith((ref) => const CropModel(
                id: 1,
                nameEn: 'Rice',
                nameBn: 'ধান',
                descriptionEn: 'Paddy',
                descriptionBn: 'ধান',
                isActive: true,
              )),
        ],
      );
      addTearDown(container.dispose);

      container
          .read(detectionProvider.notifier)
          .selectImage(tempImageFile.path);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: AnalyzingScreen(
              autoStart: false,
              animateScanning: false,
            ),
          ),
        ),
      );

      expect(find.byType(AnalyzingHeader), findsOneWidget);
      expect(find.byType(ScanningImageView), findsOneWidget);
      expect(find.text('Target Crop: Rice'), findsOneWidget);
      expect(find.byType(AnalyzingStatusSection), findsOneWidget);
      expect(find.text('Analyzing Your Plant'), findsOneWidget);
      expect(find.text('Processing image on your device'), findsOneWidget);
      expect(find.text('On-device AI • Offline'), findsOneWidget);
    });

    testWidgets(
        'autoStart runs genuine AI inference on detectionProvider exactly once',
        (WidgetTester tester) async {
      final fakeRepo = FakeDetectionRepository();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          detectionRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      container
          .read(detectionProvider.notifier)
          .selectImage(tempImageFile.path);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: AnalyzingScreen(
              autoStart: true,
              animateScanning: false,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(fakeRepo.callCount, 1);
      final detectionState = container.read(detectionProvider);
      expect(detectionState.status, DetectionStatus.success);
      expect(detectionState.prediction?.diseaseNameEn, 'Brown Spot');
    });

    testWidgets(
        'Displays AnalyzingErrorView when inference encounters an error and allows retry',
        (WidgetTester tester) async {
      final fakeRepo = FakeDetectionRepository();
      fakeRepo.shouldThrow = true;

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          detectionRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      container
          .read(detectionProvider.notifier)
          .selectImage(tempImageFile.path);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: AnalyzingScreen(
              autoStart: true,
              animateScanning: false,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(AnalyzingErrorView), findsOneWidget);
      expect(find.text("We couldn't analyze this image. Please try again."),
          findsOneWidget);

      // Now fix repo and retry
      fakeRepo.shouldThrow = false;
      await tester.tap(find.text('Retry Analysis'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(fakeRepo.callCount, 2);
      final detectionState = container.read(detectionProvider);
      expect(detectionState.status, DetectionStatus.success);
    });

    testWidgets(
        'Displays error state immediately if no image path was selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const MaterialApp(
            home: AnalyzingScreen(
              autoStart: true,
              animateScanning: false,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(AnalyzingErrorView), findsOneWidget);
      expect(find.text('No leaf image found to analyze.'), findsOneWidget);
    });
  });
}
