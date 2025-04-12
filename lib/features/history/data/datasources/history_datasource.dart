import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/history_model.dart';

class HistoryDataSource {
  final String jwtToken;
  final String baseUrl;

  HistoryDataSource({
    required this.jwtToken,
    this.baseUrl = 'https://ef1d-197-23-137-142.ngrok-free.app',
  });

  Future<List<HistoryModel>> getUserHistory(String uid) async {
    try {
      final url = Uri.parse('$baseUrl/products/history').replace(
        queryParameters: {'uid': uid, 'include_details': 'true'},
      );
      final response = await http.get(
        url,
        headers: _buildHeaders(),
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => HistoryModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load history: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on FormatException {
      throw Exception('Invalid JSON format');
    }
  }
  Future<void> recordAction({
    required String uid,
    required String productId,
    required String actionType,
  }) async {
    final endpoint = actionType == 'scan' ? 'scan' : 'view';
    final url = Uri.parse('$baseUrl/products/$endpoint');

    final response = await http.post(
      url,
      headers: _buildHeaders(),
      body: jsonEncode({
        'uid': uid,
        'product_id': productId,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to record $actionType: ${response.statusCode}');
    }
  }

  Future<void> deleteHistory(String historyId) async {
    final url = Uri.parse('$baseUrl/products/history/$historyId');
    final response = await http.delete(
      url,
      headers: _buildHeaders(),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete history entry: ${response.statusCode}');
    }
  }

  Map<String, String> _buildHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $jwtToken',
    };
  }
}