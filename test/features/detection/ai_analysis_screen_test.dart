import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leaf_agro/features/detection/presentation/providers/plant_disease_prediction_provider.dart';
import 'package:leaf_agro/features/detection/presentation/screens/ai_analysis_screen.dart';
import 'package:leaf_agro/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AiAnalysisScreen Widget Tests', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({'preferred_language': 'en'});
      prefs = await SharedPreferences.getInstance();
    });

    testWidgets('renders loading state, offline badge, and title', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsProvider.overrideWith((ref) => SettingsNotifier(prefs)),
          ],
          child: const MaterialApp(
            home: AiAnalysisScreen(autoStart: false),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('AgriCare AI'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.offline_bolt_rounded), findsOneWidget);
    });

    testWidgets('displays error view and retry button when state has error', (tester) async {
      final container = ProviderContainer(
        overrides: [
          settingsProvider.overrideWith((ref) => SettingsNotifier(prefs)),
        ],
      );
      addTearDown(container.dispose);

      // Pre-set error state
      container.read(plantDiseasePredictionProvider.notifier).state =
          PlantDiseasePredictionState.error(
        errorMessageEn: 'Leaf image decoding failed.',
        errorMessageBn: 'পাতার ছবি ডিকোড করা সম্ভব হয়নি।',
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: AiAnalysisScreen(autoStart: false),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
      expect(find.text('Leaf image decoding failed.'), findsOneWidget);
    });
  });
}
