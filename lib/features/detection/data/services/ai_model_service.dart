import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/ai_model_exception.dart';
import '../models/ai_model_metadata.dart';
import '../models/disease_label.dart';

/// Central production service responsible for TensorFlow Lite model initialization,
/// tensor validation, label alignment, lifecycle management, and raw inference.
class AiModelService {
  Interpreter? _interpreter;
  AiModelMetadata? _metadata;
  DiseaseLabels? _labels;

  bool _isInitialized = false;
  bool _isDisposed = false;

  List<int>? _inputShape;
  TensorType? _inputType;
  List<int>? _outputShape;
  TensorType? _outputType;

  // Expected constants verified in Phase 40
  static const int expectedInputWidth = 224;
  static const int expectedInputHeight = 224;
  static const int expectedInputChannels = 3;
  static const int expectedInputElements = 1 * 224 * 224 * 3; // 150,528
  static const int expectedNumClasses = 19;

  /// Whether the AI service and interpreter are fully initialized and ready for inference.
  bool get isInitialized => _isInitialized && !_isDisposed && _interpreter != null;

  /// Whether the service has been permanently disposed.
  bool get isDisposed => _isDisposed;

  /// Verified metadata loaded from model_metadata.json.
  AiModelMetadata? get metadata => _metadata;

  /// Verified 19-class labels mapping loaded from labels.json.
  DiseaseLabels? get labels => _labels;

  /// Shape of the input tensor (expected: [1, 224, 224, 3]).
  List<int>? get inputShape => _inputShape != null ? List.unmodifiable(_inputShape!) : null;

  /// Data type of the input tensor (expected: TensorType.float32).
  TensorType? get inputType => _inputType;

  /// Shape of the output tensor (expected: [1, 19]).
  List<int>? get outputShape => _outputShape != null ? List.unmodifiable(_outputShape!) : null;

  /// Data type of the output tensor (expected: TensorType.float32).
  TensorType? get outputType => _outputType;

  /// Asynchronously loads model metadata, labels, and the MobileNetV2 TFLite model,
  /// followed by strict tensor shape and type validation.
  Future<void> initialize({
    String modelAsset = AppConstants.tfliteModelAsset,
    String labelsAsset = AppConstants.labelsAsset,
    String metadataAsset = AppConstants.metadataAsset,
    AssetBundle? bundle,
    Interpreter? testInterpreter,
  }) async {
    if (_isDisposed) {
      throw InterpreterDisposedException('initialize');
    }

    if (_isInitialized && _interpreter != null) {
      // Re-initialization guard: return immediately to prevent redundant loading
      return;
    }

    final activeBundle = bundle ?? rootBundle;

    // 1. Load and parse model_metadata.json
    try {
      final metadataString = await activeBundle.loadString(metadataAsset);
      final dynamic rawMetadata = json.decode(metadataString);
      if (rawMetadata is! Map<String, dynamic>) {
        throw InvalidJsonException(metadataAsset, 'Root structure must be a JSON object.');
      }
      _metadata = AiModelMetadata.fromJson(rawMetadata);
      _metadata!.validate();
    } on AiModelException {
      rethrow;
    } on FormatException catch (e) {
      throw InvalidJsonException(metadataAsset, e.message, originalError: e);
    } catch (e) {
      throw MetadataAssetNotFoundException(
        metadataAsset,
        technicalDetails: 'Failed to read asset from bundle: $e',
        originalError: e,
      );
    }

    // 2. Load and parse labels.json
    try {
      final labelsString = await activeBundle.loadString(labelsAsset);
      final dynamic rawLabels = json.decode(labelsString);
      if (rawLabels is! Map<String, dynamic>) {
        throw InvalidJsonException(labelsAsset, 'Root structure must be a JSON object.');
      }
      _labels = DiseaseLabels.fromJson(rawLabels);
      _labels!.validate(_metadata!.numClasses);
    } on AiModelException {
      rethrow;
    } on FormatException catch (e) {
      throw InvalidJsonException(labelsAsset, e.message, originalError: e);
    } catch (e) {
      throw LabelsAssetNotFoundException(
        labelsAsset,
        technicalDetails: 'Failed to read asset from bundle: $e',
        originalError: e,
      );
    }

    // 3. Initialize TFLite Interpreter
    try {
      if (testInterpreter != null) {
        _interpreter = testInterpreter;
      } else {
        final options = InterpreterOptions()..threads = 2;
        _interpreter = await Interpreter.fromAsset(modelAsset, options: options);
      }
    } catch (e, st) {
      _cleanupPartiallyInitialized();
      throw InterpreterInitializationException(
        'Could not create TFLite interpreter from asset "$modelAsset": $e',
        originalError: e,
        stackTrace: st,
      );
    }

    // 4. Validate runtime tensors
    try {
      _validateRuntimeTensors();
    } catch (e) {
      _cleanupPartiallyInitialized();
      rethrow;
    }

    _isInitialized = true;
  }

  /// Internal validator ensuring input/output tensor dimensions and types match the contract.
  void _validateRuntimeTensors() {
    if (_interpreter == null) {
      throw InterpreterInitializationException('Interpreter instance is null after creation.');
    }

    final inputTensors = _interpreter!.getInputTensors();
    if (inputTensors.isEmpty) {
      throw InterpreterInitializationException('Model has no input tensors.');
    }

    final inputTensor = inputTensors.first;
    _inputShape = inputTensor.shape;
    _inputType = inputTensor.type;

    // Verify input tensor shape: [1, 224, 224, 3]
    final expectedInput = [1, expectedInputWidth, expectedInputHeight, expectedInputChannels];
    if (_inputShape!.length != expectedInput.length ||
        _inputShape![1] != expectedInput[1] ||
        _inputShape![2] != expectedInput[2] ||
        _inputShape![3] != expectedInput[3]) {
      throw TensorValidationException(
        tensorName: inputTensor.name,
        actualShape: _inputShape!,
        expectedShape: expectedInput,
        details: 'Model expects input shape [batch, 224, 224, 3].',
      );
    }

    // Verify input data type: float32
    if (_inputType != TensorType.float32) {
      throw QuantizationMismatchException(
        'Expected Float32 input tensor, but found ${_inputType?.name}.',
      );
    }

    final outputTensors = _interpreter!.getOutputTensors();
    if (outputTensors.isEmpty) {
      throw InterpreterInitializationException('Model has no output tensors.');
    }

    final outputTensor = outputTensors.first;
    _outputShape = outputTensor.shape;
    _outputType = outputTensor.type;

    // Verify output tensor shape: [1, 19]
    final expectedOutput = [1, expectedNumClasses];
    if (_outputShape!.length != expectedOutput.length ||
        _outputShape![1] != expectedOutput[1]) {
      throw TensorValidationException(
        tensorName: outputTensor.name,
        actualShape: _outputShape!,
        expectedShape: expectedOutput,
        details: 'Model expects output shape [1, 19] for 19 disease classes.',
      );
    }

    // Verify output data type: float32
    if (_outputType != TensorType.float32) {
      throw QuantizationMismatchException(
        'Expected Float32 output tensor, but found ${_outputType?.name}.',
      );
    }

    // Verify class alignment
    if (_labels!.numClasses != _outputShape![1]) {
      throw ClassCountMismatchException(
        labelCount: _labels!.numClasses,
        modelOutputCount: _outputShape![1],
      );
    }
  }

  /// Runs inference on a flattened Float32 input buffer (150,528 elements representing 1x224x224x3).
  ///
  /// CRITICAL PREPROCESSING CONTRACT:
  /// The model features embedded internal rescaling (x * 1/127.5 - 1.0).
  /// Input values must be in the RAW unnormalized pixel range [0.0, 255.0].
  /// Do NOT pre-normalize to [-1.0, 1.0] before calling this method.
  Future<List<double>> predict(Float32List input) async {
    if (_isDisposed) {
      throw InterpreterDisposedException('predict');
    }

    if (!_isInitialized || _interpreter == null) {
      throw InferenceException(
        'Inference cannot be executed because the model is not initialized. Call initialize() first.',
      );
    }

    // 1. Validate input element count
    if (input.length != expectedInputElements) {
      throw InferenceException(
        'Input length mismatch: expected $expectedInputElements floats (1x224x224x3), but received ${input.length}.',
      );
    }

    // 2. Reject NaN and Infinite values in input
    for (int i = 0; i < input.length; i++) {
      final val = input[i];
      if (val.isNaN || val.isInfinite) {
        throw InferenceException(
          'Input contains non-finite values (NaN or Infinity) at index $i.',
        );
      }
    }

    // 3. Format input for TFLite Interpreter (reshape flat buffer to [1, 224, 224, 3])
    final reshapedInput = input.reshape([1, expectedInputHeight, expectedInputWidth, expectedInputChannels]);

    // 4. Prepare output buffer for [1, 19]
    final outputBuffer = List.generate(1, (_) => List<double>.filled(expectedNumClasses, 0.0));

    // 5. Execute inference
    try {
      _interpreter!.run(reshapedInput, outputBuffer);
    } catch (e, st) {
      throw InferenceException(
        'TFLite native inference execution failed: $e',
        originalError: e,
        stackTrace: st,
      );
    }

    // 6. Validate output probabilities
    final probabilities = outputBuffer[0];
    if (probabilities.length != expectedNumClasses) {
      throw InferenceException(
        'Output vector length (${probabilities.length}) does not match expected $expectedNumClasses classes.',
      );
    }

    double sum = 0.0;
    for (int i = 0; i < probabilities.length; i++) {
      final p = probabilities[i];
      if (p.isNaN || p.isInfinite) {
        throw InferenceException('Output contains NaN or Infinity at class index $i.');
      }
      sum += p;
    }

    // Softmax sum check (tolerance range [0.85, 1.15] to account for FP precision)
    if (sum < 0.85 || sum > 1.15) {
      throw InferenceException(
        'Softmax probability sum anomaly: sum is $sum (expected approximately 1.0).',
      );
    }

    return List.unmodifiable(probabilities);
  }

  /// Cleans up partially allocated resources if an initialization error occurs.
  void _cleanupPartiallyInitialized() {
    try {
      _interpreter?.close();
    } catch (_) {}
    _interpreter = null;
    _isInitialized = false;
  }

  /// Safely closes the TFLite Interpreter and releases native resources.
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _isInitialized = false;
    try {
      _interpreter?.close();
    } catch (_) {}
    _interpreter = null;
  }
}
