import 'dart:convert';
import 'package:http/http.dart' as http;

/// Source distante pour interagir avec le chatbot via une API HTTP
abstract class ChatBotRemoteDataSource {
  Future<Map<String, dynamic>> getChatbotResponse({
    required String question,
  });
}

class ChatBotRemoteDataSourceImpl implements ChatBotRemoteDataSource {
  final http.Client client;
  final String baseUrl = 'http://164.132.53.159:8000';

  ChatBotRemoteDataSourceImpl({required this.client});

  /// Envoie une question au chatbot et retourne la réponse de l'API
  @override
  Future<Map<String, dynamic>> getChatbotResponse({
    required String question,
  }) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/chatbot'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json; charset=utf-8',
        },
        body: jsonEncode({'question': question}),
        encoding: utf8,
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
        return jsonResponse;
      } else {
        throw Exception('Échec de la requête - Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }
}