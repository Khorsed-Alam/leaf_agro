import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:leaf_agro/core/constants/app_constants.dart';
import 'package:leaf_agro/core/theme/app_colors.dart';
import 'package:leaf_agro/features/about/data/academic_project_config.dart';
import 'package:leaf_agro/features/about/presentation/about_screen.dart';
import 'package:leaf_agro/features/about/presentation/widgets/about_header.dart';
import 'package:leaf_agro/features/about/presentation/widgets/academic_team_card.dart';
import 'package:leaf_agro/features/about/presentation/widgets/ai_model_info_card.dart';
import 'package:leaf_agro/features/about/presentation/widgets/brand_hero_card.dart';
import 'package:leaf_agro/features/about/presentation/widgets/project_overview_card.dart';
import 'package:leaf_agro/features/about/presentation/widgets/supported_crops_section.dart';
import 'package:leaf_agro/features/about/presentation/widgets/tech_stack_section.dart';
import 'package:leaf_agro/features/settings/presentation/widgets/legal_document_dialog.dart';
import 'package:leaf_agro/providers/settings_provider.dart';

Future<Widget> createTestWidget({
  String language = 'en',
}) async {
  SharedPreferences.setMockInitialValues({
    AppConstants.keyLanguage: language,
    AppConstants.keyThemeMode: 'system',
    AppConstants.keyNotificationsEnabled: true,
  });

  final prefs = await SharedPreferences.getInstance();

  final router = GoRouter(
    initialLocation: '/about',
    routes: [
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) =>
            const Scaffold(body: Text('Settings Screen')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Screen 30: About Application Screen Tests', () {
    testWidgets('Header renders title, subtitle, and back button',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(await createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(AboutHeader), findsOneWidget);
      expect(find.text('About AgriCare AI'), findsOneWidget);
      expect(find.text('Learn more about our project and technology.'),
          findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });

    testWidgets(
        'Brand hero card renders AgriCare AI name, LeafAgro badge, and tagline',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(await createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(BrandHeroCard), findsOneWidget);
      expect(find.text('AgriCare AI'), findsOneWidget);
      expect(find.text('LeafAgro'), findsOneWidget);
      expect(find.text(AcademicProjectConfig.taglineEn), findsOneWidget);
      expect(find.text(AcademicProjectConfig.appIntroEn), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(BrandHeroCard),
          matching: find.byIcon(Icons.eco_rounded),
        ),
        findsOneWidget,
      );
    });

    testWidgets(
        'Academic project overview card renders exact approved project title and description',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(await createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(ProjectOverviewCard), findsOneWidget);
      expect(find.text(AcademicProjectConfig.projectTitleEn), findsOneWidget);
      expect(find.text(AcademicProjectConfig.projectDescriptionEn),
          findsOneWidget);
      expect(find.text(AcademicProjectConfig.projectTypeEn), findsWidgets);
    });

    testWidgets('Technology stack section reflects verified dependencies',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(await createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(TechStackSection), findsOneWidget);
      expect(find.text('Flutter 3.x'), findsOneWidget);
      expect(find.text('Dart'), findsOneWidget);
      expect(find.text('TensorFlow Lite'), findsOneWidget);
      expect(find.text('MobileNetV2'), findsWidgets);
      expect(find.text('Supabase'), findsOneWidget);
      expect(find.text('PostgreSQL'), findsOneWidget);
    });

    testWidgets(
        'Supported crops section displays exactly the 5 model-trained crops',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(await createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(SupportedCropsSection), findsOneWidget);
      expect(find.text('Rice'), findsOneWidget);
      expect(find.text('Potato'), findsOneWidget);
      expect(find.text('Tomato'), findsOneWidget);
      expect(find.text('Mango'), findsOneWidget);
      expect(find.text('Jute'), findsOneWidget);
      expect(find.text('5 Crops'), findsOneWidget);
    });

    testWidgets(
        'AI model info card displays verified model specs without fabricated metrics',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(await createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(AiModelInfoCard), findsOneWidget);
      expect(find.text('TensorFlow Lite (TFLite)'), findsOneWidget);
      expect(find.text('224 × 224 × 3 (RGB)'), findsOneWidget);
      expect(find.text('19 Classes (5 Crops)'), findsOneWidget);
      expect(find.text('100% On-Device (Offline)'), findsOneWidget);
      expect(
          find.textContaining('AI predictions are estimates'), findsOneWidget);
    });

    testWidgets(
        'Academic team card displays university and capstone project details',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(await createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(AcademicTeamCard), findsOneWidget);
      expect(find.text(AcademicProjectConfig.developerTeamEn), findsOneWidget);
      expect(find.text(AcademicProjectConfig.departmentEn), findsOneWidget);
      expect(find.text(AcademicProjectConfig.universityEn), findsOneWidget);
      expect(find.text(AcademicProjectConfig.supervisorEn), findsOneWidget);
      expect(find.text(AcademicProjectConfig.academicSession), findsOneWidget);
      expect(find.text('v1.0.0 (Build 1)'), findsOneWidget);
    });

    testWidgets('Privacy Policy tile opens verified LegalDocumentDialog',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(await createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Privacy Policy'));
      await tester.pumpAndSettle();

      expect(find.byType(LegalDocumentDialog), findsOneWidget);
      expect(find.textContaining('Your privacy is paramount.'), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.byType(LegalDocumentDialog), findsNothing);
    });

    testWidgets('Terms & Conditions tile opens verified LegalDocumentDialog',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(await createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Terms & Conditions'));
      await tester.pumpAndSettle();

      expect(find.byType(LegalDocumentDialog), findsOneWidget);
      expect(find.textContaining('Welcome to AgriCare AI.'), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.byType(LegalDocumentDialog), findsNothing);
    });

    testWidgets('Academic disclaimer renders at the bottom of the screen',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(await createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Academic Project Notice'), findsOneWidget);
      expect(find.text(AcademicProjectConfig.academicDisclaimerEn),
          findsOneWidget);
    });

    testWidgets(
        'Bangla localization renders appropriate Bengali text throughout about screen',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(await createTestWidget(language: 'bn'));
      await tester.pumpAndSettle();

      expect(find.text('এগ্রিকেয়ার এআই পরিচিতি'), findsOneWidget);
      expect(find.text('আমাদের প্রকল্প ও প্রযুক্তি সম্পর্কে জানুন'),
          findsOneWidget);
      expect(find.text(AcademicProjectConfig.taglineBn), findsOneWidget);
      expect(find.text('প্রকল্পের সারসংক্ষেপ'), findsOneWidget);
      expect(find.text(AcademicProjectConfig.projectTitleBn), findsOneWidget);
      expect(find.text('প্রযুক্তি কাঠামো'), findsOneWidget);
      expect(find.text('সমর্থিত ফসলসমূহ'), findsOneWidget);
      expect(find.text('ধান'), findsOneWidget);
      expect(find.text('আলু'), findsOneWidget);
      expect(find.text('টমেটো'), findsOneWidget);
      expect(find.text('আম'), findsOneWidget);
      expect(find.text('পাট'), findsOneWidget);
      expect(find.text('এআই মডেল স্পেসিফিকেশন'), findsOneWidget);
      expect(find.text('একাডেমিক প্রকল্প ও দল'), findsOneWidget);
      expect(find.text('গোপনীয়তা নীতি'), findsOneWidget);
      expect(find.text('শর্তাবলী ও নীতিমালা'), findsOneWidget);
      expect(find.text('একাডেমিক প্রকল্প নোটিশ'), findsOneWidget);
    });
  });
}
