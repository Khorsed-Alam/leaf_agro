class AppException implements Exception {
  final String message;
  final String? code;
  const AppException(this.message, {this.code});

  @override
  String toString() => message;
}

class AppAuthException extends AppException {
  const AppAuthException(super.message, {super.code});
}

class DatabaseException extends AppException {
  const DatabaseException(super.message, {super.code});
}

class ModelException extends AppException {
  const ModelException(super.message, {super.code});
}

