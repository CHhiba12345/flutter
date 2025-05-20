abstract class ChatbotState {}

class ChatbotInitial extends ChatbotState {}

class ChatbotLoading extends ChatbotState {}

class ChatbotLoaded extends ChatbotState {
  final String question;
  final String message;

  ChatbotLoaded({required this.question, required this.message});
}

class ChatbotError extends ChatbotState {
  final String message;

  ChatbotError({required this.message});
}