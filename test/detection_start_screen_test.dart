import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:leaf_agro/data/models/prediction_model.dart';
import 'package:leaf_agro/data/repositories/detection_repository.dart';
import 'package:leaf_agro/data/datasources/ai_crop_catalog.dart';
import 'package:leaf_agro/features/detection/presentation/detection_start_screen.dart';
import 'package:leaf_agro/features/detection/presentation/widgets/ai_scanning_illustration.dart';
import 'package:leaf_agro/features/detection/presentation/widgets/detection_action_card.dart';
import 'package:leaf_agro/features/detection/presentation/widgets/detection_screen_header.dart';
import 'package:leaf_agro/features/detection/presentation/widgets/image_quality_guide.dart';
import 'package:leaf_agro/features/detection/presentation/widgets/offline_ai_status_indicator.dart';
import 'package:leaf_agro/features/detection/presentation/widgets/selected_crop_context_bar.dart';
import 'package:leaf_agro/providers/crop_provider.dart';
import 'package:leaf_agro/providers/detection_provider.dart';
import 'package:leaf_agro/providers/settings_provider.dart';

class FakeDetectionRepository implements DetectionRepository {
  @override
  Future<void> initializeModel() async {}

  @override
  Future<PredictionModel> detectPlantDisease(String imagePath) async {
    return PredictionModel(
      className: 'rice_healthy',
      cropName: 'Rice',
      diseaseNameEn: 'Healthy',
      diseaseNameBn: 'সুস্থ',
      confidence: 0.95,
      predictedAt: DateTime.now(),
      modelVersion: '1.0.0',
    );
  }
}

class MockImagePicker extends ImagePicker {
  XFile? returnValue;
  PlatformException? exceptionToThrow;
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
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
    return returnValue;
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'preferred_language': 'en'});
  });

  Widget buildTestableWidget({
    ProviderContainer? container,
    ImagePicker? imagePicker,
  }) {
    if (container != null) {
      return UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: DetectionStartScreen(
            imagePicker: imagePicker,
            animateIllustration: false,
          ),
        ),
      );
    }
    return ProviderScope(
      child: MaterialApp(
        home: DetectionStartScreen(
          imagePicker: imagePicker,
          animateIllustration: false,
        ),
      ),
    );
  }

  testWidgets('DetectionStartScreen renders header, crop context, illustration, action cards, quality guide, and offline indicator',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        detectionRepositoryProvider.overrideWithValue(FakeDetectionRepository()),
      ],
    );

    await tester.pumpWidget(buildTestableWidget(container: container));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 1. Verify Header
    expect(find.byType(DetectionScreenHeader), findsOneWidget);
    expect(find.text('Detect Plant Disease'), findsOneWidget);
    expect(find.text('Take or upload a clear leaf photo to identify possible plant diseases.'), findsOneWidget);

    // 2. Verify Crop Context Bar
    expect(find.byType(SelectedCropContextBar), findsOneWidget);
    expect(find.text('All crops supported • Select crop for higher accuracy'), findsOneWidget);

    // 3. Verify AI Scanning Illustration
    expect(find.byType(AiScanningIllustration), findsOneWidget);
    expect(find.text('AI Leaf Scanner • 224x224 Edge Model'), findsOneWidget);

    // 4. Verify Action Cards
    expect(find.byType(DetectionActionCard), findsNWidgets(2));
    expect(find.text('Take Photo'), findsOneWidget);
    expect(find.text('Capture a leaf photo using your camera.'), findsOneWidget);
    expect(find.text('Choose from Gallery'), findsOneWidget);
    expect(find.text('Select an existing leaf photo from your device.'), findsOneWidget);

    // 5. Verify Image Quality Guide & 4 Tips
    expect(find.byType(ImageQualityGuide), findsOneWidget);
    expect(find.text('Tips for a Better Result'), findsOneWidget);
    expect(find.text('Use good lighting'), findsOneWidget);
    expect(find.text('Keep the leaf in focus'), findsOneWidget);
    expect(find.text('Avoid blurry images'), findsOneWidget);
    expect(find.text('Capture the affected area clearly'), findsOneWidget);

    // 6. Verify Offline AI Availability Indicator
    expect(find.byType(OfflineAiStatusIndicator), findsOneWidget);
    expect(find.text('AI detection available on this device'), findsOneWidget);
  });

  testWidgets('Selected crop context bar displays target crop information when crop is selected',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final riceCrop = AiCropCatalog.verifiedSupportedCrops.first;
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        selectedCropProvider.overrideWith((ref) => riceCrop),
        detectionRepositoryProvider.overrideWithValue(FakeDetectionRepository()),
      ],
    );

    await tester.pumpWidget(buildTestableWidget(container: container));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Rice'), findsOneWidget);
    expect(find.text('AI Ready'), findsOneWidget);
    expect(find.text('${riceCrop.supportedDiseaseCount} diseases supported by AI model'), findsOneWidget);
    expect(find.text('Change'), findsOneWidget);
  });

  testWidgets('Tapping Take Photo triggers camera picker and selects valid image',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Create a temporary valid image file synchronously
    final tempDir = Directory.systemTemp;
    final tempImage = File('${tempDir.path}/test_leaf_image.jpg');
    tempImage.writeAsBytesSync(List.filled(2048, 1));
    addTearDown(() {
      if (tempImage.existsSync()) {
        tempImage.deleteSync();
      }
    });

    final mockPicker = MockImagePicker()..returnValue = XFile(tempImage.path);
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        detectionRepositoryProvider.overrideWithValue(FakeDetectionRepository()),
      ],
    );

    await tester.pumpWidget(buildTestableWidget(container: container, imagePicker: mockPicker));
    await tester.pump();

    // Tap "Take Photo"
    final takePhotoButton = find.text('Take Photo');
    expect(takePhotoButton, findsOneWidget);
    await tester.tap(takePhotoButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(mockPicker.lastRequestedSource, ImageSource.camera);
    // Verify detection state updated with image path
    expect(container.read(detectionProvider).imagePath, tempImage.path);
    expect(container.read(detectionProvider).status, DetectionStatus.imageSelected);
  });

  testWidgets('Tapping Choose from Gallery triggers gallery picker and selects valid image',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final tempDir = Directory.systemTemp;
    final tempImage = File('${tempDir.path}/test_gallery_leaf.png');
    tempImage.writeAsBytesSync(List.filled(1024, 2));
    addTearDown(() {
      if (tempImage.existsSync()) {
        tempImage.deleteSync();
      }
    });

    final mockPicker = MockImagePicker()..returnValue = XFile(tempImage.path);
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        detectionRepositoryProvider.overrideWithValue(FakeDetectionRepository()),
      ],
    );

    await tester.pumpWidget(buildTestableWidget(container: container, imagePicker: mockPicker));
    await tester.pump();

    // Tap "Choose from Gallery"
    final galleryButton = find.text('Choose from Gallery');
    expect(galleryButton, findsOneWidget);
    await tester.tap(galleryButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(mockPicker.lastRequestedSource, ImageSource.gallery);
    expect(container.read(detectionProvider).imagePath, tempImage.path);
  });

  testWidgets('User cancellation of camera returns safely without errors',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final mockPicker = MockImagePicker()..returnValue = null;
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        detectionRepositoryProvider.overrideWithValue(FakeDetectionRepository()),
      ],
    );

    await tester.pumpWidget(buildTestableWidget(container: container, imagePicker: mockPicker));
    await tester.pump();

    await tester.tap(find.text('Take Photo'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(mockPicker.lastRequestedSource, ImageSource.camera);
    expect(container.read(detectionProvider).imagePath, isNull);
    expect(find.byType(DetectionStartScreen), findsOneWidget);
  });

  testWidgets('Camera permission denied displays user-friendly SnackBar without crashing',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final mockPicker = MockImagePicker()
      ..exceptionToThrow = PlatformException(
        code: 'camera_access_denied',
        message: 'Camera permission was denied.',
      );

    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        detectionRepositoryProvider.overrideWithValue(FakeDetectionRepository()),
      ],
    );

    await tester.pumpWidget(buildTestableWidget(container: container, imagePicker: mockPicker));
    await tester.pump();

    await tester.tap(find.text('Take Photo'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Camera access is required to take a photo.'), findsOneWidget);
  });

  testWidgets('Screen layout is responsive and does not overflow on compact mobile devices',
      (WidgetTester tester) async {
    // Standard compact Android device (360 x 640 logical pixels)
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        detectionRepositoryProvider.overrideWithValue(FakeDetectionRepository()),
      ],
    );

    await tester.pumpWidget(buildTestableWidget(container: container));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Must render with no RenderFlex overflow
    expect(find.byType(DetectionStartScreen), findsOneWidget);
    expect(find.byType(DetectionActionCard), findsNWidgets(2));
  });
}
