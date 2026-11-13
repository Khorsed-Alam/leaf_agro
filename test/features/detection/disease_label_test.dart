import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:leaf_agro/core/errors/ai_model_exception.dart';
import 'package:leaf_agro/features/detection/data/models/disease_label.dart';

void main() {
  group('DiseaseLabel & DiseaseLabels Tests', () {
    test('Parses authentic labels.json preserving exact 19-class ordering', () {
      final file = File('assets/models/labels.json');
      expect(file.existsSync(), isTrue, reason: 'assets/models/labels.json must exist');

      final jsonContent = json.decode(file.readAsStringSync()) as Map<String, dynamic>;
      final labels = DiseaseLabels.fromJson(jsonContent);

      expect(labels.numClasses, 19);
      expect(labels.length, 19);
      expect(labels.supportedCrops.length, 5);
      expect(labels.supportedCrops, containsAll(['Rice', 'Potato', 'Tomato', 'Mango', 'Jute']));

      // Verify exact 1-to-1 index mapping corresponding to model output neurons
      final expectedClasses = [
        'Jute___Anthracnose',
        'Jute___Stem_rot',
        'Jute___healthy',
        'Mango___Anthracnose',
        'Mango___Bacterial_canker',
        'Mango___healthy',
        'Potato___Early_blight',
        'Potato___Late_blight',
        'Potato___healthy',
        'Rice___Bacterial_leaf_blight',
        'Rice___Brown_spot',
        'Rice___Leaf_smut',
        'Rice___healthy',
        'Tomato___Bacterial_spot',
        'Tomato___Early_blight',
        'Tomato___Late_blight',
        'Tomato___Leaf_Mold',
        'Tomato___Septoria_leaf_spot',
        'Tomato___healthy',
      ];

      for (int i = 0; i < expectedClasses.length; i++) {
        final label = labels.getLabelByIndex(i);
        expect(label.index, i);
        expect(label.rawClassName, expectedClasses[i]);
      }

      // Verify specific lookups
      final potatoEarlyBlight = labels.getLabelByIndex(6);
      expect(potatoEarlyBlight.cropName, 'Potato');
      expect(potatoEarlyBlight.diseaseName, 'Early blight');
      expect(potatoEarlyBlight.isHealthy, isFalse);
      expect(potatoEarlyBlight.getDisplayName(false), 'Potato - Early blight');
      expect(potatoEarlyBlight.getDisplayName(true), contains('আলু'));

      final tomatoHealthy = labels.getLabelByIndex(18);
      expect(tomatoHealthy.cropName, 'Tomato');
      expect(tomatoHealthy.isHealthy, isTrue);
      expect(tomatoHealthy.getDisplayName(false), 'Tomato (Healthy)');
      expect(tomatoHealthy.getDisplayName(true), 'টমেটো (সুস্থ)');

      // Lookup by name
      final found = labels.getLabelByName('Rice___Bacterial_leaf_blight');
      expect(found, isNotNull);
      expect(found!.index, 9);
      expect(found.cropName, 'Rice');
    });

    test('Throws InvalidLabelIndexException on out-of-range indices', () {
      final file = File('assets/models/labels.json');
      final jsonContent = json.decode(file.readAsStringSync()) as Map<String, dynamic>;
      final labels = DiseaseLabels.fromJson(jsonContent);

      expect(() => labels.getLabelByIndex(-1), throwsA(isA<InvalidLabelIndexException>()));
      expect(() => labels.getLabelByIndex(19), throwsA(isA<InvalidLabelIndexException>()));
      expect(() => labels.getLabelByIndex(100), throwsA(isA<InvalidLabelIndexException>()));
    });

    test('Throws ClassCountMismatchException when validated against mismatched model output dimension', () {
      final file = File('assets/models/labels.json');
      final jsonContent = json.decode(file.readAsStringSync()) as Map<String, dynamic>;
      final labels = DiseaseLabels.fromJson(jsonContent);

      expect(() => labels.validate(19), returnsNormally);
      expect(() => labels.validate(20), throwsA(isA<ClassCountMismatchException>()));
      expect(() => labels.validate(10), throwsA(isA<ClassCountMismatchException>()));
    });

    test('Throws InvalidJsonException on corrupted or malformed labels JSON', () {
      final badJson1 = {'num_classes': 0, 'class_names': []};
      expect(() => DiseaseLabels.fromJson(badJson1), throwsA(isA<InvalidJsonException>()));

      final badJson2 = {
        'num_classes': 2,
        'class_names': ['A___b'], // length mismatch
      };
      expect(() => DiseaseLabels.fromJson(badJson2), throwsA(isA<InvalidJsonException>()));
    });
  });
}
