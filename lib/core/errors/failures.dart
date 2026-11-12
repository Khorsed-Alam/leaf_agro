abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'A server error occurred. Please try again.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local cache error occurred.']);
}

class ModelInferenceFailure extends Failure {
  const ModelInferenceFailure([super.message = 'AI model diagnosis failed to process image.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection available. Switched to offline mode.']);
}

