import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/ai_model_exception.dart';
import '../../data/repositories/ai_model_repository.dart';
import '../../data/services/ai_model_service.dart';
import 'ai_model_state.dart';

/// Application-level provider for the core [AiModelService] singleton.
/// Managed across the application lifecycle and properly disposed.
final aiModelServiceProvider = Provider<AiModelService>((ref) {
  final service = AiModelService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Application-level provider for [AiModelRepository].
final aiModelRepositoryProvider = Provider<AiModelRepository>((ref) {
  final service = ref.watch(aiModelServiceProvider);
  return AiModelRepository(service);
});

/// StateNotifier managing on-device AI model initialization, readiness, and diagnostics.
class AiModelNotifier extends StateNotifier<AiModelState> {
  final AiModelService _service;
  bool _isInitializing = false;

  AiModelNotifier(this._service) : super(AiModelState.initial()) {
    // Automatically trigger asynchronous initialization on creation
    initialize();
  }

  /// Initiates asynchronous loading of model, metadata, and labels.
  Future<void> initialize() async {
    if (state.isReady) return;
    if (_isInitializing) return;

    _isInitializing = true;
    state = AiModelState.loading();

    try {
      await _service.initialize();

      final metadata = _service.metadata;
      final labels = _service.labels;
      final inputShape = _service.inputShape ?? [1, 224, 224, 3];
      final outputShape = _service.outputShape ?? [1, 19];

      if (metadata != null && labels != null) {
        state = AiModelState.ready(
          metadata: metadata,
          labels: labels,
          inputShape: inputShape,
          outputShape: outputShape,
        );
      } else {
        state = AiModelState.error(
          message: 'Model loaded but metadata or labels are unavailable.',
          technicalDetails: 'metadata: $metadata, labels: $labels',
        );
      }
    } on AiModelException catch (e) {
      state = AiModelState.error(
        message: e.message,
        technicalDetails: e.technicalDetails,
      );
    } catch (e) {
      state = AiModelState.error(
        message: 'Unexpected error initializing AI model: $e',
        technicalDetails: e.toString(),
      );
    } finally {
      _isInitializing = false;
    }
  }

  /// Retries initialization after a failure.
  Future<void> retry() async {
    await initialize();
  }
}

/// Main Riverpod provider exposing [AiModelState] throughout the application.
final aiModelStateNotifierProvider =
    StateNotifierProvider<AiModelNotifier, AiModelState>((ref) {
  final service = ref.watch(aiModelServiceProvider);
  return AiModelNotifier(service);
});
