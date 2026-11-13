import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leaf_agro/core/errors/ai_model_exception.dart';
import 'package:leaf_agro/features/detection/data/services/ai_model_service.dart';

class TestAssetBundle extends CachingAssetBundle {
  final Map<String, ByteData> _assets = {};

  void addString(String key, String content) {
    final bytes = utf8.encode(content);
    _assets[key] = ByteData.view(Uint8List.fromList(bytes).buffer);
  }

  void addBytes(String key, List<int> content) {
    _assets[key] = ByteData.view(Uint8List.fromList(content).buffer);
  }

  @override
  Future<ByteData> load(String key) async {
    final asset = _assets[key];
    if (asset != null) return asset;
    throw Exception('Unable to load asset: $key');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AiModelService Unit Tests', () {
    late AiModelService service;
    late TestAssetBundle bundle;

    setUp(() {
      service = AiModelService();
      bundle = TestAssetBundle();

      // Read real assets from disk into the test bundle
      final metaFile = File('assets/models/model_metadata.json');
      bundle.addString('assets/models/model_metadata.json', metaFile.readAsStringSync());

      final labelsFile = File('assets/models/labels.json');
      bundle.addString('assets/models/labels.json', labelsFile.readAsStringSync());
    });

    tearDown(() {
      service.dispose();
    });

    test('Initial service state is uninitialized and not disposed', () {
      expect(service.isInitialized, isFalse);
      expect(service.isDisposed, isFalse);
      expect(service.metadata, isNull);
      expect(service.labels, isNull);
    });

    test('predict throws InferenceException before initialize is called', () async {
      final input = Float32List(150528);
      expect(() => service.predict(input), throwsA(isA<InferenceException>()));
    });

    test('Throws MetadataAssetNotFoundException if metadata asset is missing', () async {
      final emptyBundle = TestAssetBundle();
      expect(
        () => service.initialize(
          bundle: emptyBundle,
          metadataAsset: 'assets/models/non_existent_metadata.json',
        ),
        throwsA(isA<MetadataAssetNotFoundException>()),
      );
    });

    test('Throws LabelsAssetNotFoundException if labels asset is missing', () async {
      final incompleteBundle = TestAssetBundle();
      final metaFile = File('assets/models/model_metadata.json');
      incompleteBundle.addString('assets/models/model_metadata.json', metaFile.readAsStringSync());

      expect(
        () => service.initialize(
          bundle: incompleteBundle,
          labelsAsset: 'assets/models/non_existent_labels.json',
        ),
        throwsA(isA<LabelsAssetNotFoundException>()),
      );
    });

    test('Throws InvalidJsonException if metadata is malformed', () async {
      final brokenBundle = TestAssetBundle();
      brokenBundle.addString('assets/models/model_metadata.json', '{ bad json ...');
      expect(
        () => service.initialize(bundle: brokenBundle),
        throwsA(isA<InvalidJsonException>()),
      );
    });

    test('predict rejects input buffer with incorrect length', () async {
      expect(() => service.predict(Float32List(100)), throwsA(isA<InferenceException>()));
    });

    test('Disposing service prevents subsequent initialization and inference', () {
      service.dispose();
      expect(service.isDisposed, isTrue);
      expect(service.isInitialized, isFalse);

      expect(() => service.initialize(), throwsA(isA<InterpreterDisposedException>()));
      expect(() => service.predict(Float32List(150528)), throwsA(isA<InterpreterDisposedException>()));
    });
  });
}
