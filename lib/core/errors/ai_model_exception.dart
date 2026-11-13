import 'app_exceptions.dart';

/// Base exception class for all AI Model and TFLite inference errors in AgriCare AI.
class AiModelException extends ModelException {
  final String? technicalDetails;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AiModelException(
    super.message, {
    super.code,
    this.technicalDetails,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() {
    final buffer = StringBuffer('AiModelException: $message');
    if (code != null) buffer.write(' [Code: $code]');
    if (technicalDetails != null) buffer.write('\nDetails: $technicalDetails');
    if (originalError != null) buffer.write('\nCaused by: $originalError');
    return buffer.toString();
  }
}

/// Thrown when the TFLite model asset cannot be found or loaded from the asset bundle.
class ModelAssetNotFoundException extends AiModelException {
  final String assetPath;

  ModelAssetNotFoundException(
    this.assetPath, {
    super.technicalDetails,
    super.originalError,
  }) : super(
          'Model asset not found at path: $assetPath',
          code: 'MODEL_ASSET_NOT_FOUND',
        );
}

/// Thrown when labels.json cannot be found or loaded from the asset bundle.
class LabelsAssetNotFoundException extends AiModelException {
  final String assetPath;

  LabelsAssetNotFoundException(
    this.assetPath, {
    super.technicalDetails,
    super.originalError,
  }) : super(
          'Labels asset not found at path: $assetPath',
          code: 'LABELS_ASSET_NOT_FOUND',
        );
}

/// Thrown when model_metadata.json cannot be found or loaded from the asset bundle.
class MetadataAssetNotFoundException extends AiModelException {
  final String assetPath;

  MetadataAssetNotFoundException(
    this.assetPath, {
    super.technicalDetails,
    super.originalError,
  }) : super(
          'Metadata asset not found at path: $assetPath',
          code: 'METADATA_ASSET_NOT_FOUND',
        );
}

/// Thrown when a required JSON configuration file contains malformed or unparseable JSON.
class InvalidJsonException extends AiModelException {
  final String sourceFile;

  InvalidJsonException(
    this.sourceFile,
    String message, {
    super.technicalDetails,
    super.originalError,
  }) : super(
          'Failed to parse JSON from $sourceFile: $message',
          code: 'INVALID_JSON',
        );
}

/// Thrown when model_metadata.json contains invalid or missing required configuration fields.
class InvalidMetadataException extends AiModelException {
  final String missingOrInvalidField;

  InvalidMetadataException(
    this.missingOrInvalidField,
    String message, {
    super.technicalDetails,
  }) : super(
          'Invalid model metadata ($missingOrInvalidField): $message',
          code: 'INVALID_METADATA',
        );
}

/// Thrown when the TFLite Interpreter fails to initialize or allocate tensors.
class InterpreterInitializationException extends AiModelException {
  InterpreterInitializationException(
    String message, {
    super.technicalDetails,
    super.originalError,
    super.stackTrace,
  }) : super(
          'Failed to initialize TFLite interpreter: $message',
          code: 'INTERPRETER_INIT_FAILED',
        );
}

/// Thrown when model input or output tensor shapes or types do not match expectations.
class TensorValidationException extends AiModelException {
  final String tensorName;
  final List<int> actualShape;
  final List<int> expectedShape;

  TensorValidationException({
    required this.tensorName,
    required this.actualShape,
    required this.expectedShape,
    String? details,
  }) : super(
          'Tensor shape mismatch for "$tensorName": expected $expectedShape, but got $actualShape.',
          code: 'TENSOR_SHAPE_MISMATCH',
          technicalDetails: details,
        );
}

/// Thrown when the number of classes in labels.json does not match the model output tensor size.
class ClassCountMismatchException extends AiModelException {
  final int labelCount;
  final int modelOutputCount;

  ClassCountMismatchException({
    required this.labelCount,
    required this.modelOutputCount,
  }) : super(
          'Class count mismatch: labels.json contains $labelCount classes, but model output tensor has $modelOutputCount neurons.',
          code: 'CLASS_COUNT_MISMATCH',
          technicalDetails:
              'Every output neuron must correspond 1-to-1 with a verified disease label.',
        );
}

/// Thrown when an out-of-bounds or non-existent class index is queried.
class InvalidLabelIndexException extends AiModelException {
  final int queriedIndex;
  final int totalClasses;

  InvalidLabelIndexException({
    required this.queriedIndex,
    required this.totalClasses,
  }) : super(
          'Invalid label index $queriedIndex. Valid range is 0 to ${totalClasses - 1}.',
          code: 'INVALID_LABEL_INDEX',
        );
}

/// Thrown when an error occurs during model inference execution.
class InferenceException extends AiModelException {
  InferenceException(
    String message, {
    super.technicalDetails,
    super.originalError,
    super.stackTrace,
  }) : super(
          'Inference execution failed: $message',
          code: 'INFERENCE_EXECUTION_FAILED',
        );
}

/// Thrown when quantization parameters are unexpected or incompatible with the model type.
class QuantizationMismatchException extends AiModelException {
  QuantizationMismatchException(
    String message, {
    super.technicalDetails,
  }) : super(
          'Quantization mismatch: $message',
          code: 'QUANTIZATION_MISMATCH',
        );
}

/// Thrown when an operation is attempted on a disposed interpreter.
class InterpreterDisposedException extends AiModelException {
  InterpreterDisposedException([String operation = 'perform operation'])
      : super(
          'Cannot $operation: TFLite interpreter has already been disposed.',
          code: 'INTERPRETER_DISPOSED',
        );
}
