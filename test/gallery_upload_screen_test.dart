import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leaf_agro/data/models/crop_model.dart';
import 'package:leaf_agro/features/detection/presentation/gallery_upload_screen.dart';
import 'package:leaf_agro/features/detection/presentation/widgets/gallery/gallery_continue_button.dart';
import 'package:leaf_agro/features/detection/presentation/widgets/gallery/gallery_header.dart';
import 'package:leaf_agro/features/detection/presentation/widgets/gallery/gallery_selection_card.dart';
import 'package:leaf_agro/features/detection/presentation/widgets/gallery/selected_image_preview_card.dart';
import 'package:leaf_agro/features/detection/presentation/widgets/image_quality_guide.dart';
import 'package:leaf_agro/providers/crop_provider.dart';
import 'package:leaf_agro/providers/detection_provider.dart';
import 'package:leaf_agro/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final tempDir = Directory.systemTemp.createTempSync('leaf_gallery_test');
    tempImageFile = File('${tempDir.path}/test_leaf_sample.jpg');
    // Write standard 1x1 dummy JPEG bytes
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

  group('Screen 13 – Gallery Widgets Unit & Widget Tests', () {
    testWidgets('GalleryHeader displays title, subtitle, crop badge, and handles onBack',
        (WidgetTester tester) async {
      bool backTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GalleryHeader(
              isBn: false,
              selectedCropName: 'Rice',
              onBack: () => backTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Choose a Plant Image'), findsOneWidget);
      expect(find.text('Select a clear leaf image from your device.'), findsOneWidget);
      expect(find.text('Rice'), findsOneWidget);

      await tester.tap(find.byType(InkWell));
      expect(backTapped, isTrue);

      // Bengali localization test
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GalleryHeader(
              isBn: true,
              selectedCropName: 'ধান',
              onBack: () {},
            ),
          ),
        ),
      );

      expect(find.text('গাছের ছবি নির্বাচন করুন'), findsOneWidget);
      expect(find.text('আপনার ডিভাইস থেকে পাতার স্পষ্ট ছবি নির্বাচন করুন।'), findsOneWidget);
      expect(find.text('ধান'), findsOneWidget);
    });

    testWidgets('GallerySelectionCard renders UI elements and handles tap',
        (WidgetTester tester) async {
      bool browseTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GallerySelectionCard(
              onBrowse: () => browseTapped = true,
              isBusy: false,
              isBn: false,
            ),
          ),
        ),
      );

      expect(find.text('Select from Gallery'), findsOneWidget);
      expect(find.text('Browse Gallery'), findsOneWidget);
      expect(find.byIcon(Icons.photo_library_rounded), findsOneWidget);

      await tester.tap(find.text('Browse Gallery'));
      expect(browseTapped, isTrue);

      // Busy state test
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GallerySelectionCard(
              onBrowse: null,
              isBusy: true,
              isBn: false,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Opening Gallery...'), findsOneWidget);
    });

    testWidgets('SelectedImagePreviewCard renders photo, metadata, and Change Image action',
        (WidgetTester tester) async {
      bool changeTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SelectedImagePreviewCard(
              imagePath: tempImageFile.path,
              fileSizeBytes: 2048,
              fileName: 'test_leaf_sample.jpg',
              onChangeImage: () => changeTapped = true,
              isBusy: false,
              isBn: false,
            ),
          ),
        ),
      );

      expect(find.text('Selected Plant Image'), findsOneWidget);
      expect(find.text('Ready'), findsOneWidget);
      expect(find.text('Change Image'), findsOneWidget);
      expect(find.text('test_leaf_sample.jpg'), findsOneWidget);
      expect(find.text('•  2.0 KB'), findsOneWidget);

      await tester.tap(find.text('Change Image'));
      expect(changeTapped, isTrue);
    });

    testWidgets('GalleryContinueButton handles enabled, disabled, and loading states',
        (WidgetTester tester) async {
      bool continueTapped = false;

      // Disabled State
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GalleryContinueButton(
              onContinue: () => continueTapped = true,
              isEnabled: false,
              isLoading: false,
              isBn: false,
            ),
          ),
        ),
      );

      expect(find.text('Continue'), findsOneWidget);
      await tester.tap(find.byType(ElevatedButton));
      expect(continueTapped, isFalse);

      // Enabled State
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GalleryContinueButton(
              onContinue: () => continueTapped = true,
              isEnabled: true,
              isLoading: false,
              isBn: false,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      expect(continueTapped, isTrue);

      // Loading State
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GalleryContinueButton(
              onContinue: null,
              isEnabled: true,
              isLoading: true,
              isBn: false,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Continue'), findsNothing);
    });
  });

  group('GalleryUploadScreen Full Flow Tests', () {
    testWidgets('Initially renders empty state with selection card and quality guide',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const MaterialApp(
            home: GalleryUploadScreen(),
          ),
        ),
      );

      expect(find.byType(GalleryHeader), findsOneWidget);
      expect(find.byType(GallerySelectionCard), findsOneWidget);
      expect(find.byType(ImageQualityGuide), findsOneWidget);
      expect(find.byType(SelectedImagePreviewCard), findsNothing);
      expect(find.byType(GalleryContinueButton), findsOneWidget);
    });

    testWidgets('Picking an image via MockImagePicker updates UI to SelectedImagePreviewCard and enables Continue',
        (WidgetTester tester) async {
      final mockPicker = MockImagePicker();
      mockPicker.returnValue = XFile(tempImageFile.path);

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: GalleryUploadScreen(
              imagePicker: mockPicker,
            ),
          ),
        ),
      );

      // Tap Browse Gallery
      await tester.tap(find.text('Browse Gallery'));
      await tester.pumpAndSettle();

      // Should now display preview card and hide selection card
      expect(find.byType(SelectedImagePreviewCard), findsOneWidget);
      expect(find.byType(GallerySelectionCard), findsNothing);

      // Tap Continue
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Verify detectionProvider was updated with selected file
      final detectionState = container.read(detectionProvider);
      expect(detectionState.imagePath, tempImageFile.path);
    });

    testWidgets('Gracefully handles user cancellation when picking image',
        (WidgetTester tester) async {
      final mockPicker = MockImagePicker();
      mockPicker.returnValue = null; // User cancelled native picker

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: MaterialApp(
            home: GalleryUploadScreen(
              imagePicker: mockPicker,
            ),
          ),
        ),
      );

      // Tap Browse Gallery
      await tester.tap(find.text('Browse Gallery'));
      await tester.pumpAndSettle();

      // Remains in selection card without error
      expect(find.byType(GallerySelectionCard), findsOneWidget);
      expect(find.byType(SelectedImagePreviewCard), findsNothing);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('Displays crop badge in header when selectedCropProvider is active',
        (WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          selectedCropProvider.overrideWith((ref) => const CropModel(
                id: 1,
                nameEn: 'Rice',
                nameBn: 'ধান',
                descriptionEn: 'Paddy crop',
                descriptionBn: 'ধান ফসল',
                imageUrl: 'https://example.com/rice.jpg',
                isActive: true,
              )),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: GalleryUploadScreen(),
          ),
        ),
      );

      expect(find.text('Rice'), findsOneWidget);
    });
  });
}
