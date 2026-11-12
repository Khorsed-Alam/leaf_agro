import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:leaf_agro/features/crops/presentation/crop_selection_screen.dart';
import 'package:leaf_agro/features/crops/presentation/widgets/continue_button.dart';
import 'package:leaf_agro/features/crops/presentation/widgets/crop_search_field.dart';
import 'package:leaf_agro/features/crops/presentation/widgets/crop_selection_card.dart';
import 'package:leaf_agro/features/crops/presentation/widgets/empty_crop_search_state.dart';
import 'package:leaf_agro/data/datasources/ai_crop_catalog.dart';
import 'package:leaf_agro/providers/crop_provider.dart';
import 'package:leaf_agro/providers/settings_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'preferred_language': 'en'});
  });

  Widget buildTestableWidget({
    String language = 'en',
    ProviderContainer? container,
  }) {
    return ProviderScope(
      parent: container,
      child: const MaterialApp(
        home: CropSelectionScreen(),
      ),
    );
  }

  testWidgets('CropSelectionScreen renders header, search field, 5 AI crops, and disabled Continue button',
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

    await tester.pumpWidget(buildTestableWidget(container: container));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // 1. Verify Header
    expect(find.text('Select Your Crop'), findsOneWidget);
    expect(find.text('Choose the plant you want to examine with AI vision.'), findsOneWidget);

    // 2. Verify Search field
    expect(find.byType(CropSearchField), findsOneWidget);

    // 3. Verify exactly 5 verified AI-supported crops exist
    expect(find.byType(CropSelectionCard), findsNWidgets(5));
    expect(find.text('Rice'), findsOneWidget);
    expect(find.text('Potato'), findsOneWidget);
    expect(find.text('Tomato'), findsOneWidget);
    expect(find.text('Mango'), findsOneWidget);
    expect(find.text('Jute'), findsOneWidget);

    // Verify all 5 are recognized in the AI catalog
    for (final name in ['Rice', 'Potato', 'Tomato', 'Mango', 'Jute']) {
      expect(AiCropCatalog.isSupported(name), isTrue);
    }

    // 4. Verify Continue button is initially disabled
    expect(find.byType(ContinueButton), findsOneWidget);
    expect(find.text('Select a Crop to Continue'), findsOneWidget);
  });

  testWidgets('Selecting a crop enables Continue button and highlights card',
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

    await tester.pumpWidget(buildTestableWidget(container: container));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Tap on 'Rice'
    await tester.tap(find.text('Rice'));
    await tester.pumpAndSettle();

    // Verify Continue button is now enabled and shows selected crop
    expect(find.text('Continue to Scan'), findsOneWidget);
    expect(find.textContaining('Rice'), findsWidgets);

    // Tap on 'Tomato' to test single-selection change
    await tester.tap(find.text('Tomato'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Tomato'), findsWidgets);
  });

  testWidgets('Searching crops filters grid in real-time and shows empty state on no match',
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

    await tester.pumpWidget(buildTestableWidget(container: container));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Enter search query for 'Mango'
    await tester.enterText(find.byType(TextField), 'Mango');
    await tester.pumpAndSettle();

    // Only 1 crop card should be displayed with 'Mango'
    expect(find.byType(CropSelectionCard), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(CropSelectionCard),
        matching: find.text('Mango'),
      ),
      findsOneWidget,
    );
    expect(find.text('Rice'), findsNothing);

    // Search for a crop that is NOT supported (e.g. 'Apple')
    await tester.enterText(find.byType(TextField), 'Apple');
    await tester.pumpAndSettle();

    // Should display empty state
    expect(find.byType(EmptyCropSearchState), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(EmptyCropSearchState),
        matching: find.textContaining('Apple'),
      ),
      findsOneWidget,
    );

    // Tap Clear Search button
    await tester.tap(find.text('Clear Search'));
    await tester.pumpAndSettle();

    // All 5 crops should be restored
    expect(find.byType(CropSelectionCard), findsNWidgets(5));
  });

  testWidgets('Bilingual search supports searching in Bengali (e.g. ধান)',
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

    await tester.pumpWidget(buildTestableWidget(container: container));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Search in Bangla for ধান
    await tester.enterText(find.byType(TextField), 'ধান');
    await tester.pumpAndSettle();

    expect(find.byType(CropSelectionCard), findsOneWidget);
    expect(find.text('Rice'), findsOneWidget);
  });
}
