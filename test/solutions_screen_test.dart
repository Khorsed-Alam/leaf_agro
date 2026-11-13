import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leaf_agro/data/datasources/ai_crop_catalog.dart';
import 'package:leaf_agro/data/models/crop_model.dart';
import 'package:leaf_agro/data/models/disease_model.dart';
import 'package:leaf_agro/data/models/prediction_model.dart';
import 'package:leaf_agro/data/models/recommendation_model.dart';
import 'package:leaf_agro/features/recommendations/presentation/solutions_screen.dart';
import 'package:leaf_agro/features/recommendations/presentation/widgets/solutions/agricultural_officer_guidance_card.dart';
import 'package:leaf_agro/features/recommendations/presentation/widgets/solutions/agricultural_safety_section.dart';
import 'package:leaf_agro/features/recommendations/presentation/widgets/solutions/biological_management_section.dart';
import 'package:leaf_agro/features/recommendations/presentation/widgets/solutions/crop_protection_products_section.dart';
import 'package:leaf_agro/features/recommendations/presentation/widgets/solutions/cultural_management_section.dart';
import 'package:leaf_agro/features/recommendations/presentation/widgets/solutions/regulatory_warning_card.dart';
import 'package:leaf_agro/features/recommendations/presentation/widgets/solutions/solutions_disease_summary_card.dart';
import 'package:leaf_agro/features/recommendations/presentation/widgets/solutions/solutions_header.dart';
import 'package:leaf_agro/features/recommendations/presentation/widgets/solutions/solutions_not_found_view.dart';
import 'package:leaf_agro/features/recommendations/presentation/widgets/solutions/solutions_skeleton.dart';
import 'package:leaf_agro/providers/crop_provider.dart';
import 'package:leaf_agro/providers/disease_provider.dart';
import 'package:leaf_agro/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  const testCrop = CropModel(
    id: 1,
    nameEn: 'Rice',
    nameBn: 'ধান',
    descriptionEn: 'Major cereal food crop in Bangladesh',
    descriptionBn: 'বাংলাদেশের প্রধান খাদ্যশস্য',
    imageUrl: 'https://example.com/rice.jpg',
    isActive: true,
  );

  const testDisease = DiseaseModel(
    id: 101,
    cropId: 1,
    className: 'Rice___Bacterial_leaf_blight',
    diseaseNameEn: 'Bacterial Leaf Blight',
    diseaseNameBn: 'ব্যাকটেরিয়াল লিফ ব্লাইট',
    symptomsEn: 'Water-soaked wavy lesions.',
    symptomsBn: 'ঢেউ খেলানো দাগ।',
    causesEn: 'Xanthomonas bacteria',
    causesBn: 'ব্যাকটেরিয়া',
    isSample: false,
  );

  const testBioRec = RecommendationModel(
    id: 1014,
    diseaseId: 101,
    recommendationType: 'biological',
    titleEn: 'Beneficial Antagonistic Microorganisms (Pseudomonas / Bacillus)',
    titleBn: 'উপকারী প্রতিরোধী অণুজীব (সিউডোমোনাস / ব্যাসিলাস)',
    contentEn:
        'Application of beneficial bacterial antagonists such as Pseudomonas fluorescens or Bacillus subtilis can help suppress Xanthomonas colonization.',
    contentBn:
        'সিউডোমোনাস বা ব্যাসিলাস জাতীয় উপকারী জীবাণু স্প্রে করলে তা পাতার উপরিভাগে ক্ষতিকর ব্যাকটেরিয়ার বিস্তার দমন করে।',
    sourceName: 'BRRI Plant Pathology Division',
    sourceUrl: 'https://brri.gov.bd',
    isVerified: true,
  );

  const testCareRec = RecommendationModel(
    id: 1011,
    diseaseId: 101,
    recommendationType: 'care',
    titleEn: 'Drain Standing Field Water',
    titleBn: 'জমির পানি অবিলম্বে নিষ্কাশন করুন',
    contentEn:
        'Drain floodwater from the field immediately to prevent bacterial movement.',
    contentBn: 'জমির অতিরিক্ত পানি বের করে দিন।',
    sourceName: 'BRRI Extension Division',
    sourceUrl: 'https://brri.gov.bd',
    isVerified: true,
  );

  Widget buildTestableWidget({
    required ProviderContainer container,
    int? diseaseId,
    int? cropId,
    CropModel? initialCrop,
    DiseaseModel? initialDisease,
    PredictionModel? initialPrediction,
  }) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: SolutionsScreen(
          diseaseId: diseaseId,
          cropId: cropId,
          initialCrop: initialCrop,
          initialDisease: initialDisease,
          initialPrediction: initialPrediction,
        ),
      ),
    );
  }

  group('Screen 20 – Solutions Widgets Unit & Widget Tests', () {
    testWidgets(
        'SolutionsHeader displays title, back button, and LeafAgro badge',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: SolutionsHeader(isBn: false),
          ),
        ),
      );

      expect(find.text('Product & Solution Information'), findsOneWidget);
      expect(
          find.text(
              'Explore possible approaches to managing plant diseases safely.'),
          findsOneWidget);
      expect(find.text('LeafAgro'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });

    testWidgets('SolutionsHeader renders Bangla strings when isBn is true',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: SolutionsHeader(isBn: true),
          ),
        ),
      );

      expect(find.text('পণ্য ও সমাধান সংক্রান্ত তথ্য'), findsOneWidget);
      expect(
          find.text(
              'নিরাপদে উদ্ভিদের রোগ ব্যবস্থাপনার সম্ভাব্য উপায়গুলো জানুন'),
          findsOneWidget);
    });

    testWidgets(
        'SolutionsDiseaseSummaryCard renders disease name, crop, and AI confidence when present',
        (tester) async {
      final pred = PredictionModel(
        className: 'Rice___Bacterial_leaf_blight',
        cropName: 'Rice',
        diseaseNameEn: 'Bacterial Leaf Blight',
        diseaseNameBn: 'ব্যাকটেরিয়াল লিফ ব্লাইট',
        confidence: 0.942,
        predictedAt: DateTime.now(),
        modelVersion: '1.0.0',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SolutionsDiseaseSummaryCard(
                crop: testCrop,
                disease: testDisease,
                prediction: pred,
                isBn: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Affected Crop: Rice'), findsOneWidget);
      expect(find.text('Bacterial Leaf Blight'), findsOneWidget);
      expect(
          find.text(
              'Management Overview: Learn about possible approaches that may help manage this crop disease.'),
          findsOneWidget);
      expect(find.text('AI Pattern Match: 94.2% Confidence'), findsOneWidget);
    });

    testWidgets(
        'SolutionsDiseaseSummaryCard omits AI confidence when prediction is null (Catalogue Mode)',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SolutionsDiseaseSummaryCard(
                crop: testCrop,
                disease: testDisease,
                prediction: null,
                isBn: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Affected Crop: Rice'), findsOneWidget);
      expect(find.text('Bacterial Leaf Blight'), findsOneWidget);
      expect(find.textContaining('AI Pattern Match:'), findsNothing);
    });

    testWidgets(
        'BiologicalManagementSection displays verified bio options when present',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: BiologicalManagementSection(
                recommendations: [testBioRec],
                isBn: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Biological Management'), findsOneWidget);
      expect(
          find.text(
              'Beneficial Antagonistic Microorganisms (Pseudomonas / Bacillus)'),
          findsOneWidget);
      expect(find.text('Biocontrol Agent'), findsOneWidget);
      expect(find.textContaining('When Appropriate:'), findsOneWidget);
      expect(find.textContaining('Limitations & Precautions:'), findsOneWidget);
    });

    testWidgets(
        'BiologicalManagementSection shows honest unavailable message when bioRecs is empty',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: BiologicalManagementSection(
                recommendations: [],
                isBn: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Biological Management'), findsOneWidget);
      expect(
          find.text(
              'No verified biological management information is currently available for this crop and disease.'),
          findsOneWidget);
    });

    testWidgets('CulturalManagementSection displays core verified practices',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CulturalManagementSection(
                crop: testCrop,
                disease: testDisease,
                recommendations: [testCareRec],
                isBn: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Cultural Management'), findsOneWidget);
      expect(find.text('Field Hygiene & Sanitation'), findsOneWidget);
      expect(find.text('Irrigation & Moisture Control'), findsOneWidget);
      expect(find.text('Plant Spacing & Canopy Airflow'), findsOneWidget);
      expect(find.text('Crop Rotation Where Suitable'), findsOneWidget);
      expect(find.text('Healthy Seeds & Planting Materials'), findsOneWidget);
      expect(
          find.text('Management of Affected Plant Material'), findsOneWidget);
      expect(find.text('Drain Standing Field Water'), findsOneWidget);
    });

    testWidgets(
        'CropProtectionProductsSection is purely educational and contains NO commercial elements',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CropProtectionProductsSection(isBn: false),
            ),
          ),
        ),
      );

      expect(find.text('Crop Protection Products'), findsOneWidget);
      expect(find.text('Approved Products Only'), findsOneWidget);
      expect(find.text('Mandatory Product Labels'), findsOneWidget);
      expect(find.text('Qualified Extension Guidance'), findsOneWidget);
      expect(find.text('Integrated Management (IPM)'), findsOneWidget);

      // Verify strict non-commercial rules
      expect(find.textContaining('Buy'), findsNothing);
      expect(find.textContaining('Cart'), findsNothing);
      expect(find.textContaining('\$'), findsNothing);
      expect(find.textContaining('৳'), findsNothing);
      expect(find.byIcon(Icons.shopping_cart), findsNothing);
    });

    testWidgets(
        'AgriculturalSafetySection renders all 6 safety principle cards',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AgriculturalSafetySection(isBn: false),
            ),
          ),
        ),
      );

      expect(find.text('Important Safety Information'), findsOneWidget);
      expect(find.text('Follow the Product Label'), findsOneWidget);
      expect(find.text('Use Appropriate Protection'), findsOneWidget);
      expect(find.text('Protect People and Animals'), findsOneWidget);
      expect(find.text('Safe Storage and Disposal'), findsOneWidget);
      expect(find.text('Observe Harvest Restrictions'), findsOneWidget);
      expect(find.text('Avoid Unapproved Mixing'), findsOneWidget);
    });

    testWidgets(
        'AgriculturalOfficerGuidanceCard renders message and action button',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AgriculturalOfficerGuidanceCard(
                disease: testDisease,
                isBn: false,
              ),
            ),
          ),
        ),
      );

      expect(
          find.text('Need Help Choosing the Right Solution?'), findsOneWidget);
      expect(find.text('View Treatment Recommendations'), findsOneWidget);
    });

    testWidgets('RegulatoryWarningCard renders mandatory disclaimer',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RegulatoryWarningCard(isBn: false),
          ),
        ),
      );

      expect(find.text('Important Notice'), findsOneWidget);
      expect(
          find.text(
              'Always follow approved product labels and applicable local regulations. Product suitability and permitted uses can vary by crop, disease, and location. Consult a qualified agricultural officer before applying crop protection products.'),
          findsOneWidget);
    });

    testWidgets('SolutionsNotFoundView renders fallback and CTA button',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SolutionsNotFoundView(isBn: false),
          ),
        ),
      );

      expect(find.text('Solution Information Not Found'), findsOneWidget);
      expect(find.text('View General Solutions'), findsOneWidget);
      expect(find.text('Go Back'), findsOneWidget);
    });

    testWidgets('SolutionsSkeleton renders shimmer placeholders',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SolutionsSkeleton(),
          ),
        ),
      );

      expect(find.byType(SolutionsSkeleton), findsOneWidget);
    });
  });

  group('Screen 20 – Full Integration Tests with Riverpod Providers', () {
    testWidgets(
        'Loads disease-specific solutions for Rice Bacterial Leaf Blight (101)',
        (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          cropProvider.overrideWith(FakeCropNotifier.new),
          cropByIdProvider(1).overrideWith(
            (ref) => Future.value(testCrop),
          ),
          diseaseByIdProvider(101).overrideWith(
            (ref) => Future.value(testDisease),
          ),
          recommendationsByDiseaseProvider(101).overrideWith(
            (ref) => Future.value([testBioRec, testCareRec]),
          ),
        ],
      );

      await tester.pumpWidget(
        buildTestableWidget(container: container, diseaseId: 101),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(SolutionsHeader), findsOneWidget);
      expect(find.byType(SolutionsDiseaseSummaryCard), findsOneWidget);
      expect(find.byType(BiologicalManagementSection), findsOneWidget);
      expect(find.byType(CulturalManagementSection), findsOneWidget);
      expect(find.byType(CropProtectionProductsSection), findsOneWidget);
      expect(find.byType(AgriculturalSafetySection), findsOneWidget);
      expect(find.byType(AgriculturalOfficerGuidanceCard), findsOneWidget);
      expect(find.byType(RegulatoryWarningCard), findsOneWidget);
      expect(find.text('Bacterial Leaf Blight'), findsOneWidget);
      expect(find.text('Affected Crop: Rice'), findsOneWidget);
    });

    testWidgets(
        'Loads general crop solutions when opened standalone without disease context (cropId: 2 - Potato)',
        (tester) async {
      const potatoCrop = CropModel(
        id: 2,
        nameEn: 'Potato',
        nameBn: 'আলু',
        descriptionEn: 'High-yield tuber crop',
        descriptionBn: 'উচ্চ ফলনশীল কন্দ ফসল',
        imageUrl: 'https://example.com/potato.jpg',
        isActive: true,
      );

      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          cropProvider.overrideWith(FakeCropNotifier.new),
          cropByIdProvider(2).overrideWith(
            (ref) => Future.value(potatoCrop),
          ),
        ],
      );

      await tester.pumpWidget(
        buildTestableWidget(container: container, cropId: 2),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('General Crop Management'), findsOneWidget);
      expect(find.text('Affected Crop: Potato'), findsOneWidget);
      expect(find.byType(BiologicalManagementSection), findsOneWidget);
      expect(find.byType(CropProtectionProductsSection), findsOneWidget);
    });

    testWidgets('Renders Bangla layout correctly when language is bn',
        (tester) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('preferred_language', 'bn');

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          cropProvider.overrideWith(FakeCropNotifier.new),
          cropByIdProvider(1).overrideWith(
            (ref) => Future.value(testCrop),
          ),
          diseaseByIdProvider(101).overrideWith(
            (ref) => Future.value(testDisease),
          ),
          recommendationsByDiseaseProvider(101).overrideWith(
            (ref) => Future.value([testBioRec, testCareRec]),
          ),
        ],
      );

      await tester.pumpWidget(
        buildTestableWidget(container: container, diseaseId: 101),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('পণ্য ও সমাধান সংক্রান্ত তথ্য'), findsOneWidget);
      expect(find.text('আক্রান্ত ফসল: ধান'), findsOneWidget);
      expect(find.text('জৈবিক ব্যবস্থাপনা'), findsOneWidget);
      expect(find.text('কৃষিতাত্ত্বিক ব্যবস্থাপনা'), findsOneWidget);
      expect(find.text('গুরুত্বপূর্ণ নিরাপত্তা তথ্য'), findsOneWidget);
      expect(find.text('গুরুত্বপূর্ণ বিজ্ঞপ্তি'), findsOneWidget);
    });

    testWidgets(
        'Renders SolutionsNotFoundView when diseaseByIdProvider returns null',
        (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          diseaseByIdProvider(999).overrideWith((ref) => Future.value(null)),
        ],
      );

      await tester.pumpWidget(
        buildTestableWidget(container: container, diseaseId: 999),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(SolutionsNotFoundView), findsOneWidget);
      expect(find.text('Solution Information Not Found'), findsOneWidget);
    });
  });
}
