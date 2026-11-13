import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leaf_agro/data/models/crop_model.dart';
import 'package:leaf_agro/features/detection/presentation/camera_screen.dart';
import 'package:leaf_agro/features/detection/presentation/widgets/camera/camera_bottom_controls.dart';
import 'package:leaf_agro/features/detection/presentation/widgets/camera/camera_capture_button.dart';
import 'package:leaf_agro/features/detection/presentation/widgets/camera/camera_error_state.dart';
import 'package:leaf_agro/features/detection/presentation/widgets/camera/camera_loading_state.dart';
import 'package:leaf_agro/features/detection/presentation/widgets/camera/camera_permission_state.dart';
import 'package:leaf_agro/features/detection/presentation/widgets/camera/camera_switch_button.dart';
import 'package:leaf_agro/features/detection/presentation/widgets/camera/camera_top_controls.dart';
import 'package:leaf_agro/features/detection/presentation/widgets/camera/flash_toggle_button.dart';
import 'package:leaf_agro/features/detection/presentation/widgets/camera/gallery_shortcut_button.dart';
import 'package:leaf_agro/features/detection/presentation/widgets/camera/leaf_positioning_guide.dart';
import 'package:leaf_agro/providers/crop_provider.dart';
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

  setUp(() async {
    SharedPreferences.setMockInitialValues({'preferred_language': 'en'});
    prefs = await SharedPreferences.getInstance();
  });

  group('Screen 12 – Camera Widgets Unit & Widget Tests', () {
    testWidgets('LeafPositioningGuide displays instructions in English and Bangla',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LeafPositioningGuide(isBn: false),
          ),
        ),
      );

      expect(find.text('Place the leaf inside the frame'), findsOneWidget);
      expect(find.text('Hold steady & avoid glare / heavy shadow'), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LeafPositioningGuide(isBn: true),
          ),
        ),
      );

      expect(find.text('পাতার অংশটি ফ্রেমের ভেতরে রাখুন'), findsOneWidget);
      expect(find.text('হাত স্থির রাখুন এবং ঝাপসা বা আলো এড়ান'), findsOneWidget);
    });

    testWidgets('FlashToggleButton cycles through modes correctly',
        (WidgetTester tester) async {
      FlashMode current = FlashMode.off;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return FlashToggleButton(
                  currentMode: current,
                  hasFlash: true,
                  onModeChanged: (newMode) {
                    setState(() => current = newMode);
                  },
                  isBn: false,
                );
              },
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.flash_off_rounded), findsOneWidget);

      // Tap to cycle to torch
      await tester.tap(find.byType(FlashToggleButton));
      await tester.pumpAndSettle();
      expect(current, FlashMode.torch);
      expect(find.byIcon(Icons.flash_on_rounded), findsOneWidget);

      // Tap to cycle to auto
      await tester.tap(find.byType(FlashToggleButton));
      await tester.pumpAndSettle();
      expect(current, FlashMode.auto);
      expect(find.byIcon(Icons.flash_auto_rounded), findsOneWidget);

      // Tap to cycle back to off
      await tester.tap(find.byType(FlashToggleButton));
      await tester.pumpAndSettle();
      expect(current, FlashMode.off);
      expect(find.byIcon(Icons.flash_off_rounded), findsOneWidget);
    });

    testWidgets('CameraCaptureButton handles tap and shows loading spinner when busy',
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CameraCaptureButton(
              onCapture: () => tapped = true,
              isCapturing: false,
              isBn: false,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.camera_alt_rounded), findsOneWidget);
      await tester.tap(find.byType(CameraCaptureButton));
      expect(tapped, isTrue);

      // Test capturing state
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CameraCaptureButton(
              onCapture: null,
              isCapturing: true,
              isBn: false,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt_rounded), findsNothing);
    });

    testWidgets('GalleryShortcutButton and CameraSwitchButton render labels and handle clicks',
        (WidgetTester tester) async {
      bool galleryTapped = false;
      bool switchTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                GalleryShortcutButton(
                  onOpenGallery: () => galleryTapped = true,
                  isBn: true,
                ),
                CameraSwitchButton(
                  onSwitch: () => switchTapped = true,
                  hasMultipleCameras: true,
                  isBn: true,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('গ্যালারি'), findsOneWidget);
      expect(find.text('ক্যামেরা'), findsOneWidget);

      await tester.tap(find.byType(GalleryShortcutButton));
      expect(galleryTapped, isTrue);

      await tester.tap(find.byType(CameraSwitchButton));
      expect(switchTapped, isTrue);
    });

    testWidgets('CameraTopControls shows crop badge and handles close',
        (WidgetTester tester) async {
      bool closed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CameraTopControls(
              onClose: () => closed = true,
              flashMode: FlashMode.off,
              hasFlash: true,
              onFlashModeChanged: (_) {},
              selectedCropName: 'ধান (Rice)',
              isBn: true,
            ),
          ),
        ),
      );

      expect(find.text('ধান (Rice)'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      expect(closed, isTrue);
    });

    testWidgets('CameraBottomControls renders full control bar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CameraBottomControls(
              onCapture: () {},
              onOpenGallery: () {},
              onSwitchCamera: () {},
              hasMultipleCameras: true,
              isBn: false,
            ),
          ),
        ),
      );

      expect(find.byType(GalleryShortcutButton), findsOneWidget);
      expect(find.byType(CameraCaptureButton), findsOneWidget);
      expect(find.byType(CameraSwitchButton), findsOneWidget);
    });

    testWidgets('CameraLoadingState renders loading indicator and localized text',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CameraLoadingState(isBn: false),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Initializing camera...'), findsOneWidget);
    });

    testWidgets('CameraPermissionState displays permission actions in English and Bangla',
        (WidgetTester tester) async {
      bool permissionRequested = false;
      bool galleryOpened = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CameraPermissionState(
              onRequestPermission: () => permissionRequested = true,
              onOpenGallery: () => galleryOpened = true,
              onClose: () {},
              isBn: false,
            ),
          ),
        ),
      );

      expect(find.text('Camera Permission Required'), findsOneWidget);
      expect(find.text('Grant Permission'), findsOneWidget);
      expect(find.text('Choose from Gallery'), findsOneWidget);

      await tester.tap(find.text('Grant Permission'));
      expect(permissionRequested, isTrue);

      await tester.tap(find.text('Choose from Gallery'));
      expect(galleryOpened, isTrue);
    });

    testWidgets('CameraErrorState displays error description and retry options',
        (WidgetTester tester) async {
      bool retryTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CameraErrorState(
              errorMessage: 'Hardware sensor timeout',
              onRetry: () => retryTapped = true,
              onOpenGallery: () {},
              onClose: () {},
              isBn: false,
            ),
          ),
        ),
      );

      expect(find.text('Camera Unavailable'), findsOneWidget);
      expect(find.text('Hardware sensor timeout'), findsOneWidget);
      expect(find.text('Retry Camera'), findsOneWidget);

      await tester.tap(find.text('Retry Camera'));
      expect(retryTapped, isTrue);
    });
  });

  group('CameraScreen Full Widget Tests', () {
    testWidgets('CameraScreen shows loading state when autoInitialize is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const MaterialApp(
            home: CameraScreen(
              autoInitialize: false,
            ),
          ),
        ),
      );

      expect(find.byType(CameraLoadingState), findsOneWidget);
      expect(find.byType(CameraTopControls), findsOneWidget);
      expect(find.byType(CameraBottomControls), findsOneWidget);
    });

    testWidgets('CameraScreen shows CameraErrorState when empty camera list is provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const MaterialApp(
            home: CameraScreen(
              cameras: [],
              autoInitialize: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(CameraErrorState), findsOneWidget);
      expect(find.text('No camera hardware found on this device.'), findsOneWidget);
    });

    testWidgets('CameraScreen displays selected crop badge in top controls',
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
            home: CameraScreen(
              cameras: [],
              autoInitialize: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Rice'), findsOneWidget);
    });
  });
}
