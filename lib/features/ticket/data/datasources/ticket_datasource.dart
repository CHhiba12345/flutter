import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/ticket.dart';
import '../../../auth/data/datasources/auth_service.dart';
import '../models/tiket_model.dart';

class TicketDataSource {
  static const String baseUrl = 'http://164.132.53.159:3000';
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
        Uri.parse('$baseUrl/products/$productName/prices'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((receipt) {
          final product = receipt['products'].firstWhere(
                (p) => p['productName'] == productName,
            orElse: () => null,
          );
          return {
            'store': receipt['storeName'],
            'price': product?['unitPrice'],
            'date': receipt['receiptDate'],
          };
        }).toList();
      }
      throw Exception('Failed to load price comparisons');
    } catch (e) {
      print('❌ [TicketDataSource] Error getting comparisons: $e');
      throw e;
    }
  }


}