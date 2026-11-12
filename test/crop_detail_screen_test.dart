import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:leaf_agro/features/crops/presentation/crop_detail_screen.dart';
import 'package:leaf_agro/features/crops/presentation/widgets/crop_hero_section.dart';
import 'package:leaf_agro/features/crops/presentation/widgets/crop_information_section.dart';
import 'package:leaf_agro/features/crops/presentation/widgets/common_diseases_section.dart';
import 'package:leaf_agro/features/crops/presentation/widgets/disease_thumbnail_card.dart';
import 'package:leaf_agro/features/crops/presentation/widgets/crop_care_tips_section.dart';
import 'package:leaf_agro/features/crops/presentation/widgets/detect_crop_disease_button.dart';
import 'package:leaf_agro/providers/crop_provider.dart';
import 'package:leaf_agro/providers/settings_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'preferred_language': 'en'});
  });

  Widget buildTestableWidget({
    required int cropId,
    ProviderContainer? container,
  }) {
    return ProviderScope(
      parent: container,
      child: MaterialApp(
        home: CropDetailScreen(cropId: cropId),
      ),
    );
  }

  testWidgets('CropDetailScreen renders Rice (initial example) with all required sections and data',
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
      ],
    );

    // Load CropDetailScreen with cropId = 1 (Rice)
    await tester.pumpWidget(buildTestableWidget(cropId: 1, container: container));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 1. Verify Top Navigation & Title
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('Rice Profile'), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_border), findsOneWidget);

    // 2. Verify CropHeroSection
    expect(find.byType(CropHeroSection), findsOneWidget);
    expect(find.text('Rice'), findsWidgets);
    expect(find.text('ধান'), findsWidgets);
    expect(find.textContaining('staple crops in Bangladesh'), findsOneWidget);
    expect(find.text('AI Supported • 4 Diseases'), findsOneWidget);

    // 3. Verify CropInformationSection & Agronomic Cards
    expect(find.byType(CropInformationSection), findsOneWidget);
    expect(find.text('Crop Information'), findsOneWidget);
    expect(find.text('Category'), findsOneWidget);
    expect(find.text('Cereal Grain'), findsWidgets);
    expect(find.text('Growing Season'), findsOneWidget);
    expect(find.text('Aus, Aman, and Boro'), findsOneWidget);

    // 4. Verify CommonDiseasesSection with 4 mapped Rice diseases
    expect(find.byType(CommonDiseasesSection), findsOneWidget);
    expect(find.text('Common Diseases'), findsOneWidget);
    expect(find.text('Bacterial Leaf Blight'), findsOneWidget);
    expect(find.text('Brown Spot'), findsOneWidget);
    expect(find.text('Leaf Smut'), findsOneWidget);
    expect(find.text('Healthy Rice Leaf'), findsOneWidget);
    expect(find.byType(DiseaseThumbnailCard), findsNWidgets(4));

    // 5. Verify CropCareTipsSection with Rice care guidelines
    expect(find.byType(CropCareTipsSection), findsOneWidget);
    expect(find.text('Crop Care Tips'), findsOneWidget);
    expect(find.text('Standing Water Depth'), findsOneWidget);
    expect(find.text('Balanced Urea Application'), findsOneWidget);

    // 6. Verify Prominent Disease Detection Button
    expect(find.byType(DetectCropDiseaseButton), findsOneWidget);
    expect(find.text('Detect Rice Disease'), findsOneWidget);
  });

  testWidgets('CropDetailScreen reusability: renders Mango (cropId: 4) with mapped diseases and dynamic CTA',
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
      ],
    );

    // Load CropDetailScreen with cropId = 4 (Mango)
    await tester.pumpWidget(buildTestableWidget(cropId: 4, container: container));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Mango name and title
    expect(find.text('Mango Profile'), findsOneWidget);
    expect(find.text('Mango'), findsWidgets);
    expect(find.text('আম'), findsWidgets);

    // Verify Mango Diseases: Anthracnose, Bacterial Canker, Healthy Mango Leaf
    expect(find.text('Anthracnose'), findsOneWidget);
    expect(find.text('Bacterial Canker'), findsOneWidget);
    expect(find.text('Healthy Mango Leaf'), findsOneWidget);
    expect(find.byType(DiseaseThumbnailCard), findsNWidgets(3));

    // Verify Dynamic CTA for Mango
    expect(find.text('Detect Mango Disease'), findsOneWidget);
  });

  testWidgets('CropDetailScreen reusability: renders Potato (cropId: 2) with Late Blight and dynamic CTA',
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
      ],
    );

    // Load CropDetailScreen with cropId = 2 (Potato)
    await tester.pumpWidget(buildTestableWidget(cropId: 2, container: container));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Potato name and title
    expect(find.text('Potato Profile'), findsOneWidget);
    expect(find.text('Potato'), findsWidgets);
    expect(find.text('আলু'), findsWidgets);

    // Verify Potato Diseases: Early Blight, Late Blight, Healthy
    expect(find.text('Early Blight'), findsOneWidget);
    expect(find.text('Late Blight'), findsOneWidget);
    expect(find.text('Healthy Potato Leaf'), findsOneWidget);

    // Verify Dynamic CTA for Potato
    expect(find.text('Detect Potato Disease'), findsOneWidget);
  });

  testWidgets('Tapping Bookmark icon toggles bookmark state with feedback',
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
      ],
    );

    await tester.pumpWidget(buildTestableWidget(cropId: 1, container: container));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Initially unbookmarked
    expect(find.byIcon(Icons.bookmark_border), findsOneWidget);

    // Tap bookmark button
    await tester.tap(find.byIcon(Icons.bookmark_border));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Should now show bookmarked icon
    expect(find.byIcon(Icons.bookmark), findsOneWidget);
    expect(find.text('Crop added to bookmarks.'), findsOneWidget);
  });

  testWidgets('Tapping Detect Disease button sets selectedCropProvider in Riverpod',
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
      ],
    );

    await tester.pumpWidget(buildTestableWidget(cropId: 1, container: container));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Tap on Detect Rice Disease
    await tester.tap(find.text('Detect Rice Disease'));
    await tester.pump();

    // Verify selectedCropProvider has been updated with Rice
    final selectedCrop = container.read(selectedCropProvider);
    expect(selectedCrop, isNotNull);
    expect(selectedCrop?.nameEn, 'Rice');
    expect(selectedCrop?.id, 1);
  });

  testWidgets('CropDetailScreen renders Crop Not Found state when invalid ID is provided',
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
        cropByIdProvider(9999).overrideWith((ref) => Future.value(null)),
      ],
    );

    await tester.pumpWidget(buildTestableWidget(cropId: 9999, container: container));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Crop Not Found'), findsOneWidget);
    expect(find.text('Back to Crop Selection'), findsOneWidget);
  });
}
