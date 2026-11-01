/// Base type for errors that are expected during normal operation and are
/// safe to show to the user.
sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}

class TransportException extends AppException {
  const TransportException(super.message);
}

class LocationUnavailableException extends AppException {
  const LocationUnavailableException(super.message);
}

class SyncException extends AppException {
  const SyncException(super.message);
}
