import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leaf_agro/features/detection/data/models/ai_model_metadata.dart';
import 'package:leaf_agro/features/detection/data/models/disease_label.dart';
import 'package:leaf_agro/features/detection/presentation/providers/ai_model_provider.dart';
import 'package:leaf_agro/features/detection/presentation/providers/ai_model_state.dart';
import 'package:leaf_agro/features/detection/presentation/widgets/ai_model_status_widget.dart';

void main() {
  group('AiModelStatusWidget Tests', () {
    late AiModelMetadata testMetadata;
    late DiseaseLabels testLabels;

    setUp(() {
      final metaFile = File('assets/models/model_metadata.json');
      testMetadata = AiModelMetadata.fromJson(
        json.decode(metaFile.readAsStringSync()) as Map<String, dynamic>,
      );

      final labelsFile = File('assets/models/labels.json');
      testLabels = DiseaseLabels.fromJson(
        json.decode(labelsFile.readAsStringSync()) as Map<String, dynamic>,
      );
    });

    testWidgets('Renders loading indicator and text when model is loading', (tester) async {
      final stateNotifier = StateController<AiModelState>(AiModelState.loading());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            aiModelStateNotifierProvider.overrideWith(
              (ref) => _FakeAiModelNotifier(stateNotifier.state),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: AiModelStatusWidget(isBn: false),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Initializing MobileNetV2 on-device AI...'), findsOneWidget);
    });

    testWidgets('Renders verified model specifications when model is ready', (tester) async {
      final readyState = AiModelState.ready(
        metadata: testMetadata,
        labels: testLabels,
        inputShape: [1, 224, 224, 3],
        outputShape: [1, 19],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            aiModelStateNotifierProvider.overrideWith(
              (ref) => _FakeAiModelNotifier(readyState),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: AiModelStatusWidget(isBn: false),
            ),
          ),
        ),
      );

      expect(find.text('AgriCare AI Leaf Disease Detector'), findsOneWidget);
      expect(find.text('MobileNetV2'), findsOneWidget);
      expect(find.text('19'), findsOneWidget);
      expect(find.text('224x224 RGB'), findsOneWidget);
      expect(find.text('Ready'), findsOneWidget);
    });

    testWidgets('Renders compact ready card when compact=true', (tester) async {
      final readyState = AiModelState.ready(
        metadata: testMetadata,
        labels: testLabels,
        inputShape: [1, 224, 224, 3],
        outputShape: [1, 19],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            aiModelStateNotifierProvider.overrideWith(
              (ref) => _FakeAiModelNotifier(readyState),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: AiModelStatusWidget(isBn: false, compact: true),
            ),
          ),
        ),
      );

      expect(find.text('AI Ready (MobileNetV2 • 19 classes)'), findsOneWidget);
    });

    testWidgets('Renders error card with retry button when model fails to load', (tester) async {
      final errorState = AiModelState.error(
        message: 'Model asset file is missing.',
        technicalDetails: 'assets/models/plant_disease_model.tflite',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            aiModelStateNotifierProvider.overrideWith(
              (ref) => _FakeAiModelNotifier(errorState),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: AiModelStatusWidget(isBn: false),
            ),
          ),
        ),
      );

      expect(find.text('AI Model Initialization Failed'), findsOneWidget);
      expect(find.text('Model asset file is missing.'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('Renders Bangla localization accurately when isBn=true', (tester) async {
      final readyState = AiModelState.ready(
        metadata: testMetadata,
        labels: testLabels,
        inputShape: [1, 224, 224, 3],
        outputShape: [1, 19],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            aiModelStateNotifierProvider.overrideWith(
              (ref) => _FakeAiModelNotifier(readyState),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: AiModelStatusWidget(isBn: true),
            ),
          ),
        ),
      );

      expect(find.text('প্রস্তুত'), findsOneWidget);
      expect(find.text('আর্কিটেকচার'), findsOneWidget);
      expect(find.text('শ্রেণি'), findsOneWidget);
      expect(find.text('ইনপুট'), findsOneWidget);
    });
  });
}

class _FakeAiModelNotifier extends StateNotifier<AiModelState> implements AiModelNotifier {
  _FakeAiModelNotifier(super.state);

  @override
  Future<void> initialize() async {}

  @override
  Future<void> retry() async {}
}
