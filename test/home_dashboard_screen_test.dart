import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:leaf_agro/features/home/presentation/home_screen.dart';
import 'package:leaf_agro/features/home/presentation/widgets/scan_plant_button.dart';
import 'package:leaf_agro/features/home/presentation/widgets/dashboard_statistics.dart';
import 'package:leaf_agro/features/home/presentation/widgets/dashboard_bottom_navigation.dart';
import 'package:leaf_agro/features/home/presentation/widgets/explore_crops_section.dart';
import 'package:leaf_agro/providers/settings_provider.dart';
import 'package:leaf_agro/providers/crop_provider.dart';
import 'package:leaf_agro/providers/history_provider.dart';
import 'package:leaf_agro/providers/notification_provider.dart';
import 'package:leaf_agro/data/models/crop_model.dart';
import 'package:leaf_agro/data/models/prediction_history_model.dart';

void main() {
  testWidgets('HomeScreen renders all 5 core dashboard sections and bottom navigation',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({'app_language': 'en'});
    final prefs = await SharedPreferences.getInstance();

    final testCrops = [
      const CropModel(
        id: 1,
        nameEn: 'Rice',
        nameBn: 'ধান',
        descriptionEn: 'Staple crop',
        descriptionBn: 'প্রধান খাদ্যশস্য',
      ),
      const CropModel(
        id: 4,
        nameEn: 'Mango',
        nameBn: 'আম',
        descriptionEn: 'King of Fruits',
        descriptionBn: 'ফলের রাজা',
      ),
      const CropModel(
        id: 2,
        nameEn: 'Potato',
        nameBn: 'আলু',
        descriptionEn: 'Tuber crop',
        descriptionBn: 'কন্দজাতীয় ফসল',
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          cropProvider.overrideWith(() => _MockCropNotifier(testCrops)),
          historyProvider.overrideWith(() => _MockHistoryNotifier([])),
          unreadNotificationsCountProvider.overrideWith((ref) => Future.value(0)),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    // Initial pump
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // 1. Verify Top Header Section
    expect(find.textContaining('Farmer'), findsWidgets);
    expect(find.text("Let's keep your crops healthy today."), findsOneWidget);
    expect(find.text('বাংলা'), findsOneWidget); // Language toggle option

    // 2. Verify Hero Plant Health Detection Section
    expect(find.text('Check Your Plant Health'), findsOneWidget);
    expect(find.text('Scan Plant'), findsOneWidget);
    expect(find.byType(ScanPlantButton), findsOneWidget);

    // 3. Verify Explore Crops Section
    expect(find.text('Explore Crops'), findsOneWidget);
    expect(find.byType(ExploreCropsSection), findsOneWidget);
    expect(find.text('Rice'), findsWidgets);

    // 4. Verify Recent Detections Section
    expect(find.text('Recent Detections'), findsOneWidget);
    expect(find.text('No diagnosis logs yet'), findsOneWidget);

    // 5. Verify Fixed Bottom Navigation Bar with 4 items
    expect(find.byType(DashboardBottomNavigation), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Detect'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('HomeScreen displays real statistics when scan records exist',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({'app_language': 'en'});
    final prefs = await SharedPreferences.getInstance();

    final testScans = [
      PredictionHistoryModel(
        id: '1',
        userId: 'test_user',
        predictedClass: 'Rice___Brown_Spot',
        confidence: 0.94,
        createdAt: DateTime.now(),
      ),
      PredictionHistoryModel(
        id: '2',
        userId: 'test_user',
        predictedClass: 'Tomato___Healthy',
        confidence: 0.98,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          cropProvider.overrideWith(() => _MockCropNotifier([])),
          historyProvider.overrideWith(() => _MockHistoryNotifier(testScans)),
          unreadNotificationsCountProvider.overrideWith((ref) => Future.value(0)),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Verify statistics section appears
    expect(find.byType(DashboardStatistics), findsOneWidget);
    expect(find.text('Total Scans'), findsOneWidget);
    expect(find.text('Healthy'), findsWidgets);
    expect(find.text('Diseased'), findsOneWidget);
    expect(find.text('2'), findsOneWidget); // Total count
    expect(find.text('1'), findsNWidgets(2)); // 1 healthy, 1 disease

    // Verify recent detection card displays parsed disease and confidence
    expect(find.text('Rice'), findsWidgets);
    expect(find.text('Brown Spot'), findsOneWidget);
    expect(find.textContaining('Confidence: 94%'), findsOneWidget);
  });
}

class _MockCropNotifier extends AsyncNotifier<List<CropModel>> implements CropNotifier {
  final List<CropModel> _crops;
  _MockCropNotifier(this._crops);

  @override
  Future<List<CropModel>> build() async => _crops;

  @override
  Future<List<CropModel>> loadCrops() async => _crops;

  @override
  Future<void> refresh() async {}
}

class _MockHistoryNotifier extends AsyncNotifier<List<PredictionHistoryModel>>
    implements HistoryNotifier {
  final List<PredictionHistoryModel> _history;
  _MockHistoryNotifier(this._history);

  @override
  Future<List<PredictionHistoryModel>> build() async => _history;

  @override
  Future<List<PredictionHistoryModel>> loadHistory() async => _history;

  @override
  Future<void> addScanRecord(PredictionHistoryModel model) async {}

  @override
  Future<void> deleteScanRecord(String id) async {
    _history.removeWhere((item) => item.id == id);
  }

  @override
  Future<void> refresh() async {}
}
