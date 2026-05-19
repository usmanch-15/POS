// lib/core/errors/app_exception.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Custom Exception Hierarchy
// ─────────────────────────────────────────────────────────────

/// Base exception for all StockPro app errors
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'AppException[$code]: $message';
}

/// Firebase / Firestore errors
class FirebaseAppException extends AppException {
  const FirebaseAppException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Network / connectivity errors
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'No internet connection. Please check your network.',
    super.code = 'network_error',
    super.originalError,
  });
}

/// Validation errors (form input)
class ValidationException extends AppException {
  final String field;

  const ValidationException({
    required this.field,
    required super.message,
  }) : super(code: 'validation_error');
}

/// Not found errors
class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'The requested item was not found.',
    super.code = 'not_found',
    super.originalError,
  });
}

/// Permission / auth errors
class PermissionException extends AppException {
  const PermissionException({
    super.message = 'You do not have permission to perform this action.',
    super.code = 'permission_denied',
    super.originalError,
  });
}

/// Stock-specific errors (e.g., insufficient stock)
class StockException extends AppException {
  const StockException({
    required super.message,
    super.code = 'stock_error',
    super.originalError,
  });
}
