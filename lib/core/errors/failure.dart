// lib/core/errors/failure.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Failure Value Objects (for Result pattern)
// ─────────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

/// Base failure class — used as left side of Either<Failure, T>
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => '${runtimeType}[$code]: $message';
}

/// Firebase / Firestore failure
class FirebaseFailure extends Failure {
  const FirebaseFailure({required super.message, super.code});
}

/// Network failure
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection.',
    super.code = 'network_error',
  });
}

/// Validation failure (form fields)
class ValidationFailure extends Failure {
  final String field;
  const ValidationFailure({required this.field, required super.message})
      : super(code: 'validation_error');

  @override
  List<Object?> get props => [message, code, field];
}

/// Not found failure
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'Item not found.',
    super.code = 'not_found',
  });
}

/// Permission failure
class PermissionFailure extends Failure {
  const PermissionFailure({
    super.message = 'Permission denied.',
    super.code = 'permission_denied',
  });
}

/// Stock operation failure
class StockFailure extends Failure {
  const StockFailure({required super.message, super.code = 'stock_error'});
}

/// Unknown / unexpected failure
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unexpected error occurred.',
    super.code = 'unknown',
  });
}
