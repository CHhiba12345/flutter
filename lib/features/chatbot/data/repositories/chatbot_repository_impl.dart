import '../../domain/entities/chat_response.dart';
import '../../domain/repositories/chatbot_repository.dart';
import '../datasources/chatbot_remote_datasource.dart';
import '../models/chat_response_model.dart';

class ChatbotRepositoryImpl implements ChatbotRepository {
  final ChatBotRemoteDataSource remoteDataSource;

  ChatbotRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<ChatResponse> sendQuestion(String question, String userId) async {
    try {
      print('🟠 Envoi question au chatbot');

      // Appel direct sans session
      final result = await remoteDataSource.getChatbotResponse(
        question: question,
      );

      final model = ChatResponseModel.fromJson(result);

      // Debug du message reçu
      print('🟣 Réponse reçue: ${model.message}');

      return ChatResponse(
        message: model.message,
        hasError: model.hasError,
      );
    } catch (e) {
      print('🔴 Erreur dans sendQuestion: $e');
      return ChatResponse(
        message: 'Error: $e',
        hasError: true,
      );
    }
  }

}