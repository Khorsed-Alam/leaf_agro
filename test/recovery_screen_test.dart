import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leaf_agro/core/theme/app_colors.dart';
import 'package:leaf_agro/data/models/plant_observation_model.dart';
import 'package:leaf_agro/data/models/prediction_history_model.dart';
import 'package:leaf_agro/features/recovery/presentation/recovery_screen.dart';
import 'package:leaf_agro/features/recovery/presentation/widgets/follow_up_reminder_card.dart';
import 'package:leaf_agro/features/recovery/presentation/widgets/follow_up_suggestions_section.dart';
import 'package:leaf_agro/features/recovery/presentation/widgets/latest_observation_card.dart';
import 'package:leaf_agro/features/recovery/presentation/widgets/observation_timeline_section.dart';
import 'package:leaf_agro/features/recovery/presentation/widgets/original_detection_card.dart';
import 'package:leaf_agro/features/recovery/presentation/widgets/recovery_disclaimer_card.dart';
import 'package:leaf_agro/features/recovery/presentation/widgets/recovery_header.dart';
import 'package:leaf_agro/features/recovery/presentation/widgets/scan_again_section.dart';
import 'package:leaf_agro/providers/history_provider.dart';
import 'package:leaf_agro/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'preferred_language': 'en'});
    prefs = await SharedPreferences.getInstance();
  });

  final testScanDiseased = PredictionHistoryModel(
    id: 'scan_001',
    userId: 'farmer_123',
    diseaseId: 101,
    predictedClass: 'Tomato___Early_blight',
    confidence: 0.945,
    imagePath: null,
    modelVersion: '1.0.0',
    createdAt: DateTime(2026, 11, 10, 10, 30),
    syncStatus: 'synced',
  );

  final testScanHealthy = PredictionHistoryModel(
    id: 'scan_002',
    userId: 'farmer_123',
    diseaseId: null,
    predictedClass: 'Rice___healthy',
    confidence: 0.982,
    imagePath: null,
    modelVersion: '1.0.0',
    createdAt: DateTime(2026, 11, 12, 14, 15),
    syncStatus: 'synced',
  );

  final testObservation = PlantObservationModel(
    id: 'obs_001',
    scanId: 'scan_001',
    userId: 'farmer_123',
    cropName: 'Tomato',
    conditionLabel: FarmerConditionLabel.lookingBetter,
    notes: 'Noticed fresh green shoots; blight lesions seem dry and stopped spreading.',
    nextInspectionDate: DateTime(2026, 11, 18, 9, 0),
    createdAt: DateTime(2026, 11, 13, 9, 30),
    syncStatus: 'synced',
  );

  Widget createTestWidget({
    PredictionHistoryModel? scan,
    List<PlantObservationModel>? observations,
    bool isBn = false,
  }) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        if (scan != null)
          historyProvider.overrideWith(
            () => _FakeHistoryNotifier([scan]),
          ),
      ],
      child: MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.forestGreen),
          useMaterial3: true,
        ),
        home: RecoveryScreen(
          scanId: scan?.id,
          initialScan: scan,
          initialObservations: observations ?? [],
        ),
      ),
    );
  }

  group('Screen 21: Plant Recovery & Follow-up Tests', () {
    testWidgets('Header renders title and subtitle correctly', (tester) async {
      await tester.pumpWidget(createTestWidget(scan: testScanDiseased));
      await tester.pumpAndSettle();

      expect(find.byType(RecoveryHeader), findsOneWidget);
      expect(find.text('Plant Recovery & Follow-up'), findsOneWidget);
      expect(
        find.text("Keep track of your plant's condition over time"),
        findsOneWidget,
      );
    });

    testWidgets('OriginalDetectionCard renders authentic disease scan information',
        (tester) async {
      await tester.pumpWidget(createTestWidget(scan: testScanDiseased));
      await tester.pumpAndSettle();

      expect(find.byType(OriginalDetectionCard), findsOneWidget);
      expect(find.text('Original Detection'), findsOneWidget);
      expect(find.text('Tomato'), findsOneWidget);
      expect(find.text('Early blight'), findsOneWidget);
      expect(find.text('Original AI Record'), findsOneWidget);
      expect(find.text('94.5%'), findsOneWidget);
      expect(find.text('Disease Detected'), findsOneWidget);
    });

    testWidgets('OriginalDetectionCard handles healthy plant scans cleanly',
        (tester) async {
      await tester.pumpWidget(createTestWidget(scan: testScanHealthy));
      await tester.pumpAndSettle();

      expect(find.byType(OriginalDetectionCard), findsOneWidget);
      expect(find.text('Rice'), findsOneWidget);
      expect(find.text('Healthy Plant'), findsOneWidget);
      expect(find.text('98.2%'), findsOneWidget);
      expect(find.text('Healthy'), findsOneWidget);
    });

    testWidgets('OriginalDetectionCard displays empty state when no scan exists',
        (tester) async {
      await tester.pumpWidget(createTestWidget(scan: null));
      await tester.pumpAndSettle();

      expect(find.text('No Previous Scan Found'), findsOneWidget);
      expect(find.text('Start a New Scan'), findsOneWidget);
    });

    testWidgets('LatestObservationCard displays latest farmer note and condition badge',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          scan: testScanDiseased,
          observations: [testObservation],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LatestObservationCard), findsOneWidget);
      expect(find.text('Your Latest Observation'), findsOneWidget);
      expect(find.text('Farmer Self-Reported'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(LatestObservationCard),
          matching: find.text('Looking Better'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(LatestObservationCard),
          matching: find.text(
              'Noticed fresh green shoots; blight lesions seem dry and stopped spreading.'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('LatestObservationCard shows friendly empty state when no notes exist',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          scan: testScanDiseased,
          observations: [],
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text("You haven't recorded a follow-up observation yet."),
        findsOneWidget,
      );
    });

    testWidgets('FollowUpSuggestionsSection renders all 5 practical inspection topics',
        (tester) async {
      await tester.pumpWidget(createTestWidget(scan: testScanDiseased));
      await tester.pumpAndSettle();

      expect(find.byType(FollowUpSuggestionsSection), findsOneWidget);
      expect(find.text('Follow-up Inspection'), findsOneWidget);
      expect(find.text('Leaf Appearance'), findsOneWidget);
      expect(find.text('New Leaf Growth'), findsOneWidget);
      expect(find.text('Spread of Symptoms'), findsOneWidget);
      expect(find.text('Overall Plant Condition'), findsOneWidget);
      expect(find.text('Treatment & Care Actions'), findsOneWidget);
    });

    testWidgets('FollowUpReminderCard renders scheduled date and allows setting reminder',
        (tester) async {
      await tester.pumpWidget(createTestWidget(scan: testScanDiseased));
      await tester.pumpAndSettle();

      expect(find.byType(FollowUpReminderCard), findsOneWidget);
      expect(find.text('Time to Check Your Plant Again?'), findsOneWidget);
      expect(find.text('Set Follow-up Reminder'), findsOneWidget);
    });

    testWidgets('RecordObservationCard validates empty notes before submission',
        (tester) async {
      await tester.pumpWidget(createTestWidget(scan: testScanDiseased));
      await tester.pumpAndSettle();

      final saveButton = find.widgetWithText(ElevatedButton, 'Save Observation');
      expect(saveButton, findsOneWidget);

      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(
        find.text('Please enter a brief note describing what you noticed.'),
        findsOneWidget,
      );
    });

    testWidgets('ObservationTimelineSection displays both initial AI scan and farmer note',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          scan: testScanDiseased,
          observations: [testObservation],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ObservationTimelineSection), findsOneWidget);
      expect(find.text('Observation Timeline'), findsOneWidget);
      expect(find.text('Farmer Follow-up'), findsOneWidget);
      expect(find.text('Initial AI Scan'), findsOneWidget);
      expect(find.text('Tomato · Early blight'), findsOneWidget);
    });

    testWidgets('RecoveryDisclaimerCard renders neutral, non-fabricated advisory',
        (tester) async {
      await tester.pumpWidget(createTestWidget(scan: testScanDiseased));
      await tester.pumpAndSettle();

      expect(find.byType(RecoveryDisclaimerCard), findsOneWidget);
      expect(find.text('Monitoring Your Plant'), findsOneWidget);
      expect(
        find.text(
          'Your observations help you keep track of changes over time. A new AI scan can provide another assessment, but AI predictions are estimates and do not guarantee that a plant has recovered.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('ScanAgainSection renders prominent Scan Again button',
        (tester) async {
      await tester.pumpWidget(createTestWidget(scan: testScanDiseased));
      await tester.pumpAndSettle();

      expect(find.byType(ScanAgainSection), findsOneWidget);
      expect(find.text('Scan Again'), findsOneWidget);
      expect(
        find.text('Take a new plant photo to run another AI assessment.'),
        findsOneWidget,
      );
    });
  });
}

class _FakeHistoryNotifier extends HistoryNotifier {
  final List<PredictionHistoryModel> _scans;
  _FakeHistoryNotifier(this._scans);

  @override
  Future<List<PredictionHistoryModel>> build() async {
    return _scans;
  }
}

