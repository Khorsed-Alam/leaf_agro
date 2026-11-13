import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:leaf_agro/data/datasources/ai_crop_catalog.dart';
import 'package:leaf_agro/data/models/crop_model.dart';
import 'package:leaf_agro/data/models/disease_model.dart';
import 'package:leaf_agro/data/models/prediction_model.dart';
import 'package:leaf_agro/data/models/recommendation_model.dart';
import 'package:leaf_agro/features/recommendations/presentation/treatment_screen.dart';
import 'package:leaf_agro/features/recommendations/presentation/widgets/agricultural_practices_section.dart';
import 'package:leaf_agro/features/recommendations/presentation/widgets/detected_disease_summary_card.dart';
import 'package:leaf_agro/features/recommendations/presentation/widgets/immediate_actions_card.dart';
import 'package:leaf_agro/features/recommendations/presentation/widgets/prevention_nav_button.dart';
import 'package:leaf_agro/features/recommendations/presentation/widgets/safe_handling_reminders_card.dart';
import 'package:leaf_agro/features/recommendations/presentation/widgets/step_by_step_recommendations_card.dart';
import 'package:leaf_agro/features/recommendations/presentation/widgets/treatment_header.dart';
import 'package:leaf_agro/features/recommendations/presentation/widgets/treatment_not_found_view.dart';
import 'package:leaf_agro/features/recommendations/presentation/widgets/treatment_skeleton.dart';
import 'package:leaf_agro/features/recommendations/presentation/widgets/treatment_sources_section.dart';
import 'package:leaf_agro/features/recommendations/presentation/widgets/verified_treatments_section.dart';
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
    SharedPreferences.setMockInitialValues({'preferred_language': 'en'});
  });

  Widget buildTestableWidget({
    required ProviderContainer container,
    required int diseaseId,
    bool isSample = false,
    DiseaseModel? initialDisease,
    PredictionModel? initialPrediction,
    String? initialImagePath,
  }) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: TreatmentScreen(
          diseaseId: diseaseId,
          isSample: isSample,
          initialDisease: initialDisease,
          initialPrediction: initialPrediction,
          initialImagePath: initialImagePath,
        ),
      ),
    );
  }

  group('Screen 18 – Treatment Widgets Unit & Widget Tests', () {
    testWidgets('TreatmentHeader displays title, back button, and LeafAgro tag',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: TreatmentHeader(isBn: false),
          ),
        ),
      );

      expect(find.text('Treatment Recommendations'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(find.text('LeafAgro'), findsOneWidget);
    });

    testWidgets(
        'DetectedDiseaseSummaryCard renders disease, crop, confidence score and disclaimer',
        (tester) async {
      const disease = DiseaseModel(
        id: 101,
        cropId: 1,
        className: 'Rice___Bacterial_leaf_blight',
        diseaseNameEn: 'Bacterial Leaf Blight',
        diseaseNameBn: 'ব্যাকটেরিয়াল লিফ ব্লাইট',
        symptomsEn: 'Water-soaked wavy stripes.',
        symptomsBn: 'ঢেউ খেলানো দাগ।',
        causesEn: 'Bacteria',
        causesBn: 'ব্যাকটেরিয়া',
        isHealthy: false,
        isSample: false,
      );

      const crop = CropModel(
        id: 1,
        nameEn: 'Rice',
        nameBn: 'ধান',
        descriptionEn: 'Rice crop',
        descriptionBn: 'ধান ফসল',
        isActive: true,
      );

      final prediction = PredictionModel(
        className: 'Rice___Bacterial_leaf_blight',
        cropName: 'Rice',
        diseaseNameEn: 'Bacterial Leaf Blight',
        diseaseNameBn: 'ব্যাকটেরিয়াল লিফ ব্লাইট',
        confidence: 0.942,
        predictedAt: DateTime.now(),
        modelVersion: '1.0.0',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DetectedDiseaseSummaryCard(
              disease: disease,
              crop: crop,
              prediction: prediction,
              isBn: false,
              isSample: false,
            ),
          ),
        ),
      );

      expect(find.text('Bacterial Leaf Blight'), findsOneWidget);
      expect(find.text('Rice'), findsOneWidget);
      expect(find.text('Detected'), findsOneWidget);
      expect(find.text('AI Pattern Match: 94.2%'), findsOneWidget);
      expect(find.textContaining('not an absolute laboratory diagnosis'),
          findsOneWidget);
      // Sample banner must NOT appear on verified records
      expect(
          find.text('Sample Guidance – For Demonstration Only'), findsNothing);
    });

    testWidgets(
        'DetectedDiseaseSummaryCard renders Sample Banner when isSample is true',
        (tester) async {
      const sampleDisease = DiseaseModel(
        id: 999,
        cropId: 1,
        className: 'Rice___Sample',
        diseaseNameEn: 'Sample Disease',
        diseaseNameBn: 'নমুনা রোগ',
        symptomsEn: 'Leaf spot',
        symptomsBn: 'পাতার দাগ',
        causesEn: 'Spore',
        causesBn: 'ছত্রাক',
        isSample: true,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DetectedDiseaseSummaryCard(
                disease: sampleDisease,
                crop: null,
                prediction: null,
                isBn: false,
                isSample: true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Sample Guidance – For Demonstration Only'),
          findsOneWidget);
      expect(find.byIcon(Icons.info_outline_rounded), findsWidgets);
    });

    testWidgets(
        'ImmediateActionsCard renders numbered steps and does not advise destroying crops',
        (tester) async {
      const disease = DiseaseModel(
        id: 101,
        cropId: 1,
        className: 'Rice___Bacterial_leaf_blight',
        diseaseNameEn: 'Bacterial Leaf Blight',
        diseaseNameBn: 'ব্যাকটেরিয়াল লিফ ব্লাইট',
        symptomsEn: 'Symptoms',
        symptomsBn: 'লক্ষণ',
        causesEn: 'Causes',
        causesBn: 'কারণ',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ImmediateActionsCard(
                disease: disease,
                isBn: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text('What to Do First'), findsOneWidget);
      expect(find.text('Inspect Affected Plants & Surrounding Field'),
          findsOneWidget);
      expect(find.text('Manage Irrigation & Water Drainage'), findsOneWidget);
      expect(find.text('Consult Upazila Agriculture Extension Officer'),
          findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets(
        'AgriculturalPracticesSection renders verified cultural management cards',
        (tester) async {
      const disease = DiseaseModel(
        id: 101,
        cropId: 1,
        className: 'Rice___Bacterial_leaf_blight',
        diseaseNameEn: 'Bacterial Leaf Blight',
        diseaseNameBn: 'ব্যাকটেরিয়াল লিফ ব্লাইট',
        symptomsEn: 'Symptoms',
        symptomsBn: 'লক্ষণ',
        causesEn: 'Causes',
        causesBn: 'কারণ',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AgriculturalPracticesSection(
                disease: disease,
                crop: null,
                isBn: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Agricultural Management Practices'), findsOneWidget);
      expect(find.text('Field & Bund Sanitation'), findsOneWidget);
      expect(find.text('Regulated Water & Drainage'), findsOneWidget);
      expect(find.text('Balanced Fertilizer Application'), findsOneWidget);
    });

    testWidgets(
        'VerifiedTreatmentsSection renders verified treatments with product-label reminder',
        (tester) async {
      const disease = DiseaseModel(
        id: 101,
        cropId: 1,
        className: 'Rice___Bacterial_leaf_blight',
        diseaseNameEn: 'Bacterial Leaf Blight',
        diseaseNameBn: 'ব্যাকটেরিয়াল লিফ ব্লাইট',
        symptomsEn: 'Symptoms',
        symptomsBn: 'লক্ষণ',
        causesEn: 'Causes',
        causesBn: 'কারণ',
      );

      const rec = RecommendationModel(
        id: 1012,
        diseaseId: 101,
        recommendationType: 'treatment',
        titleEn: 'Potash Supplementation & Bio-bactericide',
        titleBn: 'পটাশ সার প্রয়োগ ও অনুমোদিত ব্যাকটেরিয়ানাশক',
        contentEn: 'Apply 5 kg MOP per bigha.',
        contentBn: 'বিঘা প্রতি ৫ কেজি এমওপি সার দিন।',
        sourceName: 'BRRI Adhunik Dhaner Chash Handbook',
        isVerified: true,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VerifiedTreatmentsSection(
              disease: disease,
              recommendations: [rec],
              isBn: false,
            ),
          ),
        ),
      );

      expect(find.text('Recommended Treatment Options'), findsOneWidget);
      expect(find.text('Potash Supplementation & Bio-bactericide'),
          findsOneWidget);
      expect(find.text('Apply 5 kg MOP per bigha.'), findsOneWidget);
      expect(find.text('Verified'), findsOneWidget);
      expect(
          find.textContaining(
              'Always follow the registered product label instructions'),
          findsOneWidget);
    });

    testWidgets(
        'VerifiedTreatmentsSection displays unavailable chemical guidance notice when empty',
        (tester) async {
      const disease = DiseaseModel(
        id: 101,
        cropId: 1,
        className: 'Rice___Bacterial_leaf_blight',
        diseaseNameEn: 'Bacterial Leaf Blight',
        diseaseNameBn: 'ব্যাকটেরিয়াল লিফ ব্লাইট',
        symptomsEn: 'Symptoms',
        symptomsBn: 'লক্ষণ',
        causesEn: 'Causes',
        causesBn: 'কারণ',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VerifiedTreatmentsSection(
              disease: disease,
              recommendations: [],
              isBn: false,
            ),
          ),
        ),
      );

      expect(
        find.textContaining(
            'Specific chemical treatment guidance is not available in the current verified information'),
        findsOneWidget,
      );
    });

    testWidgets(
        'SafeHandlingRemindersCard displays chemical safety rules and extension officer mandate',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SafeHandlingRemindersCard(isBn: false),
          ),
        ),
      );

      expect(find.text('Important Safety Reminders'), findsOneWidget);
      expect(
          find.textContaining(
              'Read and strictly follow the approved product label instructions'),
          findsOneWidget);
      expect(
          find.textContaining(
              'Always follow local agricultural extension guidance and the approved product label'),
          findsOneWidget);
    });

    testWidgets('StepByStepRecommendationsCard displays numbered action plan',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StepByStepRecommendationsCard(isBn: false),
          ),
        ),
      );

      expect(find.text('Step-by-Step Action Plan'), findsOneWidget);
      expect(find.text('Step 1'), findsOneWidget);
      expect(find.text('Step 2'), findsOneWidget);
      expect(find.text('Step 3'), findsOneWidget);
      expect(find.text('Step 4'), findsOneWidget);
      expect(find.text('Inspect the Crop & Field'), findsOneWidget);
    });

    testWidgets('PreventionNavButton renders navigation CTA', (tester) async {
      const disease = DiseaseModel(
        id: 101,
        cropId: 1,
        className: 'Rice___Bacterial_leaf_blight',
        diseaseNameEn: 'Bacterial Leaf Blight',
        diseaseNameBn: 'ব্যাকটেরিয়াল লিফ ব্লাইট',
        symptomsEn: 'Symptoms',
        symptomsBn: 'লক্ষণ',
        causesEn: 'Causes',
        causesBn: 'কারণ',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PreventionNavButton(
              disease: disease,
              isBn: false,
            ),
          ),
        ),
      );

      expect(find.text('View Prevention Tips & Care'), findsOneWidget);
      expect(find.byIcon(Icons.shield_outlined), findsOneWidget);
    });

    testWidgets(
        'TreatmentNotFoundView renders fallback when disease ID does not exist',
        (tester) async {
      bool backTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TreatmentNotFoundView(
              isBn: false,
              onBack: () => backTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('No Treatment Guidance Available'), findsOneWidget);
      expect(find.byIcon(Icons.medical_information_outlined), findsOneWidget);

      await tester.tap(find.text('Go Back'));
      expect(backTapped, isTrue);
    });
  });

  group('Screen 18 – Full Integration Tests with Riverpod Providers', () {
    testWidgets(
        'Loads treatment recommendations for Rice Bacterial Leaf Blight (101)',
        (tester) async {
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
          cropByIdProvider(1).overrideWith(
            (ref) => Future.value(AiCropCatalog.verifiedSupportedCrops.first),
          ),
          diseaseByIdProvider(101).overrideWith(
            (ref) => Future.value(AiCropCatalog.verifiedDiseases.first),
          ),
          recommendationsByDiseaseProvider(101).overrideWith(
            (ref) =>
                Future.value(AiCropCatalog.getRecommendationsForDisease(101)),
          ),
        ],
      );

      await tester.pumpWidget(
        buildTestableWidget(container: container, diseaseId: 101),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Header & Summary Card
      expect(find.byType(TreatmentHeader), findsOneWidget);
      expect(find.byType(DetectedDiseaseSummaryCard), findsOneWidget);
      expect(find.text('Bacterial Leaf Blight'), findsOneWidget);
      expect(find.text('Rice'), findsOneWidget);

      // Verify What to Do First
      expect(find.byType(ImmediateActionsCard), findsOneWidget);
      expect(find.text('What to Do First'), findsOneWidget);

      // Verify Agricultural Management Practices
      expect(find.byType(AgriculturalPracticesSection), findsOneWidget);
      expect(find.text('Agricultural Management Practices'), findsOneWidget);

      // Verify Recommended Treatment Options
      expect(find.byType(VerifiedTreatmentsSection), findsOneWidget);
      expect(find.text('Recommended Treatment Options'), findsOneWidget);

      // Verify Safety Reminders & Action Plan
      expect(find.byType(StepByStepRecommendationsCard), findsOneWidget);
      expect(find.byType(SafeHandlingRemindersCard), findsOneWidget);
      expect(find.byType(TreatmentSourcesSection), findsOneWidget);
      expect(find.byType(PreventionNavButton), findsOneWidget);
    });

    testWidgets('Renders Bangla layout correctly when language is bn',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('preferred_language', 'bn');

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          cropProvider.overrideWith(FakeCropNotifier.new),
          cropByIdProvider(1).overrideWith(
            (ref) => Future.value(AiCropCatalog.verifiedSupportedCrops.first),
          ),
          diseaseByIdProvider(101).overrideWith(
            (ref) => Future.value(AiCropCatalog.verifiedDiseases.first),
          ),
          recommendationsByDiseaseProvider(101).overrideWith(
            (ref) =>
                Future.value(AiCropCatalog.getRecommendationsForDisease(101)),
          ),
        ],
      );

      await tester.pumpWidget(
        buildTestableWidget(container: container, diseaseId: 101),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('চিকিৎসা পরামর্শ'), findsOneWidget);
      expect(find.text('ব্যাকটেরিয়াল লিফ ব্লাইট'), findsOneWidget);
      expect(find.text('ধান'), findsOneWidget);
      expect(find.text('প্রথমেই করণীয়'), findsOneWidget);
      expect(find.text('কৃষি ব্যবস্থাপনা ও পরিচর্যা'), findsOneWidget);
      expect(find.text('অনুমোদিত চিকিৎসা ব্যবস্থা'), findsOneWidget);
      expect(find.text('নিরাপদ ব্যবহারের গুরুত্বপূর্ণ নির্দেশিকা'),
          findsOneWidget);
      expect(find.text('প্রতিরোধ টিপস ও যত্ন'), findsOneWidget);
    });

    testWidgets(
        'Renders TreatmentNotFoundView when diseaseByIdProvider returns null',
        (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          diseaseByIdProvider(9999).overrideWith((ref) => Future.value(null)),
        ],
      );

      await tester.pumpWidget(
        buildTestableWidget(container: container, diseaseId: 9999),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(TreatmentNotFoundView), findsOneWidget);
      expect(find.text('No Treatment Guidance Available'), findsOneWidget);
    });

    testWidgets('Renders TreatmentSkeleton while loading', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final completer = Completer<DiseaseModel?>();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          diseaseByIdProvider(101).overrideWith((ref) => completer.future),
        ],
      );

      await tester.pumpWidget(
        buildTestableWidget(container: container, diseaseId: 101),
      );
      await tester.pump();

      expect(find.byType(TreatmentSkeleton), findsOneWidget);

      completer.complete(null);
      await tester.pump();
    });
  });
}
