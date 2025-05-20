import 'dart:convert';
import 'package:http/http.dart' as http;

abstract class ChatBotRemoteDataSource {
  Future<Map<String, dynamic>> getChatbotResponse({
    required String question,
  });
}

class ChatBotRemoteDataSourceImpl implements ChatBotRemoteDataSource {
  final http.Client client;
  final String baseUrl = 'http://192.168.100.168:8000';

  ChatBotRemoteDataSourceImpl({required this.client});

  @override
  Future<Map<String, dynamic>> getChatbotResponse({
    required String question,
  }) async {
    try {
      // Appel direct à /chatbot sans session
      final response = await client.post(
        Uri.parse('$baseUrl/chatbot'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json; charset=utf-8',
        },
        body: jsonEncode({
          'question': question,
        }),
        encoding: utf8,
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
        return jsonResponse;
      } else {
        throw Exception('Failed to load chatbot response: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}