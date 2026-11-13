import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leaf_agro/core/theme/app_colors.dart';
import 'package:leaf_agro/data/datasources/ai_crop_catalog.dart';
import 'package:leaf_agro/data/models/crop_model.dart';
import 'package:leaf_agro/data/models/prediction_history_model.dart';
import 'package:leaf_agro/features/history/presentation/history_screen.dart';
import 'package:leaf_agro/features/history/presentation/widgets/detection_history_card.dart';
import 'package:leaf_agro/features/history/presentation/widgets/detection_statistics_grid.dart';
import 'package:leaf_agro/features/history/presentation/widgets/empty_history_view.dart';
import 'package:leaf_agro/features/history/presentation/widgets/history_header.dart';
import 'package:leaf_agro/features/history/presentation/widgets/no_matching_results_view.dart';
import 'package:leaf_agro/features/home/presentation/widgets/dashboard_bottom_navigation.dart';
import 'package:leaf_agro/providers/crop_provider.dart';
import 'package:leaf_agro/providers/history_provider.dart';
import 'package:leaf_agro/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeHistoryNotifier extends HistoryNotifier {
  final List<PredictionHistoryModel> _scans;
  _FakeHistoryNotifier(this._scans);

  @override
  Future<List<PredictionHistoryModel>> build() async {
    return _scans;
  }
}

class _FakeCropNotifier extends CropNotifier {
  @override
  Future<List<CropModel>> build() async {
    return AiCropCatalog.verifiedSupportedCrops;
  }
}

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'preferred_language': 'en'});
    prefs = await SharedPreferences.getInstance();
  });

  final now = DateTime.now();

  final testScans = [
    PredictionHistoryModel(
      id: 'scan_001',
      userId: 'farmer_1',
      diseaseId: 101,
      predictedClass: 'Tomato___Early_blight',
      confidence: 0.942,
      imagePath: null,
      modelVersion: '1.0.0',
      createdAt: now.subtract(const Duration(hours: 3)),
      syncStatus: 'synced',
    ),
    PredictionHistoryModel(
      id: 'scan_002',
      userId: 'farmer_1',
      diseaseId: null,
      predictedClass: 'Rice___healthy',
      confidence: 0.985,
      imagePath: null,
      modelVersion: '1.0.0',
      createdAt: now.subtract(const Duration(days: 2)),
      syncStatus: 'synced',
    ),
    PredictionHistoryModel(
      id: 'scan_003',
      userId: 'farmer_1',
      diseaseId: 102,
      predictedClass: 'Potato___Late_blight',
      confidence: 0.887,
      imagePath: null,
      modelVersion: '1.0.0',
      createdAt: now.subtract(const Duration(days: 15)),
      syncStatus: 'synced',
    ),
  ];

  Widget createTestWidget({
    List<PredictionHistoryModel> scans = const [],
    String language = 'en',
  }) {
    prefs.setString('preferred_language', language);

    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        historyProvider.overrideWith(() => _FakeHistoryNotifier(scans)),
        cropProvider.overrideWith(() => _FakeCropNotifier()),
      ],
      child: MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.forestGreen),
          useMaterial3: true,
        ),
        home: const HistoryScreen(),
      ),
    );
  }

  group('Screen 22: Detection History Dashboard Tests', () {
    testWidgets('Header renders title, subtitle, and bottom navigation with History active',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(scans: testScans));
      await tester.pumpAndSettle();

      expect(find.byType(HistoryHeader), findsOneWidget);
      expect(find.text('Detection History'), findsOneWidget);
      expect(
        find.text('View and manage your previous plant health scans.'),
        findsOneWidget,
      );

      final bottomNav = tester.widget<DashboardBottomNavigation>(
        find.byType(DashboardBottomNavigation),
      );
      expect(bottomNav.selectedIndex, 2);
    });

    testWidgets('Statistics grid calculates authentic total, diseased, healthy, and recent scans',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(scans: testScans));
      await tester.pumpAndSettle();

      expect(find.byType(DetectionStatisticsGrid), findsOneWidget);
      expect(find.text('Total Scans'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);

      expect(
        find.descendant(
          of: find.byType(DetectionStatisticsGrid),
          matching: find.text('Diseased'),
        ),
        findsOneWidget,
      );
      expect(find.text('2'), findsNWidgets(2)); // 2 diseased, 2 recent

      expect(
        find.descendant(
          of: find.byType(DetectionStatisticsGrid),
          matching: find.text('Healthy'),
        ),
        findsOneWidget,
      );
      expect(find.text('1'), findsOneWidget);

      expect(find.text('Recent (7d)'), findsOneWidget);
    });

    testWidgets('Detection cards render crop, disease, confidence, and date accurately',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(scans: testScans));
      await tester.pumpAndSettle();

      expect(find.byType(DetectionHistoryCard), findsNWidgets(3));
      expect(find.text('Tomato'), findsOneWidget);
      expect(find.text('Early blight'), findsOneWidget);
      expect(find.text('Confidence: 94.2%'), findsOneWidget);

      expect(find.text('Rice'), findsOneWidget);
      expect(find.text('Healthy Plant'), findsOneWidget);
      expect(find.text('Confidence: 98.5%'), findsOneWidget);

      expect(find.text('Potato'), findsOneWidget);
      expect(find.text('Late blight'), findsOneWidget);
      expect(find.text('Confidence: 88.7%'), findsOneWidget);
    });

    testWidgets('Search query filters scan records by crop name dynamically',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(scans: testScans));
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'Tomato');
      await tester.pumpAndSettle();

      expect(find.byType(DetectionHistoryCard), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(DetectionHistoryCard),
          matching: find.text('Tomato'),
        ),
        findsOneWidget,
      );
      expect(find.text('Rice'), findsNothing);
      expect(find.text('Potato'), findsNothing);
    });

    testWidgets('Search query filters scan records by disease name',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(scans: testScans));
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'Late blight');
      await tester.pumpAndSettle();

      expect(find.byType(DetectionHistoryCard), findsOneWidget);
      expect(find.text('Potato'), findsOneWidget);
      expect(find.text('Tomato'), findsNothing);
    });

    testWidgets('Search query filters healthy plant scans', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(scans: testScans));
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'healthy');
      await tester.pumpAndSettle();

      expect(find.byType(DetectionHistoryCard), findsOneWidget);
      expect(find.text('Rice'), findsOneWidget);
    });

    testWidgets('Displays EmptyHistoryView when total scans list is empty',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(scans: []));
      await tester.pumpAndSettle();

      expect(find.byType(EmptyHistoryView), findsOneWidget);
      expect(find.text('No Detection History Yet'), findsOneWidget);
      expect(find.text('Scan Your First Plant'), findsOneWidget);
      expect(find.byType(DetectionHistoryCard), findsNothing);
    });

    testWidgets('Displays NoMatchingResultsView when search query matches nothing',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(scans: testScans));
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'Banana');
      await tester.pumpAndSettle();

      expect(find.byType(NoMatchingResultsView), findsOneWidget);
      expect(find.text('No Matching Results'), findsOneWidget);
      expect(find.text('Clear Filters'), findsOneWidget);
      expect(find.byType(DetectionHistoryCard), findsNothing);

      // Tap clear filters to restore
      await tester.tap(find.text('Clear Filters'));
      await tester.pumpAndSettle();

      expect(find.byType(DetectionHistoryCard), findsNWidgets(3));
    });

    testWidgets('Bangla localization renders correctly', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(scans: testScans, language: 'bn'));
      await tester.pumpAndSettle();

      expect(find.text('শনাক্তকরণ ইতিহাস'), findsOneWidget);
      expect(find.text('মোট স্ক্যান'), findsOneWidget);
      expect(find.text('রোগ শনাক্ত'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(DetectionStatisticsGrid),
          matching: find.text('সুস্থ উদ্ভিদ'),
        ),
        findsOneWidget,
      );
    });
  });
}
