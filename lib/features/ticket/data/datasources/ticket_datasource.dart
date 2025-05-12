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
      print('🔎 Fetching comparisons for: $productName');
      print('🔎 Headers: $headers');

      final response = await http.get(
        Uri.parse('$baseUrl/products/${Uri.encodeComponent(productName)}/prices'),
        headers: headers,
      );

      print('✅ [TicketDataSource] Comparison status: ${response.statusCode}');
      debugPrint('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Format Swagger (liste simple)
        if (data is List) {
          print('🔄 Processing Swagger format response');
          return data.map((item) {
            return {
              'store': item['storeName'] ?? 'Magasin inconnu',
              'price': item['unitPrice']?.toDouble(),
              'date': item['receiptDate'] ?? 'Date inconnue',
              'isCurrent': item['storeName'] == 'MG PROXI SIDI HASSINE',
            };
          }).where((item) => item['price'] != null).toList();
        }

        // Format normal (comparedProducts)
        if (data is Map && data.containsKey('comparedProducts')) {
          print('🔄 Processing comparedProducts format');
          final List<Map<String, dynamic>> results = [];
          for (final product in data['comparedProducts']) {
            // Ajouter le meilleur prix
            if (product['bestStore'] != null) {
              results.add({
                'store': product['bestStore'],
                'price': product['bestPrice']?.toDouble(),
                'date': product['otherOptions']?[0]?['lastUpdated'],
                'isBest': true,
                'isCurrent': false,
              });
            }

            // Ajouter les autres options
            if (product['otherOptions'] is List) {
              for (final option in product['otherOptions']) {
                results.add({
                  'store': option['store'],
                  'price': option['price']?.toDouble(),
                  'date': option['lastUpdated'],
                  'isBest': false,
                  'isCurrent': option['store'] == 'MG PROXI SIDI HASSINE',
                });
              }
            }
          }
          return results;
        }

        print('⚠️ Unknown response format');
        return [];
      } else {
        print('❌ Server error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ [TicketDataSource] Error getting comparisons: $e');
      return [];
    }
  }
}