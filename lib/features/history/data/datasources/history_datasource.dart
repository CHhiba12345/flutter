import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../../../auth/data/datasources/auth_service.dart';
import '../models/history_model.dart';

/// Source de données distante pour l'historique des actions utilisateur
class HistoryDataSource {
  static const String baseUrl = 'http://164.132.53.159:3002';
  final AuthService _authService = AuthService();

  /// Retourne les en-têtes avec le token d'autorisation
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getCurrentUserToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Récupère l'historique complet d'un utilisateur via son UID
  Future<List<HistoryModel>> getUserHistory(String uid) async {
    try {
      final url = Uri.parse('$baseUrl/products/history').replace(
        queryParameters: {
          'uid': uid,
          'include_details': 'true',
          'populate_product': 'true',
        },
      );
      final headers = await _getHeaders();

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final decodedJson = jsonDecode(utf8.decode(response.bodyBytes));
        if (decodedJson is List) {
          return decodedJson.map((json) => HistoryModel.fromJson(json)).toList();
        } else {
          throw Exception('Unexpected JSON structure: expected a list');
        }
      } else {
        throw Exception('Failed to load history: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } catch (e) {
      throw Exception('Unknown error occurred: $e');
    }
  }

  /// Enregistre une action dans l'historique (scan ou view)
  Future<void> recordAction({
    required String uid,
    required String productId,
    required String actionType,
  }) async {
    final endpoint = actionType == 'scan' ? 'scan' : 'view';
    final url = Uri.parse('$baseUrl/products/$endpoint');
    final headers = await _getHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        'uid': uid,
        'product_id': productId,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to record $actionType: ${response.statusCode}');
    }
  }

  /// Supprime une entrée d'historique par ID
  Future<void> deleteHistory(String historyId) async {
    final url = Uri.parse('$baseUrl/products/history/$historyId');
    final headers = await _getHeaders();

    final response = await http.delete(url, headers: headers);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete history entry: ${response.statusCode}');
    }
  }
}