import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiManager {
  final String apiKey;

  GeminiManager({required this.apiKey});

  Future<String> sendPromptWithImage(
      String prompt,
      Uint8List imageBytes, {
        String mimeType = "image/jpeg",
      }) async {
    final model = GenerativeModel(model: "gemini-1.5-flash", apiKey: apiKey);

    final content = Content("user", [
      TextPart(prompt),
      DataPart(mimeType, imageBytes),
    ]);

    final response = await model.generateContent([content]);
    return response.text ?? '{"error": "No response"}';
  }
}