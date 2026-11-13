import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:leaf_agro/data/datasources/ai_crop_catalog.dart';
import 'package:leaf_agro/data/models/crop_model.dart';
import 'package:leaf_agro/data/models/disease_model.dart';
import 'package:leaf_agro/features/diseases/presentation/disease_detail_screen.dart';
import 'package:leaf_agro/features/diseases/presentation/widgets/details/disease_action_buttons.dart';
import 'package:leaf_agro/features/diseases/presentation/widgets/details/disease_causes_card.dart';
import 'package:leaf_agro/features/diseases/presentation/widgets/details/disease_detail_header.dart';
import 'package:leaf_agro/features/diseases/presentation/widgets/details/disease_detail_skeleton.dart';
import 'package:leaf_agro/features/diseases/presentation/widgets/details/disease_hero_section.dart';
import 'package:leaf_agro/features/diseases/presentation/widgets/details/disease_not_found_view.dart';
import 'package:leaf_agro/features/diseases/presentation/widgets/details/disease_overview_card.dart';
import 'package:leaf_agro/features/diseases/presentation/widgets/details/disease_severity_card.dart';
import 'package:leaf_agro/features/diseases/presentation/widgets/details/disease_symptoms_card.dart';
import 'package:leaf_agro/features/diseases/presentation/widgets/details/disease_visible_signs_card.dart';
import 'package:leaf_agro/features/diseases/presentation/widgets/details/related_diseases_section.dart';
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
  }) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: DiseaseDetailScreen(
          diseaseId: diseaseId,
          isSample: isSample,
          initialDisease: initialDisease,
        ),
      ),
    );
  }

  group('Screen 17 – DiseaseDetailScreen Unit & Widget Tests', () {
    testWidgets(
        'DiseaseDetailHeader displays title, back button, and AgriCare AI tag',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: DiseaseDetailHeader(
              title: 'Bacterial Leaf Blight',
              isBn: false,
            ),
          ),
        ),
      );

      expect(find.text('Bacterial Leaf Blight'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(find.text('AgriCare AI'), findsOneWidget);
    });

    testWidgets(
        'DiseaseHeroSection renders disease name, crop tag, and verified status',
        (tester) async {
      const disease = DiseaseModel(
        id: 101,
        cropId: 1,
        className: 'Rice___Bacterial_leaf_blight',
        diseaseNameEn: 'Bacterial Leaf Blight',
        diseaseNameBn: 'ব্যাকটেরিয়াল লিফ ব্লাইট',
        symptomsEn: 'Water-soaked wavy stripes.',
        symptomsBn: 'ঢেউ খেলানো পানিভেজা দাগ।',
        causesEn: 'Xanthomonas bacteria.',
        causesBn: 'জ্যান্থোমোনাস ব্যাকটেরিয়া।',
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

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DiseaseHeroSection(
              disease: disease,
              crop: crop,
              isBn: false,
              isSample: false,
            ),
          ),
        ),
      );

      expect(find.text('Bacterial Leaf Blight'), findsOneWidget);
      expect(find.text('Rice'), findsOneWidget);
      expect(find.text('Infected'), findsOneWidget);
      // Sample banner must NOT be present on verified records
      expect(find.text('Sample Information – For Demonstration Only'),
          findsNothing);
    });

    testWidgets(
        'DiseaseHeroSection displays Sample Content Banner when isSample is true',
        (tester) async {
      const sampleDisease = DiseaseModel(
        id: 999,
        cropId: 1,
        className: 'Rice___Sample_Disease',
        diseaseNameEn: 'Demo Rice Disease',
        diseaseNameBn: 'নমুনা ধান রোগ',
        symptomsEn: 'Sample leaf spotting.',
        symptomsBn: 'নমুনা পাতার দাগ।',
        causesEn: 'Sample fungal spore.',
        causesBn: 'নমুনা ছত্রাক।',
        isHealthy: false,
        isSample: true,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DiseaseHeroSection(
              disease: sampleDisease,
              crop: null,
              isBn: false,
              isSample: true,
            ),
          ),
        ),
      );

      expect(find.text('Sample Information – For Demonstration Only'),
          findsOneWidget);
      expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
    });

    testWidgets(
        'DiseaseOverviewCard formats farmer-friendly overview and host crop tag',
        (tester) async {
      final disease = AiCropCatalog.verifiedDiseases.first;
      const crop = CropModel(
        id: 1,
        nameEn: 'Rice',
        nameBn: 'ধান',
        descriptionEn: 'Rice crop',
        descriptionBn: 'ধান ফসল',
        isActive: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DiseaseOverviewCard(
              disease: disease,
              crop: crop,
              isBn: false,
            ),
          ),
        ),
      );

      expect(find.text('Overview'), findsOneWidget);
      expect(find.textContaining('is a known disease affecting Rice plants'),
          findsOneWidget);
      expect(find.text('Host Crop: Rice'), findsOneWidget);
    });

    testWidgets(
        'DiseaseSymptomsCard parses checklist items and shows unavailable when empty',
        (tester) async {
      const diseaseWithSymptoms = DiseaseModel(
        id: 101,
        cropId: 1,
        className: 'Rice___Bacterial_leaf_blight',
        diseaseNameEn: 'Bacterial Leaf Blight',
        diseaseNameBn: 'ব্যাকটেরিয়াল লিফ ব্লাইট',
        symptomsEn:
            'Water-soaked wavy stripes; Rapid leaf desiccation; Gray lesion centers.',
        symptomsBn: 'ঢেউ খেলানো দাগ; পাতা শুকিয়ে যাওয়া; ধূসর কেন্দ্র।',
        causesEn: 'Bacteria',
        causesBn: 'ব্যাকটেরিয়া',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DiseaseSymptomsCard(
              disease: diseaseWithSymptoms,
              isBn: false,
            ),
          ),
        ),
      );

      expect(find.text('Common Symptoms'), findsOneWidget);
      expect(find.text('Water-soaked wavy stripes'), findsOneWidget);
      expect(find.text('Rapid leaf desiccation'), findsOneWidget);
      expect(find.text('Gray lesion centers'), findsOneWidget);
    });

    testWidgets('DiseaseVisibleSignsCard renders foliar inspection guidance',
        (tester) async {
      const disease = DiseaseModel(
        id: 101,
        cropId: 1,
        className: 'Rice___Bacterial_leaf_blight',
        diseaseNameEn: 'Bacterial Leaf Blight',
        diseaseNameBn: 'ব্যাকটেরিয়াল লিফ ব্লাইট',
        symptomsEn: 'Stripes on margins',
        symptomsBn: 'কিনারায় দাগ',
        causesEn: 'Bacteria',
        causesBn: 'ব্যাকটেরিয়া',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DiseaseVisibleSignsCard(
              disease: disease,
              isBn: false,
            ),
          ),
        ),
      );

      expect(find.text('Visible Signs on Leaves'), findsOneWidget);
      expect(find.text('Wavy Margin Lesions'), findsOneWidget);
      expect(find.text('Straw-like Desiccation'), findsOneWidget);
    });

    testWidgets(
        'DiseaseCausesCard renders causal agent biology and environmental vectors',
        (tester) async {
      const disease = DiseaseModel(
        id: 101,
        cropId: 1,
        className: 'Rice___Bacterial_leaf_blight',
        diseaseNameEn: 'Bacterial Leaf Blight',
        diseaseNameBn: 'ব্যাকটেরিয়াল লিফ ব্লাইট',
        symptomsEn: 'Symptoms text',
        symptomsBn: 'লক্ষণ বিবরণ',
        causesEn:
            'Xanthomonas oryzae pv. oryzae bacteria spread via floodwater.',
        causesBn: 'জ্যান্থোমোনাস ব্যাকটেরিয়ার আক্রমণ।',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DiseaseCausesCard(
              disease: disease,
              isBn: false,
            ),
          ),
        ),
      );

      expect(find.text('Possible Causes'), findsOneWidget);
      expect(
          find.textContaining('Xanthomonas oryzae pv. oryzae'), findsOneWidget);
      expect(find.textContaining('standing water accelerate spore germination'),
          findsOneWidget);
    });

    testWidgets(
        'DiseaseSeverityCard displays distinction disclaimer and omits when unverified',
        (tester) async {
      const unverifiedDisease = DiseaseModel(
        id: 101,
        cropId: 1,
        className: 'Rice___Bacterial_leaf_blight',
        diseaseNameEn: 'Bacterial Leaf Blight',
        diseaseNameBn: 'ব্যাকটেরিয়াল লিফ ব্লাইট',
        symptomsEn: 'Symptoms text',
        symptomsBn: 'লক্ষণ বিবরণ',
        causesEn: 'Causes text',
        causesBn: 'কারণ বিবরণ',
        isHealthy: false,
      );

      // 1. Without documented severity, section must be omitted
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DiseaseSeverityCard(
              disease: unverifiedDisease,
              isBn: false,
              severityLevel: null,
            ),
          ),
        ),
      );
      expect(find.text('Disease Severity'), findsNothing);

      // 2. When supported or healthy, section displays with literature disclaimer
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DiseaseSeverityCard(
              disease: unverifiedDisease,
              isBn: false,
              severityLevel: 'high',
            ),
          ),
        ),
      );
      expect(find.text('Disease Severity'), findsOneWidget);
      expect(find.text('High Severity'), findsOneWidget);
      expect(find.textContaining('not an assessment of your individual plant'),
          findsOneWidget);
    });

    testWidgets('DiseaseActionButtons renders Treatment and Prevention buttons',
        (tester) async {
      const disease = DiseaseModel(
        id: 101,
        cropId: 1,
        className: 'Rice___Bacterial_leaf_blight',
        diseaseNameEn: 'Bacterial Leaf Blight',
        diseaseNameBn: 'ব্যাকটেরিয়াল লিফ ব্লাইট',
        symptomsEn: 'Symptoms text',
        symptomsBn: 'লক্ষণ বিবরণ',
        causesEn: 'Causes text',
        causesBn: 'কারণ বিবরণ',
        isHealthy: false,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DiseaseActionButtons(
              disease: disease,
              isBn: false,
            ),
          ),
        ),
      );

      expect(find.text('Treatment Recommendations'), findsOneWidget);
      expect(find.text('Prevention Tips & Care'), findsOneWidget);
      expect(find.byIcon(Icons.medication_liquid_rounded), findsOneWidget);
      expect(find.byIcon(Icons.shield_outlined), findsOneWidget);
    });

    testWidgets(
        'DiseaseNotFoundView renders when invalid disease ID is requested',
        (tester) async {
      bool backTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DiseaseNotFoundView(
              isBn: false,
              onBack: () => backTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Disease Information Unavailable'), findsOneWidget);
      expect(find.byIcon(Icons.search_off_rounded), findsOneWidget);

      await tester.tap(find.text('Back to Disease Catalogue'));
      expect(backTapped, isTrue);
    });
  });

  group('Screen 17 – Integration Tests with Providers', () {
    testWidgets(
        'Loads verified Rice Bacterial Leaf Blight by ID (101) with full details',
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
          diseasesByCropProvider(1).overrideWith(
            (ref) => Future.value(AiCropCatalog.getVerifiedDiseasesForCrop(1)),
          ),
        ],
      );

      await tester.pumpWidget(
        buildTestableWidget(container: container, diseaseId: 101),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Header
      expect(find.byType(DiseaseDetailHeader), findsWidgets);
      expect(find.text('Bacterial Leaf Blight'), findsWidgets);

      // Verify Hero Section
      expect(find.byType(DiseaseHeroSection), findsOneWidget);
      expect(find.text('Rice'), findsOneWidget);
      expect(find.text('Infected'), findsOneWidget);

      // Verify Action Buttons
      expect(find.byType(DiseaseActionButtons), findsOneWidget);
      expect(find.text('Treatment Recommendations'), findsOneWidget);
      expect(find.text('Prevention Tips & Care'), findsOneWidget);

      // Verify Cards
      expect(find.byType(DiseaseOverviewCard), findsOneWidget);
      expect(find.byType(DiseaseSymptomsCard), findsOneWidget);
      expect(find.byType(DiseaseVisibleSignsCard), findsOneWidget);
      expect(find.byType(DiseaseCausesCard), findsOneWidget);
      expect(find.byType(RelatedDiseasesSection), findsOneWidget);
    });

    testWidgets(
        'Loads Healthy Rice Leaf (104) and omits chemical treatment recommendations',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final prefs = await SharedPreferences.getInstance();
      final healthyDisease =
          AiCropCatalog.verifiedDiseases.firstWhere((d) => d.id == 104);

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          cropProvider.overrideWith(FakeCropNotifier.new),
          cropByIdProvider(1).overrideWith(
            (ref) => Future.value(AiCropCatalog.verifiedSupportedCrops.first),
          ),
          diseaseByIdProvider(104).overrideWith(
            (ref) => Future.value(healthyDisease),
          ),
          diseasesByCropProvider(1).overrideWith(
            (ref) => Future.value(AiCropCatalog.getVerifiedDiseasesForCrop(1)),
          ),
        ],
      );

      await tester.pumpWidget(
        buildTestableWidget(container: container, diseaseId: 104),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Healthy Rice Leaf'), findsWidgets);
      expect(find.text('Healthy Plant'), findsOneWidget);

      // Treatment recommendations must be omitted for healthy plants
      expect(find.text('Treatment Recommendations'), findsNothing);
      // Prevention & care tips remain accessible
      expect(find.text('Prevention Tips & Care'), findsOneWidget);
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
          diseasesByCropProvider(1).overrideWith(
            (ref) => Future.value(AiCropCatalog.getVerifiedDiseasesForCrop(1)),
          ),
        ],
      );

      await tester.pumpWidget(
        buildTestableWidget(container: container, diseaseId: 101),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('ব্যাকটেরিয়াল লিফ ব্লাইট'), findsWidgets);
      expect(find.text('ধান'), findsOneWidget);
      expect(find.text('পরিচিতি ও বিবরণ'), findsOneWidget);
      expect(find.text('সাধারণ লক্ষণসমূহ'), findsOneWidget);
      expect(find.text('চিকিৎসা পরামর্শ (Treatment)'), findsOneWidget);
      expect(find.text('প্রতিরোধ টিপস (Prevention)'), findsOneWidget);
    });

    testWidgets(
        'Renders DiseaseNotFoundView when diseaseByIdProvider returns null',
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

      expect(find.byType(DiseaseNotFoundView), findsOneWidget);
      expect(find.text('Disease Information Unavailable'), findsOneWidget);
    });

    testWidgets('Renders DiseaseDetailSkeleton while disease data is loading',
        (tester) async {
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

      expect(find.byType(DiseaseDetailSkeleton), findsOneWidget);

      // Complete to avoid pending async operations
      completer.complete(null);
      await tester.pump();
    });
  });
}
