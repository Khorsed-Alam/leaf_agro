import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:leaf_agro/data/datasources/ai_crop_catalog.dart';
import 'package:leaf_agro/data/models/crop_model.dart';
import 'package:leaf_agro/data/models/disease_model.dart';
import 'package:leaf_agro/data/models/recommendation_model.dart';
import 'package:leaf_agro/features/recommendations/presentation/prevention_screen.dart';
import 'package:leaf_agro/features/recommendations/presentation/widgets/prevention/crop_specific_advice_section.dart';
import 'package:leaf_agro/features/recommendations/presentation/widgets/prevention/disease_specific_prevention_section.dart';
import 'package:leaf_agro/features/recommendations/presentation/widgets/prevention/essential_practices_section.dart';
import 'package:leaf_agro/features/recommendations/presentation/widgets/prevention/healthy_crop_hero_section.dart';
import 'package:leaf_agro/features/recommendations/presentation/widgets/prevention/prevention_checklist_card.dart';
import 'package:leaf_agro/features/recommendations/presentation/widgets/prevention/prevention_header.dart';
import 'package:leaf_agro/features/recommendations/presentation/widgets/prevention/prevention_not_found_view.dart';
import 'package:leaf_agro/features/recommendations/presentation/widgets/prevention/prevention_skeleton.dart';
import 'package:leaf_agro/features/recommendations/presentation/widgets/prevention/selected_crop_context_card.dart';
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
    int? diseaseId,
    int? cropId,
    CropModel? initialCrop,
    DiseaseModel? initialDisease,
  }) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: PreventionScreen(
          diseaseId: diseaseId,
          cropId: cropId,
          initialCrop: initialCrop,
          initialDisease: initialDisease,
        ),
      ),
    );
  }

  group('Screen 19 – Prevention Widgets Unit & Widget Tests', () {
    testWidgets(
        'PreventionHeader displays title, back button, and LeafAgro badge',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: PreventionHeader(isBn: false),
          ),
        ),
      );

      expect(find.text('Prevention & Plant Care'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(find.text('LeafAgro'), findsOneWidget);
      expect(find.byIcon(Icons.shield_outlined), findsOneWidget);
    });

    testWidgets(
        'HealthyCropHeroSection renders crop protection banner and risk note',
        (tester) async {
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
            body: SingleChildScrollView(
              child: HealthyCropHeroSection(
                crop: crop,
                isBn: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Keep Your Crops Healthy'), findsOneWidget);
      expect(find.text('Rice Protection'), findsOneWidget);
      expect(
          find.textContaining(
              'reduce disease risks and support healthy plant growth'),
          findsOneWidget);
      expect(find.textContaining('do not guarantee disease-free crops'),
          findsOneWidget);
    });

    testWidgets(
        'SelectedCropContextCard renders crop name, chips, and disease badge if present',
        (tester) async {
      const crop = CropModel(
        id: 1,
        nameEn: 'Rice',
        nameBn: 'ধান',
        descriptionEn: 'Rice crop',
        descriptionBn: 'ধান ফসল',
        isActive: true,
      );

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

      CropModel? changedCrop;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SelectedCropContextCard(
                selectedCrop: crop,
                selectedDisease: disease,
                isBn: false,
                onCropChanged: (c) => changedCrop = c,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Selected Crop'), findsOneWidget);
      expect(find.text('Rice'), findsWidgets);
      expect(find.text('Bacterial Leaf Blight'), findsOneWidget);

      // Verify switching crop chip triggers callback
      await tester.tap(find.text('Potato'));
      await tester.pump();
      expect(changedCrop?.nameEn, 'Potato');
    });

    testWidgets(
        'EssentialPracticesSection renders all 6 foundational prevention principles',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: EssentialPracticesSection(isBn: false),
            ),
          ),
        ),
      );

      expect(find.text('Essential Prevention Practices'), findsOneWidget);
      expect(find.text('Monitor Your Crops Regularly'), findsOneWidget);
      expect(find.text('Water Your Plants Properly'), findsOneWidget);
      expect(find.text('Keep the Field Clean'), findsOneWidget);
      expect(find.text('Practice Crop Rotation When Suitable'), findsOneWidget);
      expect(find.text('Maintain Proper Plant Spacing'), findsOneWidget);
      expect(find.text('Use Healthy Seeds and Planting Materials'),
          findsOneWidget);
    });

    testWidgets(
        'CropSpecificAdviceSection displays verified agronomic care tips for Rice',
        (tester) async {
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
            body: SingleChildScrollView(
              child: CropSpecificAdviceSection(
                crop: crop,
                isBn: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Advice for Rice'), findsOneWidget);
      expect(find.text('Standing Water Depth'), findsOneWidget);
      expect(find.text('Balanced Urea Application'), findsOneWidget);
      expect(find.text('Rotary Weeding & Cleaning'), findsOneWidget);
      expect(find.text('Daily Field Levee Inspection'), findsOneWidget);
    });

    testWidgets(
        'DiseaseSpecificPreventionSection renders when disease context exists and omits when null',
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
        id: 1013,
        diseaseId: 101,
        recommendationType: 'prevention',
        titleEn: 'Resistant Cultivars & Clean Seed',
        titleBn: 'রোগ প্রতিরোধী জাত নির্বাচন ও সুস্থ বীজ',
        contentEn: 'Use certified disease-free seeds.',
        contentBn: 'উন্নত রোগমুক্ত বীজ ব্যবহার করুন।',
      );

      // 1. When disease is provided, section renders
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DiseaseSpecificPreventionSection(
                disease: disease,
                recommendations: [rec],
                isBn: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Prevention for Bacterial Leaf Blight'), findsOneWidget);
      expect(find.text('Resistant Cultivars & Clean Seed'), findsOneWidget);
      expect(find.text('Use certified disease-free seeds.'), findsOneWidget);

      // 2. When disease is null, section is omitted
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DiseaseSpecificPreventionSection(
              disease: null,
              recommendations: [],
              isBn: false,
            ),
          ),
        ),
      );
      expect(find.text('Prevention for Bacterial Leaf Blight'), findsNothing);
    });

    testWidgets(
        'PreventionChecklistCard tracks checkbox changes and updates progress immediately',
        (tester) async {
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
            body: SingleChildScrollView(
              child: PreventionChecklistCard(
                crop: crop,
                isBn: false,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('My Prevention Checklist'), findsOneWidget);
      expect(find.text('Your Prevention Progress'), findsOneWidget);
      expect(find.text('0 of 5 Completed'), findsOneWidget);

      // Tap first checkbox
      final firstCheckbox = find.byType(Checkbox).first;
      await tester.tap(firstCheckbox);
      await tester.pump();

      // Progress updates immediately
      expect(find.text('1 of 5 Completed'), findsOneWidget);

      // Uncheck
      await tester.tap(firstCheckbox);
      await tester.pump();
      expect(find.text('0 of 5 Completed'), findsOneWidget);
    });

    testWidgets(
        'PreventionNotFoundView displays fallback message and back button',
        (tester) async {
      bool backTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PreventionNotFoundView(
              isBn: false,
              onBack: () => backTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Prevention Guidance Unavailable'), findsOneWidget);
      expect(find.byIcon(Icons.shield_outlined), findsOneWidget);

      await tester.tap(find.text('Go Back'));
      expect(backTapped, isTrue);
    });
  });

  group('Screen 19 – Full Integration Tests with Riverpod Providers', () {
    testWidgets(
        'Loads disease-specific prevention for Rice Bacterial Leaf Blight (101)',
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

      expect(find.byType(PreventionHeader), findsOneWidget);
      expect(find.byType(HealthyCropHeroSection), findsOneWidget);
      expect(find.byType(SelectedCropContextCard), findsOneWidget);
      expect(find.byType(DiseaseSpecificPreventionSection), findsOneWidget);
      expect(find.byType(CropSpecificAdviceSection), findsOneWidget);
      expect(find.byType(EssentialPracticesSection), findsOneWidget);
      expect(find.byType(PreventionChecklistCard), findsOneWidget);

      expect(find.text('Rice Protection'), findsOneWidget);
      expect(find.text('Bacterial Leaf Blight'), findsOneWidget);
      expect(find.text('Advice for Rice'), findsOneWidget);
    });

    testWidgets(
        'Loads general crop prevention when opened without disease context (cropId: 2 - Potato)',
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
          cropByIdProvider(2).overrideWith(
            (ref) => Future.value(AiCropCatalog.verifiedSupportedCrops[1]),
          ),
        ],
      );

      await tester.pumpWidget(
        buildTestableWidget(container: container, cropId: 2),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Hero shows Potato
      expect(find.text('Potato Protection'), findsOneWidget);
      expect(find.text('Advice for Potato'), findsOneWidget);
      expect(find.text('Timely Earthing Up'), findsOneWidget);

      // Disease-specific section must NOT be rendered in general flow
      expect(find.byType(DiseaseSpecificPreventionSection), findsNothing);
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

      expect(find.text('রোগ প্রতিরোধ ও যত্ন'), findsOneWidget);
      expect(find.text('আপনার ফসল সুস্থ ও সতেজ রাখুন'), findsOneWidget);
      expect(find.text('নির্বাচিত ফসল'), findsOneWidget);
      expect(find.text('ধান'), findsWidgets);
      expect(find.text('প্রয়োজনীয় রোগ প্রতিরোধ অভ্যাস'), findsOneWidget);
      expect(find.text('আমার রোগ প্রতিরোধ চেকলিস্ট'), findsOneWidget);
    });

    testWidgets(
        'Renders PreventionNotFoundView when diseaseByIdProvider returns null',
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

      expect(find.byType(PreventionNotFoundView), findsOneWidget);
      expect(find.text('Prevention Guidance Unavailable'), findsOneWidget);
    });

    testWidgets('Renders PreventionSkeleton while loading', (tester) async {
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

      expect(find.byType(PreventionSkeleton), findsOneWidget);

      completer.complete(null);
      await tester.pump();
    });
  });
}
