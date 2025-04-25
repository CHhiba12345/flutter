import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../auth/data/datasources/auth_service.dart';
import '../models/favorite_model.dart';

class FavoriteDataSource {
  static const String baseUrl = "http://164.132.53.159:3002";
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getCurrentUserToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<void> toggleFavorite({
    required String uid,
    required String productId,
  }) async {
    final url = Uri.parse('$baseUrl/favorites/toggle');
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
      throw Exception('Failed to toggle favorite: ${response.statusCode}');
    }
  }

  Future<List<FavoriteModel>> getFavorites(String uid) async {
    final url = Uri.parse('$baseUrl/favorites').replace(
        queryParameters: {'uid': uid}
    );
    final headers = await _getHeaders();

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((e) => FavoriteModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load favorites: ${response.statusCode}');
    }
  }
}