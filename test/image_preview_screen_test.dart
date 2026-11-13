import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leaf_agro/data/models/crop_model.dart';
import 'package:leaf_agro/data/models/prediction_model.dart';
import 'package:leaf_agro/data/repositories/detection_repository.dart';
import 'package:leaf_agro/features/detection/presentation/image_preview_screen.dart';
import 'package:leaf_agro/features/detection/presentation/widgets/preview/analyze_image_button.dart';
import 'package:leaf_agro/features/detection/presentation/widgets/preview/image_preview_actions.dart';
import 'package:leaf_agro/features/detection/presentation/widgets/preview/image_preview_error_state.dart';
import 'package:leaf_agro/features/detection/presentation/widgets/preview/image_preview_header.dart';
import 'package:leaf_agro/features/detection/presentation/widgets/preview/image_quality_status.dart';
import 'package:leaf_agro/features/detection/presentation/widgets/preview/image_review_instruction.dart';
import 'package:leaf_agro/features/detection/presentation/widgets/preview/selected_crop_info.dart';
import 'package:leaf_agro/features/detection/presentation/widgets/preview/selected_leaf_image.dart';
import 'package:leaf_agro/providers/crop_provider.dart';
import 'package:leaf_agro/providers/detection_provider.dart';
import 'package:leaf_agro/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeDetectionRepository implements DetectionRepository {
  bool shouldThrow = false;

  @override
  Future<void> initializeModel() async {}

  @override
  Future<PredictionModel> detectPlantDisease(String imagePath) async {
    if (shouldThrow) {
      throw Exception('Neural network inference failed');
    }
    return PredictionModel(
      className: 'rice_leaf_blast',
      cropName: 'Rice',
      diseaseNameEn: 'Leaf Blast',
      diseaseNameBn: 'পাতার ব্লাস্ট রোগ',
      confidence: 0.94,
      predictedAt: DateTime.now(),
      modelVersion: '1.0.0',
    );
  }
}

class MockImagePicker extends ImagePicker {
  XFile? returnValue;
  ImageSource? lastRequestedSource;

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    lastRequestedSource = source;
    return returnValue;
  }
}

void main() {
  late SharedPreferences prefs;
  late File tempImageFile;

  setUpAll(() {
    final tempDir = Directory.systemTemp.createTempSync('leaf_preview_test');
    tempImageFile = File('${tempDir.path}/test_preview_sample.jpg');
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

  group('Screen 14 – Preview Widgets Unit & Widget Tests', () {
    testWidgets('ImagePreviewHeader displays title, subtitle, and handles onBack',
        (WidgetTester tester) async {
      bool backTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImagePreviewHeader(
              isBn: false,
              onBack: () => backTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Review Your Image'), findsOneWidget);
      expect(find.text('Sample Preview'), findsOneWidget);

      await tester.tap(find.byType(InkWell));
      expect(backTapped, isTrue);

      // Bengali
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImagePreviewHeader(
              isBn: true,
              onBack: () {},
            ),
          ),
        ),
      );

      expect(find.text('আপনার ছবি পর্যালোচনা করুন'), findsOneWidget);
      expect(find.text('নমুনা প্রিভিউ'), findsOneWidget);
    });

    testWidgets('SelectedCropInfo displays crop name or hides when null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SelectedCropInfo(
              selectedCrop: CropModel(
                id: 1,
                nameEn: 'Rice',
                nameBn: 'ধান',
                descriptionEn: 'Paddy',
                descriptionBn: 'ধান',
                isActive: true,
              ),
              isBn: false,
            ),
          ),
        ),
      );

      expect(find.text('Selected Crop'), findsOneWidget);
      expect(find.text('Rice'), findsOneWidget);
      expect(find.text('AI Ready'), findsOneWidget);

      // Null case should hide
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SelectedCropInfo(
              selectedCrop: null,
              isBn: false,
            ),
          ),
        ),
      );

      expect(find.text('Selected Crop'), findsNothing);
    });

    testWidgets('SelectedLeafImage renders image viewport and handles non-existent file',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SelectedLeafImage(
              imagePath: tempImageFile.path,
              isBn: false,
            ),
          ),
        ),
      );

      expect(find.text('Ready'), findsOneWidget);

      // Non-existent file
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SelectedLeafImage(
              imagePath: '/non/existent/path/to/missing.jpg',
              isBn: false,
            ),
          ),
        ),
      );

      expect(find.text('Unable to read this image file'), findsOneWidget);
    });

    testWidgets('ImageQualityStatus displays ready, warning, and error states',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ImageQualityStatus(
              state: QualityState.ready,
              isBn: false,
            ),
          ),
        ),
      );

      expect(find.text('Image Ready'), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ImageQualityStatus(
              state: QualityState.warning,
              isBn: false,
            ),
          ),
        ),
      );

      expect(find.text('Image Quality Warning'), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ImageQualityStatus(
              state: QualityState.error,
              isBn: false,
            ),
          ),
        ),
      );

      expect(find.text('Unable to Read Image'), findsOneWidget);
    });

    testWidgets('ImageReviewInstruction displays guidance text in English and Bangla',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ImageReviewInstruction(isBn: false),
          ),
        ),
      );

      expect(find.text('Make sure the leaf is clearly visible.'), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ImageReviewInstruction(isBn: true),
          ),
        ),
      );

      expect(find.text('পাতার অংশটি স্পষ্টভাবে দেখা যাচ্ছে কিনা নিশ্চিত করুন।'), findsOneWidget);
    });

    testWidgets('ImagePreviewActions triggers retake and change image callbacks',
        (WidgetTester tester) async {
      bool retakeTapped = false;
      bool changeTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImagePreviewActions(
              onRetakePhoto: () => retakeTapped = true,
              onChooseAnotherImage: () => changeTapped = true,
              isBn: false,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Retake Photo'));
      expect(retakeTapped, isTrue);

      await tester.tap(find.text('Change Image'));
      expect(changeTapped, isTrue);
    });

    testWidgets('AnalyzeImageButton handles tap and loading state',
        (WidgetTester tester) async {
      bool analyzeTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalyzeImageButton(
              onAnalyze: () => analyzeTapped = true,
              state: AnalyzeButtonState.ready,
              isBn: false,
            ),
          ),
        ),
      );

      expect(find.text('Analyze Leaf with AI'), findsOneWidget);
      await tester.tap(find.byType(ElevatedButton));
      expect(analyzeTapped, isTrue);

      // Analyzing busy state
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnalyzeImageButton(
              onAnalyze: null,
              state: AnalyzeButtonState.analyzing,
              isBn: false,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Analyzing Leaf with AI...'), findsOneWidget);
    });
  });

  group('ImagePreviewScreen Full Integration Tests', () {
    testWidgets('Displays ImagePreviewErrorState when imagePath is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const MaterialApp(
            home: ImagePreviewScreen(),
          ),
        ),
      );

      expect(find.byType(ImagePreviewErrorState), findsOneWidget);
      expect(find.text('No Image Selected'), findsOneWidget);
      expect(find.text('Take Photo with Camera'), findsOneWidget);
      expect(find.text('Choose from Gallery'), findsOneWidget);
    });

    testWidgets('Displays full preview layout when imagePath is provided',
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

      // Set initial image
      container.read(detectionProvider.notifier).selectImage(tempImageFile.path);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ImagePreviewScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ImagePreviewHeader), findsOneWidget);
      expect(find.byType(SelectedCropInfo), findsOneWidget);
      expect(find.text('Rice'), findsOneWidget);
      expect(find.byType(SelectedLeafImage), findsOneWidget);
      expect(find.byType(ImageQualityStatus), findsOneWidget);
      expect(find.byType(ImageReviewInstruction), findsOneWidget);
      expect(find.byType(ImagePreviewActions), findsOneWidget);
      expect(find.byType(AnalyzeImageButton), findsOneWidget);
    });

    testWidgets('Tapping Analyze triggers detection inference on detectionProvider',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final fakeRepo = FakeDetectionRepository();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          detectionRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      container.read(detectionProvider.notifier).selectImage(tempImageFile.path);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ImagePreviewScreen(),
          ),
        ),
      );

      await tester.pump();

      // Tap Analyze button
      await tester.tap(find.byType(AnalyzeImageButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      final state = container.read(detectionProvider);
      expect(state.status, DetectionStatus.success);
      expect(state.prediction?.diseaseNameEn, 'Leaf Blast');
    });

    testWidgets('Retake Photo and Change Image update preview with mock picker',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockPicker = MockImagePicker();
      mockPicker.returnValue = XFile(tempImageFile.path);

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      container.read(detectionProvider.notifier).selectImage(tempImageFile.path);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: ImagePreviewScreen(
              imagePicker: mockPicker,
            ),
          ),
        ),
      );

      await tester.pump();

      // Tap Retake
      await tester.ensureVisible(find.text('Retake Photo'));
      await tester.tap(find.text('Retake Photo'));
      await tester.pump();
      expect(mockPicker.lastRequestedSource, ImageSource.camera);

      // Tap Change Image
      await tester.ensureVisible(find.text('Change Image'));
      await tester.tap(find.text('Change Image'));
      await tester.pump();
      expect(mockPicker.lastRequestedSource, ImageSource.gallery);
    });
  });
}
