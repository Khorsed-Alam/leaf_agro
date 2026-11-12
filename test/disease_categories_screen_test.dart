import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:leaf_agro/data/models/crop_model.dart';
import 'package:leaf_agro/features/diseases/presentation/plant_disease_categories_screen.dart';
import 'package:leaf_agro/features/diseases/presentation/widgets/crop_filter_selector.dart';
import 'package:leaf_agro/features/diseases/presentation/widgets/crop_filter_chip.dart';
import 'package:leaf_agro/features/diseases/presentation/widgets/disease_category_card.dart';
import 'package:leaf_agro/features/diseases/presentation/widgets/disease_empty_state.dart';
import 'package:leaf_agro/features/diseases/presentation/widgets/disease_screen_header.dart';
import 'package:leaf_agro/features/diseases/presentation/widgets/disease_search_field.dart';
import 'package:leaf_agro/providers/crop_provider.dart';
import 'package:leaf_agro/providers/disease_provider.dart';
import 'package:leaf_agro/providers/settings_provider.dart';
import 'package:leaf_agro/data/datasources/ai_crop_catalog.dart';

class FakeCropNotifier extends CropNotifier {
  @override
  Future<List<CropModel>> build() async {
    return AiCropCatalog.verifiedSupportedCrops;
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'preferred_language': 'en'});
  });

  Widget buildTestableWidget({
    ProviderContainer? container,
    int? initialCropId,
  }) {
    return ProviderScope(
      parent: container,
      child: MaterialApp(
        home: PlantDiseaseCategoriesScreen(initialCropId: initialCropId),
      ),
    );
  }

  testWidgets('PlantDiseaseCategoriesScreen renders header, crop chips, search field, and disease cards',
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
        cropProvider.overrideWith(FakeCropNotifier.new),
        allDiseasesProvider.overrideWith((ref) => Future.value(AiCropCatalog.verifiedDiseases)),
      ],
    );

    await tester.pumpWidget(buildTestableWidget(container: container));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 1. Verify Header
    expect(find.byType(DiseaseScreenHeader), findsOneWidget);
    expect(find.text('Plant Diseases'), findsOneWidget);
    expect(find.text('Explore common diseases affecting crops.'), findsOneWidget);

    // 2. Verify Crop Filter Selector & Chips
    expect(find.byType(CropFilterSelector), findsOneWidget);
    expect(find.byType(CropFilterChip), findsWidgets);
    expect(find.text('All Crops'), findsOneWidget);
    expect(find.text('Rice'), findsWidgets);
    expect(find.text('Potato'), findsWidgets);
    expect(find.text('Tomato'), findsWidgets);
    expect(find.text('Mango'), findsWidgets);
    expect(find.text('Jute'), findsWidgets);

    // 3. Verify Search Field
    expect(find.byType(DiseaseSearchField), findsOneWidget);

    // 4. Verify Disease Cards loaded from actual database catalog
    expect(find.byType(DiseaseCategoryCard), findsWidgets);
    expect(find.text('Bacterial Leaf Blight'), findsOneWidget);
    expect(find.text('Brown Spot'), findsOneWidget);
  });

  testWidgets('Selecting a crop chip filters disease records exclusively to that crop',
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
        cropProvider.overrideWith(FakeCropNotifier.new),
        allDiseasesProvider.overrideWith((ref) => Future.value(AiCropCatalog.verifiedDiseases)),
      ],
    );

    await tester.pumpWidget(buildTestableWidget(container: container));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Tap on 'Rice' crop filter chip
    await tester.tap(find.widgetWithText(CropFilterChip, 'Rice'));
    await tester.pumpAndSettle();

    // Exactly 4 Rice diseases should be displayed
    expect(find.byType(DiseaseCategoryCard), findsNWidgets(4));
    expect(find.text('Bacterial Leaf Blight'), findsOneWidget);
    expect(find.text('Brown Spot'), findsOneWidget);
    expect(find.text('Leaf Smut'), findsOneWidget);
    expect(find.text('Healthy Rice Leaf'), findsOneWidget);

    // Potato diseases should NOT be shown
    expect(find.text('Early Blight'), findsNothing);

    // Tap on 'Mango' crop filter chip
    await tester.tap(find.widgetWithText(CropFilterChip, 'Mango'));
    await tester.pumpAndSettle();

    // Exactly 3 Mango diseases should be displayed
    expect(find.byType(DiseaseCategoryCard), findsNWidgets(3));
    expect(find.text('Bacterial Canker'), findsOneWidget);
    expect(find.text('Healthy Mango Leaf'), findsOneWidget);
  });

  testWidgets('Searching disease by name filters in real-time across crops',
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
        cropProvider.overrideWith(FakeCropNotifier.new),
        allDiseasesProvider.overrideWith((ref) => Future.value(AiCropCatalog.verifiedDiseases)),
      ],
    );

    await tester.pumpWidget(buildTestableWidget(container: container));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Search for 'Stem Rot'
    await tester.enterText(find.byType(TextField), 'Stem Rot');
    await tester.pumpAndSettle();

    // Only Jute Stem Rot should be visible in DiseaseCategoryCard
    expect(find.byType(DiseaseCategoryCard), findsOneWidget);
    expect(
      find.descendant(of: find.byType(DiseaseCategoryCard), matching: find.text('Stem Rot')),
      findsOneWidget,
    );
    expect(find.text('Jute'), findsWidgets);
  });

  testWidgets('Combined filter: Selected crop + search query restricts results accurately',
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
        cropProvider.overrideWith(FakeCropNotifier.new),
        allDiseasesProvider.overrideWith((ref) => Future.value(AiCropCatalog.verifiedDiseases)),
      ],
    );

    await tester.pumpWidget(buildTestableWidget(container: container));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Select 'Potato'
    await tester.tap(find.widgetWithText(CropFilterChip, 'Potato'));
    await tester.pumpAndSettle();

    // Search for 'Late Blight'
    await tester.enterText(find.byType(TextField), 'Late Blight');
    await tester.pumpAndSettle();

    // Exactly 1 match (Potato Late Blight, not Tomato Late Blight)
    expect(find.byType(DiseaseCategoryCard), findsOneWidget);
    expect(
      find.descendant(of: find.byType(DiseaseCategoryCard), matching: find.text('Late Blight')),
      findsOneWidget,
    );
    expect(find.text('Potato'), findsWidgets);
  });

  testWidgets('Displays No Matching Diseases empty state on query without results and clears cleanly',
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
        cropProvider.overrideWith(FakeCropNotifier.new),
        allDiseasesProvider.overrideWith((ref) => Future.value(AiCropCatalog.verifiedDiseases)),
      ],
    );

    await tester.pumpWidget(buildTestableWidget(container: container));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Search for non-existent disease
    await tester.enterText(find.byType(TextField), 'NonExistentPathology');
    await tester.pumpAndSettle();

    // Verify Empty State
    expect(find.byType(DiseaseEmptyState), findsOneWidget);
    expect(find.text('No Matching Diseases'), findsOneWidget);
    expect(find.text('Try another disease name or select a different crop.'), findsOneWidget);
    expect(find.text('Clear Search'), findsOneWidget);

    // Tap 'Clear Search'
    await tester.tap(find.text('Clear Search'));
    await tester.pumpAndSettle();

    // Disease cards restored
    expect(find.byType(DiseaseCategoryCard), findsWidgets);
  });
}
