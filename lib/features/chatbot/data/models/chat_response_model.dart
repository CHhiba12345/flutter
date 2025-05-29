class ChatResponseModel {
  /// Message de réponse du chatbot
  final String message;

  /// Indique si la réponse contient une erreur
  final bool hasError;

  ChatResponseModel({
    required this.message,
    required this.hasError,
  });

  /// Crée un modèle à partir d'une réponse JSON
  factory ChatResponseModel.fromJson(Map<String, dynamic> json) {
    return ChatResponseModel(
      message: json['response'] ?? 'Aucune réponse',
      hasError: json.containsKey('error'),
    );
  }

  @override
  String toString() {
    return 'ChatResponseModel(message: $message, hasError: $hasError)';
  }
}