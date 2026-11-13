import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leaf_agro/data/models/crop_model.dart';
import 'package:leaf_agro/data/models/prediction_history_model.dart';
import 'package:leaf_agro/data/models/prediction_model.dart';
import 'package:leaf_agro/data/repositories/history_repository.dart';
import 'package:leaf_agro/features/detection/presentation/detection_result_screen.dart';
import 'package:leaf_agro/features/detection/presentation/widgets/result/ai_prediction_card.dart';
import 'package:leaf_agro/features/detection/presentation/widgets/result/detection_disclaimer.dart';
import 'package:leaf_agro/features/detection/presentation/widgets/result/detection_result_header.dart';
import 'package:leaf_agro/features/detection/presentation/widgets/result/disease_actions_section.dart';
import 'package:leaf_agro/features/detection/presentation/widgets/result/healthy_actions_section.dart';
import 'package:leaf_agro/features/detection/presentation/widgets/result/prediction_status_badge.dart';
import 'package:leaf_agro/features/detection/presentation/widgets/result/result_error_view.dart';
import 'package:leaf_agro/features/detection/presentation/widgets/result/result_image_card.dart';
import 'package:leaf_agro/features/detection/presentation/widgets/result/save_result_button.dart';
import 'package:leaf_agro/features/detection/presentation/widgets/result/scan_another_button.dart';
import 'package:leaf_agro/providers/crop_provider.dart';
import 'package:leaf_agro/providers/detection_provider.dart';
import 'package:leaf_agro/providers/history_provider.dart';
import 'package:leaf_agro/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeHistoryRepository implements HistoryRepository {
  final List<PredictionHistoryModel> savedRecords = [];

  @override
  Future<List<PredictionHistoryModel>> getAllPredictions(String userId) async {
    return savedRecords;
  }

  @override
  Future<void> savePrediction(PredictionHistoryModel model) async {
    savedRecords.add(model);
  }
}

void main() {
  late SharedPreferences prefs;
  late File tempImageFile;

  setUpAll(() {
    final tempDir = Directory.systemTemp.createTempSync('leaf_result_test');
    tempImageFile = File('${tempDir.path}/test_result_sample.jpg');
    tempImageFile.writeAsBytesSync([
      0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01,
      0x01, 0x01, 0x00, 0x48, 0x00, 0x48, 0x00, 0x00, 0xFF, 0xDB, 0x00, 0x43,
      0x00, 0xFF, 0xD9
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

  group('Screen 16 – Result Widgets Unit & Widget Tests', () {
    testWidgets('DetectionResultHeader displays title and handles close',
        (WidgetTester tester) async {
      bool closed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DetectionResultHeader(
              isBn: false,
              onClose: () => closed = true,
            ),
          ),
        ),
      );

      expect(find.text('Detection Result'), findsOneWidget);
      expect(find.text('Analysis completed'), findsOneWidget);

      await tester.tap(find.byType(InkWell));
      expect(closed, isTrue);

      // Bengali
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DetectionResultHeader(
              isBn: true,
              onClose: () {},
            ),
          ),
        ),
      );

      expect(find.text('শনাক্তকরণ ফলাফল'), findsOneWidget);
    });

    testWidgets(
        'PredictionStatusBadge renders Healthy and Disease Detected styles correctly',
        (WidgetTester tester) async {
      // Healthy badge
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PredictionStatusBadge(
              isHealthy: true,
              isBn: false,
            ),
          ),
        ),
      );

      expect(find.text('Healthy Plant'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

      // Disease badge
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PredictionStatusBadge(
              isHealthy: false,
              isBn: false,
            ),
          ),
        ),
      );

      expect(find.text('Disease Detected'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets(
        'ResultImageCard displays image, status badge, and optional crop banner',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResultImageCard(
              imagePath: tempImageFile.path,
              cropName: 'Rice',
              isHealthy: false,
              isBn: false,
            ),
          ),
        ),
      );

      expect(find.text('Target Crop:'), findsOneWidget);
      expect(find.text('Rice'), findsOneWidget);
      expect(find.text('Disease Detected'), findsOneWidget);

      // Crop name null
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResultImageCard(
              imagePath: tempImageFile.path,
              cropName: null,
              isHealthy: true,
              isBn: false,
            ),
          ),
        ),
      );

      expect(find.text('Target Crop:'), findsNothing);
      expect(find.text('Healthy Plant'), findsOneWidget);
    });

    testWidgets(
        'AiPredictionCard formats confidence %, certainty note, and summary',
        (WidgetTester tester) async {
      final diseasePrediction = PredictionModel(
        className: 'rice_bacterial_leaf_blight',
        cropName: 'Rice',
        diseaseNameEn: 'Bacterial Leaf Blight',
        diseaseNameBn: 'ব্যাকটেরিয়াল পাতা পোড়া',
        confidence: 0.924,
        predictedAt: DateTime.now(),
        modelVersion: '1.0.0',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AiPredictionCard(
                prediction: diseasePrediction,
                diseaseDescription: 'Lesions along the leaf veins',
                isBn: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Bacterial Leaf Blight'), findsOneWidget);
      expect(find.text('92.4%'), findsOneWidget);
      expect(find.textContaining('Confidence represents the model score'),
          findsOneWidget);
      expect(find.text('Lesions along the leaf veins'), findsOneWidget);
    });

    testWidgets(
        'DiseaseActionsSection renders treatment, details, and prevention buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DiseaseActionsSection(
              diseaseId: 10,
              isBn: false,
            ),
          ),
        ),
      );

      expect(find.text('Treatment Recommendations'), findsOneWidget);
      expect(find.text('Disease Details'), findsOneWidget);
      expect(find.text('Prevention Tips'), findsOneWidget);
    });

    testWidgets(
        'HealthyActionsSection renders healthy card and does not show disease treatments',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HealthyActionsSection(isBn: false),
          ),
        ),
      );

      expect(find.text('Your plant looks healthy!'), findsOneWidget);
      expect(find.textContaining('No supported disease was detected'),
          findsOneWidget);
      expect(find.text('Crop Care & Prevention Guide'), findsOneWidget);

      // Verify no disease treatment or pesticide references appear
      expect(find.text('Treatment Recommendations'), findsNothing);
      expect(find.text('Disease Details'), findsNothing);
    });

    testWidgets('SaveResultButton handles save states and tap triggers',
        (WidgetTester tester) async {
      bool saveTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SaveResultButton(
              onSave: () => saveTapped = true,
              state: SaveState.initial,
              isBn: false,
            ),
          ),
        ),
      );

      expect(find.text('Save Result to Field Log'), findsOneWidget);
      await tester.tap(find.byType(OutlinedButton));
      expect(saveTapped, isTrue);

      // Saved state
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SaveResultButton(
              onSave: null,
              state: SaveState.saved,
              isBn: false,
            ),
          ),
        ),
      );

      expect(find.text('Saved to Field History ✓'), findsOneWidget);
    });

    testWidgets('ScanAnotherButton handles tap callback',
        (WidgetTester tester) async {
      bool scanTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScanAnotherButton(
              onScanAnother: () => scanTapped = true,
              isBn: false,
            ),
          ),
        ),
      );

      expect(find.text('Scan Another Plant'), findsOneWidget);
      await tester.tap(find.byType(ElevatedButton));
      expect(scanTapped, isTrue);
    });

    testWidgets('DetectionDisclaimer displays notice in English and Bangla',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DetectionDisclaimer(isBn: false),
          ),
        ),
      );

      expect(
          find.text(
              'AI predictions are estimates and should be verified when necessary.'),
          findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DetectionDisclaimer(isBn: true),
          ),
        ),
      );

      expect(find.textContaining('AI রোগ নির্ণয় একটি সম্ভাব্য অনুমান'),
          findsOneWidget);
    });

    testWidgets('ResultErrorView renders fallback when prediction is null',
        (WidgetTester tester) async {
      bool scanAnother = false;
      bool returnHome = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResultErrorView(
              errorMessage: 'Test error message',
              onScanAnother: () => scanAnother = true,
              onReturnHome: () => returnHome = true,
              isBn: false,
            ),
          ),
        ),
      );

      expect(find.text('No Prediction Available'), findsOneWidget);
      expect(find.text('Test error message'), findsOneWidget);

      await tester.tap(find.text('Scan Another Plant'));
      expect(scanAnother, isTrue);

      await tester.tap(find.text('Return Home'));
      expect(returnHome, isTrue);
    });
  });

  group('Screen 16 – DetectionResultScreen Integration Tests', () {
    testWidgets(
        'Renders Disease Detected flow with disease actions and save functionality',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final fakeHistory = FakeHistoryRepository();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          historyRepositoryProvider.overrideWithValue(fakeHistory),
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

      final diseasePrediction = PredictionModel(
        className: 'rice_brown_spot',
        cropName: 'Rice',
        diseaseNameEn: 'Brown Spot',
        diseaseNameBn: 'বাদামী দাগ রোগ',
        confidence: 0.885,
        predictedAt: DateTime.now(),
        modelVersion: '1.0.0',
      );

      // Pre-populate detectionProvider state
      container.read(detectionProvider.notifier).selectImage(tempImageFile.path);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: DetectionResultScreen(
              initialPrediction: diseasePrediction,
              initialImagePath: tempImageFile.path,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(DetectionResultHeader), findsOneWidget);
      expect(find.byType(ResultImageCard), findsOneWidget);
      expect(find.text('Disease Detected'), findsOneWidget);
      expect(find.text('Rice'), findsOneWidget);
      expect(find.text('Brown Spot'), findsOneWidget);
      expect(find.text('88.5%'), findsOneWidget);

      // Disease actions are present
      expect(find.byType(DiseaseActionsSection), findsOneWidget);
      expect(find.byType(HealthyActionsSection), findsNothing);

      // Tap Save Result
      await tester.ensureVisible(find.byType(SaveResultButton));
      await tester.tap(find.text('Save Result to Field Log'));
      await tester.pumpAndSettle();

      expect(fakeHistory.savedRecords.length, 1);
      expect(fakeHistory.savedRecords.first.predictedClass, 'rice_brown_spot');
      expect(find.text('Saved to Field History ✓'), findsOneWidget);

      // Tap Scan Another Plant
      await tester.ensureVisible(find.byType(ScanAnotherButton));
      await tester.tap(find.byType(ScanAnotherButton));
      await tester.pumpAndSettle();
    });

    testWidgets(
        'Renders Healthy flow with HealthyActionsSection and no disease treatments',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      final healthyPrediction = PredictionModel(
        className: 'rice_healthy',
        cropName: 'Rice',
        diseaseNameEn: 'Healthy Plant',
        diseaseNameBn: 'সুস্থ ধান গাছ',
        confidence: 0.961,
        predictedAt: DateTime.now(),
        modelVersion: '1.0.0',
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: DetectionResultScreen(
              initialPrediction: healthyPrediction,
              initialImagePath: tempImageFile.path,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Healthy Plant'), findsWidgets);
      expect(find.text('96.1%'), findsOneWidget);
      expect(find.byType(HealthyActionsSection), findsOneWidget);
      expect(find.byType(DiseaseActionsSection), findsNothing);
      expect(find.text('Your plant looks healthy!'), findsOneWidget);
    });
  });
}
