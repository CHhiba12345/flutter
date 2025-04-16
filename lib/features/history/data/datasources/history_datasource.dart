import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/history_model.dart';

class HistoryDataSource {
  final String jwtToken;
  final String baseUrl;

  HistoryDataSource({
    required this.jwtToken,
    this.baseUrl = 'https://65a5-197-18-42-245.ngrok-free.app',
  });

  Future<List<HistoryModel>> getUserHistory(String uid) async {
    print('[HistoryDataSource] Starting getUserHistory for UID: $uid');

    try {
      final url = Uri.parse('$baseUrl/products/history').replace(
        queryParameters: {
          'uid': uid,
          'include_details': 'true',
          'populate_product': 'true'
        },
      );

      print('[HistoryDataSource] Request URL: ${url.toString()}');
      print('[HistoryDataSource] Headers: ${_buildHeaders()}');

      final response = await http.get(
        url,
        headers: _buildHeaders(),
      );

      print('[HistoryDataSource] Response Status: ${response.statusCode}');
      print('[HistoryDataSource] Response Body: ${response.body}');
      print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ${response.body}");
      print("**************************************************************************************************");

      if (response.statusCode == 200) {
        try {
          final List<dynamic> jsonList = jsonDecode(response.body);
          print('[HistoryDataSource] Received ${jsonList.length} history items');

          final histories = jsonList.map((json) {
            print('[HistoryDataSource] Parsing item: $json');
            return HistoryModel.fromJson(json);
          }).toList();

          return histories;
        } catch (e) {
          print('[HistoryDataSource] JSON Parsing Error: $e');
          throw Exception('Invalid JSON format');
        }
      } else {
        throw Exception('Failed to load history: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      print('[HistoryDataSource] Network Error: $e');
      throw Exception('No internet connection');
    } catch (e) {
      print('[HistoryDataSource] Unexpected Error: $e');
      throw Exception('Unknown error occurred');
    }
  }

  Future<void> recordAction({
    required String uid,
    required String productId,
    required String actionType,
  }) async {
    print('[HistoryDataSource] Recording $actionType for UID: $uid, Product: $productId');

    final endpoint = actionType == 'scan' ? 'scan' : 'view';
    final url = Uri.parse('$baseUrl/products/$endpoint');

    print('[HistoryDataSource] POST to: ${url.toString()}');
    print('[HistoryDataSource] Request Body: ${jsonEncode({'uid': uid, 'product_id': productId})}');

    final response = await http.post(
      url,
      headers: _buildHeaders(),
      body: jsonEncode({
        'uid': uid,
        'product_id': productId,
      }),
    );

    print('[HistoryDataSource] RecordAction Response: ${response.statusCode}');
    print('[HistoryDataSource] Response Body: ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to record $actionType: ${response.statusCode}');
    }
  }

  Future<void> deleteHistory(String historyId) async {
    print('[HistoryDataSource] Deleting history ID: $historyId');

    final url = Uri.parse('$baseUrl/products/history/$historyId');
    print('[HistoryDataSource] DELETE to: ${url.toString()}');

    final response = await http.delete(
      url,
      headers: _buildHeaders(),
    );

    print('[HistoryDataSource] Delete Response: ${response.statusCode}');
    print('[HistoryDataSource] Response Body: ${response.body}');

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