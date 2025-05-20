class ChatResponseModel {
  final String message;
  final bool hasError;

  ChatResponseModel({
    required this.message,
    required this.hasError,
  });

  factory ChatResponseModel.fromJson(Map<String, dynamic> json) {
    return ChatResponseModel(
      message: json['response'] ?? 'Aucune réponse',
      hasError: json.containsKey('error'),
    );
  }

  // Optionnel : Pour faciliter les tests ou le debug
  @override
  String toString() {
    return 'ChatResponseModel(message: $message, hasError: $hasError)';
  }
}