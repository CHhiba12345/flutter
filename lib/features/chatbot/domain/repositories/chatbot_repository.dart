import '../entities/chat_response.dart';

abstract class ChatbotRepository {
  Future<ChatResponse> sendQuestion(String question, String userId);
}