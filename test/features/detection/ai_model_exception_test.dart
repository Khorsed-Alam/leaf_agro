import 'package:flutter_test/flutter_test.dart';
import 'package:leaf_agro/core/errors/ai_model_exception.dart';
import 'package:leaf_agro/core/errors/app_exceptions.dart';

void main() {
  group('AiModelException Hierarchy Tests', () {
    test('Base AiModelException inherits from ModelException and AppException', () {
      const exception = AiModelException(
        'Test AI error',
        code: 'TEST_CODE',
        technicalDetails: 'Technical details here',
      );

      expect(exception, isA<ModelException>());
      expect(exception, isA<AppException>());
      expect(exception.message, 'Test AI error');
      expect(exception.code, 'TEST_CODE');
      expect(exception.technicalDetails, 'Technical details here');
      expect(exception.toString(), contains('TEST_CODE'));
      expect(exception.toString(), contains('Technical details here'));
    });

    test('ModelAssetNotFoundException formats correct code and message', () {
      final exc = ModelAssetNotFoundException('assets/models/missing.tflite');
      expect(exc.code, 'MODEL_ASSET_NOT_FOUND');
      expect(exc.assetPath, 'assets/models/missing.tflite');
      expect(exc.message, contains('assets/models/missing.tflite'));
    });

    test('LabelsAssetNotFoundException formats correct code and message', () {
      final exc = LabelsAssetNotFoundException('assets/models/labels.json');
      expect(exc.code, 'LABELS_ASSET_NOT_FOUND');
      expect(exc.assetPath, 'assets/models/labels.json');
    });

    test('MetadataAssetNotFoundException formats correct code and message', () {
      final exc = MetadataAssetNotFoundException('assets/models/model_metadata.json');
      expect(exc.code, 'METADATA_ASSET_NOT_FOUND');
      expect(exc.assetPath, 'assets/models/model_metadata.json');
    });

    test('TensorValidationException formats shape mismatch clearly', () {
      final exc = TensorValidationException(
        tensorName: 'serving_default_input_1:0',
        actualShape: [1, 128, 128, 3],
        expectedShape: [1, 224, 224, 3],
      );
      expect(exc.code, 'TENSOR_SHAPE_MISMATCH');
      expect(exc.message, contains('[1, 224, 224, 3]'));
      expect(exc.message, contains('[1, 128, 128, 3]'));
    });

    test('ClassCountMismatchException formats count mismatch clearly', () {
      final exc = ClassCountMismatchException(labelCount: 19, modelOutputCount: 20);
      expect(exc.code, 'CLASS_COUNT_MISMATCH');
      expect(exc.message, contains('19 classes'));
      expect(exc.message, contains('20 neurons'));
    });

    test('InvalidLabelIndexException formats out of range error', () {
      final exc = InvalidLabelIndexException(queriedIndex: 25, totalClasses: 19);
      expect(exc.code, 'INVALID_LABEL_INDEX');
      expect(exc.message, contains('25'));
      expect(exc.message, contains('0 to 18'));
    });

    test('InferenceException formats execution failure message', () {
      final exc = InferenceException('Input buffer length mismatch');
      expect(exc.code, 'INFERENCE_EXECUTION_FAILED');
      expect(exc.message, contains('Input buffer length mismatch'));
    });

    test('InterpreterDisposedException formats disposed operation message', () {
      final exc = InterpreterDisposedException('predict');
      expect(exc.code, 'INTERPRETER_DISPOSED');
      expect(exc.message, contains('predict'));
    });
  });
}
