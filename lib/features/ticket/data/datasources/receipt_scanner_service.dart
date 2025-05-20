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
Analyze this receipt and provide:
1. Raw receipt data in LoopBack API-compatible JSON format
2. Detailed nutritional analysis with specific health recommendations

REQUIRED FORMAT (strictly follow this format):
{
  "receipt_data": {
    "storeName": "string (required, min 2 characters)",
    "receiptDate": "date-time (ISO 8601 format ex: '2025-05-06T14:30:00Z')",
    "products": [
      {
        "productName": "string (min 2 characters)",
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
        "processing_level": "natural/minimally-processed/processed/ultra-processed",
        "nutritional_quality": "excellent/good/moderate/poor",
        "health_risks": {
          "sugar": "none/low/medium/high",
          "salt": "none/low/medium/high",
          "fats": {
            "saturated": "none/low/medium/high",
            "trans": "none/low/medium/high"
          },
          "additives": "none/some/many",
          "allergens": ["list any present allergens"]
        },
        "specific_concerns": ["string"],
        "health_benefits": ["string"],
        "advice": "string (50-100 characters)",
        "consumption_recommendation": "daily/3-4x weekly/1-2x weekly/monthly/avoid"
      }
    ],
    "global_advice": {
      "positive_aspects": ["string"],
      "main_concerns": ["string"],
      "improvement_suggestions": ["string"],
      "overall_rating": "excellent/good/fair/poor"
    }
  }
}

IMPORTANT NOTES:
- Return only valid JSON between ```json```
- Ensure receiptDate is in ISO 8601 format (ex: '2025-05-06T14:30:00Z')
- If a value is unknown, use 'Unknown store', 'Unknown product' - never leave empty
- EXCLUDE any product named "timbre" (stamp) from both receipt_data and nutrition_analysis
- All output must be in English only

NUTRITION GUIDELINES:
1. Processing Levels:
   - natural: Unprocessed whole foods (fruits, vegetables, raw meat)
   - minimally-processed: Washed, cut, frozen without additives
   - processed: Foods with added salt, sugar, or oil (bread, cheese)
   - ultra-processed: Industrial formulations with additives (soda, chips)

2. Health Risks Specification:
   - Sugar: >22.5g/100g=high, 5-22.5g=medium, <5g=low
   - Salt: >1.5g/100g=high, 0.3-1.5g=medium, <0.3g=low
   - Saturated fat: >5g/100g=high, 1.5-5g=medium, <1.5g=low
   - Trans fat: Any amount=high risk

3. Consumption Recommendations:
   - daily: Whole grains, vegetables, fruits
   - 3-4x weekly: Fish, lean meats, eggs
   - 1-2x weekly: Processed meats, cheese
   - monthly: Fried foods, pastries
   - avoid: Products with trans fats, artificial sweeteners

4. Advice Examples:
   - "Contains high fructose corn syrup - may contribute to metabolic issues"
   - "Rich in omega-3 - beneficial for heart health"
   - "High sodium content - may elevate blood pressure"
   - "Good source of fiber - supports digestive health"

5. Global Advice Should Include:
   - Balance assessment (protein/carbs/fats ratio)
   - Processed food percentage
   - Key nutrients missing
   - Suggested healthier alternatives
''' ;

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