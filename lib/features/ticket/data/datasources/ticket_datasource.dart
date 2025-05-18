import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/ticket.dart';
import '../../../auth/data/datasources/auth_service.dart';
import '../models/tiket_model.dart';

class TicketDataSource {
  static const String baseUrl = 'http://164.132.53.159:3000';
  //static const String baseUrl = 'https://3e01-41-225-2-138.ngrok-free.app';
  final AuthService _authService;

  TicketDataSource(this._authService);

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getCurrentUserToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<void> sendTicketData(Ticket ticket) async {
    try {
      final headers = await _getHeaders();
      final userId = await _authService.getCurrentUserId();

      print('🔵 [TicketDataSource] User ID: $userId');
      debugPrint('🔄 Preparing to send ticket for user: $userId');

      final ticketWithUser = TicketModel(
        storeName: ticket.storeName,
        receiptDate: ticket.receiptDate,
        products: ticket.products,
        totalAmount: ticket.totalAmount,
        userId: userId,
      );

      print('📦 Ticket data with user: ${ticketWithUser.toJson()}');

      final response = await http.post(
        Uri.parse('$baseUrl/receipts'),
        headers: headers,
        body: jsonEncode(ticketWithUser.toJson()),
      );

      print('✅ [TicketDataSource] Response status: ${response.statusCode}');
      debugPrint('📡 Response body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to send ticket data: ${response.body}');
      }
    } catch (e) {
      print('❌ [TicketDataSource] Error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getProductPriceComparisons(String productName) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/products/${Uri.encodeComponent(productName)}/prices'),
        headers: headers,
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = <Map<String, dynamic>>[];

        // Format 1: Liste simple (GET /products/{productName}/prices)
        if (data is List) {
          for (var item in data) {
            if (item['price'] != null) {
              results.add({
                'store': item['storeName'] ?? 'Magasin inconnu',
                'price': (item['price'] as num).toDouble(),
                'date': _formatDate(item['date'] ?? item['receiptDate']),
                'isBest': false,
                'isCurrent': item['storeName'] == 'MG PROXI SIDI HASSINE',
              });
            }
          }
          return results;
        }

        // Format 2: Objet avec comparedProducts (POST /receipts)
        if (data is Map && data.containsKey('comparedProducts')) {
          for (var product in data['comparedProducts']) {
            if (product['product'] == productName) {
              // Ajouter le meilleur prix
              if (product['bestStore'] != null && product['bestPrice'] != null) {
                results.add({
                  'store': product['bestStore'],
                  'price': (product['bestPrice'] as num).toDouble(),
                  'date': 'Meilleur prix',
                  'isBest': true,
                  'isCurrent': product['bestStore'] == 'MG PROXI SIDI HASSINE',
                });
              }

              // Ajouter les autres options
              for (var option in product['otherOptions'] ?? []) {
                if (option['price'] != null) {
                  results.add({
                    'store': option['store'],
                    'price': (option['price'] as num).toDouble(),
                    'date': _formatDate(option['lastUpdated']),
                    'isBest': false,
                    'isCurrent': option['store'] == 'MG PROXI SIDI HASSINE',
                  });
                }
              }
            }
          }
          return results;
        }
      }

      throw Exception('Format de réponse inattendu ou erreur serveur');
    } catch (e) {
      print('❌ Error getting comparisons: $e');
      return [];
    }
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return "${date.day}/${date.month}/${date.year}";
    } catch (_) {
      return 'Date invalide';
    }
  }
}