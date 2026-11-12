import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:leaf_agro/data/models/crop_model.dart';
import 'package:leaf_agro/data/datasources/ai_crop_catalog.dart';
import 'package:leaf_agro/features/search/presentation/global_search_screen.dart';
import 'package:leaf_agro/features/search/presentation/widgets/crop_search_result_card.dart';
import 'package:leaf_agro/features/search/presentation/widgets/disease_search_result_card.dart';
import 'package:leaf_agro/features/search/presentation/widgets/global_search_bar.dart';
import 'package:leaf_agro/features/search/presentation/widgets/popular_crop_card.dart';
import 'package:leaf_agro/features/search/presentation/widgets/popular_crops_section.dart';
import 'package:leaf_agro/features/search/presentation/widgets/recent_searches_section.dart';
import 'package:leaf_agro/features/search/presentation/widgets/search_empty_state.dart';
import 'package:leaf_agro/features/search/presentation/widgets/search_screen_header.dart';
import 'package:leaf_agro/features/search/presentation/widgets/search_suggestions_section.dart';
import 'package:leaf_agro/providers/crop_provider.dart';
import 'package:leaf_agro/providers/disease_provider.dart';
import 'package:leaf_agro/providers/settings_provider.dart';

class FakeCropNotifier extends CropNotifier {
  @override
  Future<List<CropModel>> build() async {
    return AiCropCatalog.verifiedSupportedCrops;
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'preferred_language': 'en',
      'recent_search_history': ['Rice', 'Potato'],
    });
  });

  Widget buildTestableWidget({
    ProviderContainer? container,
    String? initialQuery,
  }) {
    if (container != null) {
      return UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: GlobalSearchScreen(initialQuery: initialQuery),
        ),
      );
    }
    return ProviderScope(
      child: MaterialApp(
        home: GlobalSearchScreen(initialQuery: initialQuery),
      ),
    );
  }

  testWidgets('GlobalSearchScreen renders header, search bar, suggestions, recent searches, and popular crops',
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
    expect(find.byType(SearchScreenHeader), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);

    // 2. Verify Search Bar
    expect(find.byType(GlobalSearchBar), findsOneWidget);
    expect(find.text('Search crops or diseases...'), findsOneWidget);

    // 3. Verify Suggestions Section
    expect(find.byType(SearchSuggestionsSection), findsOneWidget);
    expect(find.text('Search Suggestions'), findsOneWidget);
    expect(find.text('Rice'), findsWidgets);
    expect(find.text('Potato'), findsWidgets);

    // 4. Verify Recent Searches Section
    expect(find.byType(RecentSearchesSection), findsOneWidget);
    expect(find.text('Recent Searches'), findsOneWidget);
    expect(find.text('Clear All'), findsOneWidget);

    // 5. Verify Popular Crops Section
    expect(find.byType(PopularCropsSection), findsOneWidget);
    expect(find.byType(PopularCropCard), findsWidgets);
  });

  testWidgets('Searching "Rice" returns matched crops and related diseases',
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

    // Enter "Rice" in the search text field
    final searchInput = find.byType(TextField);
    await tester.enterText(searchInput, 'Rice');
    // Debounce timer is 300ms
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    // Verify Crop result card
    expect(find.byType(CropSearchResultCard), findsWidgets);
    expect(find.descendant(of: find.byType(CropSearchResultCard), matching: find.text('Rice')), findsOneWidget);

    // Verify Disease result cards associated with Rice (e.g. Bacterial Leaf Blight, Brown Spot)
    expect(find.byType(DiseaseSearchResultCard), findsWidgets);
  });

  testWidgets('Searching a disease name "Late Blight" returns disease card with crop badge',
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

    final searchInput = find.byType(TextField);
    await tester.enterText(searchInput, 'Late Blight');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.byType(DiseaseSearchResultCard), findsWidgets);
    expect(find.descendant(of: find.byType(DiseaseSearchResultCard), matching: find.text('Late Blight')), findsNWidgets(2));
  });

  testWidgets('Searching non-existent query displays SearchEmptyState and Clear Search resets it',
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

    final searchInput = find.byType(TextField);
    await tester.enterText(searchInput, 'NonExistentCropOrDisease12345');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    // Verify empty state
    expect(find.byType(SearchEmptyState), findsOneWidget);
    expect(find.text('No Results Found'), findsOneWidget);

    // Tap "Clear Search" button
    final clearButton = find.text('Clear Search');
    expect(clearButton, findsOneWidget);
    await tester.tap(clearButton);
    await tester.pumpAndSettle();

    // Should return to suggestions and popular crops
    expect(find.byType(SearchSuggestionsSection), findsOneWidget);
    expect(find.byType(PopularCropsSection), findsOneWidget);
  });

  testWidgets('Tapping a suggestion chip executes search immediately',
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

    // Tap on the 'Late Blight' suggestion chip
    final suggestionChip = find.descendant(
      of: find.byType(SearchSuggestionsSection),
      matching: find.text('Late Blight'),
    );
    expect(suggestionChip, findsOneWidget);
    await tester.tap(suggestionChip);
    await tester.pumpAndSettle();

    // Results should show Late Blight
    expect(find.byType(DiseaseSearchResultCard), findsWidgets);
  });

  testWidgets('Tapping "Clear All" on recent searches clears the recent list',
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

    expect(find.byType(RecentSearchesSection), findsOneWidget);
    final clearAllBtn = find.text('Clear All');
    expect(clearAllBtn, findsOneWidget);

    await tester.tap(clearAllBtn);
    await tester.pumpAndSettle();

    // Recent searches section should be hidden when empty
    expect(find.byType(RecentSearchesSection), findsNothing);
  });
}
