import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leaf_agro/core/theme/app_colors.dart';
import 'package:leaf_agro/data/datasources/ai_crop_catalog.dart';
import 'package:leaf_agro/data/models/crop_model.dart';
import 'package:leaf_agro/data/models/prediction_history_model.dart';
import 'package:leaf_agro/features/history/presentation/history_detail_screen.dart';
import 'package:leaf_agro/features/history/presentation/widgets/details/confidence_score_card.dart';
import 'package:leaf_agro/features/history/presentation/widgets/details/crop_information_card.dart';
import 'package:leaf_agro/features/history/presentation/widgets/details/delete_history_confirmation_dialog.dart';
import 'package:leaf_agro/features/history/presentation/widgets/details/disease_information_section.dart';
import 'package:leaf_agro/features/history/presentation/widgets/details/historical_guidance_action_cards.dart';
import 'package:leaf_agro/features/history/presentation/widgets/details/historical_prediction_card.dart';
import 'package:leaf_agro/features/history/presentation/widgets/details/historical_record_banner.dart';
import 'package:leaf_agro/features/history/presentation/widgets/details/original_scan_date_card.dart';
import 'package:leaf_agro/features/history/presentation/widgets/details/original_scan_image_card.dart';
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

  @override
  Future<void> deleteScanRecord(String id) async {
    _scans.removeWhere((s) => s.id == id);
    state = AsyncValue.data(List.unmodifiable(_scans));
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

  final testScanDiseased = PredictionHistoryModel(
    id: 'scan_101',
    userId: 'user_xyz',
    diseaseId: 302,
    predictedClass: 'Tomato___Early_blight',
    confidence: 0.942,
    imagePath: null,
    modelVersion: '1.0.0',
    createdAt: DateTime(2026, 11, 10, 10, 35),
    syncStatus: 'synced',
  );

  final testScanHealthy = PredictionHistoryModel(
    id: 'scan_102',
    userId: 'user_xyz',
    diseaseId: null,
    predictedClass: 'Rice___healthy',
    confidence: 0.985,
    imagePath: null,
    modelVersion: '1.0.0',
    createdAt: DateTime(2026, 11, 12, 14, 20),
    syncStatus: 'synced',
  );

  final testScanNoConfidence = PredictionHistoryModel(
    id: 'scan_103',
    userId: 'user_xyz',
    diseaseId: null,
    predictedClass: 'UnknownCrop___healthy',
    confidence: 0.0,
    imagePath: null,
    modelVersion: '1.0.0',
    createdAt: DateTime(2026, 11, 12, 14, 20),
    syncStatus: 'synced',
  );

  Widget createTestWidget({
    required String scanId,
    PredictionHistoryModel? initialScan,
    List<PredictionHistoryModel>? customScans,
    String language = 'en',
  }) {
    prefs.setString('preferred_language', language);
    final list = customScans ?? [testScanDiseased, testScanHealthy];

    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        historyProvider.overrideWith(() => _FakeHistoryNotifier(list)),
        cropProvider.overrideWith(() => _FakeCropNotifier()),
      ],
      child: MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.forestGreen),
          useMaterial3: true,
        ),
        home: HistoryDetailScreen(
          scanId: scanId,
          initialScan: initialScan,
        ),
      ),
    );
  }

  group('Screen 23: History Details Screen Tests', () {
    testWidgets('Header renders Previous Prediction banner and Historical Details headline',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(scanId: 'scan_101'));
      await tester.pumpAndSettle();

      expect(find.text('History Details'), findsOneWidget);
      expect(find.byType(HistoricalRecordBanner), findsOneWidget);
      expect(find.text('Previous Prediction'), findsOneWidget);
      expect(
        find.text('This result is from your saved scan history.'),
        findsOneWidget,
      );
    });

    testWidgets('OriginalScanImageCard displays caption and fallback when image is missing',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(scanId: 'scan_101'));
      await tester.pumpAndSettle();

      expect(find.byType(OriginalScanImageCard), findsOneWidget);
      expect(find.text('Original Scan Image'), findsOneWidget);
      expect(find.text('Original Image Unavailable'), findsOneWidget);
    });

    testWidgets('CropInformationCard renders authentic crop information',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(scanId: 'scan_101'));
      await tester.pumpAndSettle();

      expect(find.byType(CropInformationCard), findsOneWidget);
      expect(find.text('Crop'), findsOneWidget);
      expect(find.text('Tomato (টমেটো)'), findsOneWidget);
    });

    testWidgets('HistoricalPredictionCard renders disease detection state accurately',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(scanId: 'scan_101'));
      await tester.pumpAndSettle();

      expect(find.byType(HistoricalPredictionCard), findsOneWidget);
      expect(find.text('Disease Detected'), findsOneWidget);
      expect(find.text('Early Blight'), findsOneWidget);
    });

    testWidgets('HistoricalPredictionCard renders healthy prediction state cleanly',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(scanId: 'scan_102'));
      await tester.pumpAndSettle();

      expect(find.byType(HistoricalPredictionCard), findsOneWidget);
      expect(find.text('Healthy Prediction'), findsOneWidget);
      expect(find.text('Foliage appears healthy'), findsOneWidget);
    });

    testWidgets('ConfidenceScoreCard displays exact percentage and progress indicator',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(scanId: 'scan_101'));
      await tester.pumpAndSettle();

      expect(find.byType(ConfidenceScoreCard), findsOneWidget);
      expect(find.text('AI Confidence'), findsOneWidget);
      expect(find.text('94.2%'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('ConfidenceScoreCard gracefully handles missing confidence',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        createTestWidget(
          scanId: 'scan_103',
          customScans: [testScanNoConfidence],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ConfidenceScoreCard), findsOneWidget);
      expect(find.text('Unavailable'), findsOneWidget);
    });

    testWidgets('OriginalScanDateCard renders original date and time',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(scanId: 'scan_101'));
      await tester.pumpAndSettle();

      expect(find.byType(OriginalScanDateCard), findsOneWidget);
      expect(find.text('Original Scan Date'), findsOneWidget);
      expect(find.text('Scan Time'), findsOneWidget);
      expect(find.text('10 November 2026'), findsOneWidget);
      expect(find.text('10:35 AM'), findsOneWidget);
    });

    testWidgets('DiseaseInformationSection displays disease symptoms for diseased records',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(scanId: 'scan_101'));
      await tester.pumpAndSettle();

      expect(find.byType(DiseaseInformationSection), findsOneWidget);
      expect(find.text('About This Disease'), findsOneWidget);
    });

    testWidgets('HistoricalGuidanceActionCards renders Treatment, Prevention, and Recovery links',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(scanId: 'scan_101'));
      await tester.pumpAndSettle();

      expect(find.byType(HistoricalGuidanceActionCards), findsOneWidget);
      expect(find.text('Treatment Recommendations'), findsOneWidget);
      expect(find.text('Prevention & Plant Care'), findsOneWidget);
      expect(find.text('Plant Recovery & Follow-up'), findsOneWidget);
    });

    testWidgets('Bottom action area displays Scan Again and Delete History buttons',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(scanId: 'scan_101'));
      await tester.pumpAndSettle();

      expect(find.text('Scan Again'), findsOneWidget);
      expect(find.text('Delete History'), findsOneWidget);
    });

    testWidgets('Delete confirmation dialog opens and cancels safely',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(scanId: 'scan_101'));
      await tester.pumpAndSettle();

      final deleteButton = find.text('Delete History');
      await tester.ensureVisible(deleteButton);
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      expect(find.byType(DeleteHistoryConfirmationDialog), findsOneWidget);
      expect(find.text('Delete This History Record?'), findsOneWidget);

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Dialog dismissed, record still intact
      expect(find.byType(DeleteHistoryConfirmationDialog), findsNothing);
      expect(find.text('Tomato (টমেটো)'), findsOneWidget);
    });

    testWidgets('Displays Not Found view when scanId does not exist',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(scanId: 'non_existent_id'));
      await tester.pumpAndSettle();

      expect(find.text('Historical Record Not Found'), findsOneWidget);
      expect(find.text('Back to History'), findsOneWidget);
    });

    testWidgets('Bangla localization renders correctly', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        createTestWidget(
          scanId: 'scan_101',
          language: 'bn',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ইতিহাসের বিস্তারিত'), findsOneWidget);
      expect(find.text('পূর্ববর্তী এআই ফলাফল'), findsOneWidget);
      expect(find.text('সংরক্ষিত মূল ছবি'), findsOneWidget);
      expect(find.text('ফসল'), findsOneWidget);
      expect(find.text('রোগ শনাক্ত হয়েছে'), findsOneWidget);
      expect(find.text('এআই নিশ্চিততা'), findsOneWidget);
      expect(find.text('পরীক্ষার তারিখ'), findsOneWidget);
      expect(find.text('পরীক্ষার সময়'), findsOneWidget);
    });
  });
}
