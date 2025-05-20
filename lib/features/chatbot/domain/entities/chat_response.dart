class ChatResponse {
  final String message;
  final bool hasError;

  ChatResponse({
    required this.message,
    required this.hasError,
  });

  // Optionnel : Pour faciliter le debug
  @override
  String toString() {
    return 'ChatResponse(message: $message, hasError: $hasError)';
  }
}