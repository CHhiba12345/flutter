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
          final results = <Map<String, dynamic>>[];

          for (var item in data) {
            final store = item['storeName'] ?? 'Magasin inconnu';
            final price = item['unitPrice']?.toDouble();

            if (price == null) continue;

            results.add({
              'store': store,
              'price': price,
              'date': _formatDate(item['receiptDate']),
              'isBest': false,
              'isCurrent': store == 'MG PROXI SIDI HASSINE',
            });
          }

          // Supprime les doublons
          final seenStores = <String>{};
          final filtered = results.where((item) => seenStores.add(item['store'])).toList();

          // Trie par prix croissant
          filtered.sort((a, b) => (a['price'] as double).compareTo(b['price'] as double));

          return filtered;
        }

        // Format objet avec comparedProducts
        if (data is Map && data.containsKey('comparedProducts')) {
          final comparedProducts = data['comparedProducts'] as List;
          final results = <Map<String, dynamic>>[];

          for (var product in comparedProducts) {
            final bestStore = product['bestStore'];
            final bestPrice = product['bestPrice']?.toDouble();

            if (bestStore != null && bestPrice != null) {
              results.add({
                'store': bestStore,
                'price': bestPrice,
                'date': 'Meilleur prix',
                'isBest': true,
                'isCurrent': bestStore == 'MG PROXI SIDI HASSINE',
              });
            }

            final options = product['otherOptions'] as List?;
            if (options != null) {
              for (var option in options) {
                final store = option['store'];
                final price = option['price']?.toDouble();
                final date = option['lastUpdated'];

                if (price == null) continue;

                results.add({
                  'store': store,
                  'price': price,
                  'date': date != null ? _formatDate(date) : 'Date inconnue',
                  'isBest': false,
                  'isCurrent': store == 'MG PROXI SIDI HASSINE',
                });
              }
            }
          }

          // Supprime les doublons + Tri
          final seenStores = <String>{};
          final filtered = results.where((item) => seenStores.add(item['store'])).toList();
          filtered.sort((a, b) => (a['price'] as double).compareTo(b['price'] as double));

          return filtered;
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

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return "${date.day}/${date.month}/${date.year}";
    } catch (_) {
      return 'Date invalide';
    }
  }
}