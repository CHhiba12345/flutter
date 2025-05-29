// lib/core/errors/auth_exception.dart
class AuthException implements Exception {
  final String message;
  final String? code;
  final StackTrace? stackTrace;

  AuthException({
    required this.message,
    this.code,
    this.stackTrace,
  });

  @override
  String toString() {
    return 'AuthException: $message${code != null ? ', Code: $code' : ''}';
  }
}
