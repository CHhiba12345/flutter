import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/ticket.dart';
import 'gemini_manager.dart';

class ReceiptScannerService {
  final GeminiManager _gemini = GeminiManager(apiKey: "AIzaSyBEqy_ZxFvkft9dVfrqT4exU-FFzM3w-ts");


  Future<String?> scanReceiptImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    return pickedFile?.path;
  }

  Future<Map<String, dynamic>> scanAndAnalyzeReceipt() async {
    final imagePath = await scanReceiptImage();
    if (imagePath == null) throw Exception("Aucune image sélectionnée");

    const prompt = '''
Analyse ce ticket de caisse et fournis :
1. Les données brutes du ticket au format JSON conforme à l'API LoopBack
2. Une analyse nutritionnelle détaillée

Format REQUIS (respecte strictement ce format) :
{
  "receipt_data": {
    "storeName": "string (obligatoire, min 2 caractères)",
    "receiptDate": "date-time (format ISO 8601 ex: '2025-05-06T14:30:00Z')",
    "products": [
      {
        "productName": "string (min 2 caractères)",
        "quantity": "number >= 0",
        "unitPrice": "number >= 0",
        "totalPrice": "number >= 0"
      }
    ],
    "totalAmount": "number"
  },
  "nutrition_analysis": {
    "products": [
      {
        "product_name": "string",
        "processing_level": "naturel/transformé/ultra-transformé",
        "health_risks": ["string"],
        "advice": "string",
        "consumption_recommendation": "string"
      }
    ],
    "global_advice": "string"
  }
}

ATTENTION : 
- Ne renvoie que du JSON valide entre ```json``>
- Assure-toi que receiptDate est au format ISO 8601 (ex: '2025-05-06T14:30:00Z')
- Si une valeur est inconnue, mets 'Unknown store', 'Unknown product', mais ne laisse pas vide
''';

    try {
      final mimeType = lookupMimeType(imagePath);
      final response = await _gemini.sendPromptWithImage(
        prompt,
        File(imagePath).readAsBytesSync(),
        mimeType: mimeType ?? "image/jpeg",
      );

      final completeJson = _ensureCompleteJson(response);
      return jsonDecode(completeJson);
    } catch (e) {
      debugPrint('Error scanning receipt: $e');
      rethrow;
    }
  }

  String _ensureCompleteJson(String jsonResponse) {
    String cleanJson = jsonResponse.replaceAll('```json', '').replaceAll('```', '').trim();

    if (!_isValidJson(cleanJson)) {
      if (!cleanJson.endsWith('}')) {
        final lastBrace = cleanJson.lastIndexOf('}');
        if (lastBrace > 0) cleanJson = cleanJson.substring(0, lastBrace + 1);
      }

      int openBraces = cleanJson.split('{').length - 1;
      int closeBraces = cleanJson.split('}').length - 1;
      while (openBraces > closeBraces) {
        cleanJson += '}';
        closeBraces++;
      }
    }

    if (!_isValidJson(cleanJson)) {
      throw FormatException('Invalid JSON format');
    }
    return cleanJson;
  }

  bool _isValidJson(String jsonString) {
    try {
      jsonDecode(jsonString);
      return jsonString.trim().startsWith('{') && jsonString.trim().endsWith('}');
    } catch (e) {
      return false;
    }
  }


  Future<File> _saveImageToCache(Uint8List imageBytes) async {
    final directory = await getTemporaryDirectory();
    final imagePath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final file = File(imagePath);
    await file.writeAsBytes(imageBytes);
    return file;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}