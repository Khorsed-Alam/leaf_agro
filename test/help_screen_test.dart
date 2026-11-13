import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:leaf_agro/core/constants/app_constants.dart';
import 'package:leaf_agro/core/theme/app_colors.dart';
import 'package:leaf_agro/features/help/data/help_content.dart';
import 'package:leaf_agro/features/help/presentation/help_screen.dart';
import 'package:leaf_agro/features/help/presentation/widgets/contact_support_card.dart';
import 'package:leaf_agro/features/help/presentation/widgets/empty_help_search_state.dart';
import 'package:leaf_agro/features/help/presentation/widgets/faq_accordion_card.dart';
import 'package:leaf_agro/features/help/presentation/widgets/guide_detail_dialog.dart';
import 'package:leaf_agro/features/help/presentation/widgets/help_header.dart';
import 'package:leaf_agro/features/help/presentation/widgets/quick_guide_card.dart';
import 'package:leaf_agro/providers/settings_provider.dart';

Future<Widget> createTestWidget({
  String language = 'en',
  GoRouter? customRouter,
}) async {
  SharedPreferences.setMockInitialValues({
    AppConstants.keyLanguage: language,
    AppConstants.keyThemeMode: 'system',
    AppConstants.keyNotificationsEnabled: true,
  });

  final prefs = await SharedPreferences.getInstance();

  final router = customRouter ??
      GoRouter(
        initialLocation: '/help',
        routes: [
          GoRoute(
            path: '/help',
            builder: (context, state) => const HelpScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) =>
                const Scaffold(body: Text('Settings Screen')),
          ),
          GoRoute(
            path: '/feedback',
            builder: (context, state) =>
                const Scaffold(body: Text('Feedback Screen')),
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

  group('Screen 28: Help & FAQ Screen Tests', () {
    testWidgets(
        'Header renders title, subtitle, back button, and welcoming banner',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(await createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(HelpHeader), findsOneWidget);
      expect(find.text('Help & Support'), findsOneWidget);
      expect(
          find.text("We're here to help you use AgriCare AI"), findsOneWidget);
      expect(find.text('AgriCare Farmer Support Center'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });

    testWidgets('Renders all four quick help guide cards', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(await createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(QuickGuideCard), findsNWidgets(4));
      expect(find.text('How to Detect Plant Disease'), findsOneWidget);
      expect(find.text('How to Take a Good Leaf Photo'), findsOneWidget);
      expect(find.text('Understanding AI Confidence'), findsOneWidget);
      expect(find.text('Using the App Offline'), findsOneWidget);
    });

    testWidgets('Renders all 12 verified FAQ accordion cards', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(await createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(FaqAccordionCard), findsNWidgets(12));
      expect(find.text('How do I scan a plant?'), findsOneWidget);
      expect(
          find.text('Why is my plant disease not detected?'), findsOneWidget);
      expect(find.text('Is the AI result always correct?'), findsOneWidget);
      expect(find.text('What does the confidence percentage mean?'),
          findsOneWidget);
      expect(find.text('Can I use AgriCare AI without the internet?'),
          findsOneWidget);
    });

    testWidgets(
        'Tapping a guide card opens GuideDetailBottomSheet with steps and notes',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(await createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('How to Detect Plant Disease'));
      await tester.pumpAndSettle();

      expect(find.byType(GuideDetailBottomSheet), findsOneWidget);
      expect(find.text('Quick Process Sequence'), findsOneWidget);
      expect(find.text('Step-by-Step Instructions'), findsOneWidget);
      expect(find.text('Open AgriCare AI on your phone.'), findsOneWidget);
      expect(find.text('Important Agricultural Notice'), findsOneWidget);

      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle();

      expect(find.byType(GuideDetailBottomSheet), findsNothing);
    });

    testWidgets(
        'Photography guide includes good photo vs poor photo visual guidelines',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(await createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('How to Take a Good Leaf Photo'));
      await tester.pumpAndSettle();

      expect(find.byType(GuideDetailBottomSheet), findsOneWidget);
      expect(find.text('Visual Tips & Good Practices'), findsOneWidget);
      expect(find.text('Good Photo'), findsOneWidget);
      expect(find.text('Poor Photo'), findsOneWidget);
      expect(find.text('Clear leaf in crisp focus'), findsOneWidget);
      expect(find.text('Blurry or out-of-focus shot'), findsOneWidget);
    });

    testWidgets(
        'Offline guide accurately reflects 100% on-device MobileNetV2 inference',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(await createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Using the App Offline'));
      await tester.pumpAndSettle();

      expect(find.byType(GuideDetailBottomSheet), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(GuideDetailBottomSheet),
          matching: find.textContaining('MobileNetV2'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(GuideDetailBottomSheet),
          matching: find.textContaining(
            'In-field disease detection and treatment recommendations require ZERO internet connection.',
          ),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Tapping FAQ card expands and collapses answer',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(await createTestWidget());
      await tester.pumpAndSettle();

      final firstFaq = HelpContent.faqs.first;
      expect(find.text(firstFaq.answerEn), findsNothing);

      await tester.tap(find.text(firstFaq.questionEn));
      await tester.pumpAndSettle();

      expect(find.text(firstFaq.answerEn), findsOneWidget);

      await tester.tap(find.text(firstFaq.questionEn));
      await tester.pumpAndSettle();

      expect(find.text(firstFaq.answerEn), findsNothing);
    });

    testWidgets('Search filters guides and FAQs as user types', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(await createTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'confidence');
      await tester.pumpAndSettle();

      expect(find.text('Understanding AI Confidence'), findsOneWidget);
      expect(find.text('How to Take a Good Leaf Photo'), findsNothing);
      expect(find.text('What does the confidence percentage mean?'),
          findsOneWidget);
    });

    testWidgets(
        'Empty search shows friendly no-results message and clear button',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(await createTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'xyznonexistentkeyword');
      await tester.pumpAndSettle();

      expect(find.byType(EmptyHelpSearchState), findsOneWidget);
      expect(find.text('No help topics found'), findsOneWidget);
      expect(find.text('Try a different word or browse the guides below.'),
          findsOneWidget);

      await tester.tap(find.text('Clear search'));
      await tester.pumpAndSettle();

      expect(find.byType(EmptyHelpSearchState), findsNothing);
      expect(find.byType(QuickGuideCard), findsNWidgets(4));
    });

    testWidgets(
        'Contact support card displays feedback navigation button and honest notices',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(await createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(ContactSupportCard), findsOneWidget);
      expect(find.text('Still Need Help?'), findsOneWidget);
      expect(find.text('Send Feedback & Suggestions'), findsOneWidget);
      expect(find.text('Open Feedback Form'), findsOneWidget);

      await tester.tap(find.text('Open Feedback Form'));
      await tester.pumpAndSettle();

      expect(find.text('Feedback Screen'), findsOneWidget);
    });

    testWidgets('Bangla localization renders accurate Bengali translations',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(await createTestWidget(language: 'bn'));
      await tester.pumpAndSettle();

      expect(find.text('সহায়তা ও প্রশ্নোত্তর'), findsOneWidget);
      expect(find.text('কৃষক ভাইদের সহায়তায় সর্বদা পাশে'), findsOneWidget);
      expect(find.text('সহজ সহায়িকা নির্দেশিকা'), findsOneWidget);
      expect(find.text('গাছের রোগ কীভাবে শনাক্ত করবেন'), findsOneWidget);
      expect(find.text('কীভাবে পাতার ভালো ছবি তুলবেন'), findsOneWidget);
      expect(find.text('এআই কনফিডেন্স বা আস্থার মাত্রা বোঝা'), findsOneWidget);
      expect(find.text('ইন্টারনেট ছাড়া অ্যাপ ব্যবহার'), findsOneWidget);
      expect(find.text('সাধারণ জিজ্ঞাসা ও উত্তর'), findsOneWidget);
      expect(find.text('কীভাবে গাছের রোগ পরীক্ষা বা স্ক্যান করব?'),
          findsOneWidget);
      expect(find.text('আরও সাহায্য প্রয়োজন?'), findsOneWidget);
      expect(find.text('মতামত ফর্ম খুলুন'), findsOneWidget);
    });
  });
}
