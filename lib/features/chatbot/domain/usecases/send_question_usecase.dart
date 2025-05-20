import '../entities/chat_response.dart';
import '../repositories/chatbot_repository.dart';

class SendQuestionUsecase {
  final ChatbotRepository repository;

  SendQuestionUsecase(this.repository);

  Future<ChatResponse> execute(String question, String userId) async {
    return await repository.sendQuestion(question, userId);
  }
}